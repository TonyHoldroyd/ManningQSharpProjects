import qsharp
from TH_MM_P5M1 import SolveCryptarithm

# Define the cryptarithm to solve.

# Example from Milestone 1:
# cryptarithm = ["SEE", "SEA", "EASE"]

# Another example:
# cryptarithm = ["TEN", "TEN", "MEN", "MEET"]

# Another Exanple :
# SUM
# +MUM
# ----
#  FUS
# has 1 solution in base 4.

# It is:

#  201    F=3 M=1 S=2 U=0
# +101
# ----
#  302
cryptarithm = ["SUM", "MUM", "FUS"]

# We only consider base 4 cryptarithms.


# Extract the list of variables (letters) used in the cryptarithm.
# join concats into str, set so no duplicates :))
letters = set("".join(cryptarithm))
letters = list(letters)  # convert to list
letters = sorted(letters)  # so we can sort
numLetters = len(letters)
cryptariumLength = len(cryptarithm)
base = 4

print("Letters in ", cryptarithm, "are ",
      letters, "(", numLetters, " letters)")
# Convert the summands and the sum into an array of equation coefficients.
accumulator = [0]*numLetters  # here we have [0000]
for w in range(cryptariumLength):
    multiplicand = cryptarithm[w]
    lengthOfWord = len(multiplicand)

    # If the expression is one of of the summands, add the corresponding coefficients to the equation coefficients if it is the sum, subtract them.
    pow = 1 if w != cryptariumLength - 1 else -1  # not seen this syntax before  :)

    for l in range(lengthOfWord):
        thisLetter = multiplicand[lengthOfWord - 1 - l]
        position = letters.index(thisLetter)
        accumulator[position] += pow
        pow *= base

    # Evaluate the maximum number of digits in the sum.
maxLettersWeHaveInSum = len(cryptarithm[len(cryptarithm) - 1])

# Run the quantum code to solve the equation.
answers = SolveCryptarithm.simulate(
    a=accumulator, maxDigitsInSum=maxLettersWeHaveInSum)

# Classical post-processing: print the result.
for l in range(len(accumulator)):
    print(str(letters[l]) + " = " + str(answers[l]))
