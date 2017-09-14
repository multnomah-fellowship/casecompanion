#!/bin/bash
# Usage: ./copy-and-process.sh
#          -e    Require an email for every result.
#          -d    Remove Digital VRN recipients from the dump.
# Run this script on dameta (using MobaXterm) after running `dump-data.bat`.
#
# Note: You will have to change the username and SSH login credentials to use
# this if you are not Tom.
set -euo pipefail

set -x
today="$(date +%Y-%m-%d)"
datadir="shared/data/${today}"
ssh_destination="app@dcjvp-prda"
queryfile=$(mktemp)
shared_folder='\\tsclient\REMOTE\' # Shared folder from Remote Desktop
trap "rm $queryfile" EXIT
email_only=false
remove_digital_vrns=false

while getopts ":e" opt; do
  case $opt in
    e)
      email_only=true
      ;;
    d)
      remove_digital_vrns=true
      ;;
    \?)
      echo "Invalid option: $OPTARG"
      ;;
  esac
done

ssh $ssh_destination "mkdir -p ${datadir}"

if [ $remove_digital_vrns ]; then
  dump_query="COPY (SELECT case_number, email FROM court_case_subscriptions) TO STDOUT CSV DELIMITER ',' HEADER;"
  echo $dump_query | ssh $ssh_destination "bash -c 'env \$(cat shared/.psqlenv) psql casecompanion" digital_vrns.csv
fi

# Copy all used files to the host where it will run, so there is no dev/prod
# difference.
files=(victims.csv vrns.csv cases.csv import-data.sh digital_vrns.csv crimes-schema.sql)
scp "${files[@]}" "$ssh_destination:${datadir}"

ssh $ssh_destination "bash -c 'env \$(cat shared/.psqlenv) psql crimes < ${datadir}/crimes-schema.sql'"
ssh $ssh_destination "bash -c 'env \$(cat shared/.psqlenv) ${datadir}/import-data.sh ${datadir}'"

echo "COPY(" >>$queryfile
cat ./queries/q-dump-processed-csv.sql >>$queryfile
echo ") TO STDOUT CSV DELIMITER ',' HEADER;" >>$queryfile

if [ $email_only ]; then
  sed -i'' -e 's/-- AND victims.email IS NOT NULL/AND victims.email IS NOT NULL/' $queryfile
fi

echo "Running query $(cat $queryfile)"

scp $queryfile $ssh_destination:/tmp/

ssh $ssh_destination "/bin/bash -c 'cat $queryfile | env \$(cat shared/.psqlenv) psql crimes > \"/tmp/output-victims-${today}.csv\"'"

scp "$ssh_destination:/tmp/output-victims-${today}.csv" .
ssh $ssh_destination "rm /tmp/output-victims-${today}.csv"

cp "output-victims-${today}.csv" "$shared_folder"'output-victims-'${today}'.csv'
