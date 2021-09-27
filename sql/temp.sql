explain(verbose, analyze, buffers)
select * from indiv_code where code = '85ba4c000e993993b81aa453cf45e541' and type_id = 1


alter table indiv_code add constraint uniq_code_type unique (code, type_id)


select code, count(*) from indiv_code group by code having count(1)>1