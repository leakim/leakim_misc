
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

int main()
{
   char *s = "hello world";
   *s = 'H';

   return 0;
}

