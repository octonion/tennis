select t1.team_name,
(case when t1.team_name=ts.winner then 'won'
      when t2.team_name=ts.winner then 'lost'
end) as outcome,
t2.team_name,
ts.winner,
ts.scores
from ita.team_singles ts
join ita.teams t1
  on (t1.league_id,t1.team_id)=
     (ts.player_league_id,ts.player_team_id)
join ita.teams t2
  on (t2.league_id,t2.team_id)=
     (ts.opponent_league_id,ts.opponent_team_id)
where
    not(ts.winner='Unfinished')
and not(ts.scores like 'Def%');
