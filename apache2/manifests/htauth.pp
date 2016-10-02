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

define apache2::htauth (
  $user,
  $password,
  $file,
) {
  $split_filename = split( $file, '/' )
  $tmp_file = $split_filename[-1]

  #this is probably the most hacky bit of puppet i've written.
  # only works with one user, should copy source file, grep out username and cmp that line only for more than one user
  exec { "creating htpasswd auth file $file":
    command => "/bin/cp /tmp/${tmp_file}_htpasswd ${file}; /bin/rm /tmp/${tmp_file}_htpasswd",
    unless  => "/usr/bin/htpasswd -bsc /tmp/${tmp_file}_htpasswd ${user} ${password}; /usr/bin/cmp -s /tmp/${tmp_file}_htpasswd ${file}",
  }
}
