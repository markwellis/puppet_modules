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

class default_ssh ( $open_interface = false ) {
  class { 'ssh::server':
    storeconfigs_enabled  => false,
    options               => {
      'PasswordAuthentication'  => 'no',
      'X11Forwarding'           => 'no',
      'PermitRootLogin'         => 'no',
      'ListenAddress'           => '0.0.0.0',
      'UsePrivilegeSeparation'  => 'sandbox',
      'KeyRegenerationInterval' => 3600,
      'Protocol'                => 2,
      'Port'                    => 22,
      'SyslogFacility'          => 'AUTH',
      'LogLevel'                => 'INFO',
      'LoginGraceTime'          => 120,
      'StrictModes'             => 'yes',
      'PubkeyAuthentication'    => 'yes',
      'TCPKeepAlive'            => 'yes',
      'HostKey'                 => [
        '/etc/ssh/ssh_host_rsa_key',
        '/etc/ssh/ssh_host_ed25519_key',
      ],
    }
  }

  if ( $open_interface ) {
    iptables::open_port{"allow ssh over $open_interface":
      interface => $open_interface,
      proto     => 'tcp',
      port      => 22,
      require   => Class['iptables'],
    }
  }
}
