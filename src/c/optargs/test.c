
#include <unistd.h> /* getopt(), optopt, optind */
#include <string.h> /* strchr(), strlen() */
#include <stdio.h>  /* printf(), fprintf(), sscanf() */
#include <stdlib.h> /* exit() */

int debug = 0;

void config_set_str_var(char* name, char* str_val)
{
   printf("%s = \"%s\" (%d)\n", name, str_val, strlen(str_val));
}

void config_set_int_var(char* name, int val)
{
   printf("%s = %d (0x%x)\n", name, val, val);
}

int config_optarg_vars(int argc, char *argv[])
{
   extern char *optarg;
   extern int optind, optopt;
   char* name;
   char *p;
   char c;

   /* Ex:
    * -d count=2 
    * -d hex=0x20 
    * -d negative=-1 
    * -s name_including_spaces="m i k a e l" 
    * -s empty_string=""
    */
   while ((c = getopt(argc, argv, "s:d:v")) != -1)
   {
      int val;
      int r = 0;

      name = optarg;
      p = strchr(name, '=');
      if(p != NULL)
      {
         *p++ = '\0';
         switch (c)
         {
            case 'v':
               debug++;
               break;
            case 's':
               if( !(strlen(name) > 0 && strlen(p) >= 0) )
               {
                  goto optarg_fail;
               }
               config_set_str_var(name, p);
               break;
            case 'd':
               r = 0;
               if(r != -1) r = sscanf(p,"%d", &val);
               if(r != -1) r = sscanf(p,"%x", &val);
               if(r == -1)
               {
                  goto optarg_fail;
               }
               config_set_int_var(name, val);
               break;
         } /* switch */
      }
   } /* while */

   return 0;

optarg_fail:
   fprintf(stderr, "optarg %s=%s can not be interpreted"
         " by %%d or %%x\n", name, p);
   exit(__LINE__);
   return __LINE__;
}

int main(int argc, char *argv[])
{
   config_optarg_vars(argc, argv);

   return 0;
}

