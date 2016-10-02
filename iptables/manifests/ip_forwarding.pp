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

define iptables::ip_forwarding ( $address, $interface, $snat = false ) {
  Firewall {
    require => undef,
  }

  firewall { "096 forwarding allow related,established $address $interface":
    chain    => 'FORWARD',
    action   => 'accept',
    ctstate  => ['RELATED', 'ESTABLISHED'],
    proto    => 'all',
  }->
  firewall { "097 forwarding for network $address $interface":
    chain    => 'FORWARD',
    action   => 'accept',
    proto    => 'all',
    source   => $address,
  }->
  firewall { "098 reject all forwarded traffic $address $interface":
    chain    => 'FORWARD',
    action   => 'reject',
    reject   => 'icmp-port-unreachable',
    proto    => 'all',
  }

  if( $snat ) { 
    firewall { "100 snat for network $address $interface":
      chain    => 'POSTROUTING',
      jump     => 'SNAT',
      tosource => inline_template("<%= ipaddress_${interface} %>"),
      proto    => 'all',
      outiface => $interface,
      source   => $address,
      table    => 'nat',
    }
  }
}
