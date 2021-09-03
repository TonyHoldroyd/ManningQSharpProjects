// Very cheeky answer to the Q# live Project number 3


namespace PrepArbitraryStateUsingLibrary {
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    
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

    @EntryPoint()
        operation DoItAll() : Unit {
            Prepare();
        }
}

