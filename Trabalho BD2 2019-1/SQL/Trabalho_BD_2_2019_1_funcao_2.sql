DROP FUNCTION IF EXISTS ranking_jogos;
CREATE OR REPLACE FUNCTION ranking_jogos(key int) RETURNS TABLE(jogo int, score float) AS $ranking_jogos$
BEGIN
	RETURN QUERY SELECT t1.id AS jogo, (t4.qtd_horas_jogadas::float * t3.estrelas / 5.0) AS score FROM jogo AS t1
	INNER JOIN usuario_possui_jogo AS t2 ON t2.usuario_id = key AND t2.jogo_id = t1.id
	INNER JOIN comentario AS t3 ON t3.usuario_id = key AND t3.jogo_id = t1.id
	INNER JOIN usuario_horas_jogo AS t4 ON t4.usuario_id = key AND t4.jogo_id = t1.id
	ORDER BY score DESC;
END;
$ranking_jogos$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS jogos_recomendados;
CREATE OR REPLACE FUNCTION jogos_recomendados(userid int) RETURNS SETOF jogo AS $jogos_recomendados$
DECLARE
	outros_usuarios CURSOR FOR SELECT * FROM usuario WHERE id <> userid;
	score_recomendados float[];
	n_jogos int;
	total int;
	peso float;
	r1 record;
	r3 record;
	aux float;
	maxidx int;
	auxarr int[];
	auxi int;
BEGIN
	IF NOT EXISTS (SELECT * FROM usuario WHERE id = userid) THEN
		RAISE EXCEPTION 'Usuário com ID % não existe.', userid;
	END IF;
	
	SELECT MAX(id) INTO n_jogos FROM jogo;
	score_recomendados = array_fill(0::float, ARRAY[n_jogos]);	
	
	SELECT COUNT(*) INTO total FROM ranking_jogos(userid);
	peso = 1::float;
	
	FOR r1 IN SELECT * FROM ranking_jogos(userid) LOOP
		FOR r2 IN outros_usuarios LOOP
			IF EXISTS (SELECT * FROM ranking_jogos(r2.id) WHERE jogo = r1.jogo) THEN
				FOR r3 IN SELECT * FROM ranking_jogos(r2.id) LOOP
					IF r3.jogo <> r1.jogo THEN
						score_recomendados[r3.jogo] = score_recomendados[r3.jogo] + r3.score * peso;
					END IF;
				END LOOP;
			END IF;
		END LOOP;
		peso = peso - 1::float / total;
	END LOOP;
	
	auxarr = array_fill(0, ARRAY[n_jogos]);
	FOR i IN 1..n_jogos LOOP
		auxarr[i] = i;
	END LOOP;
	
	FOR i IN 1..n_jogos LOOP
		maxidx = i;
		FOR j IN i+1..n_jogos LOOP
			IF score_recomendados[j] > score_recomendados[maxidx] THEN
				maxidx = j;
			END IF;
		END LOOP;
		
		IF maxidx <> i THEN
			aux = score_recomendados[i];
			score_recomendados[i] = score_recomendados[maxidx];
			score_recomendados[maxidx] = aux;
			
			auxi = auxarr[i];
			auxarr[i] = auxarr[maxidx];
			auxarr[maxidx] = auxi;
		END IF;
		
		IF score_recomendados[i] > 0 THEN
			RETURN QUERY SELECT * FROM jogo WHERE id = auxarr[i];
		END IF;
	END LOOP;
	
	RETURN;
END;
$jogos_recomendados$ LANGUAGE plpgsql;