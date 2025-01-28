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

--=========================================================================================================
--MOTIVO NO GESTIONABLE
SELECT *
FROM as_panel_informativo
WHERE 
    (fk_id_panel_prncipal = 7 AND id_panel_informativo IN (25, 29, 30)) 
    OR 
    (fk_id_panel_prncipal = 14)
ORDER BY id_panel_informativo ASC;

--(SUBMOTIVO NO GESTIONABLE)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (25, 29, 30, 36, 37, 38);

--VARIANTE 2
SELECT * FROM as_panel_mixto
WHERE
	(fk_id_panel_informativo = 25 AND id_panel_mixto IN (138, 139, 140, 141))
	OR (fk_id_panel_informativo = 29 AND id_panel_mixto IN (155, 156, 157))
	OR (fk_id_panel_informativo = 30 AND id_panel_mixto IN (158, 159, 160, 161))
	OR (fk_id_panel_informativo = 36 AND id_panel_mixto IN (164, 165, 166, 167))
	OR (fk_id_panel_informativo = 37 AND id_panel_mixto IN (168, 169, 170))
	OR (fk_id_panel_informativo = 38 AND id_panel_mixto IN (171, 172, 173, 174, 175, 176))
ORDER BY fk_id_panel_informativo, id_panel_mixto ASC;
--=========================================================================================================

--TIPO NEGATIVA
SELECT * FROM as_panel_informativo 
WHERE fk_id_panel_prncipal = 8;

--(SUBMOTIVO DE NEGATIVA)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (17,18, 19, 20, 21, 22, 23, 24);
--=========================================================================================================
--MOTIVO ATRASO:
SELECT * FROM as_panel_informativo
WHERE fk_id_panel_prncipal = 7
  AND id_panel_informativo NOT IN (25, 29, 30);

--(SUBMOTIVO DE ATRASO)
SELECT * FROM as_panel_mixto
WHERE fk_id_panel_informativo IN (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32);


--VARIANTE NUMERO 2:
SELECT *
FROM as_panel_mixto
WHERE 
    (fk_id_panel_informativo = 7 AND id_panel_mixto IN (83, 84, 85, 86, 87))
    OR (fk_id_panel_informativo = 8 AND id_panel_mixto IN (88, 89, 90, 91, 92, 93, 94, 95, 96))
    OR (fk_id_panel_informativo = 9 AND id_panel_mixto IN (97, 98, 99, 100, 101, 102, 103, 104, 105))
    OR (fk_id_panel_informativo = 10 AND id_panel_mixto IN (106))
    OR (fk_id_panel_informativo = 11 AND id_panel_mixto IN (107, 108))
    OR (fk_id_panel_informativo = 12 AND id_panel_mixto IN (109))
    OR (fk_id_panel_informativo = 13 AND id_panel_mixto IN (110))
    OR (fk_id_panel_informativo = 14 AND id_panel_mixto IN (111))
    OR (fk_id_panel_informativo = 15 AND id_panel_mixto IN (112))
    OR (fk_id_panel_informativo = 16 AND id_panel_mixto IN (113))
    OR (fk_id_panel_informativo = 32 AND id_panel_mixto IN (163))
ORDER BY fk_id_panel_informativo, id_panel_mixto ASC;
