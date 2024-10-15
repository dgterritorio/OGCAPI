
-- LOOP through municipios

DO
$$
declare
    temprow record;
BEGIN
FOR temprow IN
        SELECT distinct municipio FROM crus_31_julho2024
    LOOP
        EXECUTE format ('CREATE MATERIALIZED VIEW IF NOT EXISTS "v_%s" AS'
        ' select * from crus_31_julho2024 where municipio LIKE %L WITH DATA', 
        lower(replace(temprow.municipio, ' ', '')), temprow.municipio);
    END LOOP;
END
$$ LANGUAGE plpgsql;
