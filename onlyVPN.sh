#!/bin/sh

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Applying secure tunnel rules ..."

#Allow loopback device (internal communication)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Allow all local traffic.
iptables -A INPUT -s 192.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 192.0.0.0/8 -j ACCEPT

iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT

#Allow docker

iptables -A INPUT -s 172.17.0.1/16 -j ACCEPT
iptables -A OUTPUT -d 172.17.0.1/16 -j ACCEPT


#make sure you can communicate with any DHCP server
iptables -A OUTPUT -d 255.255.255.0/24 -j ACCEPT 
iptables -A INPUT -s 255.255.255.0/24 -j ACCEPT

#vmware 
iptables -A OUTPUT -d 172.16.0.0/16 -j ACCEPT 
iptables -A INPUT -s 172.16.0.0/16 -j ACCEPT

#Allow PPTP VPN establishment
iptables -A OUTPUT -p tcp --dport 1723 -j ACCEPT
iptables -A INPUT -p tcp  --sport 1723 -j ACCEPT

#Allow OPENVPN establishment (set your vpn ip here)
iptables -A INPUT  -p tcp -s YOUR.OPENVPN.IP.HERE -j ACCEPT;
iptables -A OUTPUT -p tcp -d YOUR.OPENVPN.IP.HERE -j ACCEPT;

#Allow DNS requests
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

#Accept all TUN connections (tun = VPN tunnel)
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD  -i tun+ -j ACCEPT

#Accept all PPTP connections (ppp = VPN tunnel)
iptables -A OUTPUT -o ppp+ -j ACCEPT
iptables -A INPUT -i ppp+ -j ACCEPT

iptables -A INPUT -p gre -j ACCEPT
iptables -A OUTPUT -p gre -j ACCEPT

#Set default policies to drop all communication unless specifically allowed
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "Enjoy, don't forget to run iptables-persistent!"
