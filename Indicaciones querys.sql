COLUMNAS A MODIFICAR:

MOTIVO_NO_GESTIONABLE
SUB_MOTIVO_NO_GESTIONABLE

--SECUENCIA EN BASE DE DATOS:
as_panel_informativo -> as_panel_mixto -> as_panel_principal [MOTIVO_NO_GESTIONABLE, SUB_MOTIVO_NO_GESTIONABLE]

SELECT * FROM as_panel_mixto
SELECT * FROM as_panel_prncipal
SELECT * FROM as_panel_informativo

SELECT * FROM as_panel_informativo --25, 29, 30
WHERE fk_id_panel_prncipal = 7;

SELECT * FROM as_panel_informativo --36, 37
WHERE fk_id_panel_prncipal = 14;

--CONSULTA DONDE EN MOTIVO_NO_GESTIONABLE ME TRAE LOS 5 CAMPOS:
--MOTIVO NO GESTIONABLE
SELECT *
FROM as_panel_informativo
WHERE 
    (fk_id_panel_prncipal = 7 AND id_panel_informativo IN (25, 29, 30)) 
    OR 
    (fk_id_panel_prncipal = 14);

--(SUBMOTIVO NO GESTIONABLE)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (25, 29, 30, 36, 37, 38);


--TIPO NEGATIVA
SELECT * FROM as_panel_informativo 
WHERE fk_id_panel_prncipal = 8;

--(SUBMOTIVO DE NEGATIVA)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (17,18, 19, 20, 21, 22, 23, 24);


--MOTIVO ATRASO:
SELECT * FROM as_panel_informativo
WHERE fk_id_panel_prncipal = 7
  AND id_panel_informativo NOT IN (25, 29, 30);

--(SUBMOTIVO DE ATRASO)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32);

