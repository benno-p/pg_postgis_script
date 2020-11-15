# Welcome to the pg_postgis_script !  
  
This git to keep some stuff : `select * from tips`, you will find :

## OpenLocationCode implementation _plpgsql_ :
pluscode for plpgsql, to get a code like : 8CXX5JMH+  
Create OLCode in PostgreSQL/Postgis with a lat/lng pair.  
More about [OpenLocationCode](https://plus.codes/).

## RandomPlots _plpgsql_ :  
_require postgis 2.3.0 with the excellent function --> `ST_GeneratePoints( g geometry , npoints numeric )`;_  
To create this in your db(Use Qgis to view):  
<img src="http://cen-normandie.com/doc_images/random_plots.PNG" alt="RandomPlots" width="240" height="240">  
  
## Anti-Join _sql_ :  
(Faster than NOT IN) :  
`SELECT o.id  FROM table o WHERE NOT EXISTS (SELECT distinct(v.id) FROM table_2 v WHERE o.id = v.id)`,
That reduces execution time from 1h30 to 39 sec. !

## CleaningOverlappingPolygons _sql_ :  
All is in the subtitle.  
Use too ![ST_MakeValid(geometry input);](https://postgis.net/docs/ST_MakeValid.html) with it.
