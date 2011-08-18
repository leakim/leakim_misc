
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>

#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h> // execl
#include <sys/wait.h>

#define FALSE 0

static void blocking_wait_on_child(pid_t pid)
{
   int child_exit_status;
   pid_t ws;

   fprintf(stderr,"will now wait for child to complete\n");

   //ws = waitpid( pid, &child_exit_status, WNOHANG);
   ws = waitpid(pid, &child_exit_status, 0);
   fprintf(stderr,"child is now complete\n");

   if ( !WIFEXITED(child_exit_status) )
   {
      fprintf(stderr,"waitpid() exited with an error: Status=%d\n",
              WEXITSTATUS(child_exit_status));
   }
   else if ( WIFSIGNALED(child_exit_status) )
   {
      fprintf(stderr,"waitpid() exited due to a signal: %d\n",
              WTERMSIG(child_exit_status));
   }
}

int fork_exec(
   const char *cmd,
   int wait,
   pid_t *pid_p)
{
   pid_t pid;

   fprintf(stdout,"will now do fork and run \"%s\"\n", cmd);

   pid = vfork();
   if (pid == 0) // child
   {
      execl("/bin/bash", "/bin/bash", "-c", cmd, NULL);
   }
   else if (pid < 0) // failed to fork
   {
      fprintf(stderr,"failed to fork\n");
      exit(1);
   }
   else // parent
   {
      if (wait) {
         blocking_wait_on_child(pid);
      } else {
         fprintf(stderr,"(child had PID: %d)\n", pid);
         *pid_p = pid;
      }
   }

   return 0;
}

int main(int argc, char argv[])
{
   pid_t pid[10];

   fork_exec("ping 127.0.0.1", FALSE, &pid[0]);
   fork_exec("ping 127.0.0.1", FALSE, &pid[1]);

   /* lacy */
   if(argc == 1)
      sleep(2);
   else
      sleep(60*60); // 1h

   kill(pid[0],SIGTERM);
   kill(pid[1],SIGKILL);
   blocking_wait_on_child(pid[0]);
   blocking_wait_on_child(pid[1]);

   return 0;
}
