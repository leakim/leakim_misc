
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

struct linked_list {
   struct linked_list *next;
   int id;
};

int main()
{
   int i;
   char c = 'a';
   void *p = malloc(1);
   struct linked_list *first;
   struct linked_list *s;
   
   first = malloc(sizeof(struct linked_list));
   first->id = 0;
   s = first;
   for(i=0; i<5; i++)
   {
      s->next = malloc(sizeof(struct linked_list));
      s = s->next;
      s->id = i;
      s->next = NULL;
   }

   for(i=0; i<10; i++)
   {
      int d;
      if(c == 'z') c = 'a';
      c++;

      //SIGFPE at 5
      d = c/(i-5);
   }

   // SIGSEGV with libduma
   memcpy(p,main,1000);

   return 0;
}

