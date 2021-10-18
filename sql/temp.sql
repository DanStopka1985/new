
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

