--1. Luua vaade v_turniiripartii (turniir_nimi, partii_id, partii_algus, partii_lopp).
CREATE VIEW  v_turniiripartii (turniir_nimi, partii_id, partii_algus, partii_lopp) AS
SELECT Turniir.nimi, Partii.id, Partii.algushetk, Partii.lopphetk
FROM Turniir 
JOIN Partii
ON Turniir.id=Partii.turniir; 
--2. Luua vaade v_klubipartiikogus (klubi_nimi, partiisid)partiisid = selliste partiide arv, kus kas valge või must mängija on klubi liige.
CREATE VIEW v_klubipartiikogus (klubi_nimi, partiisid) AS
SELECT klubi_nimi, SUM(arv) FROM(
    SELECT klubi.nimi AS klubi_nimi, COUNT(*) AS arv FROM Partii
    JOIN Isik 
    ON Isik.id=Partii.valge
    JOIN Klubi
    ON Klubi.id=Isik.klubi
    GROUP BY klubi.nimi
    UNION 
    SELECT Klubi.nimi AS klubi_nimi, COUNT(*) AS arv FROM Partii
    JOIN Isik 
    ON Isik.id=Partii.must
    JOIN Klubi
    ON Klubi.id=Isik.klubi
    GROUP BY Klubi.nimi
) AS  klubipartiikogus 
GROUP BY klubi_nimi ORDER BY SUM(arv) DESC;
-- eelmine oli algne ja kohmakas variant, poole lühem ja selgem variant:
CREATE VIEW v_klubipartiikogus (klubi_nimi, partiisid) AS
SELECT klubi_nimi, SUM(arv) FROM(
    SELECT klubi.nimi AS klubi_nimi, COUNT(*) AS arv FROM Partii
    JOIN Isik 
    ON Isik.id=Partii.valge OR Isik.id=Partii.must 
    JOIN Klubi
    ON Klubi.id=Isik.klubi 
    GROUP BY klubi.nimi
) AS  klubipartiikogus  
GROUP BY klubi_nimi ORDER BY SUM(arv) DESC;
--3. Luua vaade v_punkt (partii, turniir, mangija, varv, punkt),kus oleksid kõigi mängijate kõigi partiide jooksul saadud punktid 
--(viitega partiile ja turniirile) koos värviga (valge (V), must (M)). (Vaata järgnevat näidet).
CREATE VIEW  v_punkt (partii, turniir, mangija, varv, punkt) AS
SELECT Partii.id, Partii.turniir, Partii.valge, 'V', Partii.valge_tulemus/2.0 
FROM Partii
UNION 
SELECT Partii.id, Partii.turniir, Partii.must, 'M', Partii.musta_tulemus/2.0 
FROM Partii;
--4. Vaate v_punkt ja vaate v_mangija põhjal teha vaade v_edetabel(mangija, turniir, punkte), kus veerus mangija on 
--mängija nimi (v_mangija.nimi) ja veerus turniir on turniiri ID. Punkte arvutatakse iga turniiri jaoks (mängija punktid sellel turniiril).
CREATE VIEW v_edetabel(mangija, turniir, punkte) AS
SELECT isik_nimi, turniir, SUM(punkte) FROM (
SELECT isik_nimi AS isik_nimi, turniir, punkt AS punkte 
FROM v_punkt
JOIN v_mangija
ON v_punkt.mangija=v_mangija.isik_id) AS edetabel
GROUP BY isik_nimi, turniir
ORDER BY SUM(punkte) DESC;
--5. Leida (teha päring) turniiri “Kolme klubi kohtumine” (turniiri ID = 41) edetabeli saamiseks (suurema punktiarvuga mängija eespool).
SELECT * FROM v_edetabel 
WHERE turniir=41 
ORDER BY punkte DESC, mangija;
