#!/usr/bin/perl
# Copyright (c) 2000, Norbert Klasen.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# o Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# o Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# o Neither the name of the Universitaet Tuebingen nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Password migration tool. Migrates dump from Windows NT SAM or Active
# Directory to rfc2307 ldif file.
# See http://www.webspan.net/~tas/pwdump2/ for pwdump

use strict;
use Getopt::Std;
use vars qw/ $opt_u $opt_g $opt_d $opt_s $opt_b $gidNumber $homeDirectoryBase $loginShell $basedn/;

if (!getopts('uig:d:s:b:'))
{
print "migrate_pwdump: converts Windows SAM dump to rfc2307 ldif file\n";
print "usage: [-u] [-g group] [-d homebase] [-s shell] [-b basedn] pwdump-file\n";
print " -u generate ldif file for changing userPassword attribute only\n";
exit;
}

if ( $opt_g ) {
$gidNumber = $opt_g;
} else {
$gidNumber = 100;
}

if ( $opt_d ) {
$homeDirectoryBase = $opt_d;
} else {
$homeDirectoryBase = "/home/";
}

if ( $opt_s ) {
$loginShell = $opt_s;
} else {
$loginShell = "/bin/bash";
}

if ( $opt_b ) {
$basedn = $opt_b;
} else {
$basedn = "ou=Users,dc=test,dc=net";
}
while ( <> ) {
my ($name, $uidNumber, $lanmanger_hash, $nt_hash, $account_flags, $src, $rem) = split /:/, $_;
next if $name =~ /\$$/; #computer accounts shouldn't be included
print "dn: cn=$name,$basedn\n";
if ( $opt_u ) {
print "changetype: modify\n";
print "replace: userPassword\n";
print "userPassword: {NTLM}$nt_hash\n";
} else {
print "objectClass: top\n";
#print "objectclass: account\n";
#print "objectclass: posixAccount\n";
print "objectClass: inetOrgPerson\n";
#posixAccount MUST
print "cn: $name\n";
print "sn: $name\n";
print "uid: $name\n";
#print "uidNumber: $uidNumber\n";
#print "gidNumber: $gidNumber\n";
#print "homeDirectory: $src";
#posixAccount MAY
print "userPassword: {NTLM}$nt_hash\n";
#print "userPassword: {lanman}$lanmanger_hash\n";
#print "loginShell: $loginShell\n";
}
print "\n";
}
