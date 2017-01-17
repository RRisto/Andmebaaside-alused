--Deterministlik funktsioon
--Funktsioon kahe arvu liitmiseks:
CREATE FUNCTION f_liida(a_arv1 INTEGER,a_arv2 INTEGER) 
RETURNS INTEGER
DETERMINISTIC
BEGIN 
DECLARE summa INTEGER;
SET summa = a_arv1 + a_arv2; --set kui andmed pole meie andmebaasist (funkts sees pole päringut)
RETURN summa;
END;
--teine viis
CREATE FUNCTION f_liida(a_arv1 INTEGER,a_arv2 INTEGER) 
RETURNS INTEGER
BEGIN 
RETURN a_arv1 + a_arv2;
END;
--kui tahan olemasolevat muuta
ALTER FUNCTION f_liida(a_arv1 INTEGER,a_arv2 INTEGER) 
RETURNS INTEGER
BEGIN 
RETURN a_arv1 + a_arv2;
END;
--Funktsioon, mis vastavalt id väärtusele tagastab eesnime 
CREATE FUNCTION f_eesnimi(a_id integer)
RETURNS varchar(50) 
NOT DETERMINISTIC
BEGIN
DECLARE d_enimi varchar(50);
SELECT eesnimi INTO d_enimi --päringu puhul väärtuse omistamine
FROM isik
WHERE id = a_id;
RETURN d_enimi;
END;
--kasutamne
SELECT f_eesnimi(83);
SELECT f_eesnimi(83) 
FROM sys.dummy;
SELECT id, f_eesnimi(id) 
FROM isik; --ääretult ebaoptimaalne!!
--Protseduur, mis lisab tabelisse  klubi uue klubi ja väljastab vastava teate:
CREATE PROCEDURE sp_uus_klubi(IN a_nimi VARCHAR (100), 
IN a_asukoht VARCHAR(100),
OUT a_id INTEGER)
BEGIN
DECLARE i_id  INTEGER;
INSERT INTO klubi(nimi, asukoht)
VALUES (a_nimi, a_asukoht);
SELECT @@identity  INTO i_id;
--teade kliendile
MESSAGE 'Uus klubi: ' || i_id TO CLIENT;
SET a_id= i_id;
END;
--Meil on vaja muutujat, kuhu salvestatakse uue klubi id
--•Pöördume protseduuri poole
--•vaatame milline on uue klubi id väärtus --oluline osa
CREATE VARIABLE uusid INTEGER;
CALL sp_uus_klubi('Valga Valge', 'Valga',uusid);
SELECT uusid;
--Protseduur, mille väljundiks on klubimängijate tabel:
CREATE PROCEDURE sp_klubimangija(IN a_klubi_id INTEGER)
RESULT (eesnimi VARCHAR(50), perenimi VARCHAR(50), kuupaev DATE)
BEGIN 
SELECT eesnimi, perenimi, CURRENT DATE
FROM isik
WHERE klubi = a_klubi_id
ORDER BY eesnimi;
END
--kasutamine
CALL sp_klubimangija(51);
CALL sp_klubimangija(a_klubi_id=51);
--(parameetri väärtustamine nime järgi)
EXECUTE sp_klubimangija(51);
SELECT * FROM sp_klubimangija (51);
--(kasutamine päringus)

--indeksid
CREATE INDEX  ix_algus ON partii(algushetk DESC)
CREATE INDEX ix_nimi ON  isik(perenimi ASC, eesnimi ASC)







