REM This script should be run as a user with connection permission to SQL
REM Server.
REM
REM It dumps data from SQL Server into some local CSV files in preparation for
REM processing by the copy-and-process.sh script.

path C:\Program Files\Microsoft SQL Server\90\Tools\binn\;%PATH%
cd C:\Users\doonert\casecompanion\deploy\crimes-etl

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\00_SETUP.sql

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01a_TMP_VRN.sql
sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01b_TMP_RESTITUTION.sql
sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01c_TMP_PROBATION.sql
sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01d_TMP_VICTIM_INFO.sql
sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\01e_TMP_DEFENDANT_INFO.sql

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\02_VICTIM_NAME.sql -o victims.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\03_VRN.sql -o vrns.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -i queries\q-before.sql,queries\04_CASE_INFO.sql -o cases.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -Q "SET NOCOUNT ON; SELECT DISTINCT * FROM CFA_TOM_DEFENDANT_INFO" -o defendants.csv -s "^" -W

REM TODO: All victims vs victims?
sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -Q "SET NOCOUNT ON; SELECT DISTINCT * FROM CFA_TOM_VICTIM_INFO" -o all_victims.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -Q "SET NOCOUNT ON; SELECT DISTINCT * FROM CFA_TOM_PROBATION" -o probation_sentences.csv -s "^" -W

sqlcmd -S "dacry2.mcda.mccj.local\mssql$dada2" -d Crimsadl -Q "SET NOCOUNT ON; SELECT DISTINCT * FROM CFA_TOM_RESTITUTION" -o restitution_sentences.csv -s "^" -W

pause
