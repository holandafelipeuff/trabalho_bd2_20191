-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2019-07-07 02:42:55.691

-- tables
-- Table: categoria
CREATE TABLE categoria (
    id serial  NOT NULL,
    nome varchar(250)  NOT NULL,
    precisa_ser_maior_idade boolean  NOT NULL,
    CONSTRAINT categoria_pk PRIMARY KEY (id)
);

-- Table: comentario
CREATE TABLE comentario (
    id serial  NOT NULL,
    texto varchar(400)  NOT NULL,
    estrelas int  NOT NULL CHECK (estrelas >= 1 AND estrelas <= 5),
    usuario_id int  NOT NULL,
    jogo_id int  NOT NULL,
    hora timestamp  NOT NULL,
    CONSTRAINT comentario_pk PRIMARY KEY (id),
    CONSTRAINT comentario_unq_usr_jogo UNIQUE (usuario_id, jogo_id)
);

-- Table: jogo
CREATE TABLE jogo (
    id serial  NOT NULL,
    nome varchar(250)  NOT NULL,
    preco money  NOT NULL,
    CONSTRAINT jogo_pk PRIMARY KEY (id)
);

-- Table: jogo_em_promocao
CREATE TABLE jogo_em_promocao (
    promocao_id serial  NOT NULL,
    jogo_id serial  NOT NULL,
    CONSTRAINT jogo_em_promocao_pk PRIMARY KEY (promocao_id,jogo_id)
);

-- Table: jogo_pertence_categoria
CREATE TABLE jogo_pertence_categoria (
    jogo_id serial  NOT NULL,
    categoria_id serial  NOT NULL,
    CONSTRAINT jogo_pertence_categoria_pk PRIMARY KEY (jogo_id,categoria_id)
);

-- Table: promocao
CREATE TABLE promocao (
    id serial  NOT NULL,
    nome varchar(250)  NOT NULL,
    porcentagem int  NOT NULL,
    inicio date  NOT NULL,
    fim date  NOT NULL,
    categoria_id int  NULL,
    CONSTRAINT promocao_pk PRIMARY KEY (id)
);

-- Table: usuario
CREATE TABLE usuario (
    id serial  NOT NULL,
    nome varchar(250)  NOT NULL,
    cpf varchar(11)  NOT NULL,
    email varchar(250)  NOT NULL,
    senha varchar(250)  NOT NULL,
    data_nascimento date  NOT NULL,
    usuario_negativo boolean  NOT NULL,
    CONSTRAINT usuario_pk PRIMARY KEY (id)
);

-- Table: usuario_horas_jogo
CREATE TABLE usuario_horas_jogo (
    qtd_horas_jogadas int  NOT NULL,
    usuario_id serial  NOT NULL,
    jogo_id serial  NOT NULL,
    CONSTRAINT usuario_horas_jogo_pk PRIMARY KEY (usuario_id,jogo_id)
);

-- Table: usuario_possui_jogo
CREATE TABLE usuario_possui_jogo (
    preco_comprado money  NOT NULL,
    data_compra date  NOT NULL,
    usuario_id serial  NOT NULL,
    jogo_id serial  NOT NULL,
    CONSTRAINT usuario_possui_jogo_pk PRIMARY KEY (usuario_id,jogo_id)
);

-- foreign keys
-- Reference: categoria_jogo_pertence_categoria (table: jogo_pertence_categoria)
ALTER TABLE jogo_pertence_categoria ADD CONSTRAINT categoria_jogo_pertence_categoria
    FOREIGN KEY (categoria_id)
    REFERENCES categoria (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: jogo_comentario (table: comentario)
ALTER TABLE comentario ADD CONSTRAINT jogo_comentario
    FOREIGN KEY (jogo_id)
    REFERENCES jogo (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: jogo_jogo_em_promocao (table: jogo_em_promocao)
ALTER TABLE jogo_em_promocao ADD CONSTRAINT jogo_jogo_em_promocao
    FOREIGN KEY (jogo_id)
    REFERENCES jogo (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: jogo_jogo_pertence_categoria (table: jogo_pertence_categoria)
ALTER TABLE jogo_pertence_categoria ADD CONSTRAINT jogo_jogo_pertence_categoria
    FOREIGN KEY (jogo_id)
    REFERENCES jogo (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: jogo_usuario_horas_jogo (table: usuario_horas_jogo)
ALTER TABLE usuario_horas_jogo ADD CONSTRAINT jogo_usuario_horas_jogo
    FOREIGN KEY (jogo_id)
    REFERENCES jogo (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: jogo_usuario_possui_jogo (table: usuario_possui_jogo)
ALTER TABLE usuario_possui_jogo ADD CONSTRAINT jogo_usuario_possui_jogo
    FOREIGN KEY (jogo_id)
    REFERENCES jogo (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: promocao_categoria (table: promocao)
ALTER TABLE promocao ADD CONSTRAINT promocao_categoria
    FOREIGN KEY (categoria_id)
    REFERENCES categoria (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: promocao_jogo_em_promocao (table: jogo_em_promocao)
ALTER TABLE jogo_em_promocao ADD CONSTRAINT promocao_jogo_em_promocao
    FOREIGN KEY (promocao_id)
    REFERENCES promocao (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: usuario_comentario (table: comentario)
ALTER TABLE comentario ADD CONSTRAINT usuario_comentario
    FOREIGN KEY (usuario_id)
    REFERENCES usuario (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: usuario_usuario_horas_jogo (table: usuario_horas_jogo)
ALTER TABLE usuario_horas_jogo ADD CONSTRAINT usuario_usuario_horas_jogo
    FOREIGN KEY (usuario_id)
    REFERENCES usuario (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: usuario_usuario_possui_jogo (table: usuario_possui_jogo)
ALTER TABLE usuario_possui_jogo ADD CONSTRAINT usuario_usuario_possui_jogo
    FOREIGN KEY (usuario_id)
    REFERENCES usuario (id)
    ON DELETE  RESTRICT 
    ON UPDATE  CASCADE 
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

