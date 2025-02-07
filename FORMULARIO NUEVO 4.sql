-- FUNCTION: public.i_agree_informe_reporte_formulario_izzi(integer, text, text)

-- DROP FUNCTION IF EXISTS public.i_agree_informe_reporte_formulario_izzi(integer, text, text);

CREATE OR REPLACE FUNCTION public.i_agree_informe_reporte_formulario_izzi(
	idcampana integer,
	fechadesdelocal text,
	fechahastalocal text,
	OUT "FECHA_CREACION" character varying,
	OUT "CLIENTE" character varying,
	OUT "MORA" integer,
	OUT "LLAMADA_SIN_DATOS" character varying,
	OUT "GESTIONABLE" text,
	OUT "MOTIVO_NO_GESTIONABLE" text,
	OUT "SUB_MOTIVO_NO_GESTIONABLE" text,
	OUT "NO_CASO" text,
	OUT "TIPO_GESTION" text,
	OUT "TIPO_PROMESA" text,
	OUT "TIPO_NEGATIVA" text,
	OUT "SUBTIPO_NEGATIVA" text,
	OUT "TIPO_LLAMADA" text,
	OUT "NUMERO_TELEFONICO" character varying,
	OUT "MOTIVO_ATRASO" text,
	OUT "SUBMOTIVO_ATRASO" text,
	OUT "CANTIDAD_A_PAGAR" numeric,
	OUT "FECHA_PAGO_PROMETIDA" text,
	OUT "PROMOCION" character varying,
	OUT "TIPO_PROMOCION" character varying,
	OUT "TIPO_CAMPAÑA" character varying,
	OUT "SCORE_CLIENTE" character varying,
	OUT "ANTIGUEDAD" character varying)
	RETURNS SETOF record 
	LANGUAGE 'sql'
	COST 100
	VOLATILE PARALLEL UNSAFE
	ROWS 1000

