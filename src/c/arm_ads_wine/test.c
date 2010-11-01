
#include <assert.h>

int main()
{
   struct foo {
      char a;
      char b;
   } s;

   printf("This will pass\n");
   assert(sizeof(s)==2);

   printf("This will crach\n");
   assert(sizeof(s)==3);

   return 0;
}
