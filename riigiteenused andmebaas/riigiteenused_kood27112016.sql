CREATE TABLE asutus (
  nimi VARCHAR(100) NOT NULL,
  ylemasutus VARCHAR(100) NOT NULL,
  registrikood INTEGER NOT NULL PRIMARY KEY)
  
 CREATE TABLE  omanik (
  isikukood INTEGER NOT NULL PRIMARY KEY,
  nimi VARCHAR(100) NOT NULL,
  asutus INTEGER NOT NULL ,
  CONSTRAINT fk_omanik_asutus1
    FOREIGN KEY (asutus)
    REFERENCES asutus(registrikood))

CREATE TABLE teenus (
  id VARCHAR(8) NOT NULL PRIMARY KEY,
  nimi VARCHAR(220) NOT NULL,
  kirjeldus VARCHAR(245) NOT NULL,
  omanik INTEGER,
  asutus INTEGER NOT NULL,
  CONSTRAINT fk_teenus_omanik1
    FOREIGN KEY (omanik)
    REFERENCES omanik (isikukood),
	CONSTRAINT fk_teenus_asutus
    FOREIGN KEY (asutus)
    REFERENCES asutus (registrikood))

CREATE TABLE kanal (
  teenus VARCHAR(8) NOT NULL,
  link VARCHAR(300) NOT NULL,
  tyyp VARCHAR(50) NOT NULL check (tyyp in ('Veebileht', 'Letiteenus büroos', 'E-post','E-iseteenindus','Post','Nutirakendus','Telefon','Kliendijuures', 'Faks','Digitelevisioon', 'Eesti','Tekstisõnum')),
   PRIMARY KEY (teenus, tyyp),
  CONSTRAINT fk_kanal_teenus1
    FOREIGN KEY (teenus)
    REFERENCES teenus (id))

CREATE TABLE moodik (
	teenus VARCHAR(8) NOT NULL,
	kanal_tyyp VARCHAR(50) NOT NULL,
	aasta INTEGER NOT NULL,
  osutamistearv INTEGER,
  rahulolu DECIMAL(5,2),
  ajakulu DECIMAL(8,2),
  maksumus DECIMAL(10,2),
	PRIMARY KEY (teenus, kanal_tyyp, aasta),
	CONSTRAINT fk_moodik_teenus1_kanaltyyp
    FOREIGN KEY (teenus,kanal_tyyp)
    REFERENCES kanal (teenus, tyyp))
  
CREATE TABLE regulatsioon (
  link VARCHAR(300) NOT NULL PRIMARY KEY,
  tyyp VARCHAR(50) NOT NULL)
  
CREATE TABLE teenus_has_regulatsioon (
  teenus_id VARCHAR(8) NOT NULL,
  regulatsioon_link VARCHAR(300) NOT NULL,
  PRIMARY KEY (teenus_id, regulatsioon_link),
  CONSTRAINT fk_teenus_has_regulatsioon_teenus1
    FOREIGN KEY (teenus_id)
    REFERENCES teenus(id),
  CONSTRAINT fk_teenus_has_regulatsioon_regulatsioon1
    FOREIGN KEY (regulatsioon_link)
    REFERENCES regulatsioon(link))

CREATE TABLE kliendigrupp (
  nimi VARCHAR(100) NOT NULL PRIMARY KEY,
  kirjeldus VARCHAR(300) NOT NULL)
  
CREATE TABLE kliendigrupp_has_teenus (
	teenus_id VARCHAR(8) NOT NULL,
  kliendigrupp_nimi VARCHAR(100) NOT NULL,
  PRIMARY KEY (teenus_id, kliendigrupp_nimi),
  CONSTRAINT fk_kliendigrupp_has_teenus_teenus1
    FOREIGN KEY (teenus_id)
    REFERENCES teenus(id),
  CONSTRAINT fk_kliendigrupp_has_teenus_kliendigrupp1
    FOREIGN KEY (kliendigrupp_nimi)
    REFERENCES kliendigrupp(nimi))

CREATE TABLE riha (
  viitenumber VARCHAR(10) NOT NULL PRIMARY KEY,
  nimi VARCHAR(300) NOT NULL)

CREATE TABLE teenus_has_riha (
	teenus_id VARCHAR(8) NOT NULL,
  viitenumber VARCHAR(10) NOT NULL,
  PRIMARY KEY (teenus_id, viitenumber),
  CONSTRAINT fk_teenus_has_riha_teenus1
    FOREIGN KEY (teenus_id)
    REFERENCES teenus(id),
  CONSTRAINT fk_teenus_has_riha_viitenumber1
    FOREIGN KEY (viitenumber)
    REFERENCES riha(viitenumber))

