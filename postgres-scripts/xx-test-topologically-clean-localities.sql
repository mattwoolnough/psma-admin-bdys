

-- Find bowties and duplicate coords -- 17961
SELECT locality_pid, lng, lat, cnt FROM (
	SELECT locality_pid, lng, lat, Count(*) as cnt FROM (
		SELECT locality_pid, ST_X(geom)::numeric(9,6) AS lng, ST_Y(geom)::numeric(8,6) AS lat FROM (
			SELECT locality_pid, (ST_Dump(ST_Points(geom))).geom AS geom FROM admin_bdys_201611.locality_bdys_display	
		) AS sqt
	) AS sqt2
	GROUP BY locality_pid, lng, lat
) AS sqt3
WHERE cnt > 1;


-- Total points
SELECT SUM(ST_NPoints(geom)) FROM admin_bdys_201611.locality_bdys_display; -- 4688805





-- nothinh below here works....

-- 
-- 
-- CREATE INDEX temp_final_localities_geom_idx ON admin_bdys.temp_final_localities USING gist (geom);
-- ALTER TABLE admin_bdys.temp_final_localities CLUSTER ON temp_final_localities_geom_idx;
-- 
-- 
-- 
-- -- create topologicaly correct 
-- 
-- with poly as (
--         select locality_pid, (st_dump(geom)).* 
--         from admin_bdys.temp_final_localities
-- ) select d.locality_pid, baz.geom 
--  from ( 
--         select (st_dump(st_polygonize(distinct geom))).geom as geom
--         from (
--                 select (st_dump(st_simplifyPreserveTopology(st_linemerge(st_union(geom)), 0.0001))).geom as geom
--                 from (
--                         select st_exteriorRing((st_dumpRings(geom)).geom) as geom
--                         from poly
--                 ) as foo
--         ) as bar
-- ) as baz,
-- poly d
-- where st_intersects(d.geom, baz.geom)
-- and st_area(st_intersection(d.geom, baz.geom))/st_area(baz.geom) > 0.5
-- and left(d.locality_pid, 3) = 'ACT';
-- 
-- 
-- 
-- 
-- 
-- --simplifyLayerPreserveTopology (schemaname text, tablename text, idcol text, geom_col text, tolerance float)
-- 
-- select simplifyLayerPreserveTopology ('admin_bdys', 'temp_final_localities', 'locality_pid', 'geom', 0.0001) 
--  from admin_bdys.temp_final_localities
--  where left(locality_pid, 3) = 'ACT';
-- 
-- 
-- 
--  
-- 
-- -- simplify and clean up data, removing unwanted artifacts -- 1 min -- 17751 
-- DROP TABLE IF EXISTS admin_bdys.temp_final_localities_topo_test;
-- CREATE TABLE admin_bdys.temp_final_localities_topo_test (
--   locality_pid character varying(16),
--   geom geometry
-- ) WITH (OIDS=FALSE);
-- ALTER TABLE admin_bdys.temp_final_localities_topo_test OWNER TO postgres;
-- 
-- INSERT INTO admin_bdys.temp_final_localities_topo_test (locality_pid, geom)
-- SELECT locality_pid,
--        (ST_Dump(ST_MakeValid(ST_Multi(ST_SnapToGrid(ST_SimplifyVW(geom, 0.000000003), 0.00001))))).geom
--   FROM admin_bdys.temp_final_localities;
--   --WHERE area > 0.05 OR locality_pid IN ('SA514', 'SA1015', 'SA1553', 'WA1705') --  preserve these locality polygons
-- 
-- 
-- DELETE FROM admin_bdys.temp_final_localities_topo_test WHERE ST_GeometryType(geom) <> 'ST_Polygon'; -- 38
-- 
-- 
-- 
-- 
-- 
-- 
