begin;

drop table if exists ita.singles_results;

create table if not exists ita.singles_results (
	year		      integer,
	field		      text,
	player_id	      integer,
	opponent_id	      integer,
	won		      boolean
);

insert into ita.singles_results
(year,
 field,
 player_id,
 opponent_id,
 won)
(
select
2015,
'offense_home',
ts.player_id,
ts.opponent_id,
(case when t1.team_name=ts.winner then true
      when t2.team_name=ts.winner then false
end) as won
from ita.team_singles ts
join ita.teams t1
  on (t1.league_id,t1.team_id)=
     (ts.player_league_id,ts.player_team_id)
join ita.teams t2
  on (t2.league_id,t2.team_id)=
     (ts.opponent_league_id,ts.opponent_team_id)
where
    not(ts.winner='Unfinished')
and not(ts.scores like 'Def%')
and t1.league_id=1
and t2.league_id=1
);

insert into ita.singles_results
(year,
 field,
 player_id,
 opponent_id,
 won)
(
select
2015,
'defense_home',
ts.opponent_id,
ts.player_id,
(case when t1.team_name=ts.winner then false
      when t2.team_name=ts.winner then true
end) as won
from ita.team_singles ts
join ita.teams t1
  on (t1.league_id,t1.team_id)=
     (ts.player_league_id,ts.player_team_id)
join ita.teams t2
  on (t2.league_id,t2.team_id)=
     (ts.opponent_league_id,ts.opponent_team_id)
where
    not(ts.winner='Unfinished')
and not(ts.scores like 'Def%')
and t1.league_id=1
and t2.league_id=1
);

commit;
