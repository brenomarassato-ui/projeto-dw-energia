------------------------------------------------------------
-- 00_staging.sql
-- Etapa: STAGING
-- Objetivo: Ler o CSV bruto e criar uma VIEW sem transformações
-- Dataset: owid-energy-data.csv
------------------------------------------------------------

-- 1. Limpar view antiga (evita erro ao reexecutar)
DROP VIEW IF EXISTS staging_energy;

-- 2. Criar view de staging
CREATE VIEW staging_energy AS
SELECT *
FROM read_csv_auto('data/owid-energy-data.csv', HEADER=TRUE);

-- 3. Visualização rápida (opcional)
-- SELECT * FROM staging_energy LIMIT 20;
