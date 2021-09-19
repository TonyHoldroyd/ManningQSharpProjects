import qsharp
from TH_MM_LP3_M4 import FindMissingDigits

# Define the ISBN-10 number to look for.
# ISBN10 = [0,0,6,1,9,6,4,3,6,0] Pride and Predjice by Jane Austen
# 6 missing at index 2, 4 missing at 6 index 6
ISBN10 = [0, 0, -1, 1, 9, 6, -1, 3, 6, 0]
# Classical pre-processing: convert the ISBN query into the parameters
# taken by the quantum code: an equation of the form a₀x₀ + ... + aₖxₖ + b = 0 (mod 11).

a = []
b = 0
missingIndices = []
for digit in range(10):
    if ISBN10[digit] < 0:
        a.append(10 - digit)
        missingIndices.append(digit)
    else:
        b += (10 - digit) * ISBN10[digit]
b %= 11


# Run the quantum code to solve the equation.
missingDigits = FindMissingDigits.simulate(a=a, b=b)


# Classical post-processing: format the resulting ISBN.

for i in range(len(missingDigits)):
    ISBN10[missingIndices[i]] = missingDigits[i]

# Print the results (remember that digits are base-11, and "10" is printed as X).
print("".join([str(digit) if digit < 10 else "X" for digit in ISBN10]))
