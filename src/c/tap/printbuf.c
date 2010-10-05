
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <poll.h>
#include <err.h>
#include <sys/time.h>

#include <assert.h>

void printbuf(const char *prefix, const void *data, size_t len)
{
   int i, j;
   const unsigned char *p = data;

   if (len > 32)
      len = 32;

   for (i = 0; i < len; i += 16)
   {
      printf("%s: %04x : ", prefix, i);
      for (j = 0; j < 16; j++)
      {
         if (i + j < len)
            printf("%02x ", p[i+j]);
         else
            printf("   ");
      }
      printf(": ");
      for (j = 0; j < 16; j++)
      {
         if (i + j < len)
         {
            if (isprint((int)p[i+j]))
               printf("%c", p[i+j]);
            else
               printf(".");
         }
      }
      printf("\n");
   }
}

