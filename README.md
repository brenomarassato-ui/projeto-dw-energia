# Projeto Data Warehouse — Energia Global (OWID)

Este repositório contém um **Data Warehouse completo** construído com DuckDB, SQL e PowerShell, utilizando o dataset real **Our World In Data – Global Energy**.  
O projeto implementa as etapas:

**STAGING → OLTP → DW (modelo estrela) → ETL → Analytics**

---

# Estrutura do Repositório

```
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

# 1. Instalar o DuckDB (CLI)

Para rodar o pipeline, você precisa instalar o DuckDB CLI.

 **Passo 1 — Baixar o executável**
Baixe o DuckDB diretamente pelo link oficial:

https://duckdb.org/docs/installation/#windows

Escolha:

```
duckdb-windows-amd64.zip
```

**Passo 2 — Extrair o arquivo**
Extraia e coloque o arquivo `duckdb.exe` dentro da pasta do projeto:

```
projeto-dw-energia/
    duckdb.exe
```

**Passo 3 — Testar se está funcionando**

Abra PowerShell e execute:

```powershell
cd C:\projeto-dw-energia
.\duckdb.exe
```

Se abrir o terminal do DuckDB, está tudo certo.

---

# 2. Como executar o pipeline no PowerShell

Este projeto inclui um script completo que roda:

- STAGING  
- OLTP  
- Modelo Estrela  
- ETL (carga completa)  
- Consultas Analíticas  

Tudo automaticamente.

---

## 2.1 Abrir o PowerShell

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

## 2.2 Navegar até a pasta do projeto

```powershell
cd C:\projeto-dw-energia
```

---

## 2.3 Habilitar execução de scripts (apenas 1 vez)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Confirme com **S**. - Caso necessário

---

## 2.4 Rodar o pipeline completo

```powershell
.
un_all.ps1
```

---

# Se der erro de permissão (execução bloqueada)

Execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
.
un_all.ps1
```

---

# 3. O que o pipeline faz

Ao executar o script:

✔ Cria a view STAGING usando o CSV real  
✔ Cria tabelas OLTP normalizadas  
✔ Cria as dimensões e fato (modelo estrela)  
✔ Executa ETL completo populando o DW  
✔ Executa consultas analíticas úteis (ranking, evolução, coortes etc.)  
✔ Gera saída no console do DuckDB

---

# 4. Dicionário de Dados

O dicionário completo do DW está em:

```
dicionario_de_dados.md
```

Inclui:

- dim_date  
- dim_country (SCD2)  
- dim_energy_source  
- fact_energy  
- Relacionamentos  

---

# 5. Scripts SQL incluídos

| Script | Função |
|--------|--------|
| `00_staging.sql` | Cria view staging lendo o CSV |
| `01_oltp.sql` | Normaliza dados (países, fontes, eventos) |
| `02_dw_model.sql` | Cria o modelo estrela (dimensões + fato) |
| `03_etl_load.sql` | ETL completo, incluindo SCD2 |
| `04_analytics.sql` | Consultas avançadas e KPIs |

---

# 6. Visualizações

A pasta `visualizacoes/` contém:

- Gráficos gerados a partir do DW  
- Script Python **gerar_graficos.py** usado para produzir as imagens  

---

# 7. Como abrir e consultar o banco DuckDB manualmente

```powershell
.\duckdb.exe demo.duckdb
```

E então executar:

```sql
SELECT * FROM fact_energy LIMIT 20;
```


