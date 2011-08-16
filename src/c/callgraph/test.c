
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

/* 
 * http://www.ohse.de/uwe/articles/gcc-attributes.html#func-section 
 *
 * http://www.esacademy.com/automation/docs/c51primer/c08.htm
 */


int func1(void)
{
   return 0;
}

int func2(void)
{
   func1();
   return 1;
}

int main()
{
   func1();
   func2();
   return 0;
}
