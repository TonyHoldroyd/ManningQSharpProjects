from numpy import digitize
import qsharp
from TH_P4M1 import FindMissingDigit
from urllib import request
import re

# Define the ISBN-10 number to look for.
# 4 missing at index 3, Jane Asuten, Pride and Prejudice
ISBN10 = [1, 6, 0, -1, 5, 0, 1, 4, 8, 0]
# Classical pre-processing: convert the ISBN query into the parameters
# taken by the quantum code: an equation of the form ax + b = 0 (mod 11).
a, b = 0, 0
for digit in range(10):  # 0 to 9
    if ISBN10[digit] < 0:
        a = 10 - digit
        missingIndex = digit
    else:
        b += (10 - digit) * ISBN10[digit]
b %= 11

# Run the quantum code to solve the equation.
missingDigit = FindMissingDigit.simulate(a=a, b=b)
# Classical post-processing: format the resulting ISBN.
ISBN10[missingIndex] = missingDigit
# Print the results (remember that digits are base-11, and "10" is printed as X).
print("at index = ", missingIndex)
print("".join([str(digit) if digit < 10 else "X" for digit in ISBN10]))


# Retrieve the webpage with the description of this book.
print(ISBN10, "  is   ")
ISBN10_to_find = "".join(
    [str(digit) if digit < 10 else "X" for digit in ISBN10])
url = "https://www.ottobib.com/isbn/"
url = url + ISBN10_to_find
# During development process, read the same url+ISBNinformation from a local file.
with request.urlopen(url) as f:
    page = f.read().decode('utf-8')
    print(page)
print(re.search('<textarea (?P<area>.*)>(?P<content>.*)<', page).group(2))
# Extract the book description from the webpage.
