/*
MIT License

Copyright (c) 2015 Mark Ellis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

class iptables::ip4defaults ( $purge_output = false ) {
  Firewall {
    require => undef,
  }

  firewallchain { 'INPUT:filter:IPv4':
    ensure => present,
    purge  => true,
  }->
  firewallchain { 'FORWARD:filter:IPv4':
    ensure => present,
    purge  => true,
  }->
  firewallchain { 'OUTPUT:filter:IPv4':
    ensure => present,
    purge  => $purge_output,
  }->
  firewallchain { 'TCP:filter:IPv4':
    ensure  => present,
    purge  => true,
  }->
  firewallchain { 'UDP:filter:IPv4':
    ensure  => present,
    purge  => true,
  }->

  firewallchain { 'PREROUTING:nat:IPv4':
    ensure => present,
    purge  => true,
  }->
  firewallchain { 'POSTROUTING:nat:IPv4':
    ensure => present,
    purge  => true,
  }->

  firewall { "001 input allow related related,established (ip4)":
    chain    => 'INPUT',
    action   => 'accept',
    ctstate  => ['RELATED', 'ESTABLISHED'],
    proto    => 'all',
  }->
  firewall { "002 allow lo input (ip4)":
    chain    => 'INPUT',
    action   => 'accept',
    iniface  => 'lo',
    proto    => 'all',
  }->
  firewall { "003 drop invalid packets (ip4)":
    chain    => 'INPUT',
    action   => 'drop',
    ctstate  => 'INVALID',
    proto    => 'all',
  }->
  firewall { "004 accept pings (ip4)":
    chain    => 'INPUT',
    action   => 'accept',
    ctstate  => 'NEW',
    proto    => 'icmp',
    icmp     => 8,
  }->
  firewall { "005 new udp jump to UDP chain (ip4)":
    chain    => 'INPUT',
    jump     => 'UDP',
    ctstate  => 'NEW',
    proto    => 'udp',
  }->
  firewall { "006 new tcp jump to TCP chain (ip4)":
    chain    => 'INPUT',
    jump     => 'TCP',
    ctstate  => 'NEW',
    proto    => 'tcp',
    tcp_flags => 'FIN,SYN,RST,ACK SYN',
  }->
  firewall { "007 reject all unmatched udp (ip4)":
    chain    => 'INPUT',
    proto    => 'udp',
    action   => 'reject',
    reject   => 'icmp-port-unreachable',
  }->
  firewall { "008 reject all unmatched tcp (ip4)":
    chain    => 'INPUT',
    proto    => 'tcp',
    action   => 'reject',
    reject   => 'tcp-reset',
  }->
  firewall { "009 reject unmatched everything else (ip4)":
    chain    => 'INPUT',
    proto    => 'all',
    action   => 'reject',
    reject   => 'icmp-proto-unreachable',
  }
}
