namespace TH_MM_LP3_M4 {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;


    /// # Summary
    /// Marking oracle that checks whether integer x written in the register
    /// is a solution to the equation a₀x₀ + ... + aₖxₖ + b = 0 (mod 11).
    ///
    /// # Input
    /// ## a, b
    /// Coefficients of the equation.
    /// ## register
    /// Input of the marking oracle.
    /// ## target
    /// Output of the marking oracle.
    operation IsArrayEquationSolution(a : Int[], b : Int, register : Qubit[], target : Qubit) : Unit is Adj {
        // Find the number of missing digits and the number of qubits per digit.
        
        let numMissingDigits = Length(a);
        let digitSize = Length(register)/numMissingDigits;
        let modulus = 11;
        // We start with the integers x₀, ..., xₖ written in the register, digitSize qubits for each.
        // Split the register into an array of registers storing individual integers.
        
        let registerStoringDigits= Chunks(numMissingDigits, register);
        // Allocate an extra register to accumulate our expression.
        
        use expressionRegister = Qubit[digitSize];

        within {
            // Write the value of b to the expression Register register 
            ApplyXorInPlace(b, LittleEndian(expressionRegister));

            for digit  in 0 .. numMissingDigits - 1 {
                // Add terms for aᵢxᵢ.
                MultiplyAndAddByModularInteger(a[digit], modulus,LittleEndian(registerStoringDigits[digit]), LittleEndian(expressionRegister));
            }
        } apply {
            // Check whether the result is 0.
            let control = ControlledOnInt(0,X);
            control(expressionRegister, target);
        }
    }


    /// # Summary
    /// Prepare an equal superposition of all states that can encode nDigits digits, each of them between 0 and searchSpaceSize - 1, inclusive.
    operation PrepareSearchSpaceSuperposition (
        nDigits : Int,
        searchSpaceSize : Int,
        register : Qubit[]
    ) : Unit is Adj {
        // Split the given register into nDigits chunks.
        
        let chunksLength = Length(register)/nDigits;
        let digitRegisters = Chunks(chunksLength, register);
        // Prepare an equal superposition of states from 0 to searchSpaceSize - 1, inclusive, on each chunk.
        for digitRegister in digitRegisters {
              PrepareArbitraryStateD(ConstantArray(searchSpaceSize, 1.0), LittleEndian(digitRegister));          
        }
    }


    /// # Summary
    /// Runs Grover search for the problem described as a marking oracle.
    ///
    /// # Input
    /// ## markingOracle
    /// An operation that implements the marking oracle for the problem.
    /// ## nDigits
    /// The number of missing digits.
    /// ## searchSpaceSize
    /// The search looks for nDigits digits, each of them between 0 and searchSpaceSize - 1, inclusive.
    /// ## nIterations
    /// The number of iterations to run the search for.
    ///
    /// # Output
    /// An array of measurement results that the algorithm yielded.
    operation RunGroversSearchForMissingDigits(
        markingOracle : ((Qubit[], Qubit) => Unit is Adj), 
        nDigits : Int,
        searchSpaceSize : Int, 
        nIterations : Int
    ) : Result[] {
        // Count the number of bits we need to store the digit we're looking for.
        let numQubits = BitSizeI(searchSpaceSize);

        // Allocate the qubits to use in the search algorithm.
        let registerLength = numQubits*nDigits;
        use register = Qubit[registerLength];
        use minus = Qubit();
        // Prepare the minus qubit in the |-⟩ state.
        X(minus); // invert bits
        H(minus); // apply Hadamard gate

        // Prepare the equal superposition of all states in the search space
        // (this way we don't need to implement the check for each digit being < 11 in the oracle itself).
        
        PrepareSearchSpaceSuperposition(nDigits, searchSpaceSize, register);
        // Run iterations of Grover's search.
        for _ in 1 .. nIterations {
            // Apply the marking oracle as a phase oracle
            // using the minus qubit in the |-⟩ state and the phase kickback trick.
            
            markingOracle(register,minus);
            // Perform reflection around the mean.
            within {
                // Note that here we're using adjoint of the routine to prepare equal superposition 
                // of all basis states in the search space, not just of all basis states.
                
                Adjoint PrepareSearchSpaceSuperposition(nDigits, searchSpaceSize, register);
                // Flip the state of each qubit.
                ApplyToEachA(X, register);

            } apply {
                // Flip the phase if all qubits are in the |1⟩ state.
                Controlled Z(Most(register), Tail(register));
            }
        }

        // Return the minus qubit to the |0⟩ state.
            H(minus);
            X(minus);
        
        // Measure and return the result of Grover's search.
        let missingDigits = MultiM(register);
        return(missingDigits);
    }


    // The Python/C# driver will call this operation;
    // it solves equation of the form a₀x₀ + ... + aₖxₖ + b = 0 (mod 11).
    operation FindMissingDigits(a : Int[], b : Int) : Int[] {
        // Find the number of missing digits.
        
        let numDigits = Length(a);
        // Format the equation we're solving in a readable manner.
        mutable equation = "";
        for i in 0 .. numDigits - 1 {
            set equation += $"{a[i]}x_{i} + ";
        }
        set equation += $"{b} = 0 (mod 11)";
        Message($"Solving equation {equation}");

        // ISBN-10 uses base-11 digits (though only the last digit can actually be X).
        // Define search space size for each digit based on this.
        // For multiple missing digits, we'll use separate registers to store each digit.
        let searchSpaceSize =11;

        // Calculate the number of iterations:
        // for a single missing digit there are 10 candidates and 1 answer;
        // each extra missing digit multiplies the number of solutions by 11 and the search space size by 11 as well,
        // so the ratio of solutions to search space size remains 1/11.
        let numIterations = Round(PI() / 4.0 / ArcSin(Sqrt(1.0 / IntAsDouble(searchSpaceSize))) - 0.5);
        // This should be 2 iterations still.
        Message($"Using {numIterations} iterations.");

        // Instantiate the marking oracle for equation a₀x₀ + ... + aₖxₖ + b = 0 (mod 11).
        let mOracle = IsArrayEquationSolution(a, b, _, _);

        // Run Grover's search for this oracle.
        
        let groversResult = RunGroversSearchForMissingDigits(mOracle, numDigits, searchSpaceSize, numIterations);     

        // Interpret the results returned by the search.
        // In this case the result will encode the digits we're looking for.
        //  let numDigitsInResult = Chunks(Length(groversResult) / numDigits; compiler doesn't like this 
        let missingDigits = Mapped(ResultArrayAsInt, Chunks(Length(groversResult) / numDigits, groversResult));

        Message($"The missing digits found are {missingDigits}");

        return missingDigits;
        
    }
}

