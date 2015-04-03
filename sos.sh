#!/bin/bash

psql tennis -f sos/standardized_results.sql

psql tennis -c "drop table if exists ita._basic_factors;"
psql tennis -c "drop table if exists ita._parameter_levels;"

psql tennis -c "vacuum analyze ita.results;"

R --vanilla -f sos/lmer.R

psql tennis -c "vacuum full verbose analyze ita._basic_factors;"
psql tennis -c "vacuum full verbose analyze ita._parameter_levels;"

psql tennis -f sos/normalize_factors.sql

psql tennis -c "vacuum full verbose analyze ita._factors;"

psql tennis -f sos/schedule_factors.sql

psql tennis -c "vacuum full verbose analyze ita._schedule_factors;"

psql tennis -f sos/connectivity.sql > sos/connectivity.txt

psql tennis -f sos/current_ranking.sql > sos/current_ranking.txt

psql tennis -f sos/division_ranking.sql > sos/division_ranking.txt

psql tennis -f sos/test_predictions.sql > sos/test_predictions.txt

psql tennis -f sos/predict_daily.sql > sos/predict_daily.txt
