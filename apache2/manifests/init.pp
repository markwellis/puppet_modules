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

class apache2 ( $mpm = "worker" ) {
  #you may wonder why i'm not using the puppetlabs apache module
  # the answer is it's crap. and you can't just use part of it, it's all or nothing
  # and it's a pain to make work like the debian example redmine vhost config

  if ( $mpm == 'event') {
    package { "apache2-mpm-event":
      ensure  => present,
      require => Package['apache2'],
    }
    ::apache2::mod { "mpm_event": }
  }
  elsif ( $mpm == 'prefork') {
    package { "apache2-mpm-prefork":
      ensure  => present,
      require => Package['apache2']
    }
    ::apache2::mod { "mpm_prefork": }
  }
  else {
    package { "apache2-mpm-worker":
      ensure  => present,
      require => Package['apache2']
    }
    ::apache2::mod { "mpm_worker": }
  }

  ::apache2::mod { "deflate": }
  ::apache2::mod { "mime": }
  ::apache2::mod { "authz_core": }

  package { "apache2":
    ensure  => present,
  }

  file { "/etc/apache2/apache2.conf":
    ensure  => 'file',
    owner   => "root",
    group   => "root",
    content => template("apache2/apache2.conf.erb"),
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  #this one should be customisable¸to only listen on ip addresses/custom ports?
  file { "/etc/apache2/ports.conf":
    ensure  => 'file',
    owner   => "root",
    group   => "root",
    content => template("apache2/ports.conf.erb"),
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  #these should exist, but just incase they don't
  file { [
      "/etc/apache2/conf.d",
      "/etc/apache2/mods-available",
      "/etc/apache2/sites-available",
    ]:
      ensure => "directory",
      owner  => "root",
      group  => "root",
  }

  #make sure this one only contains our data
  file { [
      '/etc/apache2/mods-enabled',
      '/etc/apache2/sites-enabled',
    ]:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner   => "root",
    group   => "root",
    notify  => Service['apache2'],
  }

  file { "/etc/apache2/mods-available/ssl.conf":
    ensure  => 'file',
    owner   => "root",
    group   => "root",
    source => 'puppet:///modules/apache2/ssl.conf',
    require => [Package['apache2'], File['/etc/apache2/mods-available']],
    notify  => Service['apache2'],
  }

  service { "apache2":
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }
}
