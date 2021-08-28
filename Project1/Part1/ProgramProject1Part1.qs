// Manning Q# liveProjects: Project 1:BB84 key distribution protocol, Task 1: Plain BB4 Protocol
namespace protocolBB84 {
    	open Microsoft.Quantum.Random;
    	open Microsoft.Quantum.Canon;
    	open Microsoft.Quantum.Intrinsic;
    	open Microsoft.Quantum.Convert;
    	operation Run_Protocol() : String {
    	// Step 1: 
    	// create random bit and random basis for A(lice)
 	
    		let A_bit = DrawRandomBool(0.5);
    		let A_basis = DrawRandomBool(0.5);
 
	// Step 2: 
	// Instantiate a qubit.
	// Prepare it in the basis state that encodes her bit (0/1) in her basis (default or H)
	
		use A_qubit = Qubit(); // zero when created
	
		if A_bit == true{
			X(A_qubit); // flip qubit if required by A_bit
		}
	
		if A_basis == true  {
			H(A_qubit); // change to Hadamard basis if required by A_basis, else leave in computational basis
		}
		
	// Step 3:
	// Bob recieves Alice's qubit.
	
	//Step 4:
	// Bob then randomly creates his basis
	
	let B_basis = DrawRandomBool(0.5);
	
	// and he measures the received qubit in his own basis to create his own bit
	
	if  B_basis == true {
		H(A_qubit); // change basis to H if required
	}

	let bobBit = M(A_qubit) == One;
	
	// Step 5:
	
	// Alice and Bob compare their bases. If they are the same Bob has measured the same bit that Alice crfeated and they 
	// join their bits to their keys, otherwise they don't use this protocol run
	
	mutable bit = "0";
	if A_bit == true {
		set bit="1";	
	}
	return A_basis == B_basis ? bit | "";


   }
   @EntryPoint()
   operation BB84_protocol() : Unit {


        let protocol_length = 16;

        mutable this_key = "";
        
        for b in 1 .. protocol_length {
            set this_key += Run_Protocol();
        }
        Message($"For the BB84 protocol the key is: {this_key}");
    }    
}

