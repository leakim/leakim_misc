use strict;
use IO::Socket;

# nc 127.0.0.1 7070

my $sock = new IO::Socket::INET (
#	LocalHost => 'myLHost',
	LocalPort => '7070',
	Proto => 'tcp',
	Listen => 1,
	Reuse => 1,
	);

die "Could not create socket; $!\n" unless $sock;

my $new_sock = $sock->accept();

while(<$new_sock>)
{
	print $_;
}

close($sock);

