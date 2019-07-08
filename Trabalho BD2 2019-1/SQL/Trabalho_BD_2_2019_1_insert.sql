INSERT INTO usuario(id, nome, cpf, email, senha, data_nascimento, usuario_negativo) VALUES(1, 'Pedro', '123', 'pedro@pedro.br', '234', '14/5/1991', true);
INSERT INTO usuario(id, nome, cpf, email, senha, data_nascimento, usuario_negativo) VALUES(2, 'Joao', '1234', 'joao@joao.br', '2345', '13/8/1995', false);
INSERT INTO usuario(id, nome, cpf, email, senha, data_nascimento, usuario_negativo) VALUES(3, 'Carlitos', '12345', 'carlitos@carlitos.br', '23456', '27/11/1997', true);

INSERT INTO categoria(id, nome, precisa_ser_maior_idade) VALUES(1, 'Multiplayer', false);
INSERT INTO categoria(id, nome, precisa_ser_maior_idade) VALUES(2, 'Tiro', false);
INSERT INTO categoria(id, nome, precisa_ser_maior_idade) VALUES(3, 'Terror', true);

INSERT INTO jogo(id, nome, preco) VALUES(1, 'Call of Duty', 200);
INSERT INTO jogo(id, nome, preco) VALUES(2, 'Slender', 0);
INSERT INTO jogo(id, nome, preco) VALUES(3, 'Minecraft', 50);

INSERT INTO jogo_pertence_categoria(jogo_id, categoria_id) VALUES(1,1);
INSERT INTO jogo_pertence_categoria(jogo_id, categoria_id) VALUES(1,2);
INSERT INTO jogo_pertence_categoria(jogo_id, categoria_id) VALUES(2,3);
INSERT INTO jogo_pertence_categoria(jogo_id, categoria_id) VALUES(3,1);

INSERT INTO usuario_possui_jogo(preco_comprado, data_compra, usuario_id, jogo_id) VALUES (200, '19/1/2018', 1, 1);
INSERT INTO usuario_possui_jogo(preco_comprado, data_compra, usuario_id, jogo_id) VALUES (140, '13/11/2016', 3, 1);
INSERT INTO usuario_possui_jogo(preco_comprado, data_compra, usuario_id, jogo_id) VALUES (35, '27/8/2017', 2, 3);
INSERT INTO usuario_possui_jogo(preco_comprado, data_compra, usuario_id, jogo_id) VALUES (0, '25/3/2019', 2, 2);

INSERT INTO usuario_horas_jogo(qtd_horas_jogadas, usuario_id, jogo_id) VALUES (500, 1, 1);
INSERT INTO usuario_horas_jogo(qtd_horas_jogadas, usuario_id, jogo_id) VALUES (1, 3, 1);
INSERT INTO usuario_horas_jogo(qtd_horas_jogadas, usuario_id, jogo_id) VALUES (50, 2, 3);
INSERT INTO usuario_horas_jogo(qtd_horas_jogadas, usuario_id, jogo_id) VALUES (1, 2, 2);

INSERT INTO comentario(id, texto, estrelas, usuario_id, jogo_id, hora)VALUES (1, 'Esse jogo ta uma porra', 1, 1, 1, '2018-03-08T20:53:05');
INSERT INTO comentario(id, texto, estrelas, usuario_id, jogo_id, hora)VALUES (2, 'Nada de mais', 2, 3, 1, '2017-01-07T14:22:17');
INSERT INTO comentario(id, texto, estrelas, usuario_id, jogo_id, hora)VALUES (3, 'Bom', 4, 2, 3, '2019-04-11T10:13:46');

INSERT INTO promocao(
	id, nome, porcentagem, inicio, fim)
	VALUES (1, 'Natal', 20, '20/12/2019', '26/12/2019');

INSERT INTO promocao(
	id, nome, porcentagem, inicio, fim)
	VALUES (2, 'Fim de Ano', 20, '28/12/2019', '02/01/2020');
















