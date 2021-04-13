#!#!/usr/bin/env python3
################################################################################
# var.py
<<COMMENT
Variable assignment example code
COMMENT
################################################################################
BYTE1=b'''23234
dsf234
234234e'''
print("Variable BYTE1 has value ", BYTE1 , " is ", type( BYTE1 )) 
INP1=input("Enter your name:")
print("Variable INP1 has value ", INP1 , " is ", type( INP1 )) 
BA1=bytearray(b'''232
Happy
234234e''')
print("Variable BA1 has value ", BA1 , " is ", type( BA1 )) 
BA2=bytearray(BYTE1)
print("Variable BA2 has value ", BA2 , " is ", type( BA2 )) 
MV1=memoryview(BA1)
print("Variable MV1 has value ", MV1 , " is ", type( MV1 )) 
S1={1 ,2 ,3 ,4 ,5}
print("Variable S1 has value ", S1 , " is ", type( S1 )) 
R1=range(11,-12,-2)
print("Variable R1 has value ", R1 , " is ", type( R1 )) 
B1=True
print("Variable B1 has value ", B1 , " is ", type( B1 )) 
B2=False
print("Variable B2 has value ", B2 , " is ", type( B2 )) 
I1=100
print("Variable I1 has value ", I1 , " is ", type( I1 )) 
F1=100.0
print("Variable F1 has value ", F1 , " is ", type( F1 )) 
C1=10+15j
print("Variable C1 has value ", C1 , " is ", type( C1 )) 
STR1="string in a double' quote"
print("Variable STR1 has value ", STR1 , " is ", type( STR1 )) 
STR2='string in a single" quote'
print("Variable STR2 has value ", STR2 , " is ", type( STR2 )) 
LST1=[1 ,2 ,3 ,4 ,5]
print("Variable LST1 has value ", LST1 , " is ", type( LST1 )) 
LST2=["Hello" ,"John" ,'reese']
print("Variable LST2 has value ", LST2 , " is ", type( LST2 )) 
LST3=["Hey" ,"you" ,1 ,2 ,3 ,"go"]
print("Variable LST3 has value ", LST3 , " is ", type( LST3 )) 
TUP1=(1 ,2 ,3 ,4)
print("Variable TUP1 has value ", TUP1 , " is ", type( TUP1 )) 
TUP2=("Hey" ,"you" ,1 ,2 ,3 ,"go")
print("Variable TUP2 has value ", TUP2 , " is ", type( TUP2 )) 
DIC1={1:"first name" ,2:"last name" ,"age":33}
print("Variable DIC1 has value ", DIC1 , " is ", type( DIC1 )) 
# Assign list to to variable
#==========================
userAge=1

