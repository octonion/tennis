#!/bin/bash

psql tennis -f women/standardized_results.sql

psql tennis -c "drop table if exists ita.women_basic_factors;"
psql tennis -c "drop table if exists ita.women_parameter_levels;"

psql tennis -c "vacuum analyze ita.results;"

R --vanilla -f women/lmer.R

psql tennis -c "vacuum full verbose analyze ita.women_basic_factors;"
psql tennis -c "vacuum full verbose analyze ita.women_parameter_levels;"

psql tennis -f women/normalize_factors.sql

psql tennis -c "vacuum full verbose analyze ita.women_factors;"

psql tennis -f women/schedule_factors.sql

psql tennis -c "vacuum full verbose analyze ita.women_schedule_factors;"

psql tennis -f women/connectivity.sql > women/connectivity.txt

psql tennis -f women/current_ranking.sql > women/current_ranking.txt
cp /tmp/current_ranking.csv women/current_ranking.csv

psql tennis -f women/division_ranking.sql > women/division_ranking.txt

psql tennis -f women/test_predictions.sql > women/test_predictions.txt

psql tennis -f women/predict_daily.sql > women/predict_daily.txt
