# ad2openldap
Microsoft ActiveDirectory to OpenLDAP bridge/sync

## Description later
* Clone
* change paths, usernames and passwords in openldap/import.py (LDAP root user) and windows/ADump/ADHashes.bat (SSH remote user)
* generate SSH-Keys with puttygen.exe, save to windows/ADump/id_dsa.ppk and id_dsa.pub
* If LDAP Server is the same as the AD Server, you have to change the ADHashes.bat to not use pscp rather than standard copy command

## Requirements
* gcc, make
  -> Compile OpenLDAP
* openssl
  -> OpenLDAP requirement
* perl
  -> AD dump to OpenLDAP-LDIF conversion tool
* python
  -> Import LDIF
