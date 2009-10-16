
int tun_set_if(char *dev, int up);

int tap_open(char *dev);
int tap_close(int fd, char *dev);

int tap_write(int fd, char *buf, int len);
int tap_read(int fd, char *buf, int len);

void printbuf(const char *prefix, const void *data, size_t len);

