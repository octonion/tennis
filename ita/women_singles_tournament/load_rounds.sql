begin;

-- rounds

drop table if exists ita.women_singles_rounds;

create table ita.women_singles_rounds (
	year				integer,
	round_id			integer,
	division_id			integer,
	player_id			integer,
	player_name			text,
	team_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,player_id)
);

copy ita.women_singles_rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists ita.women_singles_matrix_p;

create table ita.women_singles_matrix_p (
	year				integer,
	player_id			integer,
	opponent_id			integer,
	player_p			float,
	opponent_p			float,
	primary key (year,player_id,opponent_id)
);

insert into ita.women_singles_matrix_p
(year,player_id,opponent_id,player_p,opponent_p)
(select
r1.year,
r1.player_id,
r2.player_id,

exp(h.estimate-v.estimate)/(1+exp(h.estimate-v.estimate))
as home_p,

1-exp(h.estimate-v.estimate)/(1+exp(h.estimate-v.estimate))
as visitor_p

from ita.women_singles_rounds r1
join ita.women_singles_rounds r2
  on ((r2.year)=(r1.year) and not((r2.player_id)=(r1.player_id)))

join ita.sw_basic_factors h
  on (h.factor,h.level)=('player',r1.player_id::text)
join ita.sw_basic_factors v
  on (v.factor,v.level)=('player',r2.player_id::text)
);

commit;
