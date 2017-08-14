#!/bin/bash
# Usage: ./copy-and-process.sh
# Run this script on dameta (using MobaXterm) after running `dump-data.bat`.
#
# Note: You will have to change the username and SSH login credentials to use
# this if you are not Tom.
set -euo pipefail

eval "$(ssh-agent)"
ssh-add ./private-key

set -x
today="$(date +%Y-%m-%d)"
datadir="data/${today}"
ssh_destination="doonerto@da-cfa"
queryfile=$(mktemp)
shared_folder='\\tsclient\REMOTE_DA\' # Shared folder from Remote Desktop
trap "rm $queryfile" EXIT

ssh $ssh_destination "mkdir -p ${datadir}"

scp ./victims.csv "$ssh_destination:${datadir}"
scp ./vrns.csv "$ssh_destination:${datadir}"

ssh $ssh_destination "./import-data.sh ${datadir}"

echo "COPY(" >>$queryfile
cat ./queries/q-dump-processed-csv.sql >>$queryfile
echo ") TO '/tmp/output-victims-${today}.csv' CSV DELIMITER ',' HEADER;" >>$queryfile

echo "Running query $(cat $queryfile)"

scp $queryfile $ssh_destination:/tmp/

ssh $ssh_destination "/bin/bash -c 'cat $queryfile | psql crimes'"

scp "$ssh_destination:/tmp/output-victims-${today}.csv" .
cp "output-victims-${today}.csv" "$shared_folder"'output-victims-'${today}'.csv'
