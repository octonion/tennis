begin;

drop table if exists ita.teams;

create table ita.teams (
	league_id	      integer,
	team_id		      integer,
        team_name	      text,
	primary key (team_id)
);

copy ita.teams from '/tmp/ita_team.csv' csv header;

commit;
