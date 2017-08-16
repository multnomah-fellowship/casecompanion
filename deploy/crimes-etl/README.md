Running CRIMES ETL
==========================================

The CRIMES ETL is a set of scripts and queries that produce subsets of data for CaseCompanion for purposes of sending VRN confirmation emails and (eventually) sharing across agencies.

These scripts are highly custom to my existing workflow, so there are many places to change if running this as a different user or from a different directory.

The batch scripts in this directory must be run from a Windows machine with access to the dameta SQL server.

## Windows machine installation
Download the "Microsoft SQL Server 2005 Command Line Query Utility"
and the "Microsoft SQL Server Native Client" from
[the Install Instructions section of this page](https://www.microsoft.com/en-us/download/details.aspx?id=17943).
*It's important that you get the ones that mention compatibility with SQL Server 2000!*

Then, you'll have to:
- Install git for windows
- Install ruby for windows (RubyInstaller)

## Creating a mailchimp CSV export
This is a two step process. First, run `dump-data-wrapper.bat` to output a raw
`victims.csv` and `vrns.csv` file.

Then, run `copy-and-process.sh` to copy those files to the production
environment, import them into the `crimes` database, and run the processing
queries.
