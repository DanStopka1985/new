/*
Теперь представим другой тип запросов – сортировка. Частая задача – вывод списка с сортировкой по колонке. Для примера будем сортировать индивидов по СНИЛС.
Обычно не нужны сразу все отсортированные данные, нужны постранично, поставим лимит 50
Посмотрим план запроса
*/
explain(verbose, analyze, buffers)
select indiv_id from indiv_code where type_id = 1
order by code
limit 50;

/*
Конечный узел опять seq scan
Для уменьшения количества текста, уберу параллельное сканирование
*/

SET max_parallel_workers_per_gather = 0;
explain(verbose, analyze, buffers)
select indiv_id from indiv_code where type_id = 1
order by code
limit 50;

/*
Здесь мы видим полный обход таблицы и только потом сортировку (top-N heapsort)
Т.е. наш индекс для сортировки не используется. Это особенность самой структуры (HASH таблицы),
где пары [хэш-код – ссылка на строку таблицы] хранятся в произвольном порядке.
Снова создадим индекс btree по сортируемому полю.
*/



create index indiv_code_code_idx on indiv_code using btree (code);
/*
выполним explain
*/

explain(verbose, analyze, buffers)
select indiv_id from indiv_code where type_id = 1
order by code
limit 50;
/*
Теперь видно, что при сортировке сканируется индекс, и не полностью, а только 50 записей.
Сама структура b-tree – это упорядоченное сбалансированное дерево, где элементы уже упорядочены.
Ненадолго вернемся к поиску по ключу.
*/

explain(verbose, analyze, buffers)
select code from indiv_code where code = '123';
/*
А здесь по-прежнему используется хэш индекс
удалим его для эксперимента и снова explain
*/
drop index indiv_code_hash_idx;
explain(verbose, analyze, buffers)
select code from indiv_code where code = '123';
/*
Сейчас в explain используется index only scan.
В хэш-индексе хранится только ссылка на строку таблицы, а в btree индексе еще и сами данные.
При использовании BTREE, если необходимые данные уже есть в индексе,
    не нужно идти в саму таблицу и совершать дополнительные считывания с диска – это называется покрывающий индекс.
*/

/*
Так же и при сортировке по коду, если вывести нам нужно только код, то будет index only scan
*/
explain(verbose, analyze, buffers)
select code from indiv_code order by code limit 50;
/*
Но нам необходимо отсортировать именно ИНДИВИДОВ по СНИЛС, поэтому просто добавим ключ индивида в индекс.
Так же в условии индекса укажем, что нам нужен именно СНИЛС (в условии where),
    и в запросе должно быть точно такое же условие в where – это называется частичный индекс.
*/

create index indiv_code_snils_indiv_id_idx on indiv_code(code, indiv_id) where type_id = 1;

explain(verbose, analyze, buffers)
select indiv_id, code from indiv_code where type_id = 1 order by code limit 50;

/*
Теперь используется index only scan и для сортировки и для вывода, к таблице обращений вообще не происходит
Мы создали частичный составной покрывающий индекс
Частичный индекс хорош тем, что он занимает меньше места чем индекс без условий.
Важно заметить, что если мы хотим использовать частичный индекс, то в запросе обязательно должно быть условие как в индексе.
*/
/*
В полном запросе будет выводиться еще и информация об индивиде, так что с нашим индексом все же будет обращение к таблице
explain
*/

explain(verbose, analyze, buffers)
select sname, fname, mname, bdate, snils.code from indiv i
join indiv_code snils on snils.indiv_id = i.id and snils.type_id = 1
order by snils.code
limit 50;

/*
в плане берутся первые 50 узлов индекса (в алфавитном порядке СНИЛС), затем из этих узлов берутся indiv_id
и по ним идет index scan индекса первичного ключа индивидов
Nested loop - это одна из стратегий (алгоритмов) соединения join
В нашем случае указано, что loops=1 - все происходит в 1 цикл

без наших индексов план общего запроса с сортиовкой был бы таким
*/

drop index indiv_code_snils_indiv_id_idx;
drop index indiv_code_code_idx;

explain(verbose, analyze, buffers)
select sname, fname, mname, bdate, snils.code from indiv i
                                                       join indiv_code snils on snils.indiv_id = i.id and snils.type_id = 1
order by snils.code
limit 50;

/*
Так как у планировщика нет индексов он принимает решение применить Hash Join стратегию для соединения таблиц
Для этого ему нужно обойти обе таблицы и по сути создать временные хэш индексы для соединения
После этого отсортировать
*/

-----------------------------------------------------------------------------------------------------------------------






explain(verbose, analyze, buffers)
select indiv_id, code from indiv_code where code like '%561%' and /*code like '0%' and*/ type_id = 1 order by code limit 10




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
