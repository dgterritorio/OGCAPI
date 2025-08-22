
-- User and schema setup for CAOP
CREATE USER caop_user LOGIN PASSWORD 'caop_password' NOINHERIT;

CREATE SCHEMA IF NOT EXISTS "CAOP2024.1" AUTHORIZATION caop_user;

GRANT ALL PRIVILEGES ON SCHEMA "CAOP2024.1" TO caop_user;

GRANT USAGE, CREATE ON SCHEMA public TO caop_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO caop_user;

ALTER DEFAULT PRIVILEGES FOR ROLE caop_user GRANT ALL ON TABLES TO caop_user;
ALTER DEFAULT PRIVILEGES FOR ROLE caop_user GRANT ALL ON SEQUENCES TO caop_user;

GRANT SELECT ON public.spatial_ref_sys TO caop_user;
GRANT SELECT, INSERT, DELETE ON public.geometry_columns TO caop_user;

ALTER USER caop_user SET search_path TO "CAOP2024.1", public;

-- User and schema setup for INSPIRE
CREATE USER inspire_user LOGIN PASSWORD 'inspire_password' NOINHERIT;

CREATE SCHEMA IF NOT EXISTS inspire AUTHORIZATION inspire_user;

GRANT ALL PRIVILEGES ON SCHEMA inspire TO inspire_user;

GRANT USAGE, CREATE ON SCHEMA public TO inspire_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO inspire_user;

ALTER DEFAULT PRIVILEGES FOR ROLE inspire_user GRANT ALL ON TABLES TO inspire_user;
ALTER DEFAULT PRIVILEGES FOR ROLE inspire_user GRANT ALL ON SEQUENCES TO inspire_user;

GRANT SELECT ON public.spatial_ref_sys TO inspire_user;
GRANT SELECT, INSERT, DELETE ON public.geometry_columns TO inspire_user;

ALTER USER inspire_user SET search_path TO public, inspire;


-- Tables and indexes

