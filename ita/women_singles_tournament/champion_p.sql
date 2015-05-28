begin;

select
r.player_name,
r.team_name,
p::numeric(4,3)
from ita.women_singles_rounds r
where round_id=7
order by p desc;

copy
(
select
r.player_name,
r.team_name,
p::numeric(4,3)
from ita.women_singles_rounds r
where round_id=7
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
