copy (
select
row_number() over (order by estimate desc) as rk,
player_name as player,
team_name as team,
exp(estimate)::numeric(6,2) as str
from ita.sw_basic_factors bf
join ita.players p
on (p.player_id)=(bf.level::integer)
where bf.factor='player'
order by str desc
) to '/tmp/women_singles.csv' csv header;