-- Table: "CAOP2024.1".cont_areas_administrativas
CREATE TABLE "CAOP2024.1".cont_areas_administrativas (
    id BIGINT PRIMARY KEY,
    dtmnfr VARCHAR(8),
    freguesia VARCHAR,
    tipo_area_administrativa VARCHAR(100),
    municipio VARCHAR,
    distrito_ilha VARCHAR,
    nuts3 VARCHAR,
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(Polygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER
);
ALTER TABLE "CAOP2024.1".cont_areas_administrativas OWNER TO caop_user;
CREATE UNIQUE INDEX cont_areas_administrativas_id_idx ON "CAOP2024.1".cont_areas_administrativas (id);
CREATE INDEX cont_areas_administrativas_geometria_idx ON "CAOP2024.1".cont_areas_administrativas USING gist (geometria);

-- Table: "CAOP2024.1".cont_distritos
CREATE TABLE "CAOP2024.1".cont_distritos (
    dt TEXT PRIMARY KEY,
    distrito VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios BIGINT,
    n_freguesias NUMERIC
);
ALTER TABLE "CAOP2024.1".cont_distritos OWNER TO caop_user;
CREATE UNIQUE INDEX cont_distritos_dt_idx ON "CAOP2024.1".cont_distritos (dt);
CREATE INDEX cont_distritos_geometria_idx ON "CAOP2024.1".cont_distritos USING gist (geometria);

-- Table: "CAOP2024.1".cont_freguesias
CREATE TABLE "CAOP2024.1".cont_freguesias (
    dtmnfr VARCHAR(8),
    freguesia VARCHAR,
    municipio VARCHAR,
    distrito_ilha VARCHAR,
    nuts3 VARCHAR,
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    designacao_simplificada TEXT
);
ALTER TABLE "CAOP2024.1".cont_freguesias OWNER TO caop_user;
CREATE UNIQUE INDEX cont_freguesias_dtmnfr_idx ON "CAOP2024.1".cont_freguesias (dtmnfr);
CREATE INDEX cont_freguesias_geometria_idx ON "CAOP2024.1".cont_freguesias USING gist (geometria);

-- Table: "CAOP2024.1".cont_municipios
CREATE TABLE "CAOP2024.1".cont_municipios (
    dtmn TEXT,
    municipio VARCHAR,
    distrito_ilha VARCHAR,
    nuts3 VARCHAR,
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_freguesias BIGINT
);
ALTER TABLE "CAOP2024.1".cont_municipios OWNER TO caop_user;
CREATE UNIQUE INDEX cont_municipios_dtmn_idx ON "CAOP2024.1".cont_municipios (dtmn);
CREATE INDEX cont_municipios_geometria_idx ON "CAOP2024.1".cont_municipios USING gist (geometria);

-- Table: "CAOP2024.1".cont_nuts1
CREATE TABLE "CAOP2024.1".cont_nuts1 (
    codigo VARCHAR(3),
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios NUMERIC,
    n_freguesias NUMERIC
);
ALTER TABLE "CAOP2024.1".cont_nuts1 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts1_codigo_idx ON "CAOP2024.1".cont_nuts1 (codigo);
CREATE INDEX cont_nuts1_geometria_idx ON "CAOP2024.1".cont_nuts1 USING gist (geometria);

-- Table: "CAOP2024.1".cont_nuts2
CREATE TABLE "CAOP2024.1".cont_nuts2 (
    codigo VARCHAR(4),
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios NUMERIC,
    n_freguesias NUMERIC
);
ALTER TABLE "CAOP2024.1".cont_nuts2 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts2_codigo_idx ON "CAOP2024.1".cont_nuts2 (codigo);
CREATE INDEX cont_nuts2_geometria_idx ON "CAOP2024.1".cont_nuts2 USING gist (geometria);

-- Table: "CAOP2024.1".cont_nuts3
CREATE TABLE "CAOP2024.1".cont_nuts3 (
    id BIGINT,
    codigo VARCHAR(5),
    nuts3 VARCHAR,
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios BIGINT,
    n_freguesias NUMERIC
);
ALTER TABLE "CAOP2024.1".cont_nuts3 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts3_codigo_idx ON "CAOP2024.1".cont_nuts3 (codigo);
CREATE INDEX cont_nuts3_geometria_idx ON "CAOP2024.1".cont_nuts3 USING gist (geometria);

-- Table: "CAOP2024.1".cont_trocos
CREATE TABLE "CAOP2024.1".cont_trocos (
    identificador UUID,
    ea_direita VARCHAR(8),
    ea_esquerda VARCHAR(8),
    paises VARCHAR(100),
    estado_limite_admin VARCHAR(100),
    significado_linha VARCHAR(100),
    nivel_limite_admin VARCHAR(100),
    geometria geometry(LineString, 3763),
    comprimento_km DOUBLE PRECISION
);
ALTER TABLE "CAOP2024.1".cont_trocos OWNER TO caop_user;
CREATE UNIQUE INDEX cont_trocos_identificador_idx ON "CAOP2024.1".cont_trocos (identificador);
CREATE INDEX cont_trocos_geometria_idx ON "CAOP2024.1".cont_trocos USING gist (geometria);


CREATE TABLE inspire.mv_cadastralparcel_4326 (
    geometry                   geometry,
    inspireid                  text,
    label                      character varying,
    nationalcadastralreference character varying,
    areavalue                  double precision,
    validfrom                  timestamp with time zone,
    validto                    timestamp with time zone,
    beginlifespanversion       timestamp with time zone,
    endlifespanversion         timestamp with time zone,
    administrativeunit         character varying,
    id                         integer,
    CONSTRAINT idx_id_mv_cp4326 UNIQUE (id),
    CONSTRAINT idx_ncr_mv_cp4326 UNIQUE (nationalcadastralreference)
);
ALTER TABLE inspire.mv_cadastralparcel_4326 OWNER TO inspire_user;
-- Indexes
CREATE INDEX idx_geom_mv_cp4326 ON inspire.mv_cadastralparcel_4326 USING gist (geometry);
