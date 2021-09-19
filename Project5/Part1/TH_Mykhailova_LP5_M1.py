import qsharp
import time
from TH_MM_P5M1 import SolveCryptarithm
#   SUM + MUM = FUS  difficulty: 1
# The following alphametic puzzle:

#  SUM
# +MUM
# ----
#  FUS
# has 1 solution in base 4.

# It is:

#  201    F=3 M=1 S=2 U=0
# +101
# ----
#  302
# Define the coefficients of the equation that the cryptarithm boils down to.


# Define other parameters of the problem.
letters = ['F', 'M', 'S', 'U']
maxDigitsInSum= 3
# base = 4
a = [16, -18, -15, -4]
# Run the quantum code to solve the cryptarithm.
t1 = time.time()
variables = SolveCryptarithm.simulate(a=a, maxDigitsInSum=maxDigitsInSum)
t2 = time.time()

# Classical post-processing: print the result.
for digit in range(len(a)):
    print(str(letters[digit]) + " = " + str(variables[digit]))
    t = t2-t1
print("in ", t/60, " minutes")
