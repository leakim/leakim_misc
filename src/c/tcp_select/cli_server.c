#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <unistd.h>

#include "cli_server.h"

//#define CLI_SERVER_DEBUG

struct cli_server_ctx {
   /* master file descriptor list */
   fd_set master;

   /* listening socket descriptor */
   int listener;

   /* maximum file descriptor number */
   int fdmax;
};

struct cli_server_ctx* cli_server_init(int listen_port)
{
   struct cli_server_ctx *ctx;

   /* server address */
   struct sockaddr_in serveraddr;

   int yes = 1;

   ctx = malloc(sizeof(struct cli_server_ctx));

   /* clear the master and temp sets */
   FD_ZERO(&ctx->master);
   /* get the listener */
   if ((ctx->listener = socket(AF_INET, SOCK_STREAM, 0)) == -1)
   {
      perror("Server-socket() error lol!");
      /*just exit lol!*/
      exit(1);
   }
   printf("Server-socket() is OK...\n");
   /*"address already in use" error message */
   if (setsockopt(ctx->listener, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
   {
      perror("Server-setsockopt() error lol!");
      exit(1);
   }
   printf("Server-setsockopt() is OK...\n");
   /* bind */
   serveraddr.sin_family = AF_INET;
   serveraddr.sin_addr.s_addr = INADDR_ANY;
   serveraddr.sin_port = htons(listen_port);
   memset(&(serveraddr.sin_zero), '\0', 8);
   if (bind(ctx->listener, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) == -1)
   {
      perror("Server-bind() error lol!");
      exit(1);
   }
   printf("Server-bind() is OK...\n");
   /* listen */
   if (listen(ctx->listener, 10) == -1)
   {
      perror("Server-listen() error lol!");
      exit(1);
   }
   printf("Server-listen() is OK...\n");
   /* add the listener to the master set */
   FD_SET(ctx->listener, &ctx->master);
   /* keep track of the biggest file descriptor */
   ctx->fdmax = ctx->listener; /* so far, it's this one*/
   /* loop */
   return ctx;
}

/* this will not truncate commands */
void pars_incomming_data(
      struct cli_server_ctx *ctx,
      cli_server_cmd_cb_t cb,
      char *in, int len)
{
   int i,j;
   int l;
   i = 0;
   j = 0;
   for(; j < len; j++)
   {
      if(in[j] == '\n')
      {
         in[j] = 0;
         l = strlen(&in[i]);
         if(l > 0)
            (*cb)(&in[i], l);
         i = j+1;
      }
   }
   if(i != j)
   {
      l = strlen(&in[i]);
      if(len > 0)
         (*cb)(&in[i], l);
   }
}


void cli_server_non_blocking_run(struct cli_server_ctx *ctx, cli_server_cmd_cb_t cb)
{
   /* temp file descriptor list for select() */
   fd_set read_fds;

   /* client address */
   struct sockaddr_in clientaddr;

   int addrlen;

   /* newly accept()ed socket descriptor */
   int newfd;

   int i;

   int nbytes;
   char buf[1024];

   struct timeval timeout;

   memset(&timeout,0,sizeof timeout); // don't block

   FD_ZERO(&read_fds);

   /* copy it */
   read_fds = ctx->master;

   if (select(ctx->fdmax+1, &read_fds, NULL, NULL, &timeout) == -1)
   {
      perror("Server-select() error lol!");
      exit(1);
   }
#ifdef CLI_SERVER_DEBUG
   printf("Server-select() is OK...\n");
#endif
   /*run through the existing connections looking for data to be read*/
   for (i = 0; i <= ctx->fdmax; i++)
   {
      if (FD_ISSET(i, &read_fds))
      { /* we got one... */
         if (i == ctx->listener)
         {
            /* handle new connections */
            addrlen = sizeof(clientaddr);
            if ((newfd = accept(ctx->listener, (struct sockaddr *)&clientaddr, &addrlen)) == -1)
            {
               perror("Server-accept() error lol!");
            }
            else
            {
#ifdef CLI_SERVER_DEBUG
               printf("Server-accept() is OK...\n");
#endif
               FD_SET(newfd, &ctx->master); /* add to master set */
               if (newfd > ctx->fdmax)
               { /* keep track of the maximum */
                  ctx->fdmax = newfd;
               }
               printf("New connection from %s on socket %d\n", inet_ntoa(clientaddr.sin_addr), newfd);
            }
         }
         else
         {
            /* handle data from a client */
            if ((nbytes = recv(i, buf, sizeof(buf), 0)) <= 0)
            {
               /* got error or connection closed by client */
               if (nbytes == 0)
                  /* connection closed */
                  printf("socket %d hung up\n", i);
               else
                  perror("recv() error lol!");
               /* close it... */
               close(i);
               /* remove from master set */
               FD_CLR(i, &ctx->master);
            }
            else
            {
               if(nbytes>0)
               {
                  buf[nbytes-1] = 0;
               }
#ifdef CLI_SERVER_DEBUG
               printf("recv %d bytes \"%s\"\n", nbytes, buf);
#endif

               pars_incomming_data(ctx, cb, buf, nbytes);
            }
         }
      }
   }
}

void cli_server_send(struct cli_server_ctx *ctx, char *buf, int nbytes)
{
   int i, j;

   /* we got some data from a client*/
   for (j = 0; j <= ctx->fdmax; j++)
   {
      /* send to everyone! */
      if (FD_ISSET(j, &ctx->master))
      {
         /* except the listener and ourselves */
         //if (j != ctx->listener && j != i)
         if (j != ctx->listener)
         {
            if (send(j, buf, nbytes, 0) == -1)
               perror("send() error lol!");
         }
      }
   }
}

