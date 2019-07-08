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