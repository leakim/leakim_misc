
#include <stdio.h>
#include <string.h>

#include "cli_server.h"

int shutdown = 0;

void cli_server_cmd(char *in, int len)
{
   printf("%s: Got command from client: %s (len %d)\n", __func__, in, len);

   if(0 == strcmp("shutdown", in))
   {
      shutdown++;
   }
}

// echo shutdown | nc 127.0.0.1 2020

int main()
{
   struct cli_server_ctx *ctx;

   ctx = cli_server_init(2020);

   while (!shutdown)
   {
      char *m = "unsolicited event from server to all clients\n";
      cli_server_send(ctx, m, strlen(m));

      cli_server_non_blocking_run(ctx, &cli_server_cmd);

      sleep(1);
      printf(".");
   }

   return 0;
}

