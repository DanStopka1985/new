--get random code for search in snils
select code from indiv_code where id = (select (random() * max(id))::int from indiv_code);

--searh
explain(verbose, analyze, buffers)
select coalesce(
               (select sname from indiv i where i.id  = (select indiv_id from indiv_code ic where ic.code = 'c95c304f7cb50afbfa5bc21b747f6508' and type_id = 1)), 'indiv not found'
           );

--drop index indiv_code_idx;
create index indiv_code_idx on indiv_code(code)