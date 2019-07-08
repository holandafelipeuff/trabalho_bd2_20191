--- ----------------------------------------------------------------------------------------

--- Ao inserir uma nova promoção de categoria, todos os jogos daquela categoria deverão ter seu preço atualizado, isso claro
--- se estiver nos periodo da promoção

CREATE OR REPLACE FUNCTION promocao_de_categoria_function() RETURNS trigger AS $promocao_de_categoria_function$
    DECLARE
        c1 REFCURSOR;
        r1 jogo_pertence_categoria%ROWTYPE;
        dinheiro_desconto money;	
    BEGIN

        IF NEW.categoria_id IS NULL THEN
            RETURN NEW;
        END IF;

        IF  NEW.categoria_id IS NOT NULL AND NEW.inicio < now()::date AND NEW.FIM > now()::date THEN

            OPEN c1 FOR SELECT * FROM jogo_pertence_categoria WHERE categoria_id = NEW.categoria_id;

            LOOP

                FETCH c1 INTO  r1;

                EXIT WHEN NOT FOUND;

                dinheiro_desconto = (SELECT preco FROM jogo WHERE id = r1.jogo_id);
                dinheiro_desconto = dinheiro_desconto * NEW.porcentagem;
                dinheiro_desconto = dinheiro_desconto / 100;

                UPDATE jogo
                SET preco = preco - dinheiro_desconto
                WHERE id = r1.jogo_id;
                 
                INSERT INTO jogo_em_promocao
                (promocao_id, jogo_id)
                VALUES (NEW.id, r1.jogo_id);

            END LOOP;

            CLOSE c1;
            
        END IF;

        RETURN NEW;
    END;
$promocao_de_categoria_function$ LANGUAGE plpgsql;

CREATE TRIGGER promocao_de_categoria AFTER INSERT ON promocao
    FOR EACH ROW EXECUTE FUNCTION promocao_de_categoria_function();



--- ----------------------------------------------------------------------------------------

--- update em promoção

CREATE OR REPLACE FUNCTION update_promocao_de_categoria_function() RETURNS trigger AS $update_promocao_de_categoria_function$
    DECLARE
        c1 REFCURSOR;
        r1 jogo_em_promocao%ROWTYPE;
        r2 jogo_pertence_categoria%ROWTYPE;
        dinheiro_desconto money;
    BEGIN

        IF OLD.porcentagem <> NEW.porcentagem THEN
            OPEN c1 FOR SELECT * FROM jogo_em_promocao WHERE promocao_id = NEW.promocao_id;

            LOOP

                FETCH c1 INTO  r1;

                EXIT WHEN NOT FOUND;

                dinheiro_desconto = (SELECT preco FROM jogo WHERE id = r1.jogo_id);
                dinheiro_desconto = dinheiro_desconto * OLD.porcentagem;
                dinheiro_desconto = dinheiro_desconto / 100;

                UPDATE jogo
                SET preco = preco + dinheiro_desconto
                WHERE id = r1.jogo_id;

                
                dinheiro_desconto = (SELECT preco FROM jogo WHERE id = r1.jogo_id);
                dinheiro_desconto = dinheiro_desconto * NEW.porcentagem;
                dinheiro_desconto = dinheiro_desconto / 100;

                UPDATE jogo
                SET preco = preco - dinheiro_desconto
                WHERE id = r1.jogo_id;
                 
            END LOOP;

            CLOSE c1;
        END IF;

        IF OLD.inicio <> NEW.inicio OR OLD.fim <> NEW.fim THEN
            RAISE EXCEPTION 'Data de inicio e fim de uma promoção não podem ser modificadas';
        END IF;

        IF OLD.categoria_id <> NEW.categoria_id THEN
            
            OPEN c1 FOR SELECT * FROM jogo_pertence_categoria WHERE categoria_id = OLD.categoria_id;

            LOOP

                FETCH c1 INTO r2;

                EXIT WHEN NOT FOUND;

                dinheiro_desconto = (SELECT preco FROM jogo WHERE id = r2.jogo_id);
                dinheiro_desconto = dinheiro_desconto * NEW.porcentagem;
                dinheiro_desconto = dinheiro_desconto / 100;

                UPDATE jogo
                SET preco = preco + dinheiro_desconto
                WHERE id = r2.jogo_id;
            
            END LOOP;

            CLOSE c1;

            OPEN c1 FOR SELECT * FROM jogo_pertence_categoria WHERE categoria_id = NEW.categoria_id;

            LOOP            
                
                FETCH c1 INTO r2;

                EXIT WHEN NOT FOUND;

                dinheiro_desconto = (SELECT preco FROM jogo WHERE id = r2.jogo_id);
                dinheiro_desconto = dinheiro_desconto * NEW.porcentagem;
                dinheiro_desconto = dinheiro_desconto / 100;

                UPDATE jogo
                SET preco = preco - dinheiro_desconto
                WHERE id = r2.jogo_id;
                 
            END LOOP;

            CLOSE c1;
        
        END IF;

        RETURN NEW;
    END;
