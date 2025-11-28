------------------------------------------------------------
-- 01_oltp.sql
-- Etapa: OLTP (normalização)
-- Compatível 100% com as colunas REAIS do CSV fornecido
------------------------------------------------------------

-- 1. Limpar tabelas antigas (idempotência)
DROP TABLE IF EXISTS oltp_country;
DROP TABLE IF EXISTS oltp_energy_source;
DROP TABLE IF EXISTS oltp_energy_event;

------------------------------------------------------------
-- 2. TABELA DE PAÍSES
------------------------------------------------------------

CREATE TABLE oltp_country AS
SELECT DISTINCT
    iso_code,
    country AS country_name,
    population,
    gdp
FROM staging_energy
WHERE iso_code IS NOT NULL
ORDER BY country_name;

------------------------------------------------------------
-- 3. TABELA DE FONTES DE ENERGIA
------------------------------------------------------------

CREATE TABLE oltp_energy_source AS
SELECT *
FROM (
    VALUES
        ('solar'),
        ('wind'),
        ('hydro'),
        ('biofuel'),
        ('nuclear'),
        ('coal'),
        ('gas'),
        ('oil'),
        ('renewables'),
        ('low_carbon'),
        ('fossil')
) AS t(energy_source_name);

------------------------------------------------------------
-- 4. TABELA DE EVENTOS ENERGÉTICOS
-- Usando SOMENTE colunas que realmente existem no CSV
------------------------------------------------------------

CREATE TABLE oltp_energy_event AS
SELECT
    iso_code,
    year,

    -----------------------------
    -- SOLAR
    -----------------------------
    solar_consumption,
    solar_electricity,
    solar_elec_per_capita,
    solar_energy_per_capita,
    solar_share_elec,
    solar_share_energy,

    -----------------------------
    -- WIND
    -----------------------------
    wind_consumption,
    wind_electricity,
    wind_elec_per_capita,
    wind_energy_per_capita,
    wind_share_elec,
    wind_share_energy,

    -----------------------------
    -- HYDRO
    -----------------------------
    hydro_consumption,
    hydro_electricity,
    hydro_elec_per_capita,
    hydro_energy_per_capita,
    hydro_share_elec,
    hydro_share_energy,

    -----------------------------
    -- BIOFUEL
    -----------------------------
    biofuel_consumption,
    biofuel_electricity,
    biofuel_elec_per_capita,
    biofuel_share_elec,
    biofuel_share_energy,

    -----------------------------
    -- COAL
    -----------------------------
    coal_consumption,
    coal_electricity,
    coal_elec_per_capita,
    coal_share_elec,
    coal_share_energy,

    -----------------------------
    -- GAS
    -----------------------------
    gas_consumption,
    gas_electricity,
    gas_elec_per_capita,
    gas_share_elec,
    gas_share_energy,

    -----------------------------
    -- OIL
    -----------------------------
    oil_consumption,
    oil_electricity,
    oil_elec_per_capita,
    oil_share_elec,
    oil_share_energy,

    -----------------------------
    -- NUCLEAR
    -----------------------------
    nuclear_consumption,
    nuclear_electricity,
    nuclear_elec_per_capita,
    nuclear_share_elec,
    nuclear_share_energy,

    -----------------------------
    -- RENEWABLES / LOW CARBON
    -----------------------------
    renewables_consumption,
    renewables_electricity,
    renewables_elec_per_capita,
    renewables_share_elec,
    renewables_share_energy,

    low_carbon_consumption,
    low_carbon_electricity,
    low_carbon_elec_per_capita,
    low_carbon_share_elec,
    low_carbon_share_energy,

    -----------------------------
    -- OUTRAS MÉTRICAS GERAIS
    -----------------------------
    electricity_generation,
    electricity_demand,
    electricity_demand_per_capita,
    energy_per_capita,
    energy_per_gdp,
    primary_energy_consumption,

    -- emissões: ESTA COLUNA EXISTE
    greenhouse_gas_emissions,

    -- população (p/ coortes futuras)
    population

FROM staging_energy
WHERE iso_code IS NOT NULL
ORDER BY iso_code, year;
