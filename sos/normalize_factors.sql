begin;

create temporary table years (
       first_year      integer,
       last_year       integer
);

insert into years
(first_year,last_year)
(select min(level::integer),max(level::integer)
from ita._parameter_levels
where parameter='year'
);

create table if not exists ita._factors (
       parameter		text,
       level			text,
       type			text,
       method			text,
       year			integer,
       first_year		integer,
       last_year		integer,
       raw_factor		float,
       exp_factor		float,
       factor			float
--       primary key (team_name,type,method,year,first_year,last_year)
);

truncate table ita._factors;

-- this can/should be rewritten agnostically
-- do random/fixed separately
-- test for the prescence of '/' using like

-- Random factors

-- defense,offense

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
split_part(npl.level,'/',2) as level,
npl.type as type,
'log_regression' as method,
split_part(npl.level,'/',1)::integer as year,
split_part(npl.level,'/',1)::integer as first_year,
split_part(npl.level,'/',1)::integer as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from ita._parameter_levels npl
left outer join ita._basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter in ('defense','offense')
);

-- other random

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from ita._parameter_levels npl
left outer join ita._basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter not in ('defense','offense')
);

-- Fixed factors

-- year

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
npl.level::integer as year,
npl.level::integer as first_year,
npl.level::integer as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from ita._parameter_levels npl
left outer join ita._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('year')
);

-- field

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from ita._parameter_levels npl
left outer join ita._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('field')
and npl.level not in ('neutral')
);

-- other fixed

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from ita._parameter_levels npl
left outer join ita._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter not in ('field','year')
);

create temporary table scale (
       parameter		text,
       mean			float,
       primary key (parameter)
);

insert into scale
(parameter,mean)
(select
parameter,
avg(raw_factor)
from ita._factors
where parameter not in ('o_div','d_div')
group by parameter
);

update ita._factors
set raw_factor=raw_factor-s.mean
from scale s
where s.parameter=_factors.parameter;

update ita._factors
set exp_factor=exp(raw_factor);

-- 'neutral' park confounded with 'neutral' field; set factor = 1.0 for field 'neutral'

insert into ita._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
values
('field','neutral','fixed','log_regression',null,null,null,0.0,1.0);

commit;
