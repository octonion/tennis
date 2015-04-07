begin;

drop table if exists ita.team_singles;

create table ita.team_singles (
	scse_id		      integer,
	ts_id		      text,
	game_url	      text,
	game_rank	      integer,
	game_type	      text,
	player_rank	      text,
	player_name	      text,
	player_league_id      integer,
	player_conf_id	      integer,
	player_team_id	      integer,
	player_id	      integer,
	player_type_id	      integer,
	player_url	      text,
	opponent_rank	      text,
	opponent_name	      text,
	opponent_league_id    integer,
	opponent_conf_id      integer,
	opponent_team_id      integer,
	opponent_id	      integer,
	opponent_type_id      integer,
	opponent_url	      text,
	winner		      text,
	scores		      text
);

copy ita.team_singles from '/tmp/singles.csv' csv header;

commit;
