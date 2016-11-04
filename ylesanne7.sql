--1. Luua tabel Asula (id integer, nimi varchar(100)),ID on primaarvõti, automaatselt tuleneva väärtusega
--Nimi on unikaalne, Mõlemad väljad on kohustuslikud.
CREATE TABLE Asula (
id integer not null default autoincrement primary key,
nimi varchar(100) not null,
Unique (nimi)
);
--2.Lisada uude tabelisse kõik asukohad tabelist Klubi ja toimumiskohad tabelist Turniir
INSERT INTO Asula (nimi)
SELECT DISTINCT Asukoht FROM klubi
UNION 
SELECT DISTINCT toimumiskoht FROM turniir; 
--3.Lisada tabelisse Klubi veerg Asula (integer).
ALTER TABLE Klubi ADD Asula INTEGER;
--4.Väärtustada korraga kõigil Klubi kirjetel veerg Asula sobiliku ID’ga tabelist Asula: update klubi set asula = (select id from asula where asula.nimi = klubi.asukoht)
UPDATE klubi SET asula = (SELECT id FROM asula WHERE asula.nimi = klubi.asukoht)
--5.Lisada tabelile Klubi välisvõti tabelisse Asula (fk_klubi_2_asula). Kontrollida andmeid (võrrelda tekstiveerge):
--select klubi.asukoht, asula.nimi from klubi join asula on klubi.asula = asula.id.
ALTER TABLE Klubi ADD CONSTRAINT fk_klubi_2_asula 
FOREIGN KEY (asula) 
REFERENCES Asula(id) 
ON DELETE CASCADE ON UPDATE CASCADE;
--kontroll
select klubi.asukoht, asula.nimi from klubi join asula on klubi.asula = asula.id;
--6.Lisada tabelisse Turniir veerg Asula (integer).
ALTER TABLE Turniir ADD Asula INTEGER;
--7.Väärtustada korraga kõigil Turniiri kirjetel veerg Asula sobiliku ID’ga tabelist Asula
UPDATE Turniir SET asula = (SELECT id FROM asula WHERE asula.nimi = turniir.toimumiskoht);
--8. Lisada tabelile Turniir välisvõti tabelisse Asula (fk_turniir_2_asula). Kontrollida andmeid (võrrelda tekstiveerge).
ALTER TABLE Turniir ADD CONSTRAINT fk_turniir_2_asula 
FOREIGN KEY (asula) 
REFERENCES Asula(id) 
ON DELETE CASCADE ON UPDATE CASCADE;
--kontroll
select turniir.toimumiskoht, asula.nimi from turniir join asula on turniir.asula = asula.id;
--9.Luua vaade v_asulaklubisid (asula_id, asula_nimi, klubisid), mis annaks asulate klubide arvud.
CREATE VIEW v_asulaklubisid (asula_id, asula_nimi, klubisid) AS
SELECT asula, asukoht, COUNT(*) 
FROM klubi
GROUP BY asula, asukoht
--10. Luua vaade v_asulasuurus (asula_id, asula_nimi, mangijaid), mis annaks asulate mängijate arvud.
--Kontrollküsimus: kas võib tekkida kirje, kus mangijaid = 0?
CREATE VIEW v_asulasuurus(asula_id, asula_nimi, mangijaid) AS
SELECT klubi.asula, klubi.asukoht, COUNT(*)  FROM 
isik JOIN klubi 
ON isik.klubi=klubi.id
GROUP BY klubi.asula, klubi.asukoht
--11. Lisada lihtne protseduur klubi kustutamiseks sp_kustuta_klubi(klubinimi)
CREATE PROCEDURE sp_kustuta_klubi(IN klubinimi VARCHAR (100))
BEGIN
DELETE FROM klubi
WHERE nimi=klubinimi;
END;
--12. Luua triger, mis klubi lisamise järel lisaks asukoha asula tabelisse, kui seda seal pole, ning väärtustaks klubi tabelis asula välja vastava asula
--ID’ga, tg_lisa_klubi.
CREATE TRIGGER tg_lisa_klubi AFTER INSERT, UPDATE ON Klubi
REFERENCING NEW AS uus 
FOR EACH ROW
WHEN ((SELECT COUNT(*) FROM Asula WHERE Nimi = uus.asukoht) = 0)
BEGIN
DECLARE l_id integer;
INSERT INTO Asula(Nimi) VALUES (uus.asukoht);
SELECT @@identity INTO l_id;
UPDATE Klubi SET Asula = l_id WHERE Id = uus.id;
END

