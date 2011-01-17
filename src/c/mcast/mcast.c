
#include <arpa/inet.h>
#include <netinet/in.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

int
main(int argc, char **argv)
{
   int sd;
   struct sockaddr_in myaddr;
   const char *group = argv[1];
   const char *message = argv[2];
#if 0
   int enable = 0; // packet must be recieved by the some external network and not from ourself
#else
   int enable = 1; // Allow looping through the kernel
#endif

   sd = socket(AF_INET, SOCK_DGRAM, 0);
   if (sd < 0) {
      perror("socket");
      return 1;
   }

   if (setsockopt(sd, IPPROTO_IP, IP_MULTICAST_LOOP, &enable, sizeof enable) < 0) {
      perror("IP_MULTICAST_LOOP");
   }

   if (argc < 2) {
      printf("Missing parameters\n");
      return 1;
   }

   memset(&myaddr, 0, sizeof myaddr);
   myaddr.sin_family = AF_INET;
   myaddr.sin_addr.s_addr = inet_addr(group);
   myaddr.sin_port = htons(5555);

   if (argc == 2) {
      char buf[512];
      struct sockaddr_in peer;
      socklen_t alen = sizeof peer;
      struct ip_mreq mreq;
      ssize_t n;
      int err;

      printf("Binding to %s\n", inet_ntoa(myaddr.sin_addr));
      if (bind(sd, (struct sockaddr *)&myaddr, sizeof myaddr) < 0) {
         perror("bind");
         return 1;
      }

      mreq.imr_multiaddr.s_addr = myaddr.sin_addr.s_addr;
      mreq.imr_interface.s_addr = INADDR_ANY;
      err = setsockopt(sd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof mreq);
      if (err < 0) {
         perror("IP_ADD_MEMBERSHIP");
      }

      printf("Waiting for message...\n");
      {
         struct pollfd pfd;
         pfd.fd = sd;
         pfd.events = POLLIN;
         int timeout = -1;

         while (poll(&pfd, 1, timeout) > 0) {
            n = recvfrom(sd, buf, sizeof buf, 0, (struct sockaddr *)&peer, &alen);
            if (n < 0) {
               perror("recvfrom");
            } else {
               printf("Received multicast from %s: %s\n", inet_ntoa(peer.sin_addr), buf);
            }
            timeout = 1000;
         }
      }
   }
   else {
      ssize_t n;
      printf("Sending to %s\n", inet_ntoa(myaddr.sin_addr));
      n = sendto(sd, message, strlen(message), 0, (struct sockaddr *)&myaddr, sizeof myaddr);
      printf("sendto() = %d\n", n);
   }

   close(sd);
   return 0;
}
