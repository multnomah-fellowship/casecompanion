REM This script should be run as a user with connection permission to SQL
REM Server.
REM
REM It dumps data from SQL Server into some local CSV files in preparation for
REM processing by the copy-and-process.sh script.

path C:\Program Files\Microsoft SQL Server\90\Tools\binn\;%PATH%
cd C:\Users\doonert\casecompanion\deploy\crimes-etl

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\00_SETUP.sql

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01_VRN.sql

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\02_VICTIM_NAME.sql -o victims.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\03_VRN.sql -o vrns.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\04_CASE_INFO.sql -o cases.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\05_DCJ_EMAIL.sql -o closed_charge_victims.csv -s "^" -W

pause
