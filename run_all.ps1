# ============================================
# 0. CONFIGURAÇÃO DE CAMINHOS
# ============================================

$BASE = "C:\projeto-dw-energia"
$SCRIPTS = "$BASE\scripts"
$VIS = "$BASE\visualizacoes"
$DB = "$BASE\demo.duckdb"

# ============================================
# 1. REMOVER BANCO ANTIGO
# ============================================

if (Test-Path $DB) {
    Remove-Item $DB -Force
    Write-Host "Banco demo.duckdb removido."
}

Write-Host "Criando novo banco demo.duckdb..."

# ============================================
# 2. EXECUTAR SCRIPTS SQL USANDO PYTHON + DUCKDB
# ============================================

$python = "python"   # usa Python do seu sistema

# Função para executar SQL usando Python + DuckDB
function Exec-SQL {
    param(
        [string]$sqlfile
    )

    Write-Host "Executando: $sqlfile"

    $code = @"
import duckdb

con = duckdb.connect(r'$DB')

with open(r'$sqlfile', 'r', encoding='utf-8') as f:
    sql = f.read()

con.execute(sql)
con.close()
"@

    $code | & $python -
}

# Rodar scripts na ordem certa:
Exec-SQL "$SCRIPTS\00_staging.sql"
Exec-SQL "$SCRIPTS\01_oltp.sql"
Exec-SQL "$SCRIPTS\02_dw_model.sql"
Exec-SQL "$SCRIPTS\03_etl_load.sql"
Exec-SQL "$SCRIPTS\04_analytics.sql"

Write-Host "`nScripts SQL executados.`n"

# ============================================
# 3. GERAR GRÁFICOS EM PYTHON
# ============================================

Write-Host "Gerando gráficos com Python..."

$graf = "$VIS\gerar_graficos.py"

& $python $graf

Write-Host "`n==== PIPELINE FINALIZADO COM SUCESSO ===="
