#!/bin/bash

psql tennis -f men/standardized_results.sql

psql tennis -c "drop table if exists ita.men_basic_factors;"
psql tennis -c "drop table if exists ita.men_parameter_levels;"

psql tennis -c "vacuum analyze ita.results;"

R --vanilla -f men/lmer.R

psql tennis -c "vacuum full verbose analyze ita.men_basic_factors;"
psql tennis -c "vacuum full verbose analyze ita.men_parameter_levels;"

psql tennis -f men/normalize_factors.sql

psql tennis -c "vacuum full verbose analyze ita.men_factors;"

psql tennis -f men/schedule_factors.sql

psql tennis -c "vacuum full verbose analyze ita.men_schedule_factors;"

psql tennis -f men/connectivity.sql > men/connectivity.txt

psql tennis -f men/current_ranking.sql > men/current_ranking.txt
cp /tmp/current_ranking.csv men/current_ranking.csv

psql tennis -f men/division_ranking.sql > men/division_ranking.txt

psql tennis -f men/test_predictions.sql > men/test_predictions.txt

psql tennis -f men/predict_daily.sql > men/predict_daily.txt
