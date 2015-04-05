begin;

select
r.year,
r.team_league_id as div,
r.opponent_league_id as div,
sum(case when r.team_score>r.opponent_score then 1 else 0 end) as won,
sum(case when r.team_score<r.opponent_score then 1 else 0 end) as lost,
sum(case when r.team_score=r.opponent_score then 1 else 0 end) as tied,
count(*)
from ita.results r
--left join ita.schools_divisions t
--  on (t.school_id,t.year)=(r.school_id,r.year)
--left join ita.schools_divisions o
--  on (o.school_id,o.year)=(r.opponent_id,r.year)
where
    r.team_league_id<=r.opponent_league_id
and r.year between 2009 and 2015
group by r.year,r.team_league_id,r.opponent_league_id
order by r.year,r.team_league_id,r.opponent_league_id;

commit;
