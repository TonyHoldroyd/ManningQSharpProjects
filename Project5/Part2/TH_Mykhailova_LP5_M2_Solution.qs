namespace P5M2_SolveFixedCryptarithm_OracleTests {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;


    /// # Summary
    /// Marking oracle that checks whether integers written in the registers are different.
    operation AreRegistersDifferent(register1 : Qubit[], register2 : Qubit[], target : Qubit) : Unit is Adj {
        // Use in-place comparison to save qubits.
        within {
            // Compute pairwise XORs the elements of the registers, storing the results in the 1st one.
            for (q1, q2) in Zipped(register1, register2) {
                CNOT(q2, q1);
            }
        } apply {
            // Check that at least one of the XORs is not 0.
            ControlledOnInt(0, X)(register1, target);
            X(target);
        }
    }


    /// # Summary
    /// Marking oracle that checks whether integers x₀...xₖ written in the registers
    /// are pairwise distinct.
    ///
    /// # Input
    /// ## digitRegisters
    /// An array of qubit arrays which store the variables x₀...xₖ.
    /// ## target
    /// Output of the marking oracle.
    operation AreAllDigitsDistinct(digitRegisters : Qubit[][], target : Qubit) : Unit is Adj {
        // The number of digits is the number of digitRegisters. 
        let nDigits = Length(digitRegisters);

        // Allocate a qubit for each pair of digits to store comparison results.
        let nPairs = nDigits * (nDigits - 1) / 2;
        use digitsPairwiseDistinct = Qubit[nPairs];

        // Rearrange the target register into an array of arrays of lengths 1, 2, ..., (N - 1), 
        // so that comparisonResult[i-1][j] stores the result of comparing digit i to digit j.
        let comparisonResults = Partitioned(RangeAsIntArray(1 .. nDigits - 1), digitsPairwiseDistinct);

        within {
            // For each pair of digits, compare them and store 1 to the corresponding qubit if they are distinct.
            for i in 1 .. nDigits - 1 {
                for j in 0 .. i - 1 {
                    AreRegistersDifferent(digitRegisters[i], digitRegisters[j], comparisonResults[i - 1][j]);
                }
            }
        } apply {
            // If all digits are distinct, store 1 to the target qubit.
            Controlled X(digitsPairwiseDistinct, target);
        }
    }


    /// # Summary
    /// Marking oracle that checks whether integers x₀...xₖ written in the registers
    /// is a solution to the equation a₀x₀ + ... + aₖxₖ = 0 (non-modular).
    ///
    /// # Input
    /// ## a
    /// Coefficients of the equation (can be negative).
    /// ## maxDigitsInSum
    /// The number of digits in the sum of the cryptarithm.
    /// ## digitRegisters
    /// An array of qubit arrays which store the variables x₀...xₖ.
    /// ## target
    /// Output of the marking oracle.
    operation IsArrayEquationSolution(a : Int[], maxDigitsInSum : Int, digitRegisters : Qubit[][], target : Qubit) : Unit is Adj {
        // Find the number of variables and the number of qubits per variable.
        let nDigits = Length(a);
        let digitSize = Length(digitRegisters[0]);

        // Allocate an extra register to accumulate the expression for the left-hand size of the equation.
        let modulus = 2 ^ (digitSize * maxDigitsInSum);
        use sum = Qubit[digitSize * maxDigitsInSum];

        within {
            for i in 0 .. nDigits - 1 {
                // Add terms for aᵢxᵢ.
                let coef = a[i] >= 0 ? a[i] | (modulus + a[i]);
                MultiplyAndAddByModularInteger(coef, modulus, LittleEndian(digitRegisters[i]), LittleEndian(sum));
            }
        } apply {
            // Check whether the result is 0.
            ControlledOnInt(0, X)(sum, target);
        }
    }
}

