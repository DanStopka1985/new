--SET max_parallel_workers_per_gather = 0;
explain(verbose, analyze, buffers)
select indiv_id from indiv_code where type_id = 1
order by code
limit 50;









create index indiv_code_code_idx on indiv_code using btree (code);









explain(verbose, analyze, buffers)
select code from indiv_code where code = '123';
drop index indiv_code_hash_idx;






explain(verbose, analyze, buffers)
select code from indiv_code order by code limit 50;





























drop index indiv_code_indiv_id_code_idx
create index indiv_code_indiv_id_code_idx on indiv_code(indiv_id, code);
create index indiv_code_code_indiv_id_idx on indiv_code(code, indiv_id);

explain(verbose, analyze, buffers)
select code from indiv_code where code = '123';










explain(verbose, analyze, buffers)
select sname, fname, mname, bdate, snils.code from indiv i
join indiv_code snils on snils.indiv_id = i.id and snils.type_id = 1
order by snils.code
limit 50









explain(verbose, analyze, buffers)
select ic.code snils, i.sname from indiv_code ic
join indiv i on i.id = ic.indiv_id
where type_id = 1 order by code
limit 50




drop index indiv_code_code_idx
create index indiv_code_code_idx on indiv_code(code)









--create index indiv_code_indiv_id_idx on indiv_code(indiv_id)
drop index indiv_code_indiv_id_idx

drop index indiv_id_idx
drop index indiv_code_indiv_id_idx
create index indiv_code_indiv_id_code_idx1 on indiv_code(code, indiv_id) where type_id = 1
drop index indiv_code_indiv_id_code_idx

select * from pg_settings where name ilike '%hash%'

set enable_hashjoin = on

set enable_mergejoin = on
