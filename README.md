# SQL Business Reports — Loja LC

Projeto de análise de dados para um e-commerce fictício. O objetivo é demonstrar modelagem relacional, integridade referencial e consultas que respondem a perguntas reais de negócio.

## Cenário

A Loja LC vende periféricos, acessórios e cursos. O banco registra clientes, categorias, produtos, pedidos, itens e pagamentos. Os dados são fictícios e servem apenas para demonstração técnica.

## O que está demonstrado

| Competência | Onde aparece |
| --- | --- |
| Modelagem relacional | `schema.sql`, com chaves primárias, estrangeiras, checks e índices |
| Carga de dados | `seed.sql`, com cenário consistente para análise |
| CTEs | Receita líquida mensal e ranking de clientes |
| Funções de janela | `RANK`, `DENSE_RANK` e participação percentual |
| Agregações | Faturamento, ticket médio, mix de pagamento e categorias |
| Análise operacional | Alertas de estoque e clientes sem compra |
| Reuso | View `vw_pedidos_detalhados` para alimentar dashboards |
| Automação | `run_reports.py` cria o SQLite e imprime indicadores principais |

## Como executar

Com Python 3 instalado:

```bash
python3 run_reports.py
```

O comando cria `loja_lc.sqlite3` e imprime relatórios selecionados. Para executar todas as consultas em um cliente SQLite:

```bash
sqlite3 loja_lc.sqlite3 < queries.sql
```

Ou, usando Python para preparar o banco:

```bash
python3 - <<'PY'
import sqlite3
from pathlib import Path

root = Path('.')
con = sqlite3.connect('loja_lc.sqlite3')
con.executescript((root / 'schema.sql').read_text())
con.executescript((root / 'seed.sql').read_text())
con.commit()
con.close()
PY
```

## Estrutura

```text
sql-reports/
├── schema.sql
├── seed.sql
├── queries.sql
├── run_reports.py
└── README.md
```

## Decisões analíticas

Pedidos cancelados são excluídos dos indicadores de receita, recorrência e produtos vendidos. O desconto é abatido no cálculo de receita líquida por pedido. O preço praticado é armazenado no item do pedido para preservar o histórico mesmo que o preço atual do produto seja alterado.

Em uma evolução para produção, o projeto poderia receber testes de qualidade SQL, uma camada de transformação com dbt e um dashboard conectado à view detalhada.

Desenvolvido por **Luiz Carlos**.
