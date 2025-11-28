
# Projeto – Inteligência Computacional  
## Previsão de Vendas Globais de Jogos PlayStation (PS3, PS4, PS5)

Este repositório contém o desenvolvimento **completo** da atividade avaliativa da disciplina **Inteligência Computacional – FATEC Jundiaí**.  
O objetivo é construir um modelo de regressão para prever o total de vendas globais de jogos PlayStation com base em metadados do dataset Kaggle.

---

# 1. Introdução

O projeto aplica técnicas de Mineração de Dados e Aprendizado de Máquina:

- Exploração e análise estatística  
- Tratamento de valores ausentes  
- Detecção e remoção de outliers  
- Criação de novos atributos (Feature Engineering)  
- Pré-processamento via Pipeline  
- Modelagem supervisionada com 3 algoritmos  
- Ajuste de hiperparâmetros via GridSearchCV  
- Validação cruzada  
- Interpretação do modelo via Feature Importance  

---

# 2. Problema

**Como prever o total de vendas globais (`Total Sales` ou `Total Shipped`) de um jogo PlayStation usando características disponíveis no dataset?**

Variáveis usadas como preditoras incluem:

- Plataforma (PS3/PS4/PS5)  
- Publicadora / Desenvolvedora  
- Notas (Metacritic / Userscore)  
- Vendas regionais  
- Ano de lançamento  
- Quantidade de gêneros  
- Indicação de multiplataforma  

---

# 3. Solução Desenvolvida

##  3.1 Exploração dos Dados

Inclui:

- `df.info()`, `df.describe()`  
- `df.isnull().sum()`  
- Histogramas  
- Heatmap de correlação  

**Mapa de Correlação:**  
![Correlação](docs/correlacao.png)

**Histogramas:**  
![Histogramas](docs/histogramas.png)

---

##  3.2 Tratamento dos Dados

- Imputação via **SimpleImputer (mediana / mais frequente)**  
- Remoção de outliers via método **IQR**  

---

##  3.3 Feature Engineering (OBRIGATÓRIO)

Criados atributos:

| Feature | Descrição | Impacto Esperado |
|---------|-----------|------------------|
| `Release_Year` | Ano de lançamento | Captura efeito temporal nas vendas |
| `Num_Genres` | Contagem de gêneros | Complexidade e nicho do jogo |
| `Is_MultiPlatform` | 0/1 multiplataforma | Jogos multiplataforma tendem a vender mais |

---

# 4. Pipeline de Pré-processamento

Implementado com **ColumnTransformer + Pipeline**, contendo:

- Imputação  
- OneHotEncoder  
- StandardScaler  
- Modelo final (dinâmico)  

---

# 5. Modelagem

Modelos testados conforme solicitado:

- **Linear Regression**  
- **Decision Tree Regressor**  
- **Random Forest Regressor**  

###  GridSearchCV aplicado em:
- max_depth  
- min_samples_split  
- n_estimators  

---

#  6. Resultados

Métricas calculadas:

- **MAE**  
- **RMSE**  
- **R²**  
- Validação cruzada (k=5)  

### Feature Importance
![Feature Importance](docs/feature_importance.png)

O modelo com melhor desempenho foi **RandomForestRegressor**.

---

# 7. Discussões

- Vendas regionais são fortemente correlacionadas com vendas globais  
- Jogos multiplataforma têm vantagem competitiva  
- Jogos com mais gêneros apresentam variação maior no desempenho  
- Anos mais recentes mostram padrões de mercado diferentes  

---

# 8. Trabalhos Futuros

Sugestões de melhorias:

- Testar XGBoost, CatBoost, LightGBM  
- Implementar NLP no nome do jogo  
- Criar modelo separado por plataforma (PS3/PS4/PS5)  
- Construir dashboard em Power BI/Streamlit  
- Ampliar dataset com mais anos de mercado  

---

# 9. Estrutura do Repositório

```
/
├── README.md
├── notebook/
│   └── Notebook_Completo_IC_PlayStation.ipynb
├── data/
│   └── dataset.csv
├── docs/
│   ├── correlacao.png
│   ├── histogramas.png
```

---

#  10. Como Executar

```bash
pip install pandas numpy scikit-learn seaborn matplotlib
jupyter notebook notebook/Notebook_Completo_IC_PlayStation.ipynb
```

