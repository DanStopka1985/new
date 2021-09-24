create or replace function get_snils_by_indiv_id(int) returns text as $$
  select code from indiv_code where indiv_id = $1 and type_id = 1
$$ language sql immutable;

create index indiv_code_indiv_id_idx on indiv_code(indiv_id);
drop index indiv_code_indiv_id_idx;

create index indiv_snils_idx on indiv((get_snils_by_indiv_id(id)));
drop index indiv_snils_idx;

explain(verbose, analyze, buffers)
select sname, fname, mname, bdate, g.name, get_snils_by_indiv_id(i.id) from indiv i
join gender g on g.id = i.gender_id
order by get_snils_by_indiv_id(i.id) limit 50