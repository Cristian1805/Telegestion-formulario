-- Function: public.i_agree_informe_reporte_formulario_izzi(integer, text, text)

-- DROP FUNCTION public.i_agree_informe_reporte_formulario_izzi(integer, text, text);

CREATE OR REPLACE FUNCTION public.i_agree_informe_reporte_formulario_izzi(
    IN idcampana integer,
    IN fechadesdelocal text,
    IN fechahastalocal text,
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
  RETURNS SETOF record AS
$BODY$	
	select distinct
	     to_char(gestion.fecha_creacion, 'dd/mm/yyyy hh:mm:ss') fecha_gestion,
	     obligacion.numero_producto,
	     obligacion.dias_mora_inicio,
	     'NO'::character varying llamada_sin_datos,
	     CASE WHEN actiPanelPrinci.descripcion2 != 'PR1' THEN 'NO' ELSE 'SI' END gestionable,
	     COALESCE(motivo_no_ges.titulo, '') motivo_no_gestionable, 
	     COALESCE(sub_motivo_no_gestionable.titulo, '') sub_motivo_no_gestionable,
	     ' '::character varying no_caso,
	    
	     CASE WHEN actiPanelPrinci.guion2 = 'PROMESA DE PAGO' THEN 'PROMESA' 
		ELSE  CASE WHEN actiPanelPrinci.guion2 = 'NEGATIVA DE PAGO' THEN 'NEGATIVA' 
		      ELSE '' END 
		END tipo_gestion, 
	     COALESCE(actiPanelPrinci.guion2, '') tipo_promesa, 
	     COALESCE(tipo_nega.titulo, '') tipo_nega, 
	     COALESCE(subtipo_nega.titulo, '') subtipo_nega, 
	     CASE WHEN gestion.fk_id_canal_contacto = 1 THEN 'OUTBOUND' 
		ELSE CASE WHEN gestion.fk_id_canal_contacto = 2 
		     THEN 'INBOUND' END  
		END tipo_llamada, 
	     telefono.numero_tel,
	     COALESCE(motivo.titulo, '') motivo_atraso, 
	     COALESCE(submotivo.titulo, '') submotivo_atraso, 
	     acuerdo.valor_acuerdo,
	     to_char(acuerdo.fecha_prom_pago, 'dd/mm/yyyy') fechaPromesa,	
             COALESCE(actiPanelPrinci.guion5, '') promocion, -- CUARTO NIVEL DEL ARBOL
             obligacion.columna25 tipo_promocion,
             'INACTIVO'::character varying,
             obligacion.columna2 SCORE_CLIENTE,
             obligacion.columna5 ANTIGUEDAD
	     
	FROM 	   as_gestiones gestion  
	INNER JOIN as_deudor deudor ON deudor.id_deudor = gestion.fk_id_deudor 
	INNER JOIN as_usuarios usuario ON usuario.id_usuario = gestion.fk_id_usuario_crea 
	INNER JOIN as_obligacion obligacion ON obligacion.fk_id_deudor = gestion.fk_id_deudor
	LEFT JOIN  as_actividades_panel_principal actiPanelPrinci ON actiPanelPrinci.fk_id_gestion = gestion.id_gestion and fk_id_agree_guion is not null 
	LEFT JOIN  as_telefono_deudores telefono ON gestion.fk_id_telefono = telefono.id_telefono
	LEFT JOIN  as_formulario_pago pago ON pago.fk_id_gestion = gestion.id_gestion 
	LEFT JOIN  as_acuerdos acuerdo ON acuerdo.fk_id_gestion = gestion.id_gestion 
        INNER JOIN as_campanas camp ON camp.id_campana = gestion.fk_id_campana
	INNER JOIN as_agrupacion_campanas agrup ON agrup.id_agrupacion_campanas = camp.fk_id_agrupacion_campanas
	LEFT JOIN (
		
SELECT  
    ap.fk_id_gestion AS fk_id_gestion,
    ap.fk_id_panel_mixto AS fk_id_panel_mixto,
    pi.titulo AS titulo
FROM  
    as_actividades_panel_principal ap
JOIN 
    as_panel_mixto pm
ON 
    ap.fk_id_panel_mixto = pm.id_panel_mixto
JOIN 
    as_panel_informativo pi
ON 
    pm.fk_id_panel_informativo = pi.id_panel_informativo
WHERE 
    (pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo IN (25, 29, 30)) 
		    OR 
		    (pi.fk_id_panel_prncipal = 14) 
		    AND ap.fk_id_gestion IS NOT NULL
	) motivo_no_ges ON motivo_no_ges.fk_id_gestion = gestion.id_gestion -- "MOTIVO NO GESTIONABLE"
    LEFT JOIN(
		SELECT  
        ap.fk_id_gestion AS fk_id_gestion,
        ap.fk_id_panel_mixto AS fk_id_panel_mixto,
        pm.titulo AS titulo
    FROM 	
        as_actividades_panel_principal ap -- Alias para as_actividades_panel_principal
    JOIN 
        as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto -- Alias para as_panel_mixto
    WHERE 
        pm.fk_id_panel_informativo IN (
            SELECT 
                pi.id_panel_informativo 
            FROM 
                as_panel_informativo pi -- Alias para as_panel_informativo
            WHERE 
                (pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo IN (25, 29, 30))
                OR 
                (pi.fk_id_panel_prncipal = 14)
        )
        AND ap.fk_id_gestion IS NOT NULL --SUBMOTIVO NO GESTIONABLE
    ) sub_motivo_no_gestionable ON sub_motivo_no_gestionable.fk_id_gestion = gestion.id_gestion
	LEFT JOIN (
		SELECT  
		    ap.fk_id_gestion AS fk_id_gestion,
		    ap.fk_id_panel_mixto AS fk_id_panel_mixto,
		    pi.titulo AS titulo
		FROM  
		    as_actividades_panel_principal ap
		JOIN 
		    as_panel_mixto pm
		ON 
		    ap.fk_id_panel_mixto = pm.id_panel_mixto
		JOIN 
		    as_panel_informativo pi
		ON 
		    pm.fk_id_panel_informativo = pi.id_panel_informativo
		WHERE 
		    pi.fk_id_panel_prncipal = 8 AND ap.fk_id_gestion IS NOT NULL 
	) tipo_nega ON tipo_nega.fk_id_gestion = gestion.id_gestion --TIPO NEGATIVA
	LEFT JOIN (
		SELECT fk_id_gestion fk_id_gestion,
			fk_id_panel_mixto fk_id_panel_mixto,
			as_panel_mixto.titulo titulo
		FROM 	as_actividades_panel_principal, 
			as_panel_mixto
		WHERE fk_id_panel_mixto = id_panel_mixto
		AND as_panel_mixto.fk_id_panel_informativo IN (SELECT 
			id_panel_informativo 
			FROM as_panel_informativo 
			WHERE fk_id_panel_prncipal = 8) 
	) subtipo_nega ON subtipo_nega.fk_id_gestion = gestion.id_gestion -- "SUBTIPO NEGATIVA"
	LEFT JOIN (
		SELECT  
		    ap.fk_id_gestion AS fk_id_gestion,
		    ap.fk_id_panel_mixto AS fk_id_panel_mixto,
		    pi.titulo AS titulo
		FROM  
		    as_actividades_panel_principal ap
		JOIN 
		    as_panel_mixto pm
		ON 
		    ap.fk_id_panel_mixto = pm.id_panel_mixto
		JOIN 
		    as_panel_informativo pi
		ON 
		    pm.fk_id_panel_informativo = pi.id_panel_informativo
		WHERE 
		    pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo NOT IN (25, 29, 30) 
			AND ap.fk_id_gestion IS NOT NULL
		) motivo ON motivo.fk_id_gestion = gestion.id_gestion  --"MOTIVO ATRASO"  
	LEFT JOIN (
		SELECT fk_id_gestion fk_id_gestion,
			fk_id_panel_mixto fk_id_panel_mixto,
			as_panel_mixto.titulo titulo
		FROM 	as_actividades_panel_principal, 
			as_panel_mixto
		WHERE fk_id_panel_mixto = id_panel_mixto
		AND as_panel_mixto.fk_id_panel_informativo IN (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32) -- "SUBMOTIVO DE ATRASO"
	) submotivo ON submotivo.fk_id_gestion = gestion.id_gestion
	WHERE 
        gestion.fk_id_campana = idcampana
	AND ((CAST (gestion.FECHA_CREACION AS date) ) BETWEEN fechadesdelocal::date and fechahastalocal::date)
	ORDER BY 1;
	
  $BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.i_agree_informe_reporte_formulario_izzi(integer, text, text)
  OWNER TO iagreedbuser;