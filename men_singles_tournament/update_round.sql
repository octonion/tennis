begin;

insert into ita.men_singles_rounds
(year,round_id,division_id,player_id,player_name,team_name,bracket,p)
(
select
r1.year as year,
r1.round_id+1 as round,
r1.division_id,
r1.player_id,
r1.player_name,
r1.team_name,
r1.bracket,

sum(
(case when r2.player_id is null then 1.0
      else r1.p*r2.p*mp.player_p
 end)
) as p

from ita.men_singles_rounds r1
left join ita.men_singles_rounds r2
  on ((r1.year,r1.round_id,r1.bracket[r1.round_id+1])=
      (r2.year,r2.round_id,r2.bracket[r1.round_id+1])
       and not(r1.bracket[r1.round_id]=r2.bracket[r1.round_id]))
left join ita.men_singles_matrix_p mp
  on (mp.year,mp.player_id,mp.opponent_id)=
     (r1.year,r1.player_id,r2.player_id)

where
    r1.year=2015
and r1.round_id=1
group by r1.year,round,r1.division_id,r1.player_id,r1.player_name,r1.team_name,r1.bracket
);

commit;