$update_promocao_de_categoria_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_promocao_de_categoria BEFORE UPDATE ON promocao
    FOR EACH ROW EXECUTE FUNCTION update_promocao_de_categoria_function();



--- -------------------------------------------------------

--- Insert em jogo_em_promocao

CREATE OR REPLACE FUNCTION insert_jogo_em_promocao_function() RETURNS trigger AS $insert_jogo_em_promocao_function$
    DECLARE
        dinheiro_desconto money;
        porcentagem int;
    BEGIN

        IF NOT EXISTS (SELECT *
                        FROM usuario
                        WHERE id = NEW.usuario_id) THEN
            RAISE EXCEPTION 'Usuario não existe';
        END IF;

        IF NOT EXISTS (SELECT *
                        FROM promocao
                        WHERE id = NEW.promocao_id) THEN
            RAISE EXCEPTION 'Promocao não existe';
        END IF;

        porcentagem = (SELECT porcentagem
                        FROM promocao
                        WHERE id = NEW.promocao_id);
        
        dinheiro_desconto = (SELECT preco FROM jogo WHERE id = NEW.jogo_id);
        dinheiro_desconto = dinheiro_desconto * porcentagem;
        dinheiro_desconto = dinheiro_desconto / 100;

        UPDATE jogo SET preco = preco - dinheiro_desconto WHERE id = NEW.jogo_id;

        RETURN NEW;

    END;
$insert_jogo_em_promocao_function$ LANGUAGE plpgsql;

CREATE TRIGGER insert_jogo_em_promocao BEFORE INSERT ON jogo_em_promocao
    FOR EACH ROW EXECUTE FUNCTION insert_jogo_em_promocao_function();

    


--- -------------------------------------------------------

--- Ao tentar dar update em jogo_em_promocao não deixo a atualização
--- falando que um jogo não pode se transferir de uma promoção para outra
CREATE OR REPLACE FUNCTION update_jogo_em_promocao_function() RETURNS trigger AS $update_jogo_em_promocao_function$
    BEGIN

        IF OLD.promocao_id <> NEW.promocao_id OR OLD.jogo_id <> NEW.jogo_id THEN
            RAISE EXCEPTION 'Jogo e Promoção não podem ser alterados por meio de update';
        END IF;
    
    END;
$update_jogo_em_promocao_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_jogo_em_promocao BEFORE UPDATE ON jogo_em_promocao
    FOR EACH ROW EXECUTE FUNCTION update_jogo_em_promocao_function();

    

--- -------------------------------------------------------

--- Ao deletar alguém da tabela jogo_em_promocao seu valor deve voltar ao normal
--- igual a antes da promoção

