#!/usr/bin/env python
import signal
import sys

def signal_handler(signal, frame): 
   print 'You pressed Ctrl+C!' 
   sys.exit(0) 

signal.signal(signal.SIGINT, signal_handler) 
print 'Press Ctrl+C' 
signal.pause()
#while 1: pass
