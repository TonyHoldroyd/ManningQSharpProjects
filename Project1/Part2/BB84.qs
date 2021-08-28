namespace BB84 {

    	open Microsoft.Quantum.Random;
    	open Microsoft.Quantum.Canon;
    	open Microsoft.Quantum.Intrinsic;
    	open Microsoft.Quantum.Convert;
    	
    	operation Run_Protocol() : (Bool, Bool, Bool, Bool) {
    	// Step 1: 
    	// create random bit and random basis for A(lice)
 	
    		let A_bit = DrawRandomBool(0.5);
    		let A_basis = DrawRandomBool(0.5);
 
	// Step 2: 
	// Instantiate a qubit.
	// Prepare it in the basis state that encodes her bit (0/1) in her basis (default or H)
	
		use A_qubit = Qubit(); // zero when created
	
		if A_bit == true {
			X(A_qubit); // flip qubit if required by A_bit
		}
	
		if A_basis == true  {
			H(A_qubit); // change to Hadamard basis if required by A_basis, else leave in computational basis
		}
		
	// Step 3:
	// Bob receives Alice's qubit.
	
	//Step 4:
	// Bob then randomly creates his basis
	
	let B_basis = DrawRandomBool(0.5);
	
	// and he measures the received qubit in his own basis to create his own bit
	
	if  B_basis == true {
		H(A_qubit); // change basis to H if required
	}

	let B_bit = M(A_qubit) == One;
	
	// Step 5:
	
	// return result to Python caller
	return (A_bit, A_basis, B_basis, B_bit);


   }

   operation BB84(bits: Int) : (Bool, Bool, Bool, Bool)[]  {      

        mutable qr = new (Bool, Bool, Bool, Bool)[0];
        for b in 1 .. bits {
            set qr += [Run_Protocol()];
        }
        return qr;
    }   
	@EntryPoint()
    operation HelloQ() : Unit {
        Message("Hello quantum world!");
   }
 
﻿}

