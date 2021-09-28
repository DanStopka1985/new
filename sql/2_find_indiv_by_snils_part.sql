--get random code for search in snils
select code, substr(code,2, 8), type_id from indiv_code where id = (select (random() * max(id))::int from indiv_code);

--searh
explain(verbose, analyze, buffers)
SELECT 'founded indivs by snils_part ' || '3398657c' || ': ' || coalesce(( SELECT string_agg(sname, ', ') FROM indiv i WHERE i.id IN ( SELECT indiv_id FROM indiv_code ic WHERE ic.code LIKE '%' || '3398657c' || '%' AND type_id = 1)), 'nothing');


















create extension pg_trgm;
create index gin_indiv_code_code_idx on indiv_code using gin(code gin_trgm_ops);

--drop index gin_indiv_code_code_idx;
