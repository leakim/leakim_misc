
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>


typedef struct s_s {
   uint32_t a;
   uint32_t b;
   char more[100];
} s_t; /* size: 100+4+4=108 */

/* size 19 (require sizeof(s_t) stack) */
void func_arg(s_t s)
{
   /* 
    * s will reside on the stack and will be a separate copy
    * the variable assignment will not remain after return; 
    */
   s.a = 3;
   s.b = 4;
   return;
}

/* size 24 */
void func_p_arg(s_t *s)
{
   /*
    * asignment using pointers takes more spaces as addr's
    * have to be loaded into registeres before assignment
    */
   s->a = 5;
   s->b = 6;
   return;
}

int main()
{
   s_t s = {1,2};

   printf("a: %d b: %d\n",s.a, s.b);

   func_arg(s);
   printf("a: %d b: %d (after func_arg)\n",s.a, s.b);

   func_p_arg(&s);
   printf("a: %d b: %d after (func_p_arg)\n",s.a, s.b);

   return 0;
}

