// Very cheeky answer to the Q# live Project 3 Milestone 4


namespace PrepArbitraryStateUsingLibrary {
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    
    operation Prep_Q_Arbitrary_State(angles: Double[], qubit: Qubit) : Unit is Adj + Ctl{
        let phi = ArcTan2(angles[1], angles[0]);
        Ry(2.0*phi, qubit);
        Rx(angles[2], qubit);
    }

    operation PrepArbitState(amps: Double[], qubits: Qubit[]): Unit is Adj + Ctl {
        PrepareArbitraryStateD(amps, LittleEndian(qubits));
    }

    operation Prepare() : Unit {
        let amps1 = [1.0/Sqrt(2.0), 1.0/Sqrt(2.0)];
        let amps2 = [Sqrt(0.125), 0.0, Sqrt(0.875), 0.0];
        let amps3 = [1.0, 0.0, 1.0,0.0, 1.0, 0.0];  

        use qubits1 = Qubit[1];
        use qubits2 = Qubit[2];
        use qubits3 = Qubit[3];   

        // 1 qubit
        PrepArbitState(amps1, qubits1);
        Adjoint PrepArbitState(amps1, qubits1);
        ResetAll(qubits1);

        // 2 qubits
        PrepArbitState(amps2, qubits2);
        Adjoint PrepArbitState(amps3, qubits3);    
        ResetAll(qubits2);

        //3 qubits
        DumpMachine("Before.txt");
        PrepArbitState(amps3, qubits3);

        DumpMachine("During.txt");        
        Adjoint PrepArbitState(amps3,qubits3);
      
        ResetAll(qubits3);
        DumpMachine("After.txt");      
        //sample dump

    }

    //@EntryPoint()
    //    operation DoItAll() : Unit {
    //        Prepare();
    //    }
    @Test("QuantumSimulator")
    // Library operation test !!
    operation TestStatePrep1() : Unit {
        let amps1 = [1.0/Sqrt(2.0), 1.0/Sqrt(2.0)];
        let amps2 = [Sqrt(0.125), 0.0, Sqrt(0.875), 0.0];
        let amps3 = [1.0, 0.0, 1.0,0.0, 1.0, 0.0];  

        use qubits1 = Qubit[1];
        use qubits2 = Qubit[2];
        use qubits3 = Qubit[3];
        // Test for 1 qubit
      
        PrepArbitState(amps1, qubits1);
        Adjoint PrepArbitState(amps1, qubits1);
        AssertAllZero(qubits1);
        Message("Test 1 passed");
        ResetAll(qubits1);        

        // Test for 2 qubits
        PrepArbitState(amps2, qubits2);
        Adjoint PrepArbitState(amps2, qubits2);  
        AssertAllZero(qubits2);
        Message("Test 2 passed");    
        ResetAll(qubits2);


        // Test for 3 qubits
        PrepArbitState(amps3, qubits3);   
        Adjoint PrepArbitState(amps3,qubits3);
        AssertAllZero(qubits3);
        Message("Test 3 passed");    
        ResetAll(qubits3); 
    }

    @Test("QuantumSimulator")
    // Library operation test !!
    operation TestStatePrep2() : Unit {
        let a = [1.0, 0.0, 0.0];
        use q = Qubit();
        Prep_Q_Arbitrary_State(a, q);
        Adjoint Prep_Q_Arbitrary_State(a,q);
        AssertQubit(Zero, q);
        Message("Test 4 passed");    
        Reset(q);
    }
}

