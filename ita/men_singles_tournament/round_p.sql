begin;

select round_id as rd,
r.player_name as name,
r.team_name as team,
p::numeric(4,3) as p
from ita.men_singles_rounds r
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc;

copy
(
select round_id as rd,
r.player_name as name,
r.team_name as team,
p::numeric(4,3) as p
from ita.men_singles_rounds r
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc
)
to '/tmp/round_p.csv' csv header;

commit;
