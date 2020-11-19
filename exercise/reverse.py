#!/usr/local/python3

a = input("Enter your world:")

if a == a[::-1]:
    print("OK")
else:
    print("NOT OK")
