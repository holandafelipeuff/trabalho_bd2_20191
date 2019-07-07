
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

            RAISE EXCEPTION 'Usuário possui menos de 2 horas jogadas do jogo, então não pode jogar';
        END IF;
        
        RETURN NEW;
    END;
$usuario_comenta_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER usuario_comenta_jogo BEFORE INSERT ON comentario
    FOR EACH ROW EXECUTE FUNCTION usuario_comenta_jogo_function();