CREATE TRIGGER tg_lisa_klubi AFTER INSERT, UPDATE ON Klubi
REFERENCING NEW AS uus 
FOR EACH ROW
WHEN (asula.nimi<>klubi.asukoht)
BEGIN
	INSERT INTO asula(nimi) VALUES (klubi.asukoht);
	UPDATE klubi SET asula=asula.id
END	

--13.Luua triger, mis klubi kustutamisel kontrollib, kas klubi asula on kuskil kasutuses (teiste klubide juures või turniiride juures), ja kui pole, siis kustutab ka asula maha. tg_kustuta_klubi.
CREATE TRIGGER tg_kustuta_klubi AFTER DELETE ON Klubi
REFERENCING OLD AS vana FOR EACH ROW
BEGIN
DECLARE l_arv1 integer;
DECLARE l_arv2 integer;
SELECT COUNT(*) INTO l_arv1 FROM Klubi WHERE Asula = vana.Asula;
SELECT COUNT(*) INTO l_arv2 FROM Turniir WHERE Asula = vana.Asula;
IF l_arv1 + l_arv2 = 0 THEN
DELETE FROM Asula WHERE Id = vana.Asula;
END IF;
END
--14. Lisada klubi “Kiire Aju” asukohaga Viljandi.
INSERT INTO Klubi(Nimi, Asukoht) VALUES ('Kiire Aju', 'Viljandi');
--15. Lisada klubi “Kambja Kibe” asukohaga Kambja.
INSERT INTO KlubiNimi, Asukoht) VALUES ('Kambja Kibe', 'Kambja');
--16. Teha päring asula tabelisse, et veenduda, mis asulad on olemas
SELECT DISTINCT nimi FROM asula;
--17. Kustutada klubid maha: call sp_kustuta_klubi(‘Kiire Aju’), call sp_kustuta_klubi(‘Kambja Kibe’)
CALL sp_kustuta_klubi('Kiire Aju');
CALL sp_kustuta_klubi('Kambja Kibe');
--18. Teha päring asula tabelisse, et veenduda, mis asulad on olemas
SELECT DISTINCT nimi FROM asula;
--19.Lisada uus klubi “SQL klubi” asukohaga Tartu.
INSERT INTO Klubi (Nimi, Asukoht) VALUES ('SQL klubi', 'Tartu');
--20. Lisada tabelisse Isik iseennast. Klubiks panna “SQL klubi”
INSERT INTO Isik (Eesnimi, Perenimi, Isikukood, Klubi)
VALUES ('Risto', 'Hinno', '38705194711',(SELECT Id FROM Klubi WHERE Nimi = 'SQL klubi'));
--21. Proovida kustutada klubi sp_kustuta_klubi(‘SQL klubi’) - ei tohi õnnestuda(miks?)
sp_kustuta_klubi('SQL klubi')
---Isikute tabelil on välisvõti, mis viitab klubi tabelile: klubi ei tohi sisaldada ühtegi isikut, et seda saaks kustutada.
--22. Luua klubi kustutamisele trigger (tg_kustuta_klubi_isikutega), mis kustutaks maha klubi isikud. NB! Kui isikul on partiisid, siis isikut ei õnnestu kustutada ja seega ei õnenstu ka klubi kustutada. Nii peabki olema! call sp_kustuta_klubi(“Laudnikud”) - ei tohi midagi halba teha (kui kõik seosed on
--varem õigesti loodud).Aga call sp_kustuta_klubi(“SQL klubi”) peab kustutama nii klubi kui ka selle ühe liikme. 
CREATE TRIGGER tg_kustuta_klubi_isikutega BEFORE DELETE ON Klubi
REFERENCING OLD AS vana FOR EACH ROW
BEGIN
DELETE FROM Isik WHERE Klubi = vana.Id;
END
--23. Lisada ennast tabelisse inimesed.
INSERT INTO inimesed(eesnimi, perenimi, sugu, synnipaev, isikukood) VALUES ('Risto', 'Hinno', 'M', '1987-05-19', '38705194711')
--24. Luua vaated ülesande 4 päringutele 1 kuni 12. Vaate nimeks panna V_<päringu number>. Näiteks V_1, V_2, … , V_12
CREATE VIEW V_1(eesnimi, perenimi) AS
SELECT eesnimi, perenimi 
FROM Isik, Klubi
WHERE Klubi.id=Isik.klubi
AND Klubi.nimi= 'Laudnikud'
ORDER BY perenimi ASC, 
eesnimi ASC;

