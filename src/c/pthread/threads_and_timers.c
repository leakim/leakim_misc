#include <pthread.h>
#include <stdio.h>

pthread_spinlock_t lock;

/* call back function - inform the user the time has expired */
void timeout_cb()
{
   printf("=== your time is up ===\n");
}

/* Go to sleep for a period of seconds */
static void* g_start_timer(void *args)
{
   /* function pointer */
   void (*function_pointer)();

   printf("3\n");
   sleep(1);
   pthread_spin_lock(&lock);
   printf("5\n");
   sleep(1);

   /* cast the seconds passed in to int and
    * set this for the period to wait */
   int seconds = *((int*) args);
   printf("go to sleep for %d\n", seconds);

   /* assign the address of the cb to the function pointer */
   function_pointer = timeout_cb;

   sleep(seconds);
   /* call the cb to inform the user time is out */
   (*function_pointer)();

   pthread_exit(NULL);
}

int main()
{
   pthread_t thread_id;
   int seconds = 3;
   int rc;

   printf("will init\n");
   pthread_spin_init(&lock, -1);

   printf("1\n");
   pthread_spin_lock(&lock);
   sleep(1);
   printf("2\n");


   rc =  pthread_create(&thread_id, NULL, g_start_timer, (void *) &seconds);
   if (rc)
      printf("=== Failed to create thread\n");

   printf("4\n");
   pthread_spin_unlock(&lock);
   sleep(1);
   if(0 != pthread_spin_trylock(&lock))
   {
      printf("6 failed to get trylock, as expected\n");
   }

#if 0
#endif
   pthread_join(thread_id, NULL);

   printf("=== End of Program - all threads in ===\n");

   return 0;
}

