# ad2openldap
Microsoft ActiveDirectory to OpenLDAP bridge/sync

## Installation
### On ActiveDirectory-server
* Clone this repo
* Copy files from repo's windows-folder to any path you like :)
* Edit the ADump/ADHashes.bat file. Set HOST (OpenLDAP-server), USER (SSH User on OpenLDAP-server) and REMOT_PATH (Path to OpenLDAP on that server)
* Create task, that will sync AD to OpenLDAP perhaps every day or every hour. As source file for the task you have to search the ADHashes.bat in your filesystem. Be aware that the task has to run under priviledged permissions.
* generate SSH-Keys with puttygen.exe, save to ADump/id_dsa.ppk and id_dsa.pub
* If LDAP Server is the same as the AD Server, you have to change the ADHashes.bat to not use pscp rather than standard copy command
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
* Now edit OpenLDAP config `slapd.conf`, be aware, that the base-dn is exactly the same as the one, ActiveDirectory uses. An example for such a file is delivered with this repo. You only have to change the paths, base_dn, root_dn and root_pw
* execute libexec/slapd maybe with command line option `-h "ldap://hostna.me:port ldaps://hostna.me:port2"`. Now your standalone-OpenLDAP-server should be running. If there are any problems, use option `-d 4` for debug mode
* Copy content from id_dsa.pub to ~/.ssh/known_hosts to allow ActiveDirectory-server to connect via SSH
* Now you AD-server executes the task, that dumps ActiveDirectory, sends dump to OpenLDAP-server, executes the migrate.pl to change format to OpenLDAP-conform format, calls import.py and deletes all temporary file. That's it

## Requirements
* gcc, make
* openssl-dev
* perl
* python
* ssh-server
