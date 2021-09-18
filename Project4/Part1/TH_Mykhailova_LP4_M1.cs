namespace P4M1_ISBNSingleDigitMissing 
{
    using System;
    using Microsoft.Quantum.Simulation.Simulators;

    /// <summary>
    /// The classical driver for the quantum computation.
    /// </summary>
    public class ClassicalHost
    {
        static void Main(string[] args) 
        {
            // Define the ISBN-10 number to look for.
            
            // Classical pre-processing: convert the ISBN query into the parameters
            // taken by the quantum code: an equation of the form ax + b = 0 (mod 11).
            
            // Run the quantum code to solve the equation.
            
            // Classical post-processing: format the resulting ISBN.
            
            // Print the results (remember that digits are base-11, and "10" is printed as X).
            
        }
    }
}