------------------------------------------------------------
-- 04_analytics.sql
-- Consultas analíticas sobre energia e sustentabilidade
-- Usando: dim_date, dim_country, dim_energy_source, fact_energy
------------------------------------------------------------


/***********************************************************
1) ANÁLISE TEMPORAL
   "Como cresceu a energia solar no Brasil ao longo do tempo?"
************************************************************/

SELECT
    d.year                                AS ano,
    SUM(f.consumption)                    AS solar_twh
FROM fact_energy f
JOIN dim_energy_source es
    ON f.energy_source_key = es.energy_source_key
JOIN dim_country c
    ON f.country_key = c.country_key
JOIN dim_date d
    ON f.date_key = d.date_key
WHERE
    es.energy_source_name = 'solar'
    AND c.country_name = 'Brazil'         
GROUP BY
    d.year
ORDER BY
    d.year;



------------------------------------------------------------
-- 2) RANKING / TOP N
--   "Quais países têm maior participação de renováveis?"
------------------------------------------------------------

SELECT
    c.country_name                                        AS pais,
    AVG(f.share_energy)                                   AS media_share_renovaveis
FROM fact_energy f
JOIN dim_energy_source es
    ON f.energy_source_key = es.energy_source_key
JOIN dim_country c
    ON f.country_key = c.country_key
WHERE
    es.energy_source_name = 'renewables'
    AND f.share_energy IS NOT NULL
GROUP BY
    c.country_name
HAVING
    COUNT(*) > 5
ORDER BY
    media_share_renovaveis DESC
LIMIT 10;



------------------------------------------------------------
-- 3) AGREGAÇÃO MULTIDIMENSIONAL
--   "Consumo por país e fonte no ano mais recente"
------------------------------------------------------------

WITH ultimo_ano AS (
    SELECT MAX(d.year) AS ano_max
    FROM fact_energy f
    JOIN dim_date d ON f.date_key = d.date_key
)

SELECT
    u.ano_max                                           AS ano,
    c.country_name                                      AS pais,
    es.energy_source_name                               AS fonte,
    SUM(f.consumption)                                  AS consumo_twh
FROM fact_energy f
JOIN dim_energy_source es
    ON f.energy_source_key = es.energy_source_key
JOIN dim_country c
    ON f.country_key = c.country_key
JOIN dim_date d
    ON f.date_key = d.date_key
JOIN ultimo_ano u
    ON d.year = u.ano_max
GROUP BY
    u.ano_max, c.country_name, es.energy_source_name
ORDER BY
    consumo_twh DESC,
    pais,
    fonte;



------------------------------------------------------------
-- 4) COORTE DE ADOÇÃO DE ENERGIA SOLAR
------------------------------------------------------------

WITH primeira_solar AS (
    SELECT
        c.country_name          AS pais,
        MIN(d.year)             AS ano_primeira_solar
    FROM fact_energy f
    JOIN dim_energy_source es
        ON f.energy_source_key = es.energy_source_key
    JOIN dim_country c
        ON f.country_key = c.country_key
    JOIN dim_date d
        ON f.date_key = d.date_key
    WHERE
        es.energy_source_name = 'solar'
        AND f.consumption IS NOT NULL
        AND f.consumption > 0
    GROUP BY
        c.country_name
)

SELECT
    ano_primeira_solar          AS ano_coorte,
    COUNT(*)                    AS qtd_paises_que_comecam_nesse_ano
FROM primeira_solar
GROUP BY
    ano_primeira_solar
ORDER BY
    ano_primeira_solar;



------------------------------------------------------------
-- 5) KPI GLOBAL — RENOVÁVEIS vs FÓSSEIS
------------------------------------------------------------

WITH ultimo_ano AS (
    SELECT MAX(d.year) AS ano_max
    FROM fact_energy f
    JOIN dim_date d ON f.date_key = d.date_key
),
consumos AS (
    SELECT
        SUM(
            CASE
                WHEN es.energy_source_name IN (
                    'solar','wind','hydro',
                    'biofuel','nuclear',
                    'renewables','low_carbon'
                )
                THEN COALESCE(f.consumption,0)
                ELSE 0
            END
        ) AS consumo_renovaveis,

        SUM(
            CASE
                WHEN es.energy_source_name IN ('coal','oil','gas','fossil')
                THEN COALESCE(f.consumption,0)
                ELSE 0
            END
        ) AS consumo_fosseis
    FROM fact_energy f
    JOIN dim_energy_source es
        ON f.energy_source_key = es.energy_source_key
    JOIN dim_date d
        ON f.date_key = d.date_key
    JOIN ultimo_ano u
        ON d.year = u.ano_max
)

SELECT
    (SELECT ano_max FROM ultimo_ano)              AS ano,
    consumo_renovaveis,
    consumo_fosseis,
    consumo_renovaveis + consumo_fosseis         AS consumo_total,
    CASE
        WHEN (consumo_renovaveis + consumo_fosseis) > 0
        THEN consumo_renovaveis * 100.0
             / (consumo_renovaveis + consumo_fosseis)
        ELSE NULL
    END AS perc_renovaveis_sobre_total
FROM consumos;



------------------------------------------------------------
-- 6) Q5 — COMPARAÇÃO HISTÓRICA: RENOVÁVEIS vs FÓSSEIS (TWH)
------------------------------------------------------------

WITH classificada AS (
    SELECT
        d.year AS ano,
        CASE 
            WHEN es.energy_source_name IN ('solar', 'wind', 'hydro', 'biofuel', 'geothermal')
                THEN 'renovavel'
            WHEN es.energy_source_name IN ('coal', 'oil', 'gas', 'fossil')
                THEN 'fosseis'
            ELSE 'outros'
        END AS tipo,
        SUM(f.consumption) AS consumo_twh
    FROM fact_energy f
    JOIN dim_date d ON f.date_key = d.date_key
    JOIN dim_energy_source es ON f.energy_source_key = es.energy_source_key
    GROUP BY ano, tipo
)

SELECT *
FROM classificada
WHERE tipo IN ('renovavel', 'fosseis')
ORDER BY ano, tipo;
