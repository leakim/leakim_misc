
#if 0
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <malloc.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 *
 * http://www.debian-administration.org/articles/408
 *
 * more
 *
 * http://www.trl.ibm.com/projects/security/ssp/node4.html
 *
 *
 */

int smash2(char *src)
{
   char static_buf_on_stack[32];

   strcpy(static_buf_on_stack, src);

   return 2;
}

int smash1(char *src)
{
   char static_buf_on_stack[32];
   
   strcpy(static_buf_on_stack, src);

   smash2(src);

   return 1;
}

int main( int argc, char *argv[] )
{
   if ( argc != 2 )
   {
      printf("Usage: %s argument\n", argv[0] );
      return( -1 );
   }
 
   smash1(argv[1]);

   printf( "Copied argument\n" );

   return(0);
}
