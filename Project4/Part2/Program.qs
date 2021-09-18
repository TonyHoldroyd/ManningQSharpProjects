namespace ISBNEquationChecker{

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Preparation;

    /// # Summary
    /// 
    /// # Input
    /// ## a
    /// 
    /// ## b
    /// 
    /// ## x
    /// 
    /// # Output
    /// 
    function EquationSolutionClassical(a : Int, b: Int, x : Int) : Bool {
        return (a*x+b)%11 ==0;
    }

    operation EquationSolutionQuantum(a : Int, b : Int, register : Qubit[], target : Qubit) : Unit is Adj {
        // We start with an integer x written in the register.
        within {
            // Multiply it by a (mod 11).
   
            MultiplyByModularInteger(a, 11, LittleEndian(register));
            // Add to it b (mod 11).            
            // Add to it b (mod 10).
            IncrementByModularInteger(b, 11, LittleEndian(register));
        } apply {
            // Check whether the result is 0.
            ControlledOnInt(0, X)(register, target);
        }      
    }

    operation AssertOracleImplementsFunction(
    N : Int, 
    classicalFunction : (Int -> Bool),
    markingOracle : ((Qubit[], Qubit) => Unit is Adj)
) : Unit  {
             // Allocate qubits to use 
        use (inp, outp) = (Qubit[N], Qubit());
        let bitLength = N;
        // Iterate over all possible input bit strings (as integers).
        for x in 0 .. 10 {
            // Convert the integer into a bit string (little-endian encoding).
            let boolBits = IntAsBoolArray (x, bitLength);
            Message($"{boolBits}");
            
            within {
                // Prepare the input state.
                ApplyPauliFromBitString (PauliX, true, boolBits, inp);
            } apply {
                // Apply the oracle to calculate the output for this input.
                markingOracle(inp, outp);
            }

            // Check that the result matches the expected (calculated using the given function).
            if classicalFunction(x) != (MResetZ(outp)==One)
            {
                   Message($"Test Failed for {classicalFunction(x)}");
            }
            //Reset(outp);
            // Check that the inputs were not modified
            if (MeasureInteger(LittleEndian(inp))!= 0){
                   Message($"Test Failedfor {boolBits}");           
            }
        }

}   
    @Test("QuantumSimulator")
    operation SingleDigitMissingTests() : Unit {
        for (a, b) in [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10), (10, 1)] {
            Message($"Testing equation {a}x + {b} = 0 (mod 11)...");
            // Call the helper operation with the classical function and the quantum oracle instantiated for (a, b).
            AssertOracleImplementsFunction(
            4, 
            EquationSolutionClassical(a, b,_),
            EquationSolutionQuantum(a,b,_,_)
            );
            Message("   Test passed!");
        }
    }   
}