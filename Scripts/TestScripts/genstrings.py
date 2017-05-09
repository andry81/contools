#!/bin/python

import random, string

def randomword(length):
   chars='01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
   return ''.join(random.choice(chars) for i in range(length))

fd = open('./bbb.txt', 'w+')
x = ''
for i in range(0, 1000000):
    string = randomword(1000)
    fd.write(string + '\n')
    if not i%1000:
        print '{0:d}: {1:10s}'.format(i,string[0:16])
fd.close()
