--Cleaning Overlapping Polygons
CREATE TABLE final_shape AS
WITH 
UNION_ AS
(SELECT  ST_Union(st_intersection(a.geom, b.geom)) AS geom_intersection
FROM test a, test b
WHERE a.id <> b.id), 
DIFFERENCE_ AS
(SELECT ST_DIFFERENCE(geom , geom_intersection) as geom_difference FROM test a, UNION_)
SELECT geom_intersection FROM UNION_
UNION
SELECT geom_difference FROM DIFFERENCE_;
