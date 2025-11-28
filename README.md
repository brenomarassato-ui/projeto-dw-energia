# Data Warehouse — Energia Global (OWID)

Este repositório contém um **Data Warehouse completo** baseado no dataset **Our World In Data — Global Energy (OWID)**.  
O projeto implementa uma arquitetura **STAGING → OLTP → DW (estrela) → Analytics**, usando **DuckDB + SQL + PowerShell**.

---

## Estrutura do Repositório

```
projeto-dw-energia/
 ├── data/
 │    └── owid-energy-data.csv
 ├── docs
      └──dicionario_de_dados.md
 ├── scripts/
 │    ├── 00_staging.sql
 │    ├── 01_oltp.sql
 │    ├── 02_dw_model.sql
 │    ├── 03_etl_load.sql
 │    └── 04_analytics.sql
 ├── visualizacoes
      └── dashboard_energia.html
      └── gerar_graficos.py
      └── grafico_1_evolucao_solar.png
      └── grafico_2_top_solar_paises.png
      └── grafico_3_heatmap.png
 ├── demo.duckdb
 ├── duckdb
 ├── run_all.ps1
 └── README.md
```

---

## Dicionário de Dados

O dicionário completo encontra-se em:  
→ **dicionario_de_dados.md**

---

## Scripts SQL utilizados no projeto

Cada etapa do pipeline está documentada e implementada em arquivos separados:

| Etapa | Script | Descrição |
|-------|--------|-----------|
| **1. STAGING** | 00_staging.sql | Cria a view *staging_energy* lendo o CSV bruto |
| **2. OLTP** | 01_oltp.sql | Normaliza dados em tabelas intermediárias |
| **3. DW (modelo estrela)** | 02_dw_model.sql | Cria dimensões e fato |
| **4. ETL (carga)** | 03_etl_load.sql | Popula dimensões, SCD2 e tabela fato |
| **5. Analytics** | 04_analytics.sql | Consultas analíticas, KPIs e rankings |

Dataset utilizado: **owid-energy-data.csv**

---

# Como Executar o Pipeline Completo (PowerShell)

## 1. Abrir o PowerShell

Pressione:

```
Windows + R
```

Digite:

```
PowerShell
```

Clique **OK**.

---

## 2. Acessar a pasta do projeto

```powershell
cd C:\projeto-dw-energia
```

---

## 3. Habilitar execução de scripts (necessário somente uma vez)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Confirme com **S**.

---

## 4. Rodar o pipeline completo

```powershell
.
un_all.ps1
```

---

## 5. Caso ocorra erro de permissão

```powershell
Set-ExecutionPolicy Bypass -Scope Process
.
un_all.ps1
```

---

# Saídas Esperadas

Após executar o pipeline:

- Tabelas criadas: **dim_date**, **dim_country**, **dim_energy_source**, **fact_energy**
- Carga completa do DW
- KPIs e análises no console DuckDB


