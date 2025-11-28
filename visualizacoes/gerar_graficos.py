import duckdb
import pandas as pd
import plotly.express as px
from plotly.subplots import make_subplots
import plotly.graph_objects as go
import os

# ============================================================
# CONFIGURAÇÃO DE CAMINHOS
# ============================================================
# Pasta onde este script está localizado
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Caminho do banco DuckDB (na pasta raiz)
DB_PATH = os.path.join(BASE_DIR, "..", "demo.duckdb")

# Conectar ao banco
con = duckdb.connect(DB_PATH)

# ============================================================
# 1. CONSULTAS SQL ANALÍTICAS
# ============================================================

# Q1 — Evolução da energia solar
q1 = """
SELECT 
    d.year AS ano,
    SUM(f.consumption) AS solar_twh
FROM fact_energy f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_energy_source s ON f.energy_source_key = s.energy_source_key
WHERE s.energy_source_name = 'solar'
GROUP BY d.year
ORDER BY d.year;
"""
df_evolucao = con.execute(q1).fetchdf()

# Q2 — Top 15 países
q2 = """
SELECT
    d.year AS ano,
    c.country_name AS pais,
    s.energy_source_name AS fonte,
    SUM(f.consumption) AS consumo_twh
FROM fact_energy f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_country c ON f.country_key = c.country_key
JOIN dim_energy_source s ON f.energy_source_key = s.energy_source_key
WHERE d.year = 2024
  AND s.energy_source_name = 'solar'
GROUP BY ano, pais, fonte
ORDER BY consumo_twh DESC
LIMIT 15;
"""
df_top = con.execute(q2).fetchdf()

# Q3 — Heatmap por ano x fonte
q3 = """
SELECT
    d.year AS ano,
    s.energy_source_name AS fonte,
    SUM(f.consumption) AS consumo_twh
FROM fact_energy f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_energy_source s ON f.energy_source_key = s.energy_source_key
GROUP BY ano, fonte
ORDER BY ano, fonte;
"""
df_heatmap = con.execute(q3).fetchdf()

# Q4 — KPI renováveis
q4 = """
SELECT
    d.year AS ano,
    SUM(CASE WHEN s.energy_source_name IN ('solar','wind','hydro','biofuel') 
             THEN f.consumption ELSE 0 END) AS consumo_renovaveis,
    SUM(CASE WHEN s.energy_source_name IN ('coal','gas','oil','fossil') 
             THEN f.consumption ELSE 0 END) AS consumo_fosseis,
    SUM(f.consumption) AS consumo_total,
    100.0 * SUM(CASE WHEN s.energy_source_name IN ('solar','wind','hydro','biofuel')
                     THEN f.consumption ELSE 0 END)
           / SUM(f.consumption) AS perc_renovaveis_sobre_total
FROM fact_energy f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_energy_source s ON f.energy_source_key = s.energy_source_key
WHERE d.year = 2024
GROUP BY d.year;
"""
df_kpi = con.execute(q4).fetchdf()

# ============================================================
# 2. GRÁFICOS
# ============================================================

# GRÁFICO 1 — Evolução Solar
fig1 = px.line(
    df_evolucao,
    x="ano",
    y="solar_twh",
    title="Evolução do Consumo de Energia Solar no Mundo",
    markers=True
)
fig1.update_layout(xaxis_title="Ano", yaxis_title="Consumo (TWh)")
fig1.write_image(os.path.join(BASE_DIR, "grafico_1_evolucao_solar.png"))

# GRÁFICO 2 — Top Países
fig2 = px.bar(
    df_top,
    x="pais",
    y="consumo_twh",
    title="Top 15 Países que Mais Consumiram Energia Solar (2024)",
    text_auto=True
)
fig2.update_layout(xaxis_title="País", yaxis_title="Consumo (TWh)", xaxis=dict(tickangle=45))
fig2.write_image(os.path.join(BASE_DIR, "grafico_2_top_solar_paises.png"))

# GRÁFICO 3 — Heatmap
df_pivot = df_heatmap.pivot(index="fonte", columns="ano", values="consumo_twh")

fig3 = px.imshow(
    df_pivot,
    aspect="auto",
    color_continuous_scale="Viridis",
    title="Heatmap – Consumo de Energia por Ano e Tipo"
)
fig3.update_layout(xaxis_title="Ano", yaxis_title="Fonte Energética")
fig3.write_image(os.path.join(BASE_DIR, "grafico_3_heatmap.png"))

# GRÁFICO 4 — Dashboard
kpi_value = df_kpi["perc_renovaveis_sobre_total"].iloc[0]

fig_dash = make_subplots(
    rows=2,
    cols=2,
    specs=[[{"type": "xy"}, {"type": "xy"}],
           [{"type": "xy"}, {"type": "indicator"}]],
    subplot_titles=("Evolução Solar", "Top Países Solar 2024", "Heatmap Energia", "KPI Renováveis (%)")
)

fig_dash.add_trace(go.Scatter(x=df_evolucao["ano"], y=df_evolucao["solar_twh"], mode="lines+markers"), row=1, col=1)
fig_dash.add_trace(go.Bar(x=df_top["pais"], y=df_top["consumo_twh"]), row=1, col=2)
fig_dash.add_trace(go.Heatmap(z=df_pivot.values, x=df_pivot.columns, y=df_pivot.index), row=2, col=1)
fig_dash.add_trace(go.Indicator(mode="number", value=kpi_value, number={"suffix": "%"}), row=2, col=2)

fig_dash.update_layout(height=900, width=1200, title_text="Dashboard – Energia Mundial")
fig_dash.write_html(os.path.join(BASE_DIR, "dashboard_energia.html"))

print("✔ Todos os gráficos foram gerados com sucesso!")
