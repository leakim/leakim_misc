#!/usr/bin/perl -w

use strict; 

# First, set the standard output to auto-flush 


select((select(STDOUT), $| = 1)[0]); 

# And loop 5000 times, printing values... 

my $offset = 1.5; 
while(1) 
{ 
   print "0:".sin($offset)."\n"; 
   print "1:".cos($offset)."\n"; 
   #print sin($offset)." ".cos($offset)."\n"; 
   $offset += 0.1; 
   if ($offset > 500) 
   { 
      last; 
   } 
   system("sleep 0.02") == 0  or last; 
} 

