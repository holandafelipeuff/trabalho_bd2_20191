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
	
		 
SELECT badlanguage();
