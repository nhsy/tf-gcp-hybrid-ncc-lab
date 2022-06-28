#!/bin/bash
set -xe

exec &> >(tee -a /var/log/metadata_startup.log)
echo "metadata_startup_start"

# Add routing for nic1 - hub
echo "1    hub" | tee -a /etc/iproute2/rt_tables
ip route add ${hub_ip} src ${hub_ip} dev ens5 table hub
ip route add default via ${hub_gw} dev ens5 table hub
ip rule add from ${hub_ip}/32 table hub
ip rule add to ${hub_ip}/32 table hub
ip rule show

# Add iptables masquerade for peered networks
iptables -t nat -A POSTROUTING -o ens4 -s ${peered_networks_cidr_range} -j MASQUERADE
#ip route add 10.72.0.0/22 via ${hub_gw} dev ens5

if [ -f /var/log/metadata_startup_complete ];then
  echo "metadata_startup_skipped"
  exit 0
fi

apt install -y \
  frr \
  htop \
  vim \
  tcpdump \
  traceroute

cat >/etc/network/interfaces.d/loopback <<EOF
auto lo:0
iface lo:0 inet static
  address 192.168.192.168
  netmask 255.255.255.255
EOF

ifup lo:0

# Enable ip forwarding and martian routing
sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sed -i "s/^#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=2/" /etc/sysctl.conf
sed -i "s/^#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=2/" /etc/sysctl.conf
sysctl -p

sed -i "s/^bgpd=no/bgpd=yes/" /etc/frr/daemons

cat >/etc/frr/frr.conf <<EOF
frr version 7.5.1
frr defaults traditional
hostname appliance-fw1
log syslog
no ipv6 forwarding
service integrated-vtysh-config
!
ip router-id ${router_id}
!
router bgp ${local_asn}
 neighbor V4 peer-group
 neighbor V4 remote-as ${peer_asn}
 neighbor ${peer_ip1} peer-group V4
 neighbor ${peer_ip1} default-originate
 neighbor ${peer_ip1} soft-reconfiguration inbound
 neighbor ${peer_ip1} disable-connected-check
 neighbor ${peer_ip2} peer-group V4
 neighbor ${peer_ip2} default-originate
 neighbor ${peer_ip2} soft-reconfiguration inbound
 neighbor ${peer_ip2} disable-connected-check
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor V4 route-map IMPORT in
  neighbor V4 route-map EXPORT out
 exit-address-family
!
ip prefix-list default_route seq 10 permit 0.0.0.0/0
ip prefix-list peering_routes seq 10 permit 10.64.0.0/12 le 32
!
route-map EXPORT permit 10
 match interface lo
!
route-map EXPORT permit 20
 match ip address prefix-list default_route
!
route-map EXPORT deny 100
!
route-map IMPORT deny 10
 match ip address prefix-list default_route
!
route-map IMPORT permit 20
 match ip address prefix-list peering_routes
!
route-map IMPORT deny 100
!
line vty
!
EOF

systemctl restart frr

touch /var/log/metadata_startup_complete
echo "metadata_startup_end"