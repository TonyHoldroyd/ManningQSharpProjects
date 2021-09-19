namespace P5M2{
// SolveFixedCryptarithm 

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
            for (qubit1, qubit2) in Zipped(register1, register2){
                CNOT(qubit2, qubit1);
            }
        } apply {
            // Check that at least one of the XORs is 1
            let control = ControlledOnInt(0,X);
            control(register1,target);
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
        
        let numDigits = Length(digitRegisters);
        // Allocate a qubit for each pair of digits to store comparison results.
        let numPrs = numDigits*(numDigits-1)/2;
        use digitsDistinctInPrs = Qubit[numPrs];
        

        // Rearrange the target register into an array of arrays of lengths 1, 2, ..., (N - 1), 
        let comparisonResults = Partitioned(RangeAsIntArray(1 .. numDigits - 1), digitsDistinctInPrs);

        // so that comparisonResult[i-1][j] stores the result of comparing digit i to digit j.
        
        let compRslts = Partitioned(RangeAsIntArray(1 .. numDigits - 1), digitsDistinctInPrs);
        within {
            // For each pair of digits, compare them and store 1 to the corresponding qubit if they are distinct.
            for i in 1.. numDigits-1{
                for j in 0 .. i-1   {
                AreRegistersDifferent(digitRegisters[i], digitRegisters[j], compRslts[i - 1][j]);                    
                }

            }
        } apply {
            // If all digits are distinct, store 1 to the target qubit.
            Controlled X(digitsDistinctInPrs, target);  
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
        let numVariables = Length(a);
        let numQbitsPerVariable = Length(digitRegisters[0]);
        // Allocate an extra register to accumulate the expression for the left-hand size of the equation.

        let registerLength =  numQbitsPerVariable * maxDigitsInSum;

        let mod = 2^(registerLength);
      
        use accumulatedValue = Qubit[registerLength];

        within {
            for i in 0 .. numVariables - 1 {
                // Add terms for aᵢxᵢ.
                let coef = (a[i] >= 0 ? a[i] | (mod + a[i])); // term may be <0 !!
                MultiplyAndAddByModularInteger(coef, mod, LittleEndian(digitRegisters[i]), LittleEndian(accumulatedValue));
            }
        } apply {
            // Check whether the result is 0.
            let control =ControlledOnInt(0,X);
            control(accumulatedValue, target);           
        }
    }


    /// # Summary
    /// Marking oracle that checks whether integer x written in the register
    /// is a solution to the cryptarithm that boils down to an equation a₀x₀ + ... + aₖxₖ = 0.
    ///
    /// # Input
    /// ## a
    /// Coefficients of the equation (can be negative).
    /// ## register
    /// Input of the marking oracle.
    /// ## target
    /// Output of the marking oracle.
    operation IsCryptarithmSolution(a : Int[], maxDigitsInSum : Int, register : Qubit[], target : Qubit) : Unit is Adj {
        // Find the number of variables and the number of qubits per variable.
        let numVariables = Length(a);
        let numQubitsPerVariable = Length(register)/numVariables;

        // Split the given register into nDigits chunks that store digits.
        let digitRegisters = Chunks(numQubitsPerVariable,register);

        // Allocate two qubits to store the constraint evaluation results.
        use differentDigits = Qubit();
        use doesThisSolveTheEquation = Qubit();

        // Check that both constraints are satisfied.
        within {
            // Check each constraint individually.
            IsArrayEquationSolution(a, maxDigitsInSum, digitRegisters, doesThisSolveTheEquation);

            AreAllDigitsDistinct(digitRegisters, differentDigits);
        } apply {
            // For the register to be a solution, both constraints must be satisfied.
            CCNOT(differentDigits,doesThisSolveTheEquation, target);
        }
    }


    /// # Summary
    /// Prepare an equal superposition of all states that can encode the digits, each of them between 0 and searchSpaceSize - 1, inclusive.
    operation PrepareSearchSpaceSuperposition(
        nDigits : Int,
        searchSpaceSize : Int,
        register : Qubit[]
    ) : Unit is Adj {
        // In this case all basis states are valid search space elements, so we need simply an equal superposition of all basis states.
        ApplyToEachA(H,register);
    }


    /// # Summary
    /// Runs Grover search for the problem described as a marking oracle.
    ///
    /// # Input
    /// ## markingOracle
    /// An operation that implements the marking oracle for the problem.
    /// ## nDigits
    /// The number of digit variables.
    /// ## searchSpaceSize
    /// The search looks for nDigits digits, each of them between 0 and searchSpaceSize - 1, inclusive.
    /// ## nIterations
    /// The number of iterations to run the search for.
    ///
    /// # Output
    /// An array of measurement results that the algorithm yielded.
    operation RunGroversSearch(
        mOracle : ((Qubit[], Qubit) => Unit is Adj), 
        numDigits : Int,
        searchSpaceSize : Int, 
        numIterations : Int
    ) : Result[] {
        // Count the number of bits we need to store the digit we're looking for.
        let digitSize = BitSizeI(searchSpaceSize - 1);

        // Allocate the qubits to use in the search algorithm.
        let registerLength = numDigits*digitSize;
        use register = Qubit[registerLength];
        use minus  = Qubit();

        // Prepare the minus qubit in the |-⟩ state.
        X(minus); //invert
        H(minus);  // hadamard

        // Prepare the equal superposition of all states in the search space.
        PrepareSearchSpaceSuperposition(numDigits, searchSpaceSize, register);
        
        // Run iterations of Grover's search.
        for it in 1 .. numIterations {
            Message($"Iteration {it}");
            // Apply the marking oracle as a phase oracle
            // using the minus qubit in the |-⟩ state and the phase kickback trick.
            mOracle(register, minus);
            
            // Perform reflection around the mean.
            within {
                // Note that here we're using adjoint of the routine to prepare equal superposition 
                // of all basis states in the search space.
                Adjoint PrepareSearchSpaceSuperposition(numDigits, searchSpaceSize, register);
                 ApplyToEachA(X,register);
            }
            apply {
                // Flip the state of each qubit.            
                // Flip the phase if all qubits are in the |1⟩ state.
                Controlled Z(Most(register), Tail(register));
            }
        }

        // Return the minus qubit to the |0⟩ state.
        H(minus); //hadaamard
        X(minus); // invert
        
        // Measure and return the result of Grover's search.
        let result = MultiM(register);
        return(result);

    }


    // The Python/C# driver will call this operation.
    operation SolveCryptarithm(a : Int[], maxDigitsInSum : Int) : Int[] {
        // Find the number of variables.
        let numDigits = Length(a);
        // Format the equation we're solving in a readable manner.
        
        mutable equation = "";
        for i in 0 .. numDigits - 1 {
            if i > 0 {
                set equation += "+ ";
            }
            set equation += $"({a[i]})x_{i} ";
        }
        set equation += "= 0";
        Message($"Solving equation {equation}");

        // We're solving base 4 cryptarithm, so each digit is between 0 and 3, inclusive.

        let searchSpaceSize = 4;


        // Calculate the number of iterations:
        // there should be 1 answer out of searchSpaceSize^nDigits possibilities
        // each extra missing digit multiplies the number of solutions by 11 and the search space size by 11 as well,
        // so the ratio of solutions to search space size remains 1/11.
        let numIterations = Round(PI() / 4.0 / ArcSin(Sqrt(1.0 / IntAsDouble(searchSpaceSize^numDigits))) - 0.5);        
        Message($"Using {numIterations} iterations.");

        // Instantiate the marking oracle for equation a₀x₀ + ... + aₖxₖ = 0 (mod 11).
        let mOracle = IsCryptarithmSolution(a, maxDigitsInSum, _, _);

        // Run Grover's search for this oracle.
        let groversResult = RunGroversSearch(mOracle, numDigits, searchSpaceSize, numIterations);

        // Interpret the results returned by the search.
        // In this case the result will encode the digits we're looking for.

        let digitsFound = Mapped(ResultArrayAsInt, Chunks(Length(groversResult) / numDigits, groversResult));
        Message($"Solution found = {digitsFound}");

        return digitsFound;
    }
}

