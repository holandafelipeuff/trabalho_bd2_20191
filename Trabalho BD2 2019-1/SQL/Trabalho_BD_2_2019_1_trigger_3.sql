--- -----------------------------------------------------------------------

--- INSERT INTO usuario_possui_jogo(preco_comprado, data_compra, usuario_id, jogo_id) VALUES (12, '25/3/2019', 5, 2);

--- insert em usuario_possui_jogo

create or replace function maior_idade_compra() returns trigger as $$
declare
	categoria_cursor REFCURSOR;
	jogo_categoria_row jogo_pertence_categoria%ROWTYPE;
	
	idade_usuario integer;
	jogo_restrito bool = false;
	usuario_nasc date;	
BEGIN
   	select data_nascimento into usuario_nasc from usuario where usuario.id = NEW.usuario_id;
   	if usuario_nasc is null then
   		RAISE EXCEPTION 'Não existe esse id -- %', NEW.usuario_id;
   	end if;
   	idade_usuario = date_part('year',age(now(), usuario_nasc));
							  							  
   	open categoria_cursor for select * from jogo_pertence_categoria where jogo_id = NEW.jogo_id;				 
   	LOOP
      	FETCH categoria_cursor INTO jogo_categoria_row;
      	EXIT WHEN NOT FOUND;
		select precisa_ser_maior_idade into jogo_restrito from categoria where id = jogo_categoria_row.categoria_id;					 
		if jogo_restrito = true then				 
			exit;			 				 
		end if;
   	END LOOP;
   
   	if jogo_restrito = true and idade_usuario < 18 then
		RAISE EXCEPTION 'Jogo é de maior de idade e o usuário tem -- %', idade_usuario;					 
   	else
		RETURN NEW;
   	end if;
END;$$
LANGUAGE plpgsql;					  

CREATE TRIGGER insert_maior_idade_compra BEFORE INSERT ON usuario_possui_jogo
    FOR EACH ROW EXECUTE FUNCTION maior_idade_compra();




--- ----------------------------------------------------------------------------------------------------

--- update em usuario_possui_jogo
CREATE OR REPLACE FUNCTION update_negado_usuario_possui_jogo_function() RETURNS trigger AS $update_negado_usuario_possui_jogo_function$
    BEGIN

        IF OLD.usuario_id <> NEW.usuario_id OR OLD.jogo_id <> NEW.jogo_id THEN
            RAISE EXCEPTION 'Jogo e Usuario não podem ser alterados por meio de update na tabela usuario possui jogo';
        END IF;

		RETURN NEW;
    
    END;
$update_negado_usuario_possui_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_negado_usuario_possui_jogo BEFORE UPDATE ON usuario_possui_jogo
    FOR EACH ROW EXECUTE FUNCTION update_negado_usuario_possui_jogo_function();




--- ----------------------------------------------------------------------------------------------------

--- DELETE em usuario_possui_jogo
CREATE OR REPLACE FUNCTION delete_atualiza_usuario_possui_jogo_function() RETURNS trigger AS $delete_atualiza_usuario_possui_jogo_function$
    BEGIN
		
		DELETE FROM comentario
		WHERE usuario_id = OLD.usuario_id;

		RETURN OLD;

    END;
$delete_atualiza_usuario_possui_jogo_function$ LANGUAGE plpgsql;

CREATE TRIGGER delete_atualiza_usuario_possui_jogo BEFORE DELETE ON usuario_possui_jogo
    FOR EACH ROW EXECUTE FUNCTION delete_atualiza_usuario_possui_jogo_function();


--- ----------------------------------------------------------------------------------------------------

--- update em CATEGORIA
CREATE OR REPLACE FUNCTION update_categoria_maior_function() RETURNS trigger AS $update_categoria_maior_function$
    BEGIN

        IF OLD.maior_idade_compra <> NEW.maior_idade_compra AND NEW.maior_idade_compra THEN
            RAISE EXCEPTION 'Não pode setar uma categoria para maior de idade depois de adicionada';
        END IF;

		RETURN NEW;
    
    END;
$update_categoria_maior_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_categoria_maior BEFORE UPDATE ON categoria
    FOR EACH ROW EXECUTE FUNCTION update_categoria_maior_function();



--- ----------------------------------------------------------------------------------------------------

--- update em CATEGORIA
CREATE OR REPLACE FUNCTION update_usuario_nascimento_function() RETURNS trigger AS $update_usuario_nascimento_function$
    BEGIN

        IF OLD.data_nascimento <> NEW.data_nascimento THEN
            RAISE EXCEPTION 'Não pode modificar data de nascimento depois do usuário ser inserido no bd';
        END IF;

		RETURN NEW;
    
    END;
$update_usuario_nascimento_function$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuario_nascimento BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION update_usuario_nascimento_function();


