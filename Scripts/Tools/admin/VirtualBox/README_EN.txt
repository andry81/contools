* README_EN.txt
* 2023.03.01
* contools/admin/VirtualBox

1. DESCRIPTION
2. VM shared VPN setup
2.1. win7-host-VPN with port forwading for win7-guest-application
2.2. win7-guest-VPN with port forwading for another win7-guest-application
1.2. win7-host-VPN with port forwading for win7-guest-application
3. KNOWN ISSUES
3.1 Internet still is not reachable from the target guest

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
VirtualBox setup for different VPN configurations.

-------------------------------------------------------------------------------
2. VM shared VPN setup
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
2.1. win7-host-VPN with port forwading for win7-guest-application
-------------------------------------------------------------------------------

1. Create NAT Network of name `MyApp` with these major parameters:

  * Network CIDR: 192.168.200.0/24
  * [x] Supports DHCP

Port Fowarding Rules:

Name      | Protocol | Host IP |Host Port | Guest IP      | Guest Port
          +          +         |          +               +
Host IP   | TCP      |         | 12345    | 192.168.200.5 | 12345
Host IP U | UDP      |         | 12345    | 192.168.200.5 | 12345

, where:

  12345 - application port you want to forward
  192.168.200.5 - application ip address in the guest

Note:
  Guest IP can be different because of DHCP enabled.

2. Use `MyApp` NAT Network adapter in the guest

3. After VM NAT Network adapter is enabled and used:

Add `VBoxNetNAT.exe` and `VBoxNetDHCP.exe` process into VPN split tunneling
list to use VPN only mode.

This must be supported by your VPN provider in the VPN UI software.

-------------------------------------------------------------------------------
2.2. win7-guest-VPN with port forwading for another win7-guest-application
-------------------------------------------------------------------------------

1. Create VirtualBox Host-Only Ethernet Adapter or use already existed.

Go to `File -> Host Network Manager` and add the adapter if not added yet or
use already existed with these parameters:

  [x] Configure Adapter Manually

  IPv4 Address:       192.168.100.1
  IPv4 Network Mask:  255.255.255.0

  [ ] DHCP Server (disabled)

2. For win7-guest-application:

For `Adapter 1`:

  Attached to:      Host-only Adapter
  Name:             VirtualBox Host-Only Ethernet Adapter
  Promiscuous Mode: Allow All
  [x] Cable Connected

  Use these IPv4 configuration for the adapter:

  IP address:             192.168.100.6
  Subnet Mask:            255.255.255.0
  Default Gateway:        192.168.100.5

  Preffered DNS server:   192.168.100.5

2. For win7-guest-VPN:

For `Adapter 1`:

  Attached to:      NAT

  Use these IPv4 configuration for the adapter:

  [x] Obtain an IP address automatically
  [x] Obtain DSN server address automatically

For `Adapter 2`:

  Attached to:      Host-only Adapter
  Name:             VirtualBox Host-Only Ethernet Adapter
  Promiscuous Mode: Allow All
  [x] Cable Connected

  Use these IPv4 configuration for the adapter:

  IP address:             192.168.100.5
  Subnet Mask:            255.255.255.0
  Default Gateway:        192.168.100.6

  [x] Obtain DSN server address automatically

For VPN Adapter:

  Properties->Sharing:
    [x] Allow other network users to connect through this computer's Internet connection
    Home networking connection: Adapter 2

  Note:
    After enabled you must reset (setup again) the IPv4 configuration for the
    `Adapter 2`.

Add port fowarding using the netsh:

  >
  netsh interface portproxy add v4tov4 listenport=12345 listenaddress=0.0.0.0 connectaddress=192.168.100.6 connectport=12345 protocol=tcp

  , where 12345 - port you want to forward into win7-guest-application

To test port forwarding:

  >
  netstat -ano | findstr :12345

CAUTION:
  With the netsh you can setup only the TCP port forwarding. For the UDP you
  have to use an external application software.

-------------------------------------------------------------------------------
3. KNOWN ISSUES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
3.1 Internet still is not reachable from the target guest
-------------------------------------------------------------------------------

Try to switch off and on related VM network interfaces including OS interfaces.
