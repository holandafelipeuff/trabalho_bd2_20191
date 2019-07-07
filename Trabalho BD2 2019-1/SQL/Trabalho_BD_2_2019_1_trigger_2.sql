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