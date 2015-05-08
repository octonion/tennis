begin;

-- rounds

drop table if exists ita.men_rounds;

create table ita.men_rounds (
	year				integer,
	round_id			integer,
	seed				integer,
	division_id			integer,
	team_id				integer,
	team_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,team_id)
);

copy ita.men_rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists ita.men_matrix_p;

create table ita.men_matrix_p (
	year				integer,
	field				text,
	team_id				integer,
	opponent_id			integer,
	team_p				float,
	opponent_p			float,
	primary key (year,field,team_id,opponent_id)
);

insert into ita.men_matrix_p
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'home',
r1.team_id,
r2.team_id,

exp(ln(h.offensive)+ln(o.exp_factor)-ln(v.offensive))/
(1+exp(ln(h.offensive)+ln(o.exp_factor)-ln(v.offensive)))
as home_p,

1-exp(ln(h.offensive)+ln(o.exp_factor)-ln(v.offensive))/
(1+exp(ln(h.offensive)+ln(o.exp_factor)-ln(v.offensive)))
as visitor_p

from ita.men_rounds r1
join ita.men_rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ita.men_schedule_factors v
  on (v.year,v.school_id)=(r2.year,r2.team_id)
join ita.men_schedule_factors h
  on (h.year,h.school_id)=(r1.year,r1.team_id)
join ita.men_factors o
  on (o.parameter,o.level)=('field','offense_home')
join ita.men_factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

insert into ita.men_matrix_p
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'away',
r1.team_id,
r2.team_id,

exp(ln(h.offensive)-ln(o.exp_factor)-ln(v.offensive))/
(1+exp(ln(h.offensive)-ln(o.exp_factor)-ln(v.offensive)))
as home_p,

1-exp(ln(h.offensive)-ln(o.exp_factor)-ln(v.offensive))/
(1+exp(ln(h.offensive)-ln(o.exp_factor)-ln(v.offensive)))
as visitor_p

--(h.strength*d.exp_factor)^3.2/
--((h.strength*d.exp_factor)^3.2+(v.strength*o.exp_factor)^3.2)
--  as home_p,
--(v.strength*o.exp_factor)^3.2/
--((v.strength*o.exp_factor)^3.2+(h.strength*d.exp_factor)^3.2)
--  as visitor_p
from ita.men_rounds r1
join ita.men_rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ita.men_schedule_factors v
  on (v.year,v.school_id)=(r2.year,r2.team_id)
join ita.men_schedule_factors h
  on (h.year,h.school_id)=(r1.year,r1.team_id)
join ita.men_factors o
  on (o.parameter,o.level)=('field','offense_home')
join ita.men_factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);


insert into ita.men_matrix_p
(year,field,team_id,opponent_id,team_p,opponent_p)
(select
r1.year,
'neutral',
r1.team_id,
r2.team_id,

exp(ln(h.offensive)-ln(v.offensive))/
(1+exp(ln(h.offensive)-ln(v.offensive)))
as home_p,

1-exp(ln(h.offensive)-ln(v.offensive))/
(1+exp(ln(h.offensive)-ln(v.offensive)))
as visitor_p

from ita.men_rounds r1
join ita.men_rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join ita.men_schedule_factors v
  on (v.year,v.school_id)=(r2.year,r2.team_id)
join ita.men_schedule_factors h
  on (h.year,h.school_id)=(r1.year,r1.team_id)
where
  r1.year=2015
);

-- home advantage

-- Determined by:

drop table if exists ita.men_matrix_field;

create table ita.men_matrix_field (
	year				integer,
	round_id			integer,
	team_id				integer,
	opponent_id			integer,
	field				text,
	primary key (year,round_id,team_id,opponent_id)
);

insert into ita.men_matrix_field
(year,round_id,team_id,opponent_id,field)
(select
r1.year,
gs.round_id,
r1.team_id,
r2.team_id,
'neutral'
from ita.men_rounds r1
join ita.men_rounds r2
  on (r2.year=r1.year and not(r2.team_id=r1.team_id))
join (select generate_series(1, 7) round_id) gs
  on TRUE
where
  r1.year=2015
);

-- 1st and 2nd round seeds have home

--update ita.men_matrix_field
--set field='home'
--from ita.men_rounds r
--where (r.year,r.team_id)=
--      (men_matrix_field.year,men_matrix_field.team_id)
--and r.round_id=1
--and men_matrix_field.round_id between 1 and 2
--and r.seed is not null;

--update ita.men_matrix_field
--set field='away'
--from ita.men_rounds r
--where (r.year,r.team_id)=
--      (men_matrix_field.year,men_matrix_field.team_id)
--and r.round_id=1
--and men_matrix_field.round_id between 1 and 2
--and r.seed is null;

-- Baylor

update ita.men_matrix_field
set field='home'
where (year,team_id)=(2015,10);

update ita.men_matrix_field
set field='away'
where (year,opponent_id)=(2015,10);

commit;
