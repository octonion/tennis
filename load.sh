#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'tennis';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb tennis"
   eval $cmd
fi

psql tennis -f schema/create_schema.sql

tail -q -n+2 csv/ita_team_results_*.csv >> /tmp/results.csv
psql tennis -f loaders/load_team_results.sql
rm /tmp/results.csv

grep -v "Never Scheduled" csv/ita_team_singles_*.csv > /tmp/singles.csv
psql tennis -f loaders/load_team_singles.sql
rm /tmp/singles.csv
