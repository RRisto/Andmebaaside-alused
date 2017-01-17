--Lõige isikutabelist: vaid isikud klubist numbriga 54
CREATE VIEW v_klubi54 AS
SELECT*FROM isik
WHERE klubi= 54;
--Lõige isikutabelist: vaid isikute nimed klubist numbriga 54
CREATE VIEW v_klubi54pisi(eesnimi,perenimi) AS
SELECT eesnimi, perenimi 
FROM isik
WHERE klubi= 54;
--Ühendame isikutabeli ja klubitabeli: Klubi nimi, klubi id, isiku nimi ja id
CREATE VIEW v_mangija(klubi_nimi, klubi_id, isik_nimi, isik_id) AS
SELECT klubi.nimi, klubi.id, isik.perenimi || ', ' || isik.eesnimi, isik.id 
FROM isik 
JOIN klubi
ON isik.klubi= klubi.id;
--Kui tahame andmeid tabelitest isik ((2x) –valgetega ja mustadega mängija nime), klubi (mängijate klubide nimesid) ja partii (
--partii tulemust), siis võime oma päringut lihtsustada pannes kokku tabeli  partii ja vaate v_mangija (2x)
CREATE VIEW v_partii(id, turniir, algus,valge_nimi, valge_klubi, valge_punkt,must_nimi, must_klubi, must_punkt) AS
SELECT p.id, p.turniir, p.algushetk, v.isik_nimi,v.klubi_nimi, p.valge_tulemus/ 2.0, m.isik_nimi,m.klubi_nimi, p.musta_tulemus/ 2.0
FROM partii
AS p, v_mangija
AS v, v_mangija
AS m
WHERE p.valge= v.isik_id
AND p.must=m.isik_id;

SELECT* FROM v_partii ORDER BY algus;
--Loome tabeli eesnimede muutuste jälgimiseks
CREATE TABLE  eesnimi(
eesnimi varchar(50) NOT NULL, 
kogus integer NOT NULL, 
hetk datetime NOT NULL  DEFAULT current timestamp,
PRIMARY KEY  (eesnimi, hetk));
--Lisame andmed veergudesse eesnimi ja kogus
INSERT INTO eesnimi (eesnimi, kogus)
SELECT eesnimi , count(*) 
FROM isik
GROUP BY eesnimi;
--Muudame eesnimesid tabelis isik
INSERT INTO isik (eesnimi, perenimi, klubi)
VALUES ('Maria', 'Lihtne', 54);

UPDATE isik SET eesnimi = 'Toomas'
WHERE eesnimi = 'Taivo';
--Kordame andmete lisamist tabelisse eesnimi:
INSERT INTO eesnimi (eesnimi, kogus)
SELECT eesnimi, count(*) FROM isik
GROUP BY eesnimi;
--Vaatame kuidas muutus nimede arv
SELECT eesnimi, hetk, kogus
FROM eesnimi
WHERE eesnimi IN('Maria', 'Toomas','Taivo')  
ORDER BY hetk;
--Kolm esimest nimekirjas 
SELECT TOP 3 eesnimi, perenimi
FROM isik;
--Õigem oleks
SELECT TOP 3 eesnimi, perenimi
FROM isik
ORDER BY perenimi, eesnimi;
--Eelviimane isik (perenimede järjestuses) mängijate nimekirjas
SELECT TOP 1 START AT 2 eesnimi, perenimi
FROM isik 
ORDER BY perenimi  DESC, eesnimi DESC;
--tabeli täitmine nullidega
CREATE TABLE viis (
nr INTEGER NOT NULL  PRIMARY KEY);

INSERT INTO viis
SELECT TOP 8 number(*)
FROM partii;

DELETE FROM viis
WHERE nr > 5;
--Tekitame kõigile tudengitele erinevused tabelisse partii (omad andmed).  
--Selleks: Lisame uue kirje (uue turniiri) tabelisse turniir. Olgu uus turniiri numbriga 47 (id=47) Lisame selle kirje (nn käsitsi)
INSERT INTO turniir (id, nimi, toimumiskoht, alguskuupaev, loppkuupaev)
VALUES (47, 'Kuldkarikas 2010', 'Elva', '2010-10-14', '2010-10-14');
--Muutsime meelt: turniiri nimi olgu Plekkkarikas
UPDATE turniir
SET nimi= 'Plekkkarikas 2010' 
WHERE id = 47;
--Lisame juurde kõigi mängijate omavahelised partii.(va endaga) ja mängijatega klubist 57, algushetke võtame juhusliku
INSERT INTO partii (turniir, algushetk, valge, must)
SELECT turniir.id, dateadd(minute,1+rand()*10, dateadd(hour, 8+rand()*10,turniir.alguskuupaev)), v.id, m.id
FROM turniir, isik v, isik m
WHERE turniir.id = 47 AND v.id <> m.id AND
v.klubi <> 57 AND m.klubi<> 57;
--Väärtustame (juhuslikult) veerud Lõpphetk ja paneme paika juhuslik võitja
UPDATE partii SET lopphetk= dateadd(second,50+mod(id, 121), 
	dateadd(minute, 19 +mod(id,18) + mod(id,3) -mod(id,13), algushetk))
WHERE turniir= 47;

UPDATE partii SET valge_tulemus=mod(id+valge-must+turniir, 3) 
WHERE turniir = 47;

UPDATE partii SET musta_tulemus= 2 -valge_tulemus
WHERE turniir= 47;
--Kustutame need partiid, kus sama turniiri jooksul mängijate paar kordub
DELETE FROM partii p 
WHERE EXISTS(SELECT* FROM partii q 
WHERE p.valge=q.must AND
	q.valge = p.must AND
	p.id < q.id AND 
	turniir=47)  AND
	turniir = 47;
--Kustutame maha ajaliselt kõlbmatud. Pole võimalik alustada uut partiid, kui ühel mängijatest eelmine veel pooleli
DELETE FROM partii p 
WHERE EXISTS(
SELECT* FROM partii q 
WHERE p.algushetk>= q.algushetk AND
	p.algushetk<=q.lopphetk AND
	p.id <> q.id AND(
	p.valge= q.valge OR 
	p.valge=q.must OR
	p.must=q.valge OR 
	p.must=q.must) AND
	q.turniir= p.turniir)  AND
turniir= 47;	
--Peale koduse ülesande tegemist on võimalik sooritada alljärgnev päring Näha äsja sisestatud turniiri viite paremat
SELECT TOP 5 number(*), mangija, punkte
FROM v_edetabel
WHERE turniir= 47
ORDER BY punkte DESC;
