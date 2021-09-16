namespace P5M2_SolveFixedCryptarithm_OracleTests {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    

    // Helper operation that asserts that the oracle indeed implements the given function.
    operation AssertOracleImplementsFunction(
        N : Int, 
        classical : (Int -> Bool),
        mOracle : ((Qubit[], Qubit) => Unit is Adj)
    ) : Unit {
        // Allocate qubits to use.
        use (inp, outp) = (Qubit[N], Qubit());

        // Iterate over all possible input bit strings (as integers).
        for x in 0 .. 2^N - 1 {
            // Convert the integer into a bit string (little-endian encoding).
            let bitsAsBool = IntAsBoolArray(x, N);
            within {
                // Prepare the input state.
                ApplyPauliFromBitString(PauliX, true, bitsAsBool, inp);
            } apply {
                // Apply the oracle to calculate the output for this input.
                mOracle(inp, outp);
            }

            // Check that the result matches the expected (calculated using the given function).
            let cResult = classical(x);
            let qResult = MResetZ(outp) == One;
            Fact(cResult ==qResult,
                $"Test failed for input {bitsAsBool}: expected function value {cResult}, actual oracle evaluation result {qResult}");

            // Check that the inputs were not modified
            Fact(MeasureInteger(LittleEndian(inp)) == 0, 
                $"Test failed for input {bitsAsBool}: the input states were modified");
        }
    }


    // -----------------------------------------------------------------------------------------
    // Test the oracle which checks that all digits are different.

    // A function that checks whether all digits of x are different classically.
    function F_AreAllDigitsDistinct(digit : Int[]) : Bool {
        // Iterate over all pairs of digits.
        let l1 = 1 .. Length(digit) - 1;
        for i in  l1{
            let l2 = i - 1;
            for j in 0 .. l2 {
                // Compare the digits; if they are the same, return false.
                if digit[i] == digit[j] {
                    return false;
                }
            }
        }
        // If none of the pairs were the same, return true.
        return true;
    }


    // A wrapper for the function which converts an integer parameter to an array of digits
    // and applies the given function to this array.
    function ApplyFunctionToArray(
        funcnToApply : (Int[]) -> Bool,
        inpt : Int,
        nDigits : Int,
        digitSize : Int
    ) : Bool {
        // Convert the integer x into binary.
        let digitAsBinary = IntAsBoolArray(inpt, nDigits * digitSize);
        // Split it into nDigits digitSize-sized chunks and convert them back to integer.
        let digits = Mapped(BoolArrayAsInt, Chunks(digitSize, digitAsBinary));

        // Return the value of the function applied to the digits.
        return funcnToApply(digits);
    }


    // A wrapper for the oracle which converts a qubit array parameter to an array of qubit arrays parameter
    // and applies the given oracle to this 2D array.
    operation ApplyOracleToArray2D(
        oracle : (Qubit[][], Qubit) => Unit is Adj,
        register : Qubit[],
        target : Qubit,
        digitSize : Int
    ) : Unit is Adj {
        // Split the given register into nDigits chunks that store digits.
        let digitRegisters = Chunks(digitSize, register);

        // Apply the oracle to the new parameter.
        oracle(digitRegisters, target);
    }

    // Operations marked with @Test attribute will be executed as Q# unit tests.
    @Test("QuantumSimulator")
    operation AreAllDigitsDifferentTests() : Unit {
        // Define the size of each digit, in bits.
        let digitSize = 2;

        // Run the test with different numbers of digits.
        for nDigits in 2 .. 4 {
            Message($"Testing Are All Digits Different for {nDigits} digits...");
            // Instantiate the classical function using current parameters.
            let fnToApply = ApplyFunctionToArray(F_AreAllDigitsDistinct, _, nDigits, digitSize);
            // Instantiate the oracle using the wrapper.
            let oracle = ApplyOracleToArray2D(AreAllDigitsDistinct, _, _, digitSize);
            // Call the helper operation with the classical function and the quantum oracle.
            AssertOracleImplementsFunction(nDigits * digitSize, fnToApply, oracle);
            Message("   Test passed!");
        }
    }


    // -----------------------------------------------------------------------------------------
    // Test the oracle which checks that the digits are a solution to the equation.

    // A function that checks whether the digits are a solution to the equation.
    function F_IsArrayEquationSolution(x : Int[], a : Int[]) : Bool {
        // Define a mutable variable for the sum.
        mutable total = 0;
        // Add up aᵢxᵢ for each term.
        for i in 0 .. Length(x) - 1 {
            set total += x[i] * a[i];
        }
        // Check whether the resulting sum equals 0.
        return total == 0;
    }


    // Operations marked with @Test attribute will be executed as Q# unit tests.
    @Test("QuantumSimulator")
    operation IsArrayEquationSolutionTests() : Unit {
        // Define the size of each digit, in bits.
        let digitSizeInBits = 2;
        // Run the test with different equations.
        for (a, maxDigitsInSum) in [([15, 56, -28], 4)]{
            let nDigits = Length(a);
            Message($"Testing for equation {a}...");
            // Instantiate the classical function using current parameters.
            let f = ApplyFunctionToArray(F_IsArrayEquationSolution(_, a), _, nDigits, digitSizeInBits);
            // Instantiate the oracle using the wrapper.
            let oracle = ApplyOracleToArray2D(IsArrayEquationSolution(a, 4, _, _), _, _, digitSizeInBits);
            // Call the helper operation with the classical function and the quantum oracle.
            AssertOracleImplementsFunction(nDigits * digitSizeInBits, f, oracle);
            Message("   Test passed!");
        }
    }
}