AS $BODY$
	SELECT DISTINCT
		to_char(g.fecha_creacion, 'dd/mm/yyyy hh:mm:ss') AS "FECHA_CREACION",
		o.numero_producto AS "CLIENTE",
		o.dias_mora_inicio AS "MORA",
		'NO'::character varying AS "LLAMADA_SIN_DATOS",
		CASE WHEN app.descripcion2 != 'PR1' THEN 'NO' ELSE 'SI' END AS "GESTIONABLE",
		COALESCE(mng.titulo, '') AS "MOTIVO_NO_GESTIONABLE",
		COALESCE(smng.titulo, '') AS "SUB_MOTIVO_NO_GESTIONABLE",
		' '::character varying AS "NO_CASO",
		CASE 
			WHEN app.guion2 = 'PROMESA DE PAGO' THEN 'PROMESA' 
			WHEN app.guion2 = 'NEGATIVA DE PAGO' THEN 'NEGATIVA' 
			ELSE '' 
		END AS "TIPO_GESTION",
		COALESCE(app.guion2, '') AS "TIPO_PROMESA",
		COALESCE(tn.titulo, '') AS "TIPO_NEGATIVA",
		COALESCE(stn.titulo, '') AS "SUBTIPO_NEGATIVA",
		CASE 
			WHEN g.fk_id_canal_contacto = 1 THEN 'OUTBOUND' 
			WHEN g.fk_id_canal_contacto = 2 THEN 'INBOUND' 
		END AS "TIPO_LLAMADA",
		t.numero_tel AS "NUMERO_TELEFONICO",
		COALESCE(m.titulo, '') AS "MOTIVO_ATRASO",
		COALESCE(sm.titulo, '') AS "SUBMOTIVO_ATRASO",
		a.valor_acuerdo AS "CANTIDAD_A_PAGAR",
		to_char(a.fecha_prom_pago, 'dd/mm/yyyy') AS "FECHA_PAGO_PROMETIDA",
		COALESCE(app.guion5, '') AS "PROMOCION",
		o.columna25 AS "TIPO_PROMOCION",
		'INACTIVO'::character varying AS "TIPO_CAMPAÑA",
		o.columna2 AS "SCORE_CLIENTE",
		o.columna5 AS "ANTIGUEDAD"
	FROM as_gestiones g
	INNER JOIN as_deudor d ON d.id_deudor = g.fk_id_deudor
	INNER JOIN as_usuarios u ON u.id_usuario = g.fk_id_usuario_crea
	INNER JOIN as_obligacion o ON o.fk_id_deudor = g.fk_id_deudor
	LEFT JOIN as_actividades_panel_principal app ON app.fk_id_gestion = g.id_gestion AND app.fk_id_agree_guion IS NOT NULL
	LEFT JOIN as_telefono_deudores t ON g.fk_id_telefono = t.id_telefono
	LEFT JOIN as_formulario_pago p ON p.fk_id_gestion = g.id_gestion
	LEFT JOIN as_acuerdos a ON a.fk_id_gestion = g.id_gestion
	INNER JOIN as_campanas c ON c.id_campana = g.fk_id_campana
	INNER JOIN as_agrupacion_campanas ac ON ac.id_agrupacion_campanas = c.fk_id_agrupacion_campanas
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pi.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		JOIN as_panel_informativo pi ON pm.fk_id_panel_informativo = pi.id_panel_informativo
		WHERE (pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo IN (25, 29, 30)) 
			OR (pi.fk_id_panel_prncipal = 14) 
			AND ap.fk_id_gestion IS NOT NULL
	) mng ON mng.fk_id_gestion = g.id_gestion
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pm.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		WHERE (pm.fk_id_panel_informativo = 25 AND pm.id_panel_mixto IN (138, 139, 140, 141))
			OR (pm.fk_id_panel_informativo = 29 AND pm.id_panel_mixto IN (155, 156, 157))
			OR (pm.fk_id_panel_informativo = 30 AND pm.id_panel_mixto IN (158, 159, 160, 161))
			OR (pm.fk_id_panel_informativo = 36 AND pm.id_panel_mixto IN (164, 165, 166, 167))
			OR (pm.fk_id_panel_informativo = 37 AND pm.id_panel_mixto IN (168, 169, 170))
			OR (pm.fk_id_panel_informativo = 38 AND pm.id_panel_mixto IN (171, 172, 173, 174, 175, 176))
			AND ap.fk_id_gestion IS NOT NULL
	) smng ON smng.fk_id_gestion = g.id_gestion
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pi.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		JOIN as_panel_informativo pi ON pm.fk_id_panel_informativo = pi.id_panel_informativo
		WHERE pi.fk_id_panel_prncipal = 8 AND ap.fk_id_gestion IS NOT NULL
	) tn ON tn.fk_id_gestion = g.id_gestion
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pm.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		WHERE pm.fk_id_panel_informativo IN (
			SELECT id_panel_informativo 
			FROM as_panel_informativo 
			WHERE fk_id_panel_prncipal = 8
		)
	) stn ON stn.fk_id_gestion = g.id_gestion
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pi.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		JOIN as_panel_informativo pi ON pm.fk_id_panel_informativo = pi.id_panel_informativo
		WHERE pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo NOT IN (25, 29, 30) 
			AND ap.fk_id_gestion IS NOT NULL
	) m ON m.fk_id_gestion = g.id_gestion
	LEFT JOIN (
		SELECT ap.fk_id_gestion, pm.titulo
		FROM as_actividades_panel_principal ap
		JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
		WHERE (pm.fk_id_panel_informativo = 7 AND pm.id_panel_mixto IN (83, 84, 85, 86, 87))
			OR (pm.fk_id_panel_informativo = 8 AND pm.id_panel_mixto IN (88, 89, 90, 91, 92, 93, 94, 95, 96))
			OR (pm.fk_id_panel_informativo = 9 AND pm.id_panel_mixto IN (97, 98, 99, 100, 101, 102, 103, 104, 105))
			OR (pm.fk_id_panel_informativo = 10 AND pm.id_panel_mixto IN (106, 178))
			OR (pm.fk_id_panel_informativo = 11 AND pm.id_panel_mixto IN (107, 108))
			OR (pm.fk_id_panel_informativo = 12 AND pm.id_panel_mixto IN (109))
			OR (pm.fk_id_panel_informativo = 13 AND pm.id_panel_mixto IN (110))
			OR (pm.fk_id_panel_informativo = 14 AND pm.id_panel_mixto IN (111))
			OR (pm.fk_id_panel_informativo = 15 AND pm.id_panel_mixto IN (112))
			OR (pm.fk_id_panel_informativo = 16 AND pm.id_panel_mixto IN (113))
			OR (pm.fk_id_panel_informativo = 32 AND pm.id_panel_mixto IN (163, 179))
	) sm ON sm.fk_id_gestion = g.id_gestion
	WHERE 
		g.fk_id_campana = idcampana
		AND (CAST(g.fecha_creacion AS date) BETWEEN fechadesdelocal::date AND fechahastalocal::date)
	ORDER BY 1;
$BODY$;

ALTER FUNCTION public.i_agree_informe_reporte_formulario_izzi(integer, text, text)
	OWNER TO iagreedbuser;
