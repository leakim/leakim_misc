
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

#if 0
/* GCC */
#define UNUSED_D(_name) __attribute__ ((unused)) _name
#else
/* other */
#define UNUSED_D(_name) unused_##_name
#endif

int test_f(int UNUSED_D( arg ))
{
   return 0;
}

int main()
{
   int __attribute__((unused)) i;
   int UNUSED_D(a_var);

   test_f(4);

   return 0;
}
