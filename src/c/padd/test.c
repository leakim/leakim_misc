
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h> 


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

typedef struct s_unaligned_
{
   char m1_c; /* unaligned */
   int  m2_i;
   char m3_c; /* unaligned */
} s_unaligned;

typedef struct s_with_unaligned_s_array_
{
   char m1_c; /* unaligned */
   int  m2_count;
   s_unaligned m3_unaligned_s[1]; /* growable */
} s_with_unaligned_s_array;

int main()
{
   s_t s;
   sp_t sp;
   s_t *sp_p;

   printf("size: 4+1+0=5==%u\n",sizeof(s));
   printf("size: 4+1+0=5==%u\n",sizeof(sp));

   printf("offset: 4+1+0=5==%u\n",
         ((uintptr_t) &sp.more[0] - (uintptr_t)&sp));
   printf("offset: 4+4+0=5==%u (padding is part of more[0]\n",
         ((uintptr_t) &s.more[0] - (uintptr_t)&s));

   sp_p = (s_t*)malloc(sizeof(*sp_p)+10);
   memset(sp_p->more,0,10);

   free(sp_p);

   printf("-------------\n");

   printf("size of member %s: 1+4+1=6 or 4+4+4=12 ? Z=%u\n", 
      "s_unaligned", 
      sizeof(s_unaligned));

   printf("size of %s: 1+4+Z or 4+4+Z? Y=%u\n", 
         "s_with_unaligned_s_array",
         sizeof(s_with_unaligned_s_array));

   printf("size of %s: with 3 members? 1+4+2*Y or 4+4+2*Y? X=%u\n", 
         "s_with_unaligned_s_array",
         sizeof(s_with_unaligned_s_array) +  (3-1)*sizeof(s_unaligned));

   return 0;
}
