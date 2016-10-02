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

class iptables ( $ssh_interface = undef, $output_drop = false ) {
  if ( $operatingsystem == 'Debian' ) {
    $iptables_persistent = "iptables-persistent"
  }
  elsif ( $operatingsystem == 'Fedora' ) {
    $iptables_persistent = "iptables-services"
  }

  package { $iptables_persistent:
    ensure => present,
  }
  #in debian containers modprobe fails and breaks iptables-persistent save
  if (
    ( $operatingsystem == 'Debian' )
    and $is_virtual and ( $virtual == 'lxc' )
  ) {
    file { "/sbin/modprobe":
      ensure => 'link',
      target => '/bin/true',
    }
    $faked_modprobe = File['/sbin/modprobe']
  }
  else {
    $faked_modprobe = []
  }

  class { "iptables::ip4defaults":
    purge_output => $output_drop,
    require      => [Package[$iptables_persistent], $faked_modprobe],
  }
  class { "iptables::ip6defaults":
    require      => [Package[$iptables_persistent], $faked_modprobe],
  }

  if ( $ssh_interface ) {
    iptables::open_port{ "allow internal ssh access":
      interface => 'eth1',
      proto     => 'tcp',
      port      => 22,
      require   => [Class['iptables::ip4defaults'], Class['iptables::ip6defaults']],
    }
    $iptables_require = Iptables::Open_port['allow internal ssh access']
  }
  else {
    $iptables_require = undef
  }

  class {"iptables::default_policy_drop":
    output_drop => $output_drop,
    require     => $iptables_require,
  }
}
