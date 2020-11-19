#!/usr/local/python3

from time import sleep

try_count = 0
while try_count < 5:
    data = input("?")
    if data == "test":
        break
    else:
        data = None
    try_count += 1
    sleep(5)

if data == None:
    print("Bad Try")
else:
    print("Thanks!")
