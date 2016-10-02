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

define apache2::mod ( $ensure = 'present' ) {
  if $ensure == 'absent' {
    apache2::mod::disable { $title:
      notify => Service['apache2'],
    }
  }
  else {
    apache2::mod::enable { $title:
      notify => Service['apache2'],
    }
  }
}

define apache2::mod::disable {
  file { "/etc/apache2/mods-enabled/$title.load":
    ensure => absent,
  }

  file { "/etc/apache2/mods-enabled/$title.conf":
    ensure => absent,
  }
}

define apache2::mod::enable {
  file { "/etc/apache2/mods-enabled/$title.load":
    ensure => link,
    target => "/etc/apache2/mods-available/$title.load",
  }

  if ( $::apache_mods[$title][has_conf] ) {
    file { "/etc/apache2/mods-enabled/$title.conf":
      ensure => link,
      target => "/etc/apache2/mods-available/$title.conf",
    }
  }
}
