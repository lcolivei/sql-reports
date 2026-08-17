-- Schema do projeto SQL Reports (compatível com SQLite)
PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS vw_pedidos_detalhados;
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    cliente_id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    cidade TEXT NOT NULL,
    estado TEXT NOT NULL,
    data_cadastro TEXT NOT NULL
);

CREATE TABLE categorias (
    categoria_id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE
);

CREATE TABLE produtos (
    produto_id INTEGER PRIMARY KEY,
    categoria_id INTEGER NOT NULL REFERENCES categorias(categoria_id),
    nome TEXT NOT NULL,
    preco REAL NOT NULL CHECK (preco >= 0),
    estoque_atual INTEGER NOT NULL CHECK (estoque_atual >= 0),
    estoque_minimo INTEGER NOT NULL DEFAULT 5 CHECK (estoque_minimo >= 0),
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE pedidos (
    pedido_id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
    data_pedido TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pago', 'enviado', 'entregue', 'cancelado', 'pendente')),
    desconto REAL NOT NULL DEFAULT 0 CHECK (desconto >= 0)
);

CREATE TABLE itens_pedido (
    pedido_id INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    produto_id INTEGER NOT NULL REFERENCES produtos(produto_id),
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario REAL NOT NULL CHECK (preco_unitario >= 0),
    PRIMARY KEY (pedido_id, produto_id)
);

CREATE TABLE pagamentos (
    pagamento_id INTEGER PRIMARY KEY,
    pedido_id INTEGER NOT NULL UNIQUE REFERENCES pedidos(pedido_id),
    metodo TEXT NOT NULL CHECK (metodo IN ('pix', 'cartao', 'boleto')),
    valor REAL NOT NULL CHECK (valor >= 0),
    data_pagamento TEXT
);

CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_itens_produto ON itens_pedido(produto_id);

CREATE VIEW vw_pedidos_detalhados AS
SELECT
    p.pedido_id,
    p.data_pedido,
    p.status,
    c.cliente_id,
    c.nome AS cliente,
    c.cidade,
    c.estado,
    pr.produto_id,
    pr.nome AS produto,
    cat.nome AS categoria,
    i.quantidade,
    i.preco_unitario,
    ROUND(i.quantidade * i.preco_unitario, 2) AS subtotal,
    p.desconto
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
JOIN itens_pedido i ON i.pedido_id = p.pedido_id
JOIN produtos pr ON pr.produto_id = i.produto_id
JOIN categorias cat ON cat.categoria_id = pr.categoria_id;
