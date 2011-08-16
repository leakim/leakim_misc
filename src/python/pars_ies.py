#!/usr/bin/python
#
# echo "00 04 74 65 73 74" | python pars_ies.py
#

import sys
from curses.ascii import isprint

def printable(input):
   r = []
   for char in input:
      if isprint(char):
         r += char
      else:
         r += "."
   return ''.join(r)

def ByteToHex( byteStr, indent):
   return ''.join( [ indent + "%02X" % ord(x) for x in byteStr ] ).strip()

def ByteToASCII( byteStr, indent):
   return ''.join( [ indent + "%s" % printable(x) for x in byteStr ] ).strip()

def HexToByte( hexStr ):
   bytes = []

   hexStr = ''.join( hexStr.split(" ") )
   for i in range(0, len(hexStr), 2):
      bytes.append( chr( int (hexStr[i:i+2], 16) ) )

   return ''.join(bytes)

def print_parts(b, mod):
   if len(b) > mod:
      print ByteToHex(  b[:mod], " ")
      print ByteToASCII(b[:mod], "  ")
      print_parts(b[mod:], mod)
   else:
      print ByteToHex(  b, " ")
      print ByteToASCII(b, "  ")

def print_ie(ies):
   if len(ies) == 0:
      return
   l = ord(ies[1])
   if l+2 > len(ies):
      print "Oops! %d > %d" % (l, len(ies))
      print ByteToHex(ies, " ")
      print ByteToASCII(ies, "  ")
      return
   print "ID: %d (0x%02x) len %d (0x%02x)" % ( ord(ies[0]),ord(ies[0]), ord(ies[1]),ord(ies[1]))
   print "-------------------------------"
   print_parts(ies[:2+l], 32)
   print ""
   print_ie(ies[2+l:])

loop = True
line_count = 0
ies = []

f = sys.stdin

# Ugly, but it does the job!
while loop:
   line_count += 1
   l = f.readline().replace("\n","")
   if(len(l) < 3):
      loop = False
   else:
      ies += HexToByte(l)

loop = True
while loop:
   line_count += 1
   l = f.readline().replace("\n","")
   if(len(l) < 3):
      loop = False
   else:
      ies += HexToByte(l)

print

print_ie(ies)
   
