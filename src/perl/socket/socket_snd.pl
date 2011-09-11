
use strict;
use IO::Socket;

my $sock = new IO::Socket::INET (
	PeerAddr => 'localhost',
	PeerPort => '7070',
        Proto => 'udp',
        #Proto => 'tcp',
	);

die "Could not create socket; $!\n" unless $sock;

print $sock "hello there!\n";

close($sock);

