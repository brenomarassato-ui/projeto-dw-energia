------------------------------------------------------------
-- 03_etl_load.sql
-- ETL completo (dim_date, dimensões, fato)
-- Versão compatível com DuckDB CLI
------------------------------------------------------------

------------------------------------------------------------
-- 1. DIM_DATE
------------------------------------------------------------

DELETE FROM dim_date;

INSERT INTO dim_date
SELECT
    -- chave YYYYMMDD
    CAST(
        CAST(y AS VARCHAR) ||
        LPAD(CAST(m AS VARCHAR), 2, '0') ||
        LPAD(CAST(d AS VARCHAR), 2, '0')
        AS INTEGER
    ) AS date_key,

    -- data completa
    CAST(
        CAST(y AS VARCHAR) || '-' ||
        LPAD(CAST(m AS VARCHAR), 2, '0') || '-' ||
        LPAD(CAST(d AS VARCHAR), 2, '0')
        AS DATE
    ) AS full_date,

    y AS year,
    m AS month,
    d AS day,
    ((m - 1) / 3) + 1 AS quarter,

    strftime(
        '%B',
        CAST(
            CAST(y AS VARCHAR) || '-' ||
            LPAD(CAST(m AS VARCHAR), 2, '0') || '-' ||
            LPAD(CAST(d AS VARCHAR), 2, '0')
            AS DATE
        )
    ) AS month_name

FROM
    (SELECT range AS y
     FROM range(
         (SELECT MIN(year) FROM oltp_energy_event),
         (SELECT MAX(year) FROM oltp_energy_event) + 1
     )) AS years
CROSS JOIN
    (SELECT range AS m FROM range(1, 13)) AS months
CROSS JOIN
    (SELECT range AS d FROM range(1, 32)) AS days
WHERE
    TRY_CAST(
        CAST(y AS VARCHAR) || '-' ||
        LPAD(CAST(m AS VARCHAR), 2, '0') || '-' ||
        LPAD(CAST(d AS VARCHAR), 2, '0')
        AS DATE
    ) IS NOT NULL;


------------------------------------------------------------
-- 2. DIM_ENERGY_SOURCE
------------------------------------------------------------

DELETE FROM dim_energy_source;

INSERT INTO dim_energy_source (energy_source_key, energy_source_name)
SELECT
    ROW_NUMBER() OVER () AS energy_source_key,
    energy_source_name
FROM oltp_energy_source;


------------------------------------------------------------
-- 3. DIM_COUNTRY (SCD2 inicial)
------------------------------------------------------------

DELETE FROM dim_country;

INSERT INTO dim_country (
    country_key, iso_code, country_name,
    population, gdp,
    start_date, end_date, is_current
)
SELECT
    ROW_NUMBER() OVER () AS country_key,
    iso_code,
    country_name,
    population,
    gdp,
    CURRENT_DATE AS start_date,
    NULL AS end_date,
    TRUE AS is_current
FROM oltp_country;


------------------------------------------------------------
-- 4. FACT_ENERGY
------------------------------------------------------------

DELETE FROM fact_energy;

INSERT INTO fact_energy (
    fact_key,
    date_key,
    country_key,
    energy_source_key,
    consumption,
    electricity,
    per_capita,
    share_electricity,
    share_energy,
    greenhouse_gas_emissions,
    population
)
SELECT
    ROW_NUMBER() OVER () AS fact_key,

    -- usa sempre 1º de janeiro do ano pra date_key
    CAST(CAST(e.year AS VARCHAR) || '0101' AS INTEGER) AS date_key,

    dc.country_key,

    CASE
        WHEN e.solar_consumption        IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'solar')
        WHEN e.wind_consumption         IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'wind')
        WHEN e.hydro_consumption        IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'hydro')
        WHEN e.biofuel_consumption      IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'biofuel')
        WHEN e.nuclear_consumption      IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'nuclear')
        WHEN e.coal_consumption         IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'coal')
        WHEN e.gas_consumption          IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'gas')
        WHEN e.oil_consumption          IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'oil')
        WHEN e.renewables_consumption   IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'renewables')
        WHEN e.low_carbon_consumption   IS NOT NULL THEN (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'low_carbon')
        ELSE (SELECT energy_source_key FROM dim_energy_source WHERE energy_source_name = 'fossil')
    END AS energy_source_key,

    COALESCE(
        e.solar_consumption, e.wind_consumption, e.hydro_consumption,
        e.biofuel_consumption, e.nuclear_consumption, e.coal_consumption,
        e.gas_consumption, e.oil_consumption, e.renewables_consumption,
        e.low_carbon_consumption
    ) AS consumption,

    COALESCE(
        e.solar_electricity, e.wind_electricity, e.hydro_electricity,
        e.biofuel_electricity, e.nuclear_electricity, e.coal_electricity,
        e.gas_electricity, e.oil_electricity, e.renewables_electricity,
        e.low_carbon_electricity
    ) AS electricity,

    COALESCE(
        e.solar_energy_per_capita, e.wind_energy_per_capita, e.hydro_energy_per_capita,
        e.biofuel_elec_per_capita, e.nuclear_elec_per_capita, e.coal_elec_per_capita,
        e.gas_elec_per_capita, e.oil_elec_per_capita, e.renewables_elec_per_capita,
        e.low_carbon_elec_per_capita
    ) AS per_capita,

    COALESCE(
        e.solar_share_elec, e.wind_share_elec, e.hydro_share_elec,
        e.biofuel_share_elec, e.nuclear_share_elec, e.coal_share_elec,
        e.gas_share_elec, e.oil_share_elec, e.renewables_share_elec,
        e.low_carbon_share_elec
    ) AS share_electricity,

    COALESCE(
        e.solar_share_energy, e.wind_share_energy, e.hydro_share_energy,
        e.biofuel_share_energy, e.nuclear_share_energy, e.coal_share_energy,
        e.gas_share_energy, e.oil_share_energy, e.renewables_share_energy,
        e.low_carbon_share_energy
    ) AS share_energy,

    e.greenhouse_gas_emissions,
    e.population
FROM oltp_energy_event e
JOIN dim_country dc USING (iso_code);
