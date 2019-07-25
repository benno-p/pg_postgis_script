-- ANTI JOIN
-- table_ > 1400000 entities | table_2 > 1100000 entities
-- execution time : 39 sec 
SELECT o.id  from table_2 o where 
NOT EXISTS 
    (SELECT distinct(v.id) 
    FROM table_ v 
    WHERE o.id = v.id);

-- execution time : stopped after 1h30
select o.id  from table_2 o
where o.id 
NOT IN (select distinct(v.id) from table_ v);
