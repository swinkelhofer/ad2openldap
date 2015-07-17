# ad2openldap
Microsoft ActiveDirectory to OpenLDAP bridge/sync

## Installation
### On ActiveDirectory-server
* Clone this repo
* Copy files from repo's windows-folder to any path you like :)
* Edit the ADump/ADHashes.bat file. Set HOST (OpenLDAP-server), USER (SSH User on OpenLDAP-server) and REMOT_PATH (Path to OpenLDAP on that server)
* Create task, that will sync AD to OpenLDAP perhaps every day or every hour. As source file for the task you have to search the ADHashes.bat in your filesystem. Be aware that the task has to run under priviledged permissions.
* Now you are ready for creating OpenLDAP

### On OpenLDAP-server
* Also clone this repo
* change to openldap/openldap-2.4.40 folder
* Now you have to compile it from source. If you use openldap from another source, you have to rewrite the file libraries/liblutil/passwd.c. You can find a diff-file inside the repo, with this you can edit the file to required format (Little technical note: OpenLDAP doesn't 'understand' ActiveDirectory's NTLM-Hashes, so we have to insert code, that will add this feature to OpenLDAP)
* The steps for compiling are:
  * `./configure --prefix=/installation/path/to/openldap/ --sysconfdir=/installation/path/to/openldap --enable-slapd --enable-debug --with-tls=openssl`
  * `make depend`
  * `make`
  * `make install`
* Copy import.py and migrate.pl to OpenLDAP's installation path and edit import.py. Set path, ldap_base (The same you use in config file from next step), host and port as the local hostname/ip and OpenLDAP-port, root and root_pw has to be an user, who has the permissions to import LDIF-files to OpenLDAP. 

## Description later
* Clone
* change paths, usernames and passwords in openldap/import.py (LDAP root user) and windows/ADump/ADHashes.bat (SSH remote user)
* generate SSH-Keys with puttygen.exe, save to windows/ADump/id_dsa.ppk and id_dsa.pub
* If LDAP Server is the same as the AD Server, you have to change the ADHashes.bat to not use pscp rather than standard copy command

## Requirements
* gcc, make
* openssl-dev
* perl
* python
* ssh-server
