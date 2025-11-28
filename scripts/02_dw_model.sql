------------------------------------------------------------
-- 02_dw_model.sql
-- Estrutura do Data Warehouse (modelo estrela)
-- Criação das dimensões e da tabela fato
------------------------------------------------------------

------------------------------------------------------------
-- 1. Remover tabelas antigas (idempotência)
------------------------------------------------------------
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_energy_source;
DROP TABLE IF EXISTS fact_energy;

------------------------------------------------------------
-- 2. DIM_DATE (dimensão de tempo)
-- Será populada automaticamente no ETL
------------------------------------------------------------
CREATE TABLE dim_date (
    date_key        INTEGER PRIMARY KEY,
    full_date       DATE,
    year            INTEGER,
    month           INTEGER,
    day             INTEGER,
    quarter         INTEGER,
    month_name      VARCHAR
);

------------------------------------------------------------
-- 3. DIM_COUNTRY (SCD TIPO 2)
-- Controla mudanças históricas de população, gdp etc.
------------------------------------------------------------
CREATE TABLE dim_country (
    country_key     INTEGER PRIMARY KEY,
    iso_code        VARCHAR,
    country_name    VARCHAR,
    population      DOUBLE,
    gdp             DOUBLE,

    -- Controle SCD2
    start_date      DATE,
    end_date        DATE,
    is_current      BOOLEAN
);

------------------------------------------------------------
-- 4. DIM_ENERGY_SOURCE
------------------------------------------------------------
CREATE TABLE dim_energy_source (
    energy_source_key   INTEGER PRIMARY KEY,
    energy_source_name  VARCHAR
);

------------------------------------------------------------
-- 5. FACT_ENERGY
-- Tabela fato principal do projeto
------------------------------------------------------------
CREATE TABLE fact_energy (
    fact_key                    INTEGER PRIMARY KEY,

    -- Chaves estrangeiras
    date_key                    INTEGER,
    country_key                 INTEGER,
    energy_source_key           INTEGER,

    -- Métricas principais
    consumption                 DOUBLE,
    electricity                 DOUBLE,
    per_capita                  DOUBLE,
    share_electricity           DOUBLE,
    share_energy                DOUBLE,

    greenhouse_gas_emissions    DOUBLE,
    population                  DOUBLE,


);
