#!/bin/bash
# This script should be run on an app server with access to the database.
set -euo pipefail

path=${1:-""}

if [ -z "$path" -o ! -d "$path" ]; then
  echo "Usage: $0 [data/2017-08-03]"
  exit 1
fi

fixfile() {
  file=$1
  echo "Fixing file ${file}..."

  # first, fix the line endings to be unixy
  echo "  - line endings"
  tr -d '\r' < "$file" > "${file}.fixed"
  mv "${file}.fixed" "${file}"

  # second, remove the garbage header separation row that sqlcmd adds
  echo "  - remove header separation row"
  sed -i'' -e '/^[-\^]*$/d' "${file}"

  # third, make the headers lowercase
  echo "  - lowercasing and removing space from headers"
  sed -i'' -e '1s/.*/\L&/' "${file}"
  sed -i'' -e '1s/ //g' "${file}"

  # fourth, convert the file to valid UTF-8
  echo "  - removing invalid utf-8 characters"
  iconv -f utf-8 -t utf-8 -c "${file}" > "${file}.utf8"
  mv "${file}.utf8" "${file}"
}

fixfile "${path}/victims.csv"
fixfile "${path}/vrns.csv"
fixfile "${path}/digital_vrns.csv"
fixfile "${path}/cases.csv"

echo "Downloading Advocate contact spreadsheet..."
curl 'https://docs.google.com/spreadsheets/d/1kDpMM3Ls44NuPUkluSo6dUwMTseSGLS3K1GqteYxisY/pub?gid=0&single=true&output=csv' \
  | sed -e '1s/.*/\L&/g' \
  | sed -e '1s/ /_/g' \
  > "${path}/advocates.csv"

export $(cat $(dirname $0)/../../.psqlenv)

echo "Importing files..."
cat "${path}/victims.csv" | psql crimes -c "COPY victims FROM STDIN (FORMAT csv, DELIMITER '^', HEADER, NULL 'NULL', QUOTE E'\b')"
cat "${path}/vrns.csv" | psql crimes -c "COPY vrns FROM STDIN (FORMAT csv, DELIMITER '^', HEADER, NULL 'NULL', QUOTE E'\b')"
cat "${path}/advocates.csv" | psql crimes -c "COPY advocates FROM STDIN (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL', QUOTE E'\b')"
cat "${path}/cases.csv" | psql crimes -c "COPY cases FROM STDIN (FORMAT csv, DELIMITER '^', HEADER, NULL 'NULL', QUOTE E'\b')"
cat "${path}/digital_vrns.csv" | psql crimes -c "COPY digital_vrns FROM STDIN (FORMAT csv, DELIMITER ',', HEADER, NULL 'NULL', QUOTE E'\b')"
