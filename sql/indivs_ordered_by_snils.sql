explain(verbose, analyze, buffers)													 
select sname, fname, mname, bdate, g.name, snils.code from indiv i
join gender g on g.id = i.gender_id
join indiv_code snils on snils.indiv_id = i.id and snils.type_id in (select id from indiv_code_type where code = 'SNILS')
order by snils.code limit 50