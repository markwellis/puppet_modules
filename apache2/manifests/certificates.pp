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

define apache2::certificates ( $source ) {
  $certname = $title

  file { "/etc/apache2/certs":
    ensure => directory,
    owner  => 'root',
    group  => 'root'
  }
  file { "/etc/apache2/certs/${certname}.crt":
    source  => "${source}/${certname}.crt",
    owner   => 'root',
    group   => 'root',
    require => File['/etc/apache2/certs'],
    notify  => Service['apache2'],
  }
  file { "/etc/apache2/certs/${certname}.key":
    source  => "${source}/${certname}.key",
    owner   => 'root',
    group   => 'root',
    require => File['/etc/apache2/certs'],
    notify  => Service['apache2'],
  }
  file { "/etc/apache2/certs/${certname}.ca-crt":
    source  => "${source}/${certname}.ca-crt",
    owner   => 'root',
    group   => 'root',
    require => File['/etc/apache2/certs'],
    notify  => Service['apache2'],
  }
  #  file { "/etc/apache2/certs/${certname}.csr":
  #    source  => "${source}/${certname}.csr",
  #    owner   => 'root',
  #    group   => 'root',
  #    require => File['/etc/apache2/certs'],
  #    notify  => Class['Apache::Service'],
  #  }
}