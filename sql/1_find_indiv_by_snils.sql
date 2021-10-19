--Теперь напишем запрос по поиску индивида по СНИЛС


--получаем случайный идентификатор индивида
-- (просто получаем случайную строку из идентификаторов без привязки к типу идентификатора)
select code
from indiv_code
where id = (select (random() * max(id))::int from indiv_code);

--ищем полученный код среди имеющихся СНИЛС и достаем индивида
select coalesce(
               (select concat_ws(' ', sname, fname, mname)
                from indiv i
                where i.id = (select indiv_id
                              from indiv_code ic
                              where ic.code = '5998ddb21630dfa8ac748ff9d9f96775' and type_id = 1)),
               'indiv not found'
           );
/**

 */

/*
запрос выполняется ~100ms
Вроде бы быстро, но попробуем запустить его 200ми пользователями
    -выполнить App1
    -сгенерировать pgbadger (shift+ctrl+b)
    -посмотреть top timeconsuming queries (alt+ctrl+t ; ctrl+c ; shift+ctrl+w)
        file:///C:/PostgreSQL/data/logs/pg11/a.html#time-consuming-queries

*/

/*
Для 200 условных пользователей общее время выполнения составляет уже около минуты
Для такого малого количества данных удалось получить уже серьезную нагрузку
Самый  долгий выполняется около минуты
*/

/*
Чтобы это ускорить, нужно понять, что именно долго работает
Если вкратце в Postgres есть оптимизатор, который строит для запроса оптимальный алгоритм выполнения (План запроса).
И затем выполняет этот алгоритм и достает нужные данные. Чтобы увидеть этот алгоритм нам поможет explain
https://www.postgresql.org/docs/14/sql-explain.html
что из этого мы будем смотреть:

analyze - говорит о том, что запрос надо выполнить и замерить, что по факту было затрачено
verbose - вывести дополнительную информацию о выполнении узлов, вывод колонок,
            используемые триггеры, названия псевдонимов и схем
Buffers говорит об используемой памяти так же для каждого узла
формат по умолчанию текст
*/

/*
Выполним explain для нашего запроса поиска.
explain представляет план запроса в виде дерева, каждый узел дерева - какое-то действие

*/
explain--(verbose, analyse, buffers)
select coalesce(
               (select concat_ws(' ', sname, fname, mname)
                from indiv i
                where i.id = (select indiv_id
                              from indiv_code ic
                              where ic.code = 'd0cd20f38f1c73cde6db4b8ce2fcffd6' and type_id = 1)),
               'indiv not found'
           );

SET max_parallel_workers_per_gather = 2;


/*
cost - стоимость выполнения узла. единица стоимости - абстрактная величина;
shared
*/

--drop index indiv_code_idx;
create index indiv_code_idx on indiv_code (code);


--просмотреть DDL создания индекса
select pg_get_indexdef('indiv_code_idx'::regclass);


--drop index indiv_code_hash_idx;
create index indiv_code_hash_idx on indiv_code using hash (code);



select pg_size_pretty(pg_table_size('indiv_code_hash_idx')) hash,
       pg_size_pretty(pg_table_size('indiv_code_idx'))      btree;
--drop index indiv_code_hash_idx;