
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
        -- Normalize - lower case, remove spaces and '-', 
        -- remove accents and other special characters
            replace(trim(regexp_replace(translate(
                lower(replace(replace(temprow.municipio, ' ', ''),'-','')),
                'áàâãäåāăąèééêëēĕėęěìíîïìĩīĭḩóôõöōŏőùúûüũūŭůäàáâãåæçćĉčöòóôõøüùúûßéèêëýñîìíïş',
                'aaaaaaaaaeeeeeeeeeeiiiiiiiihooooooouuuuuuuuaaaaaaeccccoooooouuuuseeeeyniiiis'
            ), '[^a-z0-9\-]+', ' ', 'g')),' ', '-')
        , temprow.municipio);

    END LOOP;
END
$$ LANGUAGE plpgsql;
