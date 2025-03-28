-- User and schema setup
CREATE USER caop_user LOGIN PASSWORD 'caop_password' NOINHERIT;

CREATE SCHEMA IF NOT EXISTS caop2024 AUTHORIZATION caop_user;

GRANT ALL PRIVILEGES ON SCHEMA caop2024 TO caop_user;

GRANT USAGE, CREATE ON SCHEMA public TO caop_user;

ALTER DEFAULT PRIVILEGES FOR ROLE caop_user GRANT ALL ON TABLES TO caop_user;
ALTER DEFAULT PRIVILEGES FOR ROLE caop_user GRANT ALL ON SEQUENCES TO caop_user;

GRANT SELECT ON public.spatial_ref_sys TO caop_user;
GRANT SELECT, INSERT, DELETE ON public.geometry_columns TO caop_user;

ALTER USER caop_user SET search_path TO caop2024, public;

-- Tables and indexes

-- Table: caop2024.cont_areas_administrativas
CREATE TABLE caop2024.cont_areas_administrativas (
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
ALTER TABLE caop2024.cont_areas_administrativas OWNER TO caop_user;
CREATE UNIQUE INDEX cont_areas_administrativas_id_idx ON caop2024.cont_areas_administrativas (id);
CREATE INDEX cont_areas_administrativas_geometria_idx ON caop2024.cont_areas_administrativas USING gist (geometria);

-- Table: caop2024.cont_distritos
CREATE TABLE caop2024.cont_distritos (
    dt TEXT PRIMARY KEY,
    distrito VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios BIGINT,
    n_freguesias NUMERIC
);
ALTER TABLE caop2024.cont_distritos OWNER TO caop_user;
CREATE UNIQUE INDEX cont_distritos_dt_idx ON caop2024.cont_distritos (dt);
CREATE INDEX cont_distritos_geometria_idx ON caop2024.cont_distritos USING gist (geometria);

-- Table: caop2024.cont_freguesias
CREATE TABLE caop2024.cont_freguesias (
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
ALTER TABLE caop2024.cont_freguesias OWNER TO caop_user;
CREATE UNIQUE INDEX cont_freguesias_dtmnfr_idx ON caop2024.cont_freguesias (dtmnfr);
CREATE INDEX cont_freguesias_geometria_idx ON caop2024.cont_freguesias USING gist (geometria);

-- Table: caop2024.cont_municipios
CREATE TABLE caop2024.cont_municipios (
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
ALTER TABLE caop2024.cont_municipios OWNER TO caop_user;
CREATE UNIQUE INDEX cont_municipios_dtmn_idx ON caop2024.cont_municipios (dtmn);
CREATE INDEX cont_municipios_geometria_idx ON caop2024.cont_municipios USING gist (geometria);

-- Table: caop2024.cont_nuts1
CREATE TABLE caop2024.cont_nuts1 (
    codigo VARCHAR(3),
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios NUMERIC,
    n_freguesias NUMERIC
);
ALTER TABLE caop2024.cont_nuts1 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts1_codigo_idx ON caop2024.cont_nuts1 (codigo);
CREATE INDEX cont_nuts1_geometria_idx ON caop2024.cont_nuts1 USING gist (geometria);

-- Table: caop2024.cont_nuts2
CREATE TABLE caop2024.cont_nuts2 (
    codigo VARCHAR(4),
    nuts2 VARCHAR,
    nuts1 VARCHAR,
    geometria geometry(MultiPolygon, 3763),
    area_ha NUMERIC(15,2),
    perimetro_km INTEGER,
    n_municipios NUMERIC,
    n_freguesias NUMERIC
);
ALTER TABLE caop2024.cont_nuts2 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts2_codigo_idx ON caop2024.cont_nuts2 (codigo);
CREATE INDEX cont_nuts2_geometria_idx ON caop2024.cont_nuts2 USING gist (geometria);

-- Table: caop2024.cont_nuts3
CREATE TABLE caop2024.cont_nuts3 (
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
ALTER TABLE caop2024.cont_nuts3 OWNER TO caop_user;
CREATE UNIQUE INDEX cont_nuts3_codigo_idx ON caop2024.cont_nuts3 (codigo);
CREATE INDEX cont_nuts3_geometria_idx ON caop2024.cont_nuts3 USING gist (geometria);

-- Table: caop2024.cont_trocos
CREATE TABLE caop2024.cont_trocos (
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
ALTER TABLE caop2024.cont_trocos OWNER TO caop_user;
CREATE UNIQUE INDEX cont_trocos_identificador_idx ON caop2024.cont_trocos (identificador);
CREATE INDEX cont_trocos_geometria_idx ON caop2024.cont_trocos USING gist (geometria);
