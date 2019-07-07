-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2019-07-07 02:42:55.691

-- foreign keys
ALTER TABLE jogo_pertence_categoria
    DROP CONSTRAINT categoria_jogo_pertence_categoria;

ALTER TABLE comentario
    DROP CONSTRAINT jogo_comentario;

ALTER TABLE jogo_em_promocao
    DROP CONSTRAINT jogo_jogo_em_promocao;

ALTER TABLE jogo_pertence_categoria
    DROP CONSTRAINT jogo_jogo_pertence_categoria;

ALTER TABLE usuario_horas_jogo
    DROP CONSTRAINT jogo_usuario_horas_jogo;

ALTER TABLE usuario_possui_jogo
    DROP CONSTRAINT jogo_usuario_possui_jogo;

ALTER TABLE promocao
    DROP CONSTRAINT promocao_categoria;

ALTER TABLE jogo_em_promocao
    DROP CONSTRAINT promocao_jogo_em_promocao;

ALTER TABLE comentario
    DROP CONSTRAINT usuario_comentario;

ALTER TABLE usuario_horas_jogo
    DROP CONSTRAINT usuario_usuario_horas_jogo;

ALTER TABLE usuario_possui_jogo
    DROP CONSTRAINT usuario_usuario_possui_jogo;

-- tables
DROP TABLE categoria;

DROP TABLE comentario;

DROP TABLE jogo;

DROP TABLE jogo_em_promocao;

DROP TABLE jogo_pertence_categoria;

DROP TABLE promocao;

DROP TABLE usuario;

DROP TABLE usuario_horas_jogo;

DROP TABLE usuario_possui_jogo;

-- End of file.

