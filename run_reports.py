"""Executa o banco de demonstração e imprime relatórios selecionados."""

from __future__ import annotations

import sqlite3
from pathlib import Path

ROOT = Path(__file__).parent
DB_PATH = ROOT / "loja_lc.sqlite3"


def build_database() -> sqlite3.Connection:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    connection.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
    connection.executescript((ROOT / "seed.sql").read_text(encoding="utf-8"))
    return connection


def show_report(connection: sqlite3.Connection, title: str, query: str) -> None:
    print(f"\n=== {title} ===")
    rows = connection.execute(query).fetchall()
    if not rows:
        print("Nenhum resultado.")
        return
    headers = rows[0].keys()
    print(" | ".join(headers))
    print("-" * 80)
    for row in rows:
        print(" | ".join(str(row[header]) for header in headers))


def main() -> None:
    connection = build_database()
    try:
        show_report(
            connection,
            "Receita mensal",
            """
            WITH pedido_totais AS (
                SELECT p.pedido_id, substr(p.data_pedido, 1, 7) AS mes,
                       SUM(i.quantidade * i.preco_unitario) - p.desconto AS valor_liquido
                FROM pedidos p JOIN itens_pedido i ON i.pedido_id = p.pedido_id
                WHERE p.status <> 'cancelado'
                GROUP BY p.pedido_id, p.data_pedido, p.desconto
            )
            SELECT mes, COUNT(*) AS pedidos, ROUND(SUM(valor_liquido), 2) AS receita_liquida
            FROM pedido_totais GROUP BY mes ORDER BY mes;
            """,
        )
        show_report(
            connection,
            "Estoque abaixo do mínimo",
            """
            SELECT nome, estoque_atual, estoque_minimo,
                   estoque_minimo - estoque_atual AS unidades_para_repor
            FROM produtos
            WHERE ativo = 1 AND estoque_atual <= estoque_minimo
            ORDER BY unidades_para_repor DESC;
            """,
        )
    finally:
        connection.close()


if __name__ == "__main__":
    main()
