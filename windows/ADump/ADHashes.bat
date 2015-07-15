:: Global root directory setting for ntds_decode.exe
set NTDS_DECODE_ROOT=%cd%
set HOST="Host.ip"
set USER="SSH User of Host"
set REMOTE_PATH="/remote/path/to/openldap"

:: Create workspace
cd %NTDS_DECODE_ROOT%
mkdir tmp

:: VSS!!!
vssadmin create shadow /for=C: | findstr \\\\?\\GLOBALROOT.*$ > tmp/VAR

:: String processing to get VSS-Volumename
set /p VAR= < tmp/VAR
set VAR=%VAR: =%
set VAR=%VAR:Schattenkopie-Volumename:=%

:: Copy required files from VSS-Volume
wmic process call create "cmd /c copy %VAR%\Windows\NTDS\ntds.dit %NTDS_DECODE_ROOT%\tmp\ntds.dit"
wmic process call create "cmd /c copy %VAR%\Windows\System32\config\SYSTEM %NTDS_DECODE_ROOT%\tmp\SYSTEM"

:: Repair ntds.dit-copy quiet
esentutl /p %NTDS_DECODE_ROOT%\tmp\ntds.dit /o

:: GET ActiveDirectory PW-Hashes > hashes.txt
ntds_decode -d %NTDS_DECODE_ROOT%\tmp\ntds.dit -s %NTDS_DECODE_ROOT%\tmp\SYSTEM

:: Generate of all AD-Users > adusers.ldf
:: ldifde -f adusers.ldf -d "ou=benutzer,ou=zawiw,dc=zawiw-domain,dc=local"

:: send hashes.txt to OpenLDAP-Web for further processing
pscp -i id_dsa.ppk hashes.txt %USER%@%HOST%:%REMOTE_PATH%/

:: send adusers.ldf to OpenLDAP-Web for further processing
:: pscp -i id_dsa.ppk adusers.ldf web12@ldap.zawiw.de:files/openldap/

:: Call import routines on server
plink -i id_dsa.ppk %USER%@%HOST% /usr/bin/python %REMOTE_PATH%/import.py

:: Cleanup
vssadmin delete shadows /for=C: /all /quiet
rmdir /s /q tmp
del ntds.INTEG.RAW
del hashes.txt
:: del adusers.ldf
plink -i id_dsa.ppk %USER%@%HOST% rm %REMOTE_PATH%/hashes.txt
