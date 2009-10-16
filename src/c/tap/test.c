
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>
#include <errno.h>

#include <sys/time.h>

#include "tun_dev.h"

/* http://www.gnu.org/s/libc/manual/html_node/Server-Example.html#Server-Example */

int main_loop(int fd, char *dev)
{
   fd_set readset;
   int tx_count = 0;
   int rx_count = 0;
   int loop = 1;
   struct timeval timeout = 
   {
      5,
      100*1000 // us
   }; 

   FD_ZERO(&readset);
   FD_SET(fd, &readset);

   while (loop)
   {
      char buf[2000];
      int result;
      int s;


      result = select(FD_SETSIZE, &readset, NULL, NULL, &timeout);

      if (result == 0)
      {
         /* timeout */

         /* XXX */
         usleep(100*1000);
      }
      if (result == -1)
      {
         if(errno == EINTR)	/* Interrupted system call */
         {
            /* gprof? keep on going */
         } else {
            perror("select");
         }
      }
      if (result < -1)
      {
         printf("result: %d errno: %d\n", result, errno);
         perror("select");
         return -__LINE__;
      }
      if (result > 0)
      {
         s = read(fd, buf, sizeof(buf));
         if (s>0)
         {
            rx_count++;
            printf("rx pkt[%d] size: %d\n", rx_count, s);
            printbuf("rx: ", buf, s);

            tx_count++;
            s = write(fd, buf, s);
            buf[6] = 0xab;
            buf[7] = 0xcd;
            printf("tx pkt[%d] wrote: %d\n", tx_count, s);

            if (rx_count>10)
               loop = 0;
         }
      }
   }
   return 0;
}

int main()
{
   char dev[14] = "nano_net%d";
   int fd;
   int err;

   fd = tap_open(dev);

   if (fd<0)
      return -__LINE__;

   printf("dev %s fd: %d\n", dev, fd);

   usleep(1000*1000*1);

   err = tun_set_if(dev, 1);
   if (err < 0)
      return -__LINE__;

   main_loop(fd, dev);

   err = tun_set_if(dev, 0);
   tap_close(fd, dev);

   return 0;
}
