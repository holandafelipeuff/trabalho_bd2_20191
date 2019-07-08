--- -----------------------------------------------------------------------------------
--- Ao criar um comentário, ele deve seguir algumas restrições em relação ao usuário e jogo

CREATE OR REPLACE FUNCTION usuario_comenta_jogo_function() RETURNS trigger AS $usuario_comenta_jogo_function$
    BEGIN
        IF (SELECT usuario_negativo 
            FROM usuario
            WHERE id = NEW.usuario_id) = true THEN
            
            RAISE EXCEPTION 'Usuário não pode ser um usuário negativo!';
        END IF;

        IF NOT EXISTS (SELECT * 
                       FROM usuario_possui_jogo
                       WHERE usuario_id = NEW.usuario_id
                       AND jogo_id = NEW.jogo_id) THEN

                       RAISE EXCEPTION 'Usuário somente pode comentar em jogos que o mesmo possui';
        END IF;

        IF (SELECT qtd_horas_jogadas
            FROM usuario_horas_jogo
            WHERE usuario_id = NEW.usuario_id
            AND jogo_id = NEW.jogo_id) <= 2 THEN

            RAISE EXCEPTION 'Usuário possui menos de 2 horas jogadas do jogo, então não pode comentar';
        END IF;
        
        RETURN NEW;
    END;
$usuario_comenta_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER usuario_comenta_jogo BEFORE INSERT ON comentario
    FOR EACH ROW EXECUTE FUNCTION usuario_comenta_jogo_function();

--- -----------------------------------------------------------------------------------

--- Ao dar update na tabela de comentário, verificar se trocando o usuário, esse usuário
--- segue as regras e ao trocar o jogo, verificar se o usuário pode comentar sobre aquele jogo

--- update comentario
--- set usuario_id = 1
--- where id = 3

--- update comentario
--- set usuario_id = 4
--- where id = 3

CREATE OR REPLACE FUNCTION update_usuario_comenta_jogo_function() RETURNS trigger AS $update_usuario_comenta_jogo_function$
    BEGIN
        IF (OLD.usuario_id <> NEW.usuario_id OR OLD.jogo_id <> NEW.jogo_id) THEN 
            IF (SELECT usuario_negativo
                FROM usuario
                WHERE id = NEW.usuario_id) = true THEN
                RAISE EXCEPTION 'Na tentativa de UPDATE o novo usuário do comentário não pode ser um usuário negativo';
            END IF;

            IF NOT EXISTS (SELECT * 
                       FROM usuario_possui_jogo
                       WHERE usuario_id = NEW.usuario_id
                       AND jogo_id = NEW.jogo_id) THEN

                       RAISE EXCEPTION 'Na tentativa de UPDATE o novo usuário somente pode comentar em jogos que o mesmo possui';
            END IF;

            IF (SELECT qtd_horas_jogadas
                FROM usuario_horas_jogo
                WHERE usuario_id = NEW.usuario_id
                AND jogo_id = NEW.jogo_id) <= 2 THEN

                RAISE EXCEPTION 'Na tentativa de UPDATE o novo usuário possui menos de 2 horas jogadas do jogo, então não pode comentar';
            END IF;
        END IF;
        RETURN NEW;
    END;
$update_usuario_comenta_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuario_comenta_jogo BEFORE UPDATE ON comentario
    FOR EACH ROW EXECUTE FUNCTION update_usuario_comenta_jogo_function();

--- -----------------------------------------------------------------------------------

--- Verificar se ao dar update em um usuário, se o update trocar os valor da coluna usuário
--- negativo, isso fará com que todos os seus comentários sejam excluídos também

CREATE OR REPLACE FUNCTION update_usuario_para_negativo_function() RETURNS trigger AS $update_usuario_para_negativo_function$
    BEGIN
        IF (OLD.usuario_negativo <> NEW.usuario_negativo AND NEW.usuario_negativo = true) THEN 
            DELETE FROM comentario WHERE usuario_id = NEW.usuario;
        END IF;

        RETURN NEW;
    END;
$update_usuario_para_negativo_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuario_para_negativo BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION update_usuario_para_negativo_function();

--- -----------------------------------------------------------------------------------

