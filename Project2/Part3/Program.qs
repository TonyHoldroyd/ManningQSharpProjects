namespace SuperDenseCoding {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;

    newtype  TwoBitString = (bit1: String, bit2: String);

    operation Prepare_Bell(qb1: Qubit, qb2 : Qubit) : Unit is Adj {
        H(qb1);
        CX(qb1, qb2);
    }
    
    operation Str(bits: TwoBitString):String {
            //let bit1= bits::bit1;
            //let bit2 = bits::bit2;
            let (bit1, bit2) = bits!;
            return bit1+bit2;
    }

    operation Encode_Message_Bits_In_Qubit (A_qubit : Qubit, message_to_send : TwoBitString) : Unit {
        let (bit1, bit2) = message_to_send!;
        let message = bit1 + bit2; 
        if message == "00" { //(|00⟩ + |11⟩) / sqrt(2)
            I(A_qubit);
        }
        if message == "01" { // (|00⟩ - |11⟩) / sqrt(2)
            X(A_qubit);
        }
        if message == "10" { //(|01⟩ + |10⟩) / sqrt(2)
            Z(A_qubit);
        }
        if message == "11" { // (|01⟩ - |10⟩) / sqrt(2)
            Y(A_qubit);
        }
    }

    operation Extract_Message(qb1 : Qubit, qb2: Qubit) :  TwoBitString {
        Adjoint Prepare_Bell(qb1, qb2);
        let bit1 = MResetZ(qb1) == Zero ? "0" | "1";
        let bit2 = MResetZ(qb2) == Zero ? "0" | "1"; 
        return TwoBitString(bit1,bit2);
    }

    @EntryPoint()
        operation Do_It_All() : Unit {

        use A_bell_bit = Qubit();
        use B_bell_bit  = Qubit();

        let bit1 = DrawRandomBool(0.5) ? "0" | "1";
        let bit2 = DrawRandomBool(0.5) ? "0" | "1";

        let message = TwoBitString(bit1, bit2);

        Message($"Alice sends: {Str(message)}");
        
        // Step 1 Prepare Bell pair
        Prepare_Bell(A_bell_bit, B_bell_bit);

        Encode_Message_Bits_In_Qubit(A_bell_bit, message);

        // Alice sends her half of the Bell pair to Bob, he already has his half of the Bell pair!        
        
        // Bob builds the message using Alice's bits and reports his findings
        let B_message = Extract_Message(A_bell_bit, B_bell_bit) ;   
        Message($"Bob gets:{Str(B_message)}");
        Message("Over and Out!");
        Reset(A_bell_bit);
        Reset(B_bell_bit);     
    }
}

