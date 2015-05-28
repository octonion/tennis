begin;

create temporary table r (
       rk			serial,
       school			text,
       school_id		integer,
       league			text,
       year			integer,
       str			float,
       ofs			float,
       dfs			float,
       sos			float
);

insert into r
(school,school_id,league,year,str,ofs,dfs,sos)
(
select
t.team_name,
sf.school_id,
(case when t.league_id in (1,4) then 'D1'
      when t.league_id in (2,5) then 'D2'
      when t.league_id in (3,6) then 'D3'
      when t.league_id in (7,8) then 'NAIA'
      when t.league_id in (9,10) then 'NJCAA I'
      when t.league_id in (11) then 'NJCAA II'
      when t.league_id in (12,993) then 'NJCAA II'
      when t.league_id in (13,14) then 'SCCC'
      when t.league_id in (994,995) then 'NCCC'
end) as league,
sf.year,
--log(sf.strength)+log(o.exp_factor)-log(d.exp_factor) as str,
log(sf.strength)+log(o.exp_factor)-log(d.exp_factor) as str,
log(offensive)+log(o.exp_factor) as ofs,
--(offensive*o.exp_factor) as ofs,
--(defensive*d.exp_factor) as dfs,
log(defensive)+log(d.exp_factor) as dfs,
schedule_strength as sos
from ita._schedule_factors sf
join ita.teams t
  on (t.team_id,2015)=(sf.school_id,sf.year)
--join ita.teams sd
--  on (sd.school_id,sd.year)=(sf.school_id,sf.year)
join ita._factors o
  on (o.parameter,o.level::integer)=('o_div',t.league_id)
join ita._factors d
  on (d.parameter,d.level::integer)=('d_div',t.league_id)
where sf.year in (2015)
order by str desc);

select
rk,school,league,
str::numeric(4,2),
ofs::numeric(4,2),
dfs::numeric(4,2),
sos::numeric(4,2)
from r
order by rk asc;

copy
(
select
rk,school,league,
str::numeric(4,2),
ofs::numeric(4,2),
dfs::numeric(4,2),
sos::numeric(4,2)
from r
order by rk asc
) to '/tmp/current_ranking.csv' csv header;

commit;
