drop table if exists indiv_code cascade;
drop table if exists indiv cascade;
drop table if exists indiv_code_type;
drop table if exists gender;

create table gender(
	id int primary key,
	name text,
	code text unique
);

insert into gender(id, name, code) 
	values (1, 'Мужской', 'MALE'), (2, 'Женский', 'FAMALE');

create table indiv(
	id serial primary key,
	sname text,
	fname text,
	mname text,
	bdate date,
	gender_id int references gender(id)
);

insert into indiv(sname, fname, mname, gender_id, bdate)
select
	md5(random()::text), md5(random()::text), md5(random()::text), (random() + 1)::int,
	(now() - interval '90 years') + random() * (now() - (now() - interval '90 years'))
from generate_series(1, 500000);

create table indiv_code_type(
	id int primary key,
	name text,
	code text
);

insert into indiv_code_type(id, name, code) 
	values (1, 'SNILS', 'SNILS'), (2, 'UID', 'UID');														 
														 
create table indiv_code(
	id serial primary key,
	indiv_id int references indiv(id),
	type_id int references indiv_code_type(id),
	code text,
	from_dt date,
	to_dt date
);

insert into indiv_code(indiv_id, type_id, code)
select id, 2, md5(random()::text) from indiv;
														 
insert into indiv_code(indiv_id, type_id, code)
select id, 1, md5(random()::text) from indiv;	