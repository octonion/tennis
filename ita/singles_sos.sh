#!/bin/bash

psql tennis -f singles/standardized_results.sql

psql tennis -c "drop table if exists ita._basic_factors;"
psql tennis -c "drop table if exists ita._parameter_levels;"

psql tennis -c "vacuum analyze ita.results;"

R --vanilla -f singles/lmer.R

psql tennis -c "vacuum full verbose analyze ita._basic_factors;"
psql tennis -c "vacuum full verbose analyze ita._parameter_levels;"

psql tennis -f singles/normalize_factors.sql

psql tennis -c "vacuum full verbose analyze ita._factors;"

psql tennis -f singles/schedule_factors.sql

psql tennis -c "vacuum full verbose analyze ita._schedule_factors;"

psql tennis -f singles/connectivity.sql > singles/connectivity.txt

psql tennis -f singles/current_ranking.sql > singles/current_ranking.txt

psql tennis -f singles/division_ranking.sql > singles/division_ranking.txt

psql tennis -f singles/test_predictions.sql > singles/test_predictions.txt

psql tennis -f singles/predict_daily.sql > singles/predict_daily.txt
