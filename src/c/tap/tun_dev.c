/* $Id: $ */

//#include "config.h"

#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <syslog.h>
#include <errno.h>

#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/if.h>

#include <linux/in.h>

#include <linux/if_tun.h>

#include "tun_dev.h"

static int tun_open_common(char *dev, int istun)
{
   struct ifreq ifr;
   int fd;

   if ((fd = open("/dev/net/tun", O_RDWR)) < 0)
   {
      fprintf(stderr,"err opening: %d",fd);
      return -__LINE__;
   }

   memset(&ifr, 0, sizeof(ifr));
   ifr.ifr_flags = (istun ? IFF_TUN : IFF_TAP) | IFF_NO_PI;
   if (*dev)
      strncpy(ifr.ifr_name, dev, IFNAMSIZ);

   if (ioctl(fd, TUNSETIFF, (void *) &ifr) < 0)
   {
      close(fd);
      return -__LINE__;
   }

   strcpy(dev, ifr.ifr_name);
   return fd;
}

static int set_flag(int fd, char *ifname, short flag)
{
   struct ifreq ifr;

   strncpy(ifr.ifr_name, ifname, IFNAMSIZ);
   if (ioctl(fd, SIOCGIFFLAGS, &ifr) < 0)
   {
      fprintf(stderr, "%s: ERROR while getting interface flags: %s\n",
              ifname, strerror(errno));
      return -__LINE__;
   }
   strncpy(ifr.ifr_name, ifname, IFNAMSIZ);
   ifr.ifr_flags |= flag;
   if (ioctl(fd, SIOCSIFFLAGS, &ifr) < 0)
   {
      perror("SIOCSIFFLAGS");
      return -__LINE__;
   }
   return (0);
}


int tun_set_if(char *dev, int up)
{
   int flags = IFF_UP;
   int skfd;
   int s;

   if (up)
      flags |= IFF_RUNNING;

   if ((skfd = socket(PF_INET, SOCK_DGRAM, 0)) < 0)
      return -1;

   s = set_flag(skfd, dev, flags);
   close(skfd);
   return s;
}

int tun_open(char *dev) { return tun_open_common(dev, 1); }
int tap_open(char *dev) { return tun_open_common(dev, 0); }

int tun_close(int fd, char *dev) { return close(fd); }
int tap_close(int fd, char *dev) { return close(fd); }

int tun_write(int fd, char *buf, int len) { return write(fd, buf, len); }
int tap_write(int fd, char *buf, int len) { return write(fd, buf, len); }

int tun_read(int fd, char *buf, int len) { return read(fd, buf, len); }
int tap_read(int fd, char *buf, int len) { return read(fd, buf, len); }
