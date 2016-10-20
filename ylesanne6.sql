--1. Luua f-n klubiliikmete arvu leidmiseks klubi id põhjal f_klubisuurus(...)
CREATE FUNCTION f_klubisuurus(klubi_id integer)
RETURNS INTEGER 
BEGIN
DECLARE liikmearv INTEGER;
SELECT COUNT(*) INTO liikmearv
FROM isik
WHERE Klubi = klubi_id;
RETURN liikmearv;
END;
--2. Luua f-n ees-ja perenime kokku liitmiseks eesti ametlikul viisil ("perenimi, eesnimi") f_nimi(...)
CREATE FUNCTION f_nimi(eesnimi VARCHAR(50), perenimi VARCHAR(50))
RETURNS VARCHAR(100) 
BEGIN
DECLARE pere_eesnimi VARCHAR(100);
SELECT perenimi+', '+eesnimi INTO pere_eesnimi;
RETURN pere_eesnimi;
END;
--3. Luua f-n ühe mängija partiide koguarv f_mangija_koormus(...)
CREATE FUNCTION f_mangija_koormus(mangija_id INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE koormus INTEGER;
SELECT COUNT(*) INTO koormus
FROM partii
WHERE Valge = mangija_id OR Must=mangija_id;
RETURN koormus;
END;
--4. Luua f-n ühe mängija võitude arv turniiril f_mangija_voite_turniiril(...)
CREATE FUNCTION f_mangija_voite_turniiril(mangija_id INTEGER, turniiri_id INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE voite INTEGER;
SELECT COUNT(*) INTO voite
FROM v_punkt
WHERE mangija = mangija_id AND punkt=1 AND turniir=turniiri_id;
RETURN voite;
END
--5 Luua f-n ühe mängija punktisumma  turniiril f_mangija_punktid_turniiril(...)
CREATE FUNCTION f_mangija_punktid_turniiril(mangija_id INTEGER, turniiri_id INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE punktid INTEGER;
SELECT SUM(punkt) INTO punktid
FROM v_punkt
WHERE mangija = mangija_id AND turniir=turniiri_id;
RETURN punktid;
END;
--6. Luua protseduur sp_uus_isik, mis lisab eesnime ja perenimega määratud isiku etteantud numbriga klubisse ning paneb neljandasse parameetrisse uue isiku ID väärtuse
CREATE PROCEDURE sp_uus_isik(IN a_eesnimi VARCHAR (50), 
IN a_perenimi VARCHAR(50), IN a_klubi INTEGER,OUT a_id INTEGER)
BEGIN
DECLARE i_id  INTEGER;
INSERT INTO isik(eesnimi, perenimi, klubi)
VALUES (a_eesnimi, a_perenimi, a_klubi);
SELECT @@identity  INTO i_id;
END;
--6. Luua tabelit väljastav protseduur sp_infopump() See peab andma välja unioniga kokku panduna järgmised asjad (kasutades varemdefineeritud võimalusi):
	--1) klubi nimi ja tema mängijate arv (kasutada funktsiooni f_klubisuurus)
	--2) turniiri nimi ja tema jooksul tehtud mängude arv (kasutada group by)
	--3) mängija nimi ja tema poolt mängitud partiide arv (kasutada f_nimi ja f_mangija_koormus) ning tulemus sorteerida nii, et klubide info oleks kõige ees, siis turniiride oma ja siis alles isikud. Iga grupi sees sorteerida nime järgi.
CREATE PROCEDURE sp_infopump()
RESULT (nimi VARCHAR(50), arv INTEGER)
BEGIN 
SELECT nimi, arv FROM 
	(
	SELECT nimi AS nimi, f_klubisuurus(id) AS arv, 1 AS filter 
	FROM klubi
	UNION
		SELECT turniir.nimi AS nimi, COUNT(*) AS arv, 2 AS filter 
		FROM partii 
		JOIN turniir ON turniir.id=partii.turniir 
		GROUP BY turniir.nimi
	UNION
		SELECT f_nimi(isik.eesnimi, isik.perenimi) AS nimi, COUNT(*) AS arv, 3 AS filter 
		FROM isik 
		JOIN partii ON isik.id=partii.Valge OR isik.id=partii.Must 
		GROUP BY nimi) 
	AS tabel, 
	ORDER BY filter, nimi
END
--7. Luua tabelit väljastav protseduur sp_top10, millel on üks parameeter -turniiri id, ja mis kasutab vaadet v_edetabel ja annab tulemuseks kümme parimat etteantud turniiril.
CREATE PROCEDURE sp_top10(IN turniir_id INTEGER)
RESULT (mangija VARCHAR(50))
BEGIN 
SELECT TOP 10 mangija
FROM v_edetabel
WHERE turniir = turniir_id
ORDER BY punkte DESC;
END
--8. Luua tabelit väljastav protseduur sp_voit_viik_kaotus, mis väljastab kõigi osalenud mängijate võitude, viikide ja kaotuste arvu etteantud turniiril. Tabeli struktuur: id, eesnimi, perenimi, võite, viike, kaotusi (f_mangija_voite_turniiril jt sarnased funktsioonid oleksid abiks ...)
--teen funktsiooni viikide leidmiseks
CREATE FUNCTION f_mangija_viike_turniiril(mangija_id INTEGER, turniiri_id INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE voite INTEGER;
SELECT COUNT(*) INTO voite
FROM v_punkt
WHERE mangija = mangija_id AND punkt=0.5 AND turniir=turniiri_id;
RETURN voite;
END
--funktsioon kaotuste leidmiseks
CREATE FUNCTION f_mangija_kaotusi_turniiril(mangija_id INTEGER, turniiri_id INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE voite INTEGER;
SELECT COUNT(*) INTO voite
FROM v_punkt
WHERE mangija = mangija_id AND punkt=0 AND turniir=turniiri_id;
RETURN voite;
END
--ja viimaks protseduur
CREATE PROCEDURE sp_voit_viik_kaotus(IN turniir_id INTEGER)
RESULT (id INTEGER, eesnimi VARCHAR(50), perenimi VARCHAR(50), võite INTEGER, viike INTEGER, kaotusi INTEGER)
BEGIN
SELECT mangija,isik.eesnimi, isik.perenimi, f_mangija_voite_turniiril(mangija, turniir) AS 'võite',
f_mangija_viike_turniiril(mangija, turniir) AS 'viike',f_mangija_kaotusi_turniiril(mangija, turniir) AS 'kaotusi'
FROM v_punkt 
JOIN isik 
ON mangija=isik.id
WHERE turniir = 41 GROUP BY turniir,mangija, perenimi, eesnimi
END
--9. Luua indeks turniiride algusaegade peale.
CREATE INDEX  ix_turniir_algus ON turniir(alguskuupaev DESC)
--10. Luua indeksid partiidele kahanevalt valge ja musta tulemuse peale.
CREATE INDEX ix_valge_musta_tulemus ON  partii(valge_tulemus DESC, Musta_tulemus DESC)




