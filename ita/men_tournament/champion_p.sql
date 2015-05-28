begin;

select
r.team_name,p::numeric(4,3)
from ita.men_rounds r
join ita.teams t
  on (t.team_id)=(r.team_id)
where round_id=7
order by p desc;

copy
(
select
r.team_name,p::numeric(4,3)
from ita.men_rounds r
join ita.teams t
  on (t.team_id)=(r.team_id)
where round_id=7
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
