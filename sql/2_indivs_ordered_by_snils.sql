explain(verbose, analyze, buffers)
select sname, fname, mname, bdate, snils.code from indiv i
join indiv_code snils on snils.indiv_id = i.id and snils.type_id = (select id from indiv_code_type where code = 'SNILS')
order by snils.code limit 50


