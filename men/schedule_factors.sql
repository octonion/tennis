begin;

create table if not exists ita.men_schedule_factors (
        school_id		integer,
	year			integer,
        offensive               float,
        defensive		float,
        strength                float,
        schedule_offensive      float,
        schedule_defensive      float,
        schedule_strength       float,
        schedule_offensive_all	float,
        schedule_defensive_all	float,
        primary key (school_id,year)
);

truncate table ita.men_schedule_factors;

-- defensive
-- offensive
-- strength 
-- schedule_offensive
-- schedule_defensive
-- schedule_strength 

insert into ita.men_schedule_factors
(school_id,year,offensive,defensive)
(
select o.level::integer,o.year,coalesce(o.exp_factor,1.0),coalesce(d.exp_factor,1.0)
from ita.men_factors o
left outer join ita.men_factors d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
where o.parameter='offense'
);

update ita.men_schedule_factors
set strength=offensive/defensive;

----

create temporary table r (
         school_id		integer,
	 school_div_id		integer,
         opponent_id		integer,
	 opponent_div_id	integer,
         game_date              date,
         year                   integer,
	 field_id		text,
         offensive              float,
         defensive		float,
         strength               float,
	 field			float,
	 o_div			float,
	 d_div			float
);

insert into r
(school_id,school_div_id,opponent_id,opponent_div_id,game_date,year,field_id)
(
select
r.team_id,
r.team_league_id,
r.opponent_id,
r.opponent_league_id,
r.game_date,
r.year,
r.field
from ita.results r
where r.year between 2009 and 2015
);

update r
set
offensive=o.offensive,
defensive=o.defensive,
strength=o.strength
from ita.men_schedule_factors o
where (r.opponent_id,r.year)=(o.school_id,o.year);

-- field

update r
set field=f.exp_factor
from ita.men_factors f
where (f.parameter,f.level)=('field',r.field_id);

-- opponent o_div

update r
--set o_div=coalesce(f.exp_factor,1.0)
set o_div=f.exp_factor
from ita.men_factors f
where (f.parameter,f.level::integer)=('o_div',r.opponent_div_id);

-- opponent d_div

update r
--set d_div=coalesce(f.exp_factor,1.0)
set d_div=f.exp_factor
from ita.men_factors f
where (f.parameter,f.level::integer)=('d_div',r.opponent_div_id);

create temporary table rs (
         school_id		integer,
         year                   integer,
         offensive              float,
         defensive              float,
         strength               float,
         offensive_all		float,
         defensive_all		float
);

--update r
--set o_div=1.0
--where o_div is null;

--update r
--set d_div=1.0
--where d_div is null;

insert into rs
(school_id,year,
 offensive,defensive,strength,offensive_all,defensive_all)
(
select
school_id,
year,
exp(avg(ln(offensive*o_div))),
exp(avg(ln(defensive*d_div))),
exp(avg(ln(strength*o_div/d_div))),
exp(avg(ln(offensive*o_div/field))),
exp(avg(ln(defensive*d_div*field)))
from r
group by school_id,year
);

update ita.men_schedule_factors
set
  schedule_offensive=rs.offensive,
  schedule_defensive=rs.defensive,
  schedule_strength=rs.strength,
  schedule_offensive_all=rs.offensive_all,
  schedule_defensive_all=rs.defensive_all
from rs
where
  (men_schedule_factors.school_id,men_schedule_factors.year)=
  (rs.school_id,rs.year);

commit;
