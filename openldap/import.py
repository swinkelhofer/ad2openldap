#!/usr/bin/python
import os
import re

# basic defs
path = "/path/to/openldap"
ldap_base = "ou=base,dc=domain"
host = "host.ip"
port = "xxxx"
root = "ruth"
root_pw = "xxxxxxxx"

entrystring = os.popen("/usr/bin/perl %s/migrate.pl -b '%s' %s/hashes.txt" % (path, ldap_base, path)).read()

# add all entries, existing entries are skipped
entries = entrystring.rstrip().split("\n\n")
for elem in entries:
	f = open("%s/tmp.ldif" % (path), 'w')
	f.write(elem)
	f.close()
	print os.popen("%s/bin/ldapadd -h %s -p %s -x -w '%s' -D \"cn=%s,%s\" -f %s/tmp.ldif 2>&1" % (path, host, port, root_pw, root, ldap_base, path)).read()

# update all entries
entrystring = os.popen("/usr/bin/perl %s/migrate.pl -u -b '%s' %s/hashes.txt" % (path, ldap_base, path)).read()
entries = entrystring.rstrip().split("\n\n")
for elem in entries:
	f = open("%s/tmp.ldif" % (path), 'w')
	f.write(elem)
	f.close()
	print os.popen("%s/bin/ldapmodify -h %s -p %s -x -w '%s' -D \"cn=%s,%s\" -f %s/tmp.ldif 2>&1" % (path, host, port, root_pw, root, ldap_base, path)).read()

# Find entries to delete
entrystring = os.popen("/usr/bin/perl %s/migrate.pl -u -b '%s' %s/hashes.txt | grep dn: | sed 's/dn: //g'" % (path, ldap_base, path)).read()
entries = entrystring.rstrip().split("\n")

oldentrystring = os.popen("%s/bin/ldapsearch -h %s -p %s -x -w '%s' -b \"%s\" -D \"cn=%s,%s\" | grep dn: | sed 's/dn: //g'" % (path, host, port, root_pw, ldap_base, root, ldap_base)).read()
oldentries = oldentrystring.rstrip().split("\n")
oldentries.pop(0)

for entry in oldentries:
	try:
		entries.index(entry)
	except:
		print os.popen("%s/bin/ldapdelete -h %s -p %s -x -w '%s' -D \"cn=%s,%s\" %s 2>&1" % (path, host, port, root_pw, root, ldap_base, entry)).read()
os.remove("%s/tmp.ldif" % (path))
