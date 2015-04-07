begin;

drop table if exists ita.players;

create table ita.players (
	league_id	      integer,
	conf_id		      integer,
	team_id		      integer,
	player_id	      integer,
	player_name	      text
);

insert into ita.players
(league_id, conf_id, team_id, player_id, player_name)
(
select
player_league_id,
player_conf_id,
player_team_id,
player_id,
player_name
from ita.team_singles
union
select
opponent_league_id,
opponent_conf_id,
opponent_team_id,
opponent_id,
opponent_name
from ita.team_singles
);

commit;
