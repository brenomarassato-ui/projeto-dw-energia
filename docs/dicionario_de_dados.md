# Dicionário de Dados — Data Warehouse de Energia Global

## 1. Tabela: dim_date
| Campo        | Tipo     | Descrição |
|--------------|----------|-----------|
| **date_key** | INTEGER (PK) | Chave surrogate no formato `AAAAMMDD` |
| full_date    | DATE     | Data completa |
| year         | INTEGER  | Ano (ex: 2024) |
| month        | INTEGER  | Mês (1–12) |
| day          | INTEGER  | Dia do mês |
| quarter      | INTEGER  | Trimestre (1–4) |
| month_name   | TEXT     | Nome completo do mês |

## 2. Tabela: dim_country
| Campo              | Tipo     | Descrição |
|--------------------|----------|-----------|
| **country_key**    | INTEGER (PK) | Chave surrogate da dimensão país |
| iso_code           | TEXT     | Código ISO-3166 do país |
| country_name       | TEXT     | Nome oficial do país |
| population         | DOUBLE   | População total |
| gdp                | DOUBLE   | Produto Interno Bruto |
| start_date         | DATE     | Primeira data registrada |
| end_date           | DATE     | Última data registrada |
| is_current         | BOOLEAN  | País ativo atualmente |

## 3. Tabela: dim_energy_source
| Campo                 | Tipo     | Descrição |
|-----------------------|----------|-----------|
| **energy_source_key** | INTEGER (PK) | Chave surrogate |
| energy_source_name    | TEXT     | Nome da fonte energética |

## 4. Tabela: fact_energy
| Campo                     | Tipo     | Descrição |
|---------------------------|----------|-----------|
| **fact_key**              | INTEGER (PK) | Chave surrogate |
| **date_key**              | INTEGER (FK) | Referência para dim_date |
| **country_key**           | INTEGER (FK) | Referência para dim_country |
| **energy_source_key**     | INTEGER (FK) | Referência para dim_energy_source |
| consumption               | DOUBLE   | Consumo de energia (TWh) |
| electricity               | DOUBLE   | Energia elétrica (TWh) |
| per_capita               | DOUBLE   | Energia per capita |
| share_electricity        | DOUBLE   | % da eletricidade |
| share_energy             | DOUBLE   | % da energia total |
| greenhouse_gas_emissions | DOUBLE   | Emissões de gases |
| population               | DOUBLE   | População do ano |

## 5. Relacionamentos
```
fact_energy.date_key          → dim_date.date_key
fact_energy.country_key       → dim_country.country_key
fact_energy.energy_source_key → dim_energy_source.energy_source_key
```
