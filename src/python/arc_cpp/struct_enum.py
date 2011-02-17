#!/usr/bin/python

from optparse import OptionParser
from shutil import move
from os import remove

def indent_none(l):
   s = l
   while len(s) > 0 and s[0] == '\t':
      s = s[1:]
   return s

def indent_one(l):
   s = l
   while len(s) > 1 and s[0] == '\t' and s[1] == '\t':
      s = s[1:]
   return s

def index_of_def(l):
   s = l.strip().split()
   i = 0
   for f in s:
      if f == "struct":
         return i
      if f == "enum":
         return i
      if f == "union":
         return i
      i += 1
   return -1

def index_of_S(l):
   s = l.strip().split()
   i = 0
   for f in s:
      if f.find('{') > -1:
         return i
      i += 1
   return -1

def is_def(l):
   i = index_of_def(l)
   if i == -1:
      return False
   if i > 1:
      return False
   return True

class S:
   # struct my_struct_s {} my_struct;
   # type0 decl body name (end);
   decl = None # "my_struct_s"
   name0 = None # "*name[10]"
   name = None # "name"
   type0 = False # struct | union | enum
   struct_packed = False
   start = 0
   end = 0
   l = ""
   body = "" # { ... }
   def __init__(self, start, l):
      self.start = start
      f = l.strip().split()
      if is_def(l):
         #type0 = (struct|union|enum)
         self.type0 = f[index_of_def(l)]
         if index_of_def(l) + 2 == index_of_S(l):
            #decl = "my_struct_s"
            self.decl = f[index_of_def(l)+1]
      else:
         self.type0 = None
      i = l.find('{')
      if i != -1:
         self.body = l[i:]
      j = self.body.find('}')
      if j != -1:
         self.body = self.body[:j] # do not include '}'

      self.tostring("FIRST LINE")

   def last_line(self, fd, l, parent):
      if self.type0 == None:
         return
      i = l.find('}')
      i += 1 # include '}'
      #self.body += l[0:i]
      self.body += '}'
      self.end = fd.tell()
      f = l[i:].strip().split()
      if -1 != l.find('STRUCT_PACKED'):
         self.struct_packed = True
         f = f[1:] # strip 'STRUCT_PACKED'
      if len(f) >= 1:
         name = f[0]
         name = name[0:name.find(';')]
         self.name0 = name
         if name.find('[') != -1:
            name = name[0:name.find('[')]
         if name.find('*') != -1:
            name = name[name.find('*'):]
         self.name = name

      if self.decl == None:
         self.decl = self.name + "_in_" + parent + "_" + self.type0[0:1]

      self.tostring("LAST LINE")

   def append(self, l):
      self.body += l

   def get_decl(self):
      if self.type0 == None:
         return "MISSING_type0"
      if self.decl == None:
         return "MISSING_decl"
      if self.name == None:
         return "MISSING_name"
      return self.type0 + " " + self.decl + " " + self.name0 + ";"
   def get_typedef(self):
      #b = self.body.replace('\n',' ').strip().replace('\t',' ').replace('   ',' ')
      b = self.body
      if self.struct_packed:
         return "STRUCT_PACKED_START " + self.type0 + " " + self.decl + " " + b + " STRUCT_PACKED_END " + ";"
      else:
         return self.type0 + " " + self.decl + " " + b + ";"
   def tostring(self, title):
      print "----- %s ----" % title
      print "type0: '%s'" % self.type0
      print "decl:  '%s'" % self.decl
      print "name:  '%s'" % self.name
      print "name0: '%s'" % self.name0
      print "start:  %d" % (self.start)
      print "stop:   %d" % (self.end)
      print "body:   SSS%sEEE" % (self.body.replace('\n',' '))
      if self.type0:
         if self.decl:
            if self.name:
               print "----- decl will be ----"
               print self.get_decl()
               print "----- typedef will be ----"
               print self.get_typedef()
               print "----- typedef done ----"


def is_start(l):
   if l.find('{') > -1:
      return True
   return False

def is_end(l):
   if l.find('}') > -1:
      return True
   return False
#   for f in l.strip().split():
#      if f == "}":
#         return True
#      if f == "};":
#         return True
#   return False

def modify_and_swap(n,m,f,options):
#   print "-----MIWI----"
#   print "type0: '%s'" % n.type0
#   print "decl:  '%s'" % n.decl
#   print "name:  '%s'" % n.name
#   print "----- decl will be ----"
#   print n.get_decl()
#   print "----- typedef will be ----"
#   print n.get_typedef()
#   print "replace %d-%d" % (n.start,n.end)
#   print "insert typedef at %d" % (m.start)

   fin = open(options.infile,'r')
   fout = open("/tmp/asdf.h",'w')

   fout.write(fin.read(m.start))
   fout.write(n.get_typedef())
   fout.write("\n")

   fout.write(fin.read(n.start-m.start))

   fin.seek(n.end)
   fout.write("\t/* GENERATED */\n")
   fout.write("\t")
   fout.write(n.get_decl())
   fout.write("\n\n")

   again = True
   while again:
      d = fin.read(1000)
      if len(d) > 0:
         fout.write(d)
      else:
         again=False
   fin.close()
   fout.flush()
   fout.close()

   remove(options.infile)
   move("/tmp/asdf.h",options.infile)




def search_and_mod(options):
   fd = None
   m = None
   n = None
   line_count = 0
   b_count = 0
   fd = open(options.infile,'r')
   if fd == None:
      exit(3)
   while True:
      start = fd.tell()
      line = fd.readline()
      line_count += 1
      l = line.strip()
      f = l.split()
      start_or_end = False

      if is_start(l):
         b_count += 1
         print "%d: line_count %d" % (b_count,line_count)
         if m == None:
            m = S(start,line)
            start_or_end = True
         else:
            if n == None:
               n = S(start,line)
               start_or_end = True

      if is_end(l):
         b_count -= 1
         print "%d: line_count %d" % (b_count,line_count)
         if b_count == 0:
            n = None
            m = None
         if b_count == 1:
            start_or_end = True
            if m and n:
               m.tostring("PARENT")
               n.last_line(fd, indent_none(line), m.decl)
               n.tostring("CHILD")
               if n.type0:
                  if m:
                     # SAVE
                     fd.close()
                     fd = None
                     b_count = 0
                     modify_and_swap(n,m,f,options)
                     return True
            n = None

      if start_or_end == False and (b_count > 0):
         if n:
            n.append(indent_one(line))

      if len(line) == 0:
         return False



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

mod_count = 0
keep_running = True
while keep_running:
   again = search_and_mod(options)
   if again:
      mod_count += 1
   else:
      keep_running = False

   #if mod_count > 2:
   #   exit(3210)

print "all done %d mods done" % mod_count

