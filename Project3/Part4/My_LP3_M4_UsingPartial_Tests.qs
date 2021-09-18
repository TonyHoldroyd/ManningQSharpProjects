namespace P3M4_Tests{

    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    

    // Helper operation that compares PrepareArbitraryState to PrepareArbitraryStateD for the given state.
    operation AssertPrepareSameState (N : Int, amps : Double[]) : Unit {
        Message($"Testing N = {N}, amplitudes = {amps}...");
        // (optional) Double-check that the test is valid (N matches the number of amplitudes).
        Message($"We reqire N={N} and amplitudes ={amps}");
        // Use the trick described in https://devblogs.microsoft.com/qsharp/inside-the-quantum-katas-part-1/
        // to check that PrepareArbitraryState and PrepareArbitraryStateD prepare the same state.
        Fact(2 ^ N == Length(amps), "Length of amplitudes must be {2^N}, but it was {Length(amps)}");
        // Allocate the qubits.
        use qubits = Qubit[N];
        // Prepare the state using your solution.
        Prep_N_Arbitrary_States(qubits,amps);
        // Undo state preparation using the library operation.
        Adjoint PrepareArbitraryStateD(amps, LittleEndian(qubits));
        // If the states prepared are the same, the qubits will end up in the |0...0⟩ state, and assert will pass;
        // otherwise it will fail.
        AssertAllZero(qubits);
        Message("   Test passed!");
    }


    // Operations marked with @Test attribute will be executed as Q# unit tests.
    @Test("QuantumSimulator")
        operation SingleQubitTests () : Unit {
        AssertPrepareSameState(1, [1.0, 0.0]);
        AssertPrepareSameState(1, [0.0, 1.0]);
        AssertPrepareSameState(1, [1.0/Sqrt(2.0), 1.0/Sqrt(2.0)]);
        AssertPrepareSameState(1, [1.0/Sqrt(2.0), -1.0/Sqrt(2.0)]);
        AssertPrepareSameState(1, [-0.8, -0.6]);
    }


    @Test("QuantumSimulator")
    operation TwoQubitTests () : Unit {
        AssertPrepareSameState(2, [1.0, 0.0, 0.0, 0.0]);
        AssertPrepareSameState(2, [0.0, 0.0, 0.0, 1.0]);
        AssertPrepareSameState(2, [0.0, 1.0, 0.0, 0.0]);  
        AssertPrepareSameState(2, [0.0, 0.0, 1.0, 0.0]);                
        AssertPrepareSameState(2, [0.5, 0.5, 0.5, 0.5]);
        AssertPrepareSameState(2, [0.5, -0.5, -0.5, 0.5]);
        AssertPrepareSameState(2, [-0.5, -0.5, -0.5, -0.5]);        
        AssertPrepareSameState(2, [1.0/Sqrt(2.0), 0.0, 0.0, 1.0/Sqrt(2.0)]);
        AssertPrepareSameState(2, [1.0/Sqrt(2.0), 0.0, 0.0, -1.0/Sqrt(2.0)]);
        AssertPrepareSameState(2, [0.0, 1.0/Sqrt(2.0), 1.0/Sqrt(2.0), 0.0]);
        AssertPrepareSameState(2, [0.0, -1.0/Sqrt(2.0), 1.0/Sqrt(2.0), 0.0]);
    }


    // Come up with your own test for 3 or more qubits!

    // @Test("QuantumSimulator")
    // operation ThreeQubitTests () : Unit { 
    // AssertPrepareSameState(3, PNormalized(2.0, [1., 0., 1., 0., 0., 1., 0., 1.])), "0.5(|000⟩ + |010⟩ + |101⟩ + |111⟩)");
    
}