--- Ao tentar dar um update na tabela de usuario_horas_jogo, verificar:
---     - Se for update em qtd de horas, se for pra menor de 2, verificar
---     se existe comentario do usuario nesse jogo, se sim, não deixar

---     - Se for update em usuário ou jogo, não deixo pensando na ideia de que essa info é instransferível

CREATE OR REPLACE FUNCTION update_usuario_horas_jogo_function() RETURNS trigger AS $update_usuario_horas_jogo_function$
    BEGIN
        IF (OLD.qtd_horas_jogadas <> NEW.qtd_horas_jogadas AND NEW.qtd_horas_jogadas < 2) THEN
            IF EXISTS (SELECT *
                        FROM comentario
                        WHERE usuario_id = NEW.usuario_id
                        AND jogo_id = NEW.jogo_id) THEN
                        RAISE EXCEPTION 'Na tentativa de UPDATE para uma qtd de horas de jogo menor que 2, o usuário em questão possui comentários, logo não pode ter menos de 2horas de jogo';
            END IF;
        END IF;

        IF (OLD.usuario_id <> NEW.usuario_id OR OLD.jogo_id <> NEW.jogo_id) THEN
            RAISE EXCEPTION 'Informação de horas de jogo não pode ser transferida de um jogador para outro nem de um jogo para outro';
        END IF;

        RETURN NEW;
    END;
$update_usuario_horas_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuario_horas_jogo BEFORE UPDATE ON usuario_horas_jogo
    FOR EACH ROW EXECUTE FUNCTION update_usuario_horas_jogo_function();

--- -----------------------------------------------------------------------------------

--- Ao tentar dar um delete na tabela usuario_horas_jogo, verificar se o usuario possui comentario sobre o jogo em questão, se sim, não deixar

CREATE OR REPLACE FUNCTION delete_usuario_horas_jogo_function() RETURNS trigger AS $delete_usuario_horas_jogo_function$
    BEGIN
        IF EXISTS (SELECT *
                    FROM comentario
                    WHERE usuario_id = OLD.usuario_id
                    AND jogo_id = OLD.jogo_id) THEN
                    RAISE EXCEPTION 'Não é possível deletar horas de jogo do usuário em questão pois o mesmo possui comentários sobre o jogo';
        END IF;

        RETURN OLD;
    END;
$delete_usuario_horas_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER delete_usuario_horas_jogo BEFORE DELETE ON usuario_horas_jogo
    FOR EACH ROW EXECUTE FUNCTION delete_usuario_horas_jogo_function();

--- -----------------------------------------------------------------------------------

--- Ao tentar dar um update na tabela de usuario_possui_jogo, verificar:

---     - Se for update em usuário ou jogo, não deixo pensando na ideia de que essa info é instransferível

CREATE OR REPLACE FUNCTION update_usuario_possui_jogo_function() RETURNS trigger AS $update_usuario_possui_jogo_function$
    BEGIN
        IF (OLD.usuario_id <> NEW.usuario_id OR OLD.jogo_id <> NEW.jogo_id) THEN
            RAISE EXCEPTION 'Informação de posse de jogo não pode ser transferida de um jogador para outro nem de um jogo para outro';
        END IF;

        RETURN NEW;
    END;
$update_usuario_possui_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuario_possui_jogo BEFORE UPDATE ON usuario_possui_jogo
    FOR EACH ROW EXECUTE FUNCTION update_usuario_possui_jogo_function();

--- -----------------------------------------------------------------------------------

--- Ao tentar dar um delete na tabela usuario_horas_jogo, verificar se o usuario possui comentario sobre o jogo em questão, se sim, não deixar

CREATE OR REPLACE FUNCTION delete_usuario_possui_jogo_function() RETURNS trigger AS $delete_usuario_possui_jogo_function$
    BEGIN
        DELETE FROM comentario WHERE usuario_id = OLD.usuario_id AND jogo_id = OLD.jogo_id;
        
        RETURN OLD;
    END;
$delete_usuario_possui_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER delete_usuario_possui_jogo BEFORE DELETE ON usuario_possui_jogo
    FOR EACH ROW EXECUTE FUNCTION delete_usuario_possui_jogo_function();

    