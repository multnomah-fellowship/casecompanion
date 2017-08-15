REM Run this script first before copy-and-process.sh
REM
REM This script calls the dump-data.bat script with the proper permissions

icacls "C:\Users\doonert\casecompanion\deploy\crimes-etl" /grant mcda\doonerto:(OI)(CI)F /T

runas.exe /user:mcda\doonerto "C:\Users\doonert\casecompanion\deploy\crimes-etl\dump-data.bat"

pause
