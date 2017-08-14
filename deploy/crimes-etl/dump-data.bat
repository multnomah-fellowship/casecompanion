REM Run this script first (on dameta).
REM
REM This script dumps data from SQL Server into some local CSV files

sqlcmd -S "dacry2\mssql$dada2" -d Crimsadl -i queries\00_SETUP.sql

sqlcmd -S "dacry2\mssql$dada2" -d Crimsadl -i queries\01_VRN.sql

sqlcmd -S "dacry2\mssql$dada2" -d Crimsadl -i queries\before.sql,queries\02_VICTIM_NAME.sql -o victims.csv -s "^" -W

sqlcmd -S "dacry2\mssql$dada2" -d Crimsadl -i queries\before.sql,queries\03_VRN.sql -o vrns.csv -s "^" -W

pause
