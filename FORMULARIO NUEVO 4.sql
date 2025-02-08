CREATE OR REPLACE FUNCTION public.i_agree_informe_reporte_formulario_izzi(
    idcampana integer,
    fechadesdelocal text,
    fechahastalocal text,
    OUT "FECHA_CREACION" timestamp without time zone,
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
SELECT 
    g.fecha_creacion AS "FECHA_CREACION",
    o.numero_producto AS "CLIENTE",
    o.dias_mora_inicio AS "MORA",
    'NO'::character varying AS "LLAMADA_SIN_DATOS",
    CASE WHEN app.descripcion2 != 'PR1' THEN 'NO' ELSE 'SI' END AS "GESTIONABLE",
    COALESCE(mng.titulo, '') AS "MOTIVO_NO_GESTIONABLE",
    COALESCE(smng.titulo, '') AS "SUB_MOTIVO_NO_GESTIONABLE",
    ' '::text AS "NO_CASO",
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
) mng ON mng.fk_id_gestion = g.id_gestion
LEFT JOIN (
    SELECT ap.fk_id_gestion, pm.titulo
    FROM as_actividades_panel_principal ap
    JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
    WHERE (pm.fk_id_panel_informativo IN (25, 29, 30, 36, 37, 38))
) smng ON smng.fk_id_gestion = g.id_gestion
LEFT JOIN (
    SELECT ap.fk_id_gestion, pi.titulo
    FROM as_actividades_panel_principal ap
    JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
    JOIN as_panel_informativo pi ON pm.fk_id_panel_informativo = pi.id_panel_informativo
    WHERE pi.fk_id_panel_prncipal = 8
) tn ON tn.fk_id_gestion = g.id_gestion
LEFT JOIN (
    SELECT ap.fk_id_gestion, pm.titulo
    FROM as_actividades_panel_principal ap
    JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
    WHERE pm.fk_id_panel_informativo IN (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32)
) stn ON stn.fk_id_gestion = g.id_gestion
LEFT JOIN (
    SELECT ap.fk_id_gestion, pi.titulo
    FROM as_actividades_panel_principal ap
    JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
    JOIN as_panel_informativo pi ON pm.fk_id_panel_informativo = pi.id_panel_informativo
    WHERE pi.fk_id_panel_prncipal = 7 AND pi.id_panel_informativo NOT IN (25, 29, 30)
) m ON m.fk_id_gestion = g.id_gestion
LEFT JOIN (
    SELECT ap.fk_id_gestion, pm.titulo
    FROM as_actividades_panel_principal ap
    JOIN as_panel_mixto pm ON ap.fk_id_panel_mixto = pm.id_panel_mixto
    WHERE pm.fk_id_panel_informativo IN (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32)
) sm ON sm.fk_id_gestion = g.id_gestion
WHERE 
    g.fk_id_campana = idcampana
    AND g.fecha_creacion::date BETWEEN fechadesdelocal::date AND fechahastalocal::date
ORDER BY g.fecha_creacion;
$BODY$;

ALTER FUNCTION public.i_agree_informe_reporte_formulario_izzi(integer, text, text)
    OWNER TO iagreedbuser;