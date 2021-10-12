
create index indiv_code_idx on indiv_code(code);
drop index indiv_code_idx;
drop index indiv_code_hash_idx;

explain(verbose, analyze, buffers)
select 'founded indivs by snils_part  : ' || coalesce((select string_agg(sname, ', ') from indiv i where i.id in
                                         (select indiv_id from indiv_code ic where ic.code like '123' || '%' and type_id = 1)), 'nothing')


--SET max_parallel_workers_per_gather = 0;
explain(verbose, analyze, buffers)
select * from indiv_code ic where ic.type_id = 1 order by code limit 50