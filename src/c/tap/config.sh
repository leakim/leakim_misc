INTERFACE=tap0

# Set hardware ethernet address, needed on Linux when in router mode
ifconfig $INTERFACE hw ether fe:fd:0:0:0:0

# Give it the right ip and netmask. Remember, the subnet of the
# tap device must be larger than that of the individual Subnets
# as defined in the host configuration file!
ifconfig $INTERFACE 192.168.1.7 netmask 255.255.255.0

# Disable ARP, needed on Linux when in router mode
ifconfig $INTERFACE -arp

#Add a route to the other network
route add -net 192.168.2.0 netmask 255.255.255.0 dev $INTERFACE


