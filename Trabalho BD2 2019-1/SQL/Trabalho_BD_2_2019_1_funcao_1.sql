--- INSERT INTO comentario(id, texto, estrelas, usuario_id, jogo_id, hora)VALUES (2, 'Esse jogo está uma porra', 4, 2, 3, '2019-04-11T10:13:46');


CREATE OR REPLACE FUNCTION badlanguage() RETURNS VOID AS $$
	DECLARE
		c_comentario CURSOR FOR SELECT * FROM comentario FOR UPDATE OF comentario;
	BEGIN
		FOR i IN c_comentario LOOP
			IF(i.texto LIKE '%porra')=TRUE THEN
			    UPDATE usuario SET usuario_negativo = true WHERE id in (select usuario_id from comentario where texto = i.texto);
			  	DELETE FROM comentario WHERE texto = i.texto;
			 END IF;
		END LOOP;
	END;
	$$ LANGUAGE plpgsql;
