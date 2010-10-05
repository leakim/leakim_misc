
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

typedef struct sp_s {
   uint32_t u32;
   uint8_t u8;
   char more[0];
} __attribute__((__packed__)) sp_t; 

typedef struct s_s {
   uint32_t u32;
   uint8_t u8;
   char more[0];
} s_t; 


s_t __attribute__ ((section (".debug_miwi"))) g_s; 

int main()
{
   s_t s;
   sp_t sp;
   s_t *sp_p;
   int i;

   printf("size: 4+1+0=5==%u\n",sizeof(s));
   printf("size: 4+1+0=5==%u\n",sizeof(sp));

   printf("offset: 4+1+0=5==%u\n",
         ((uintptr_t) &sp.more[0] - (uintptr_t)&sp));
   printf("offset: 4+4+0=5==%u (padding is part of more[0]\n",
         ((uintptr_t) &s.more[0] - (uintptr_t)&s));

   sp_p = (s_t*)malloc(sizeof(*sp_p)+10);
   memset(sp_p->more,0,10);

   free(sp_p);

   printf("gs: %p s: %p\n",&g_s,&s);

   for(i=0; i < 4; i++)
   {
      printf("%d: %d %x %x\n",
            i,
            (1<<i),
            (1<<i),
            (1<<i)
            );
   }

   return 0;
}
