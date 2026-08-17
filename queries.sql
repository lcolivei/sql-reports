-- SQL Reports: perguntas de negócio para a Loja LC
-- Banco-alvo: SQLite 3+

-- 1) Receita líquida por mês, ignorando pedidos cancelados.
WITH pedido_totais AS (
    SELECT
        p.pedido_id,
        substr(p.data_pedido, 1, 7) AS mes,
        ROUND(SUM(i.quantidade * i.preco_unitario) - p.desconto, 2) AS valor_liquido
    FROM pedidos p
    JOIN itens_pedido i ON i.pedido_id = p.pedido_id
    WHERE p.status <> 'cancelado'
    GROUP BY p.pedido_id, p.data_pedido, p.desconto
)
SELECT mes, COUNT(*) AS pedidos, ROUND(SUM(valor_liquido), 2) AS receita_liquida
FROM pedido_totais
GROUP BY mes
ORDER BY mes;

-- 2) Ranking de clientes por faturamento e ticket médio.
WITH pedido_totais AS (
    SELECT p.pedido_id, p.cliente_id,
           SUM(i.quantidade * i.preco_unitario) - p.desconto AS valor_liquido
    FROM pedidos p
    JOIN itens_pedido i ON i.pedido_id = p.pedido_id
    WHERE p.status <> 'cancelado'
    GROUP BY p.pedido_id, p.cliente_id, p.desconto
), ranking AS (
    SELECT c.nome, c.cidade, COUNT(pt.pedido_id) AS pedidos,
           ROUND(SUM(pt.valor_liquido), 2) AS faturamento,
           ROUND(AVG(pt.valor_liquido), 2) AS ticket_medio,
           DENSE_RANK() OVER (ORDER BY SUM(pt.valor_liquido) DESC) AS posicao
    FROM clientes c
    JOIN pedido_totais pt ON pt.cliente_id = c.cliente_id
    GROUP BY c.cliente_id, c.nome, c.cidade
)
SELECT * FROM ranking ORDER BY posicao, nome;

-- 3) Produtos mais vendidos por quantidade e receita.
SELECT
    pr.nome AS produto,
    cat.nome AS categoria,
    SUM(i.quantidade) AS unidades_vendidas,
    ROUND(SUM(i.quantidade * i.preco_unitario), 2) AS receita_bruta,
    RANK() OVER (ORDER BY SUM(i.quantidade) DESC) AS ranking_quantidade
FROM itens_pedido i
JOIN pedidos p ON p.pedido_id = i.pedido_id
JOIN produtos pr ON pr.produto_id = i.produto_id
JOIN categorias cat ON cat.categoria_id = pr.categoria_id
WHERE p.status <> 'cancelado'
GROUP BY pr.produto_id, pr.nome, cat.nome
ORDER BY unidades_vendidas DESC, receita_bruta DESC;

-- 4) Receita e participação por categoria.
WITH categoria_receita AS (
    SELECT cat.nome AS categoria, SUM(i.quantidade * i.preco_unitario) AS receita
    FROM itens_pedido i
    JOIN pedidos p ON p.pedido_id = i.pedido_id
    JOIN produtos pr ON pr.produto_id = i.produto_id
    JOIN categorias cat ON cat.categoria_id = pr.categoria_id
    WHERE p.status <> 'cancelado'
    GROUP BY cat.categoria_id, cat.nome
)
SELECT categoria,
       ROUND(receita, 2) AS receita,
       ROUND(100.0 * receita / SUM(receita) OVER (), 2) AS participacao_percentual
FROM categoria_receita
ORDER BY receita DESC;

-- 5) Alertas de estoque: produtos abaixo do mínimo e cobertura simples.
SELECT
    pr.nome AS produto,
    cat.nome AS categoria,
    pr.estoque_atual,
    pr.estoque_minimo,
    pr.estoque_minimo - pr.estoque_atual AS unidades_para_repor,
    CASE WHEN pr.estoque_atual = 0 THEN 'CRÍTICO' ELSE 'REPOR' END AS prioridade
FROM produtos pr
JOIN categorias cat ON cat.categoria_id = pr.categoria_id
WHERE pr.ativo = 1 AND pr.estoque_atual <= pr.estoque_minimo
ORDER BY prioridade DESC, unidades_para_repor DESC;

-- 6) Clientes recorrentes: mais de um pedido não cancelado.
SELECT
    c.nome,
    c.email,
    COUNT(p.pedido_id) AS pedidos_realizados,
    MIN(p.data_pedido) AS primeira_compra,
    MAX(p.data_pedido) AS compra_mais_recente
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.status <> 'cancelado'
GROUP BY c.cliente_id, c.nome, c.email
HAVING COUNT(p.pedido_id) > 1
ORDER BY pedidos_realizados DESC, compra_mais_recente DESC;

-- 7) Mix de pagamentos e valor médio por método.
SELECT
    metodo,
    COUNT(*) AS transacoes,
    ROUND(SUM(valor), 2) AS valor_total,
    ROUND(AVG(valor), 2) AS valor_medio,
    ROUND(100.0 * SUM(valor) / SUM(SUM(valor)) OVER (), 2) AS participacao_percentual
FROM pagamentos
GROUP BY metodo
ORDER BY valor_total DESC;

-- 8) Clientes cadastrados sem compra válida (oportunidade de ativação).
SELECT c.cliente_id, c.nome, c.email, c.data_cadastro
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id AND p.status <> 'cancelado'
WHERE p.pedido_id IS NULL
ORDER BY c.data_cadastro;

-- 9) Visão detalhada pronta para alimentar um dashboard.
SELECT * FROM vw_pedidos_detalhados
ORDER BY data_pedido, pedido_id, produto_id;
