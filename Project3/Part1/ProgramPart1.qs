namespace Project3Part1 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
     
    operation Prep_Q_Arbitrary_State(angles: Double[], qubit: Qubit) : Unit is Adj + Ctl{
        let phi = ArcTan2(angles[1], angles[0]);
        Ry(2.0*phi, qubit);
        Rx(angles[2], qubit);
    }

    @EntryPoint()
    operation RunPrepOp() : Unit {
        use qb = Qubit();
        let OnedivRt2 = 1.0/Sqrt(2.0);
        let PIdiv4 = PI()/4.0;
        let PIdiv2  = PI()/2.0;
        mutable count = 0;
        let runs =  [
                        [1.0, 0.0, 0.0],    // |0⟩ Basis state
                        [0.0, 1.0, 0.0],    // |1⟩ Basis state
                        [OnedivRt2, OnedivRt2, 0.0 ], //  Equal superpositions
                        [-OnedivRt2, OnedivRt2, 0.0 ],    //  Equal superpositions
                        [0.6, 0.8, 0.0],    //  Unequal superpositions, note square of sum of terms is 1.0
                        [-0.8, -0.6, 0.0],     // Unequal superpositions, note square of sum of terms is 1.0 
                        [1.0, 0.0, PIdiv2],    // |0⟩ Basis state with phase Pi/2
                        [0.0, 1.0, PIdiv2]    // |1⟩ Basis state with phase Pi/2

                    ];

        for r in runs {
            set count+=1;
            Prep_Q_Arbitrary_State(r, qb);
            Message($"Superposition state #{count} for : ({r[0]}|0⟩ +{r[1]}|1⟩), with phase  of {r[2]} is :");
            DumpMachine();
            Message("");
            Message("");
            Reset(qb);   
        }         
     }
}