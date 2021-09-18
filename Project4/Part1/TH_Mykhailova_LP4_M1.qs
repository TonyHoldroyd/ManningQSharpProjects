namespace TH_P4M1  {

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
    /// is a solution to the equation ax + b = 0 (mod 11).
    ///
    /// # Input
    /// ## a, b
    /// Coefficients of the equation.
    /// ## register
    /// Input of the marking oracle.
    /// ## target
    /// Output of the marking oracle.
    operation IsEquationSolution(a: Int, b : Int, register : Qubit[], target : Qubit) : Unit is Adj {
        // We start with an integer x written in the register.
        let modulus = 11;
        within {
            // Multiply it by a (mod 11).
            MultiplyByModularInteger(a, modulus, LittleEndian(register));
            // Add to it b (mod 11).
            IncrementByModularInteger(b, modulus,LittleEndian(register) );
        } apply {
            // Check whether the result is 0.
            let control = ControlledOnInt(0, X);
            control(register, target);

        }
    }


    /// # Summary
    /// Runs Grover search for the problem described as a marking oracle.
    ///
    /// # Input
    /// ## markingOracle
    /// An operation that implements the marking oracle for the problem.
    /// ## searchSpaceSize
    /// The search looks for a digit between 0 and searchSpaceSize - 1, inclusive.
    /// ## nIterations
    /// The number of iterations to run the search for.
    ///
    /// # Output
    /// An array of measurement results that the algorithm yielded.
    operation RunGroversSearchForMissingDigit(
        mOracle : ((Qubit[], Qubit) => Unit is Adj), 
        searchSpcSz : Int, 
        numTimes : Int
    ) : Result[] {
        // Calculate the number of bits we need to store the digit we're looking for.
        let numQubits = BitSizeI(searchSpcSz);

        // Allocate the qubits to use in the search algorithm.
        use reg= Qubit[numQubits];
        use minus = Qubit();
        // Prepare the minus qubit in the |-⟩ state.
        X(minus);
        H(minus);

        // Prepare an equal superposition of all basis states from 0 to (searchSpaceSize - 1), inclusive
        // (this way we don't need to implement the check for the digit being < 11 in the oracle itself).
        PrepareArbitraryStateD(ConstantArray(searchSpcSz, 1.0), LittleEndian(reg));
        
        // Run iterations of Grover's search.
        for _ in 1 .. numTimes {
            // Apply the marking oracle as a phase oracle
            // using the minus qubit in the |-⟩ state and the phase kickback trick.
            
            mOracle(reg, minus);
            // Perform reflection around the mean.
            within {
                // Note that here we're using adjoint of the routine to prepare equal superposition 
                // of all basis states in the search space, not just of all basis states.
                Adjoint PrepareArbitraryStateD(ConstantArray(searchSpcSz, 1.0), LittleEndian(reg));
                // Flip the state of each qubit.
                ApplyToEachA(X, reg);
            } 
            
            apply {
               
                // Flip the phase if all qubits are in the |1⟩ state.
                Controlled Z(Most(reg), Tail(reg));
            }
        }

        // Return the minus qubit to the |0⟩ state.
                H(minus);
                X(minus);
        // Measure and return the result of Grover's search.
        let measure = MultiM(reg);
        return (measure);
    }


    // The Python/C# driver will call this operation;
    // it solves equation of the form ax + b = 0 (mod 11).
    operation FindMissingDigit(a : Int, b : Int) : Int {
        Message($"Solving equation {a}x + {b} = 0 (mod 11)");

        // ISBN-10 uses base-11 digits (though only the last digit can actually be X).
        // Define search space size based on this.
        let searchSpcSz = 11;


        // Calculate the number of iterations:
        // for a single missing digit there are 10 candidates and 1 answer, so:
        let numTimes = Round(PI() / 4.0 / ArcSin(Sqrt(1.0 / IntAsDouble(searchSpcSz))) - 0.5);
        // This should be 2 iterations.
        Message($"Using {numTimes} iterations.");

        // Instantiate the marking oracle for equation ax + b = 0 (mod 11).
        
        let mOracle = IsEquationSolution(a,b,_,_);
        // Run Grover's search for this oracle.
        
        let groverAns = RunGroversSearchForMissingDigit(mOracle, searchSpcSz, numTimes);

        // Interpret the results returned by the search.
        // In this case the result will encode the digit we're looking for.
        let foundDig = ResultArrayAsInt(groverAns);
        Message($"Missing digit found = {foundDig}");

        return foundDig;
    }
    @EntryPoint()
    operation dummy() : Unit {}
}

