use strict;
use IO::Socket;

#
# echo "hello" | nc -q1 -u 127.0.0.1 7070
#

my $sock = new IO::Socket::INET -> new(
	LocalPort => '7070',
	Proto => 'udp',
	);

die "Could not create socket; $!\n" unless $sock;

my $user;
my $dgram;
my $max_to_read = 2047;

while($user = $sock->recv($dgram, $max_to_read))
{
	printf "---\n";
	printf $dgram
}

close($sock);

