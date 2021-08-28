namespace Teleport {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
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

        mutable bob_gets_bit = false;

        if M(qb) == One {
            set bob_gets_bit = true;
        }
        let B_basis_state_received = bob_gets_bit ? "|1⟩" | "|0⟩";
        Message($"Bob gets  {B_basis_state_received}");
        Message("Over and Out!");
    }



    @EntryPoint()
        operation Do_It_all() : Unit {
        use A_bell_bit = Qubit();
        use B_bell_bit  = Qubit();
        use A_message_bit = Qubit();
        Message($"{A_bell_bit}");
        // Step 1 Prepare Bell pair
        Prepare_Bell(A_bell_bit, B_bell_bit);

        // Create message bit
        let A_to_send_bit = DrawRandomBool(0.5);

        let A_basis_state_sent = A_to_send_bit ? "|1⟩" | "|0⟩";
        
        Message("Sending...");     
        Message($"Alice sent {A_basis_state_sent}");  

        if  A_to_send_bit == true {
            X(A_message_bit); // 1, otherwise 0
        }

       

        // entangle message bit - basis state with Alice's half of Bell pair
        Entangle(A_message_bit, A_bell_bit);

        // Alice measures her bits

        
        let mA_bit = Measure(A_bell_bit);
        let mA_message_bit = Measure(A_message_bit);

        // Alice sends these Booleans (as classical bits) to Bob        
        
        // Bob builds the message using Alice's bits and reports his findings
        Reassemble_Message_And_Report(B_bell_bit, mA_message_bit, mA_bit) ;     

        Reset(A_bell_bit);
        Reset(B_bell_bit);
        Reset(A_message_bit);    
    }
}