
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include <execinfo.h>

static char* stack_trace(void)
{
    void *array[128];
    size_t size;
    char **strings;
    size_t i;
    size_t str_len = 0;
    char *str = NULL;
    char *result = NULL;
  
    size = backtrace (array, 32);
    strings = backtrace_symbols(array, size);
  
    for (i = 0; i < size; i++)
       str_len += strlen(strings[i]) + 1;

    str = malloc(str_len+10);
    result = str;

    for (i = 0; i < size; i++)
       str += sprintf(str,"%s\n", strings[i]);
  
    free (strings);
    //printf(":::%s:::",result);
    return result;
}

void testf(void)
{
   char *st;

   st = stack_trace();
   printf("%s",st);
   free(st);
}


int main()
{
   testf();

   return 0;
}


