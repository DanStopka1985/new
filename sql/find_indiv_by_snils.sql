select code from indiv_code where id = (select (random() * max(id))::int from indiv_code where type_id = 1);

explain(verbose, analyze, buffers)
select * from indiv_code ic where ic.code = '76ec84b443f2d86bdeb2ce50f1b985f3'