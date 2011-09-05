
#ifndef __cli_server_h__
#define __cli_server_h__

struct cli_server_ctx;

typedef void (*cli_server_cmd_cb_t)(char *in, int len);

struct cli_server_ctx* cli_server_init(int listen_port);

void cli_server_non_blocking_run(struct cli_server_ctx *ctx, cli_server_cmd_cb_t cb);
void cli_server_send(struct cli_server_ctx *ctx, char *buf, int nbytes);

#endif /* __cli_server_h__ */

