begin;

drop table if exists ita.team_results;

create table ita.team_results (
	year		      integer,
	season_id	      integer,
	league_id	      integer,
	team_id		      integer,
	game_date	      date,
	opponent_string	      text,
	opponent_id	      integer,
	opponent_url	      text,
	outcome		      text,
	score		      text,
	result_javascript     text
);

copy ita.team_results from '/tmp/results.csv' csv header;

commit;
