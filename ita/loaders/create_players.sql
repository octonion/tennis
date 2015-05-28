begin;

drop table if exists ita.players;

create table ita.players (
	league_id	      integer,
	conf_id		      integer,
	team_id		      integer,
	player_id	      integer,
	team_name	      text,
	player_name	      text
);

insert into ita.players
(league_id, conf_id, team_id, player_id, team_name, player_name)
(
select
ts.player_league_id,
ts.player_conf_id,
ts.player_team_id,
ts.player_id,
t.team_name,
ts.player_name
from ita.team_singles ts
join ita.teams t
  on (t.league_id,t.team_id)=(ts.player_league_id,ts.player_team_id)
union
select
ts.opponent_league_id,
ts.opponent_conf_id,
ts.opponent_team_id,
ts.opponent_id,
t.team_name,
ts.opponent_name
from ita.team_singles ts
join ita.teams t
  on (t.league_id,t.team_id)=(ts.opponent_league_id,ts.opponent_team_id)
);

commit;
