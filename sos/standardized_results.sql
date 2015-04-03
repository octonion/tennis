begin;

drop table if exists ita.results;

create table if not exists ita.results (
	game_date	      date,
	year		      integer,
	team_id		      integer,
	opponent_id	      integer,
	field		      text,
	team_score	      integer,
	opponent_score	      integer
);

insert into ita.results
(game_date,
 year,
 team_id, opponent_id,
 field,
 team_score, opponent_score)
(
select
tr.game_date,
extract(year from tr.game_date) as year,
tr.team_id,
tr.opponent_id,

(case when tr.opponent_string like 'at %' then 'defense_home'
      else 'offense_home'
end) as field,

(case when score in ('Scheduled','Not Played') then null
      when score='' then null
      when outcome='Win' then split_part(score,'-',1)::integer
      when outcome='Loss' then split_part(score,'-',2)::integer
end) as team_score,

(case when score in ('Scheduled','Not Played') then null
      when score='' then null
      when outcome='Win' then split_part(score,'-',2)::integer
      when outcome='Loss' then split_part(score,'-',1)::integer
end) as opponent_score

from ita.team_results tr
where tr.league_id=1
);

commit;
