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
  hind DECIMAL(10,2),
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

--see osa on uuendamata!!!!	
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
FORMAT ASCII DELIMITED BY ';'  (teenus, link,tyyp, ajakulu, hind, osutamistearv,rahulolu);
--regulatsioon
INPUT INTO regulatsioon FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\regulatsioon.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (link,tyyp);
--teenus_has_regulatsioon
INPUT INTO teenus_has_regulatsioon FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\riigiteenused andmebaas\teenus_has_regulatsioon.csv' SKIP 1
FORMAT ASCII DELIMITED BY ';'  (regulatsioon_link,teenus_id);

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
END
--trigger, kui kanal kustutatakse, kontrollib, kas sama teenusega on veel kanaleid. Kui enam pole, kustutab teenuse ära
CREATE TRIGGER tg_kustuta_kanal AFTER DELETE ON kanal
REFERENCING OLD AS vana FOR EACH ROW
BEGIN
DECLARE l_arv1 integer;
SELECT COUNT(*) INTO l_arv1 FROM kanal WHERE teenus = vana.teenus;
IF l_arv1 = 0 THEN
DELETE FROM teenus WHERE Id = vana.teenus;
END IF;
END

