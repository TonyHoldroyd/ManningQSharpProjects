namespace Teleport2 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    operation Prepare_Bell(qb1: Qubit, qb2 : Qubit) : Unit  {
        H(qb1);
        CX(qb1, qb2);
    }

    operation Entangle(qb1: Qubit, qb2: Qubit) : Unit {
        CX(qb1, qb2);
        H(qb1);
    }

    operation Measure(qb : Qubit): Bool {
        return M(qb) == One;
    }

    operation Reassemble_Message_And_Report(qb : Qubit, bool1 :Bool, bool2: Bool ) : Unit {
        if bool1 {
            Z(qb);            
        }
        if bool2 {
            X(qb);
        }
      
        
        Message($"Bob gets:");
        DumpRegister((),[qb]);

        Message("Over and Out!");
    }

    operation Prep_Q_Arbitrary_State(alpha : Double, beta : Double , theta : Double, qbit : Qubit) : Unit is Adj + Ctl {
        let phi = ArcTan2(beta, alpha);
        Ry(2.0*phi, qbit);
        Rx(theta, qbit);
    }

    @EntryPoint()
        operation Do_It_all() : Unit {

        use A_bell_bit = Qubit();
        use B_bell_bit  = Qubit();
        use A_message_bit = Qubit();

        Prep_Q_Arbitrary_State(0.0, 1.0, 0.0, A_message_bit);
        Message("Alice sends:");
        DumpRegister((), [A_message_bit]);
        
        // Step 1 Prepare Bell pair
        Prepare_Bell(A_bell_bit, B_bell_bit);



        // entangle message bit - basis state with Alice's half of Bell pair
        Entangle(A_message_bit, A_bell_bit);

        // Alice measures her bits

        
        let mA_bit = Measure(A_bell_bit);
        let mA_message_bit = Measure(A_message_bit);


        // Alice sends these Booleans to Bob        
        
        // Bob builds the message using Alice's bits and reports his findings
        Reassemble_Message_And_Report(B_bell_bit, mA_message_bit, mA_bit) ;     

        Reset(A_bell_bit);
        Reset(B_bell_bit);
        Reset(A_message_bit);
     
    }
}

