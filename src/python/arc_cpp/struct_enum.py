#!/usr/bin/python

import struct
import sys
import re

from optparse import OptionParser

#f.flush()
#f.seek(offset)
#f.tell()

def is_def(l):
   s = l.strip().split()
   if len(s) > 4:
      return False

   for f in s:
      if f == "struct":
         return True
      if f == "enum":
         return True
      if f == "union":
         return True
   return False

class S:
   type0 = False
   name0 = None
   type0name = None
   start = 0
   end = 0
   l = ""
   def get_name(self):
      return self.name0
   def get_type(self):
      return self.type0
   def get_typename(self):
      return self.type0name
   def get_orig(self):
      return self.l
   def get_h(self):
      s = ""
      if self.type0name:
         s += "def: " + self.type0name + " "
      if self.name0:
         s += "name: " + self.name0 + " "
      return s
   def __init__(self, start, l):
      self.start = start
      f = l.strip().split()
      if is_def(l):
         self.type0 = True
         if len(f)>2:
            self.type0name = f[1]
      else:
         self.type0 = None
      if len(f) > 1:
         self.name0 = f[1]
      self.l = l
   def end(self, fd, l):
      self.end = fd.tell()
      if self.type0:
         f = l.strip().split()
         if len(f) > 1:
            self.name0 = f[1]
      self.l += l

   def append(self, l):
      self.l += l

def is_start(l):
   if l.find('{') > -1:
      return True
   return False

def is_end(l):
   for f in l.split():
      if f == "}":
         return True
      if f == "};":
         return True
   return False

def modify_and_swap(n,m,f,options):
   p = m[0]
   print "modify_and_swap"
   print p.type0
   print p.name0
   print p.type0name
   print p.start
   print p.end
   print p.l
   #print p.l
   print "move this one up"
   print n.type0
   print n.name0
   print n.type0name
   print n.start
   print n.end
   print n.l

name0 = None
mode = None
m = []
n = None
count = 0

parser = OptionParser()
parser.add_option("-i", "--infile", dest="infile", 
                        help="file to read from FILE (default is STDIN)", metavar="FILE")
parser.add_option("-q", "--quiet",
                        action="store_true", dest="quiet", default=False,
                        help="don't write HEX to stdout while decoding input")
parser.add_option("-v", "--verbose",
                        action="store_true", dest="verbose", default=False,
                        help="print debug info while parsing")

(options, args) = parser.parse_args()

if options.infile == None:
   print("no in file specified, will read from STDIN")
   exit(1)
else:
   print "reading from %s" % (options.infile)
   fd = open(options.infile,'rw')

#try:
while True:
   start = fd.tell()
   line = fd.readline()
   l = line.strip()
   f = l.split()
   count += 1

   if is_start(l):
      #print "DEBUG: start: %s" % l
      if n:
         m.append(n)
      n = S(start,line)
      continue

   if is_end(l):
      #print "DEBUG: end: %s" % l
      n.end(fd,line)
      s = n.get_orig()
      if n.type0:
         # SAVE
         if len(m) > 0:
            print "MIWI: def in def start ----------- %s " % n.get_h()
            print s
            print "MIWI: def in def end -------------"
            modify_and_swap(n,m,f,options.infile)
            exit(2)
      n = None
      if len(m) > 0:
         n = m.pop()
      continue

   if n:
      n.append(line)

