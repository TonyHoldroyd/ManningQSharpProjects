namespace P3M4_Tests{

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Arithmetic;
    operation Prep_Single_Arbitrary_State(qubit: Qubit, coeffs : Double[] ): Unit is Adj + Ctl {
        let phi = ArcTan2(coeffs[1], coeffs[0]);
        Ry(2.0*phi, qubit);
    }

    operation PrepSuperpositionRecursively (
        qubits : Qubit[], 
        amps : Double[], 
        substatesPrep : (Qubit[] => Unit is Adj + Ctl)[]
    ) : Unit is Adj + Ctl {
        // Prepare the first qubit in the state α|0⟩ + β|1⟩.
        Prep_Single_Arbitrary_State(qubits[0], amps );

        // At this point the state of the system is (α|0⟩ + β|1⟩) ⊗ |0...0⟩ = α|0⟩ ⊗ |0...0⟩ + β|1⟩ ⊗ |0...0⟩.
        if Length(qubits) > 1 {
            // Adjust the first term without modifying the second one: α|0⟩ ⊗ |0...0⟩ -> α|0⟩ ⊗ |φ⟩.
            let controlledOnFirstTerm = ControlledOnInt(0,substatesPrep[0] );
            controlledOnFirstTerm([qubits[0]], qubits[1 ...]);
            // Adjust the second term without modifying the first one: β|1⟩ ⊗ |0...0⟩ -> β|1⟩ ⊗ |ψ⟩.
            let controlledOnSecondTerm = ControlledOnInt(1,substatesPrep[1] );
            controlledOnSecondTerm([qubits[0]], qubits[1 ...]);
            
        }
    }

    operation Prep_N_Arbitrary_States (
        qubits : Qubit[], 
        amps : Double[]
    ) : Unit is Adj + Ctl {
        // Group terms that have 0 and 1 as their first bits into separate groups.
        // Since we're using little endian, the first bit is the index modulo 0, 
        // so all even elements will go to one group and all odd - to another one
        let ampsFirstBit0 = amps[0 .. 2 ...];
        let ampsFirstBit1 = amps[1 .. 2 ...];   

        // Figure out the new coefficients: α, β and the amplitudes for preparing |φ⟩ and |ψ⟩.

        let  normalisedAmps  = [PNorm(2.0, ampsFirstBit0), PNorm(2.0, ampsFirstBit1)];

        let normalisedAmpsFirstBit0 = PNormalized(2.0, ampsFirstBit0);
        let normalisedAmpsFirstBit1 = PNormalized(2.0, ampsFirstBit1);

  
        
        // Call recursive state preparation with these parameters.
        // The recursion will stop based on the condition in PrepareSuperpositionRecursively.
        PrepSuperpositionRecursively(qubits,normalisedAmps, 
            [Prep_N_Arbitrary_States(_,normalisedAmpsFirstBit0 ), 
            Prep_N_Arbitrary_States(_,normalisedAmpsFirstBit1 )] );
        
    }


    // A helper operation that demonstrates the effect of the state prep operation.
    // The state prep operation is passed as a parameter to this operation, 
    // so that the arrays parameters are defined in the caller operation only.
    operation AllocateQubitsAndPrepareStateDemo (
        nQubits : Int,
        statePrep : (Qubit[] => Unit is Adj + Ctl),
        targetString : String
    ) : Unit {
        // Allocate nQubits qubits.
        use qubits = Qubit[nQubits];
        Message($"Preparing superposition state {targetString}...");
        // Apply the given state preparation operation to the qubits.
        statePrep(qubits);
        // Print the qubits state.
        DumpMachine();
        Message("");
        // Return the qubits to the |0...0⟩ state before releasing them.
        ResetAll(qubits);
    }


    // Operation marked with @EntryPoint will be executed when running Q# standalone project.
    operation RunPrepareArbitraryStateDemo () : Unit {
        // States hard-coded individually and output  saved to .txt files
        // Single-qubit states:
        let OneOverRoot2 = 1.0/Sqrt(2.0);
        // AllocateQubitsAndPrepareStateDemo(
        //     1, Prep_N_Arbitrary_States(_, [1.0,0.0]), "|0⟩");
        // AllocateQubitsAndPrepareStateDemo(
        //     1, Prep_N_Arbitrary_States(_, [0.0,1.0]), "|1⟩");        
        // AllocateQubitsAndPrepareStateDemo(
        //     1, Prep_N_Arbitrary_States(_, [OneOverRoot2,OneOverRoot2]), "1/root2|0⟩ + 1/root2|1⟩");
        // Two-qubit states:       
        // AllocateQubitsAndPrepareStateDemo(
        //     2, Prep_N_Arbitrary_States(_, [1.0, 0.0, 0.0, 0.0]), "|00⟩");   

        // AllocateQubitsAndPrepareStateDemo(
        //     2, Prep_N_Arbitrary_States(_, [1.0, 0.0, 0.0, 0.0]), "|00⟩");              

        // AllocateQubitsAndPrepareStateDemo(
        //     2, Prep_N_Arbitrary_States(_, [0.0, 1.0, 0.0, 0.0]), "|10⟩");              

        // AllocateQubitsAndPrepareStateDemo(
        //     2, Prep_N_Arbitrary_States(_, [0.0, 0.0, 1.0, 0.0]), "|10⟩");              

        // AllocateQubitsAndPrepareStateDemo(
        //     2, Prep_N_Arbitrary_States(_, [0.0,OneOverRoot2 ,  0.0, OneOverRoot2]), "|10⟩");              
        
        AllocateQubitsAndPrepareStateDemo(
            3, Prep_N_Arbitrary_States(_, PNormalized(2.0, [1., 0., 1., 0., 0., 1., 0., 1.])), "0.5(|000⟩ + |010⟩ + |101⟩ + |111⟩)");



 


        // Three-qubit states. Note that we can reuse PNormalized to simplify the presentation of our amplitudes!


        // Come up with your own test cases!
    }
}