CREATE VIEW V_2(liikmete_arv) AS
SELECT COUNT(*) 
FROM Isik
JOIN Klubi
ON Klubi.id=Isik.klubi
WHERE Klubi.nimi= 'Laudnikud'

CREATE VIEW V_3(perenimi) AS
SELECT perenimi 
FROM Isik, Klubi
WHERE Isik.klubi= Klubi.id 
	AND(LEFT(Klubi.nimi,1)= 'V' 
	AND LEFT(Isik.eesnimi,1)= 'M');
	
CREATE VIEW V_4(algusaeg) AS
SELECT MIN(algushetk) 
FROM Partii;

CREATE VIEW V_5(must, valge) AS
SELECT valge, must 
FROM Partii 
WHERE algushetk 
	BETWEEN '2005-03-04 09:00:00.000' 
	AND '2005-03-04 11:00:00.000';
	
CREATE VIEW V_6(eesnimi, perenimi) AS
SELECT eesnimi, perenimi 
FROM Isik 
JOIN Partii 
	ON Isik.Id= Partii.valge 
	AND Datediff(minute, algushetk, lopphetk) 
	BETWEEN 9 AND 11 
	AND valge_tulemus=2;

CREATE VIEW V_7(perenimi) AS
SELECT perenimi 
FROM Isik 
GROUP BY perenimi 
HAVING COUNT(*) > 1;

CREATE VIEW V_8(klubi,liikmeid) AS
SELECT Klubi.nimi, COUNT(*)
FROM Klubi 
KEY JOIN Isik 
GROUP BY Klubi.nimi 
HAVING COUNT(*) < 4;

CREATE VIEW V_9("Arvod valgetega partiid") AS
SELECT COUNT(*) 
FROM Partii 
JOIN Isik 
ON Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo';

CREATE VIEW V_10(turniir, "Arvod valgetega partiid") AS
SELECT Turniir.nimi, COUNT(*)  
FROM Partii 
KEY JOIN Turniir 
JOIN Isik 
	ON Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo' 
GROUP BY nimi;

CREATE VIEW V_11("musta tulemus") AS
SELECT SUM(
	CASE WHEN musta_tulemus=2 THEN 1 
	WHEN musta_tulemus=1 THEN 0.5 
	ELSE musta_tulemus END) 
AS 'musta tulemus' 
FROM Partii 
JOIN Isik 
	ON Partii.must= Isik.id 
	AND isik.Eesnimi='Maria'; 

CREATE VIEW V_12("turniiri nimi", "keskmine partii pikkus") AS
SELECT Turniir.nimi, AVG(Datediff(minute, algushetk, lopphetk))
FROM Partii 
KEY JOIN Turniir 
GROUP BY Turniir.nimi;










