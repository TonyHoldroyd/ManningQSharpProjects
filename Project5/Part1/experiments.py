#To get my thinking going on this problem I looked at a classial solution as follows:
# Used and adapted with permission from David Radcliffe
# https://gist.github.com/Radcliffe/04bb0c62069083b0e2e6956ea9c9a3a9

from itertools import permutations
import sys


def word_to_number(word, lookup):
    """Convert a word to a number by replacing each letter with a digit, using a lookup dictionary."""
    return int(''.join(str(lookup[letter]) for letter in word))


def solve_cryptarithm(words):
    """Solve an equation like SEND + MORE = MONEY given a list of three or more words.
       The last word should be the sum of the other words."""
    words = [word.upper() for word in words]
    answer = []
    letters = list(set(''.join(words)))

    for perm in permutations(range(10), len(letters)):
        lookup = dict(zip(letters, perm))
        if all(lookup[w[0]] > 0 for w in words):
            numbers = [word_to_number(w, lookup) for w in words]
            if sum(numbers[:-1]) == numbers[-1]:
                answer.append(numbers)
    return(answer)


def DoIt(words):
    print(words)
    a = solve_cryptarithm(words)
    print(a)


#words = ["ZERO", "POINT", "ENERGY"]
#DoIt(words)

words = ["ZERO", "POINT", "ENERGY"] # really need to upper() them

# we have :
# POINT + ZERO = ENERGY base 10 i.e. base10, 10 diff digits)
# Z,E,R,O,P,I,N,T,G,Y
# i.e. 4 bits per digit
# store in a single 40 qubit register!!! Too big, oh dear.
# It is:
#
# 98504    E=1 G=7 I=5 N=0 O=8 P=9 R=6 T=4 Y=2 Z=3
#+ 3168
# ------
# 101672
# 98504 + 3168 = 101672
# In this milestone we're considering a fixed cryptarithm, namely, 
#  SEE
# +SEA
# ----
# EASE
# 211 + 210 
# A = x₀, E = x₁, S = x₂
#   x₂x₁x₁
#  +x₂x₁x₀
# --------
# x₁x₀x₂x₁
# 
# 15x₀ + 56x₁ - 28x₂ = 0
# DAN
# +NAN
# ----
# NORA
# has 1 solution in base 6.

# It is:

#  521    A=2 D=5 N=1 O=0 R=4 
# +121
# ----
# 1042
#i.e. 5 letters/variables, so base 6, each between 0 and 4 = 3 bits per letter, register of 18 qubits, I think !


# Define the coefficients of the equation that the cryptarithm boils down to.
#A=X0, D= X1,  N=X2, O= X3, R= X4

# Define other parameters of the problem.
# need to check 5!=120 checks
# Now check solution is correct i.e 
# with place values 216, 36, 6 and 1
#we need:
# (36X1 + 6X0 + X2 ) + (36X2 + 6X0 + X2) - (216X2 + 36X3 + 6X4  + X0 = 0)
# which is: (6X0 + 6X0 - X0) + (36X1) (X2 + 36X2 + X2 - 216X2) -(36X3) -  (6X4)
# OR  11X0 +  36X1 -178X2 -36X3 - 6X4 !!!!!!to do check me agAIn!!!!!!
# Run the quantum code to solve the cryptarithm.


# Classical post-processing: print the result.