CREATE OR REPLACE FUNCTION delete_jogo_em_promocao_function() RETURNS trigger AS $delete_jogo_em_promocao_function$
    DECLARE
        dinheiro_desconto money;
    
    BEGIN

        dinheiro_desconto = (SELECT preco FROM jogo WHERE id = OLD.jogo_id);
        dinheiro_desconto = dinheiro_desconto * (SELECT porcentagem FROM promocao WHERE id = OLD.promocao_id);
        dinheiro_desconto = dinheiro_desconto / 100;

        UPDATE jogo SET preco = preco + dinheiro_desconto WHERE id = OLD.jogo_id;

        RETURN OLD;   
    
    END;
$delete_jogo_em_promocao_function$ LANGUAGE plpgsql;

CREATE TRIGGER delete_jogo_em_promocao BEFORE DELETE ON jogo_em_promocao
    FOR EACH ROW EXECUTE FUNCTION delete_jogo_em_promocao_function();


    
--- -------------------------------------------------------

--- Insert em jogo_pertence_categoria
CREATE OR REPLACE FUNCTION insert_jogo_pertence_categoria_function() RETURNS trigger AS $insert_jogo_pertence_categoria_function$
    DECLARE
        dinheiro_desconto money;
    BEGIN
        IF EXISTS (SELECT *
                    FROM promocao
                    WHERE categoria_id = NEW.categoria_id
                    AND inicio < now()::date
                    AND fim > now()::date) THEN

            dinheiro_desconto = (SELECT preco FROM jogo WHERE id = NEW.jogo_id);
            dinheiro_desconto = dinheiro_desconto * (SELECT porcentagem FROM promocao WHERE categoria_id = NEW.categoria_id);
            dinheiro_desconto = dinheiro_desconto / 100;

            NEW.preco = NEW.preco - dinheiro_desconto;

        END IF;
        
        RETURN NEW;   
    END;
$insert_jogo_pertence_categoria_function$ LANGUAGE plpgsql;

CREATE TRIGGER insert_jogo_pertence_categoria BEFORE UPDATE ON jogo_pertence_categoria
    FOR EACH ROW EXECUTE FUNCTION insert_jogo_pertence_categoria_function();


--- -------------------------------------------------------

--- Ao tentar dar update em jogo_pertence_categoria não deixo a atualização
--- falando que um jogo não pode se transferir de uma categoria para outra
CREATE OR REPLACE FUNCTION update_jogo_pertence_categoria_function() RETURNS trigger AS $update_jogo_pertence_categoria_function$
    BEGIN

        IF OLD.categoria_id <> NEW.categoria_id OR OLD.jogo_id <> NEW.jogo_id THEN
            RAISE EXCEPTION 'Jogo e Categoria não podem ser alterados por meio de update';
        END IF;
    
    END;
$update_jogo_pertence_categoria_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_jogo_pertence_categoria BEFORE UPDATE ON jogo_pertence_categoria
    FOR EACH ROW EXECUTE FUNCTION update_jogo_pertence_categoria_function();

    --- -------------------------------------------------------

--- Delete em jogo_pertence_categoria
CREATE OR REPLACE FUNCTION delete_jogo_pertence_categoria_function() RETURNS trigger AS $delete_jogo_pertence_categoria_function$
    DECLARE
        dinheiro_desconto money;
    BEGIN
        IF EXISTS (SELECT *
                    FROM promocao
                    WHERE categoria_id = OLD.categoria_id
                    AND inicio < now()::date
                    AND fim > now()::date) THEN

            dinheiro_desconto = (SELECT preco FROM jogo WHERE id = OLD.jogo_id);
            dinheiro_desconto = dinheiro_desconto * (SELECT porcentagem FROM promocao WHERE categoria_id = OLD.categoria_id);
            dinheiro_desconto = dinheiro_desconto / 100;

            UPDATE jogo SET preco = preco + dinheiro_desconto WHERE id = OLD.jogo_id;

        END IF;
        
        RETURN OLD;   
    END;
$delete_jogo_pertence_categoria_function$ LANGUAGE plpgsql;

CREATE TRIGGER delete_jogo_pertence_categoria BEFORE DELETE ON jogo_pertence_categoria
    FOR EACH ROW EXECUTE FUNCTION delete_jogo_pertence_categoria_function();
