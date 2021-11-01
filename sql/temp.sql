
create index indiv_code_idx on indiv_code(code);
drop index indiv_code_idx;
drop index indiv_code_hash_idx;

explain(verbose, analyze, buffers)
select 'founded indivs by snils_part  : ' || coalesce((select string_agg(sname, ', ') from indiv i where i.id in
                                         (select indiv_id from indiv_code ic where ic.code like '123' || '%' and type_id = 1)), 'nothing')


--SET max_parallel_workers_per_gather = 0;
explain(verbose, analyze, buffers)
select * from indiv_code ic where ic.type_id = 1 order by code limit 50


create extension pg_trgm;
create index gin_indiv_code_code_idx on indiv_code using gin(code gin_trgm_ops);
drop index gin_indiv_code_code_idx

explain(verbose, analyze, buffers)
select * from indiv_code where code like '56718%'


create table temp(id int);

begin;
create index temp_id_idx on temp using hash(id);
rollback;
drop index temp_id_idx

explain
select * from temp where id = 1


drop table if exists t1;
drop table if exists t2;
create table t1 (code text);
insert into t1(code)
select
    md5(random()::text)
from generate_series(1, 100000);

create table t2 (code text);
insert into t2(code)
select
    md5(random()::text)
from generate_series(1, 100000);

explain(verbose, analyze, buffers)
select * from t1 left join t2 on t1.code = t2.code;

explain(verbose, analyze, buffers)
select * from t2 order by code limit 10

create index t1_code on t1(code text_pattern_ops);
create index t2_code on t2(code text_pattern_ops);

explain(verbose, analyze, buffers)
select * from t1 join t2 on t1.code = t2.code;

cluster verbose t1 using t1_code;
cluster verbose t2 using t2_code;

explain(verbose, analyze, buffers)
select * from t1 left join t2 on t1.code = t2.code;

analyze t1;

analyze t2;

explain(verbose, analyze, buffers)
select * from t1 left join t2 on t1.code = t2.code
order by t1.code limit 10

select * from pg_settings where name ilike '%seq%'
set enable_seqscan = on



select decode(':')

















/*
http://google.com
file:///C:/PostgreSQL/data/logs/pg11/a.html#time-consuming-queries


file:///C:/PostgreSQL/data/logs/pg11/a.html#time-consuming-queries
*/









explain
select coalesce(
   (select concat_ws(' ', sname, fname, mname)
    from indiv
    where id = (select indiv_id
                from indiv_code
                where code = 'd0cd20f38f1c73cde6db4b8ce2fcffd6' and type_id = 1)),
   'indiv not found'
);