--andmed sisse
--asutus
INPUT INTO asutus FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\asutus.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (nimi, ylemasutus,registrikood);
--omanik
INPUT INTO omanik FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\omanik.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (isikukood, nimi,asutus);
--teenus
INPUT INTO teenus FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\teenus.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (nimi, kirjeldus,id, asutus, omanik);
--kanal
INPUT INTO kanal FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\kanal.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (teenus, link,tyyp);
--moodik
INPUT INTO moodik FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\moodik.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (teenus, kanal_tyyp, aasta, ajakulu,maksumus,osutamistearv,rahulolu);
--regulatsioon
INPUT INTO regulatsioon FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\regulatsioon.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (link,tyyp);
--teenus_has_regulatsioon
INPUT INTO teenus_has_regulatsioon FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\teenus_has_regulatsioon.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (regulatsioon_link,teenus_id);
--RIHA
INPUT INTO riha FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\riha.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (viitenumber,nimi);
--teenus_has_riha
INPUT INTO teenus_has_riha FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\teenus_has_riha.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (teenus_id,viitenumber);
--kliendigrupid
INPUT INTO kliendigrupp FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\kliendigrupp.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (nimi,kirjeldus);
--kliendigrupp has teenus
INPUT INTO kliendigrupp_has_teenus FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\kliendigrupp_has_teenus.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (teenus_id,kliendigrupp_nimi);

--triggerid, et vältida mõttetuid kirjeid andmebaasis
--kui kustutatakse asutus, siis kaovad selle asutuse omanikud ja teenused
CREATE TRIGGER tg_asutus_delete     
  AFTER DELETE ON asutus
	REFERENCING OLD AS vana  
  FOR EACH ROW     
BEGIN
  DELETE FROM omanik where asutus = vana.registrikood;
  DELETE FROM teenus where asutus = vana.registrikood;
END
--teenuse kustutamisel kustutatakse ära teenuse kanalid ja teenus_has_regulatsioon kirjed
CREATE TRIGGER tg_teenus_delete     
  AFTER DELETE ON teenus 
REFERENCING OLD AS vana  
  FOR EACH ROW     
BEGIN
  DELETE FROM kanal where teenus = vana.id;
  DELETE FROM teenus_has_regulatsioon where teenus_id = vana.id;
  DELETE FROM moodik where teenus = vana.id;
  DELETE FROM kliendigrupp_has_teenus where teenus_id=vana.id;
  DELETE FROM teenus_has_riha where teenus_id=vana.id;
END
--trigger, kui kanal kustutatakse, kontrollib, kas sama teenusega on veel kanaleid. Kui enam pole, kustutab teenuse ära
CREATE TRIGGER tg_ara_kustuta_kanal 
AFTER DELETE ON kanal
REFERENCING OLD AS vana FOR EACH ROW
BEGIN
DECLARE l_arv1 integer;
SELECT COUNT(*) INTO l_arv1 FROM kanal WHERE teenus = vana.teenus;
IF l_arv1 = 0 THEN
DELETE FROM teenus WHERE Id = vana.teenus;
END IF;
END

