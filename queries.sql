-- =====================================================
-- Projeto: Relatórios e Consultas SQL para Negócios
-- Autor: Luiz Carlos
-- Descrição: Exemplos práticos de DDL e DQL (JOINs, Agregações, Subqueries)
-- =====================================================

-- 1. Criação das Tabelas (Schema)
CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(50),
    data_cadastro DATE
);

CREATE TABLE pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    valor_total DECIMAL(10,2),
    data_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- 2. Consulta: Faturamento Total por Cliente (JOIN e GROUP BY)
SELECT 
    c.nome AS cliente_nome,
    c.cidade,
    COUNT(p.pedido_id) AS total_pedidos,
    SUM(p.valor_total) AS faturamento_total
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
GROUP BY c.cliente_id, c.nome, c.cidade
ORDER BY faturamento_total DESC;

-- 3. Consulta: Clientes que compraram acima da média geral (Subquery)
SELECT 
    nome,
    cidade
FROM clientes
WHERE cliente_id IN (
    SELECT cliente_id 
    FROM pedidos 
    WHERE valor_total > (SELECT AVG(valor_total) FROM pedidos)
);

-- 4. Consulta: Ranking de vendas por período e cidade
SELECT 
    c.cidade,
    SUM(p.valor_total) AS total_vendas
FROM clientes c
JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE p.data_pedido >= '2026-01-01'
GROUP BY c.cidade
HAVING SUM(p.valor_total) > 1000
ORDER BY total_vendas DESC;
