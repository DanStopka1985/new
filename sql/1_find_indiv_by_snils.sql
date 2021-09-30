--получаем случайный идентификатор индивида
select code from indiv_code where id = (select (random() * max(id))::int from indiv_code);

--ищем полученный код среди имеющихся СНИЛС и достаем индивида
select coalesce(
    (select concat_ws(' ', sname, fname, mname) from indiv i
        where i.id  = (select indiv_id from indiv_code ic where ic.code = 'd0cd20f38f1c73cde6db4b8ce2fcffd6' and type_id = 1)),
    'indiv not found'
);
























explain(verbose, analyse, buffers)
select coalesce(
               (select concat_ws(' ', sname, fname, mname) from indiv i
                where i.id  = (select indiv_id from indiv_code ic where ic.code = 'd0cd20f38f1c73cde6db4b8ce2fcffd6' and type_id = 1)),
               'indiv not found'
           );





















--drop index indiv_code_idx;
create index indiv_code_idx on indiv_code(code)