--SQL päringud
--1. teha protseduur, mis annab omanike nimed koos asutuse nimedega, kes on etteantud aastal etteantud kanalis teenuse osutamiste arvu
--mõõtnud
CREATE PROCEDURE sp_omanik_rahulolu_mootnud(IN kanal_nimi VARCHAR(50), aastaarv INTEGER)
RESULT (omanik VARCHAR(50), asutus VARCHAR(100), kanal VARCHAR(50))
BEGIN
SELECT DISTINCT omanik.nimi, asutus.nimi, moodik.kanal_tyyp FROM moodik 
JOIN teenus ON teenus.id=moodik.teenus 
JOIN omanik ON teenus.omanik=omanik.isikukood 
JOIN asutus ON asutus.registrikood=teenus.asutus
WHERE moodik.osutamistearv IS NOT NULL AND 
moodik.aasta=aastaarv AND moodik.kanal_tyyp=kanal_nimi
ORDER BY asutus.nimi, omanik.nimi
END
--näide
CALL sp_omanik_rahulolu_mootnud('Veebileht', 2014)
--2.leida omanike järgi, mitmel % teenuste kanalites on mõõdetud rahulolu ja osutamiste arv
--esmalt funktsioon, mis leiab omaniku teenuste kanalite arvu konkreetsel aastal
CREATE FUNCTION f_omanik_teenuseid(omanik_id INTEGER, aastaarv INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE teenuseid INTEGER;
SELECT COUNT(*) INTO teenuseid 
FROM moodik 
JOIN teenus ON teenus.id=moodik.teenus 
JOIN omanik ON teenus.omanik=omanik.isikukood WHERE
moodik.aasta=aastaarv AND
omanik.isikukood=omanik_id;
RETURN teenuseid;
END
--funktsioon, mis leiab teenuste kanalite arvu etteantud aastal, kus on osutamiste arv mõõdetus
CREATE FUNCTION f_omanik_osutamistearv(omanik_id INTEGER, aastaarv INTEGER)
RETURNS INTEGER 
BEGIN
DECLARE teenuseid INTEGER;
SELECT COUNT(*) INTO teenuseid 
FROM moodik 
JOIN teenus ON teenus.id=moodik.teenus 
JOIN omanik ON teenus.omanik=omanik.isikukood
WHERE moodik.aasta=aastaarv AND
omanik.isikukood=omanik_id AND
moodik.osutamistearv IS NOT NULL;
RETURN teenuseid;
END
--ja viimaks protseduur
CREATE PROCEDURE sp_asutus_omanik_osutamistearv(IN asutus_nimi VARCHAR(100), aastaarv INTEGER)
RESULT (asutus VARCHAR(100), nimi VARCHAR(100), teenuseid INTEGER, osutamistearv_moodetud INTEGER, osakaal DOUBLE)
BEGIN
SELECT asutus.nimi, omanik.nimi, f_omanik_teenuseid(omanik.isikukood, aastaarv) AS 'teenuseid',
f_omanik_osutamistearv(omanik.isikukood, aastaarv) AS 'osutamistearv_moodetud', 
CASE WHEN osutamistearv_moodetud=0 THEN NULL
ELSE ROUND(
	CAST(osutamistearv_moodetud AS FLOAT) / CAST(teenuseid AS FLOAT),2) END
AS 'osakaal'
FROM asutus 
JOIN omanik ON omanik.asutus=asutus.registrikood
WHERE asutus.nimi=asutus_nimi AND
teenuseid>0
ORDER BY omanik.nimi;
END
--näide
CALL sp_asutus_omanik_osutamistearv('Maanteeamet', 2014)
--3. Milliste õigusaktidega seotud teenuse kanaleid on kõige rohkem mõõdetud (ehk milliste regulatsioonidega seotud
--teenustel on kõige rohkem ridu mõõdikute tabelis)
SELECT regulatsioon_link, COUNT(*) FROM moodik 
JOIN teenus_has_regulatsioon on moodik.teenus=teenus_has_regulatsioon.teenus_id 
GROUP BY regulatsioon_link
ORDER BY COUNT(*)DESC
--teeme asja põnevaks ning summaarselt tahame teada, mis õigusaktidel on kõige rohkem
--osutamiste arvu, rahulolu, ajakulu ja maksumust
CREATE PROCEDURE sp_regulatsioon_moodik_arv()
RESULT (regulatsioon_link VARCHAR(300), arv INTEGER, moodik VARCHAR(100))
BEGIN
SELECT regulatsioon_link, SUM(arv) as summa FROM (
select regulatsioon_link, COUNT(*) as arv, 'osutamistearv' from moodik 
join teenus_has_regulatsioon on moodik.teenus=teenus_has_regulatsioon.teenus_id 
where osutamistearv is not null
group by regulatsioon_link
union 
select regulatsioon_link, COUNT(*)as Arv, 'rahulolu' from moodik 
join teenus_has_regulatsioon on moodik.teenus=teenus_has_regulatsioon.teenus_id 
where rahulolu is not null
group by regulatsioon_link
union 
select regulatsioon_link, COUNT(*) as Arv, 'ajakulu' from moodik 
join teenus_has_regulatsioon on moodik.teenus=teenus_has_regulatsioon.teenus_id 
where ajakulu is not null
group by regulatsioon_link
union 
select regulatsioon_link, COUNT(*) as Arv, 'maksumus' from moodik 
join teenus_has_regulatsioon on moodik.teenus=teenus_has_regulatsioon.teenus_id 
where maksumus is not null
group by regulatsioon_link) AS tabel
GROUP BY regulatsioon_link
ORDER by summa;
END
--näide
CALL sp_regulatsioon_moodik_arv()





