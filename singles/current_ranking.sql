begin;

copy
(
select
p.player_name as player,
bf.estimate::numeric(4,3) as str
from ita.singles_basic_factors bf
join ita.players p
  on (p.player_id)=(bf.level::integer)
where type='random'
and factor='player'
order by estimate desc
) to '/tmp/current_singles_men.csv' csv header;

commit;
