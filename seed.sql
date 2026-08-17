-- Dados de demonstração do cenário Loja LC (valores fictícios)
INSERT INTO clientes (cliente_id, nome, email, cidade, estado, data_cadastro) VALUES
    (1, 'Ana Souza', 'ana@example.com', 'São Paulo', 'SP', '2025-10-12'),
    (2, 'Carlos Silva', 'carlos@example.com', 'Guarulhos', 'SP', '2025-11-03'),
    (3, 'Maria Oliveira', 'maria@example.com', 'Campinas', 'SP', '2025-12-19'),
    (4, 'João Santos', 'joao@example.com', 'Belo Horizonte', 'MG', '2026-01-04'),
    (5, 'Fernanda Lima', 'fernanda@example.com', 'São Paulo', 'SP', '2026-01-21'),
    (6, 'Rafael Costa', 'rafael@example.com', 'Santos', 'SP', '2026-02-06');

INSERT INTO categorias (categoria_id, nome) VALUES
    (1, 'Periféricos'),
    (2, 'Acessórios'),
    (3, 'Cursos');

INSERT INTO produtos (produto_id, categoria_id, nome, preco, estoque_atual, estoque_minimo, ativo) VALUES
    (1, 1, 'Teclado mecânico', 249.90, 4, 5, 1),
    (2, 1, 'Mouse sem fio', 129.90, 18, 8, 1),
    (3, 1, 'Webcam Full HD', 289.90, 3, 5, 1),
    (4, 2, 'Suporte para notebook', 89.90, 25, 10, 1),
    (5, 2, 'Hub USB-C', 119.90, 7, 8, 1),
    (6, 3, 'Curso Python para dados', 199.90, 100, 10, 1),
    (7, 3, 'Curso SQL para negócios', 179.90, 100, 10, 1),
    (8, 2, 'Cabo HDMI', 39.90, 2, 10, 1);

INSERT INTO pedidos (pedido_id, cliente_id, data_pedido, status, desconto) VALUES
    (101, 1, '2026-01-08', 'entregue', 0),
    (102, 2, '2026-01-14', 'entregue', 20),
    (103, 1, '2026-01-28', 'pago', 0),
    (104, 3, '2026-02-03', 'entregue', 10),
    (105, 4, '2026-02-11', 'cancelado', 0),
    (106, 5, '2026-02-18', 'enviado', 15),
    (107, 6, '2026-03-02', 'pago', 0),
    (108, 2, '2026-03-08', 'entregue', 0),
    (109, 3, '2026-03-12', 'pendente', 5),
    (110, 5, '2026-03-15', 'entregue', 0);

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
    (101, 1, 1, 249.90), (101, 4, 1, 89.90),
    (102, 2, 2, 129.90), (102, 8, 1, 39.90),
    (103, 6, 1, 199.90), (103, 7, 1, 179.90),
    (104, 3, 1, 289.90), (104, 5, 1, 119.90),
    (105, 1, 1, 249.90),
    (106, 2, 1, 129.90), (106, 4, 2, 89.90),
    (107, 7, 1, 179.90), (107, 8, 2, 39.90),
    (108, 1, 1, 249.90), (108, 2, 1, 129.90),
    (109, 6, 1, 199.90),
    (110, 3, 1, 289.90), (110, 5, 1, 119.90);

INSERT INTO pagamentos (pagamento_id, pedido_id, metodo, valor, data_pagamento) VALUES
    (1001, 101, 'pix', 339.80, '2026-01-08'),
    (1002, 102, 'cartao', 279.70, '2026-01-14'),
    (1003, 103, 'pix', 379.80, '2026-01-28'),
    (1004, 104, 'cartao', 399.80, '2026-02-03'),
    (1006, 106, 'pix', 294.70, '2026-02-18'),
    (1007, 107, 'boleto', 259.70, '2026-03-02'),
    (1008, 108, 'cartao', 379.80, '2026-03-08'),
    (1010, 110, 'pix', 409.80, '2026-03-15');
