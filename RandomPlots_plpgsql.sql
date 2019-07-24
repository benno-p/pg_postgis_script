--Function with return ø
--It creates 2 tables
--quadraXXXX
--plotsXXXX
--inputs parameters : nb of plots, radius of plots, width of quadra, height of quadra
--a projection is apply to geom to display easier with QGIS (here EPSG:2154)
CREATE OR REPLACE FUNCTION public.random_plots(
    n integer, --number of points
    radius numeric, --size of radius in unit projection
    long_ integer, -- L width in unit projection
    larg_ integer -- l height in unit projection
)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE
    area_ integer;
    is_geom_null boolean;
BEGIN
area_:= long_*larg_;
IF ( ((PI()*(radius^2)) * n) < (area_) ) THEN 
--DROP TABLES
EXECUTE 'drop table if exists public.quadra'||area_||' ';
EXECUTE 'drop table if exists public.plots'||area_||' ';
--CREATE TABLES
EXECUTE 'CREATE TABLE quadra'||area_||' as select '''||n::text||'''::text as id, ST_GeomFromText(''POLYGON((0 0,0 '||larg_||','||long_||' '||larg_||','||long_||' 0, 0 0))'')::geometry as geom, ST_GeomFromText(''POLYGON EMPTY'')::geometry as geom_minus ;';
EXECUTE 'CREATE TABLE plots'||area_||' ( id_ text, geom geometry, x_ float, y_ float)';
EXECUTE 'UPDATE plots'||area_||' set geom = st_setsrid(geom,2154);';
EXECUTE 'UPDATE quadra'||area_||' set geom = st_setsrid(geom,2154);';
EXECUTE 'UPDATE quadra'||area_||' set geom_minus = st_setsrid(st_buffer(geom,-(@'||radius||')::numeric),2154);';
--LOOP
FOR i in 1..n LOOP
    EXECUTE ' WITH geom as (select geom_minus FROM quadra'||area_||' )
        insert into plots'||area_||' (id_,geom) 
            select '||i::text||n::text||', 
            st_buffer(ST_GeneratePoints( geom.geom_minus , 1::numeric ),
            ((@'||radius||')::numeric)) from geom  ';
    EXECUTE ' UPDATE quadra'||area_||' 
        set geom_minus = ST_Difference(geom_minus, (select st_buffer(geom,(@'||radius||')::numeric) from plots'||area_||' where id_ = '''||i::text||n::text||''' ) ) 
        where id= '''||n::text||''' ';
      EXECUTE ' SELECT ST_IsEmpty(geom_minus)  from quadra'||area_||' ' INTO is_geom_null;
    IF is_geom_null THEN
        RAISE EXCEPTION 'Unlucky, No more space available in the quadra '
            USING HINT = 'Try to re-run or Try with less plots';
        EXIT;
    END IF;
END LOOP;
EXECUTE 'UPDATE plots'||area_||' set 
    x_ = round(st_x(st_centroid(geom))::numeric,0),
    y_ = round(st_y(st_centroid(geom))::numeric,0)
    ';
RETURN;
ELSE
RAISE EXCEPTION '((π * radius²) * n plots) > (%) ', area_
      USING HINT = 'Please check your area';
END IF;
END;$BODY$;

select random_plots(30,0.4,10,10);




