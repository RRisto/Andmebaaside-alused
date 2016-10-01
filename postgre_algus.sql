--make sequence for Id
CREATE SEQUENCE rank_id_seq;

CREATE TABLE Isik (
Id INTEGER NOT NULL default nextval('rank_id_seq') PRIMARY KEY,
Eesnimi varchar(50) not null,
Perenimi varchar(50) not null,
Klubi integer,
Unique (eesnimi, perenimi)
);

--klubi
CREATE TABLE Klubi (
Id INTEGER NOT NULL default nextval('rank_id_seq') PRIMARY KEY,
Nimi varchar(100) not null unique
);

--turniir
CREATE TABLE Turniir(
Id INTEGER NOT NULL default nextval('rank_id_seq') PRIMARY KEY,
Nimetus varchar(100) not null unique,
Toimumiskoht varchar(100),
Alguskuupaev date not null,
Loppkuupaev date
);

--partii
CREATE TABLE Partii(
Id INTEGER NOT NULL default nextval('rank_id_seq') PRIMARY KEY,
Turniir integer not null,
Algushetk timestamp not null default current_timestamp,
Lopphetk timestamp,
Valge integer not null,
Must integer not null,
Valge_tulemus smallint check (valge_tulemus in (0,1,2)),
Musta_tulemus smallint check (musta_tulemus in (0,1,2))
);
--andmed sisse
COPY Isik FROM 
'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\isik.txt' 
(DELIMITER('	'));

COPY Klubi FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\klubi_enc.txt'
(DELIMITER('	'));

COPY Turniir FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\turniir_enc.txt'
(DELIMITER('	'));

COPY Partii (Turniir, Algushetk, Lopphetk, Valge, Must, Valge_tulemus, Musta_tulemus)
FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\partii.txt'
(DELIMITER('	'));

--teeme välisvõtmed
--neli välisvõtit
ALTER TABLE Isik ADD CONSTRAINT fk_isik_2_klubi 
FOREIGN KEY (klubi) 
REFERENCES klubi(id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_turniir
FOREIGN KEY (Turniir) 
REFERENCES Turniir(Id) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_isikValge
FOREIGN KEY (Valge) 
REFERENCES Isik(Id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_isikMust
FOREIGN KEY (Must) 
REFERENCES Isik(Id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

--päringud
SELECT eesnimi FROM isik WHERE len(eesnimi)<6 GROUP BY eesnimi HAVING count(eesnimi)>1 ORDER BY eesnimi 
SELECT eesnimi, perenimi FROM isik;
SELECT DISTINCT eesnimi FROM isik;
SELECT DISTINCT klubi FROM isik;
SELECT nimi, 0, CURRENT_DATE, NULL FROM klubi;
SELECT perenimi ||', '|| eesnimi, klubi + id FROM isik; 
SELECT CASE WHEN eesnimi='Maria' THEN '***'ELSE eesnimi END, perenimi FROM isik
SELECT LEFT (eesnimi,1),SUBSTRING(perenimi, 2, 4), EXTRACT(YEAR FROM CURRENT_DATE ) FROM isik;
---agregeerivad funktsioonid
SELECT COUNT(*) FROM isik; 
SELECT COUNT(DISTINCT eesnimi) FROM isik;
SELECT MIN(algushetk), MAX(lopphetk) FROM partii;
SELECT MAX(eesnimi), MIN(perenimi) FROM isik;
SELECT AVG((valge_tulemus-musta_tulemus)/2.0), SUM(valge_tulemus)/2.0,SUM(musta_tulemus)/2.0 FROM partii;
--tulemi tabelite veergude nimede ette andmine
SELECT perenimi || ', '|| eesnimi AS nimi FROM isik;
SELECT COUNT(*) AS arv FROM isik;
--loogilised avaldised
SELECT* FROM isik WHERE klubi=55 OR klubi=57;
SELECT * FROM isik WHERE klubi IN(55,57);
SELECT * FROM isik WHERE klubi BETWEEN 55 AND 57;
SELECT* FROM isik WHERE eesnimi LIKE 'M%';--võrreldes sybasega on suurtähe tundlik
SELECT* FROM isik WHERE eesnimi LIKE '_alle';
SELECT * FROM isik WHERE eesnimi SIMILAR TO 'A__a|e%';
SELECT * FROM isik WHERE CAST(id AS TEXT) SIMILAR TO '[8-9][1,3-4]';
--Alampäringud
--Esitada turniiride andmed, kui neis mängiti partii, mille üheks mängijaks (must või valge) oli isik, kelle id on 72
SELECT* FROM turniir WHERE EXISTS(SELECT* FROM partii WHERE partii.turniir= turniir.id AND(valge= 72 OR must= 72));
--järjestus
SELECT eesnimi FROM isik ORDER BY eesnimi ASC;
SELECT eesnimi FROM isik ORDER BY eesnimi DESC;
SELECT eesnimi, perenimi FROM isik ORDER BY perenimi, eesnimi;
SELECT eesnimi, perenimi FROM isik ORDER BY 2, 1; --järjestus positsiooni järgi lauses
--mitme päringu sidumine lausesse
SELECT* FROM isik, klubi; --Tehakse tabelite otsekorrutis:(Pannakse kõrvuti mõlema tabeli veerud ja korratakse 
--esimese tabeli sisu iga veeru korral teisest tabelist.)
SELECT eesnimi, perenimi, klubi, klubi.id, klubi.nimi FROM isik, klubi WHERE perenimi= 'Hiis';
--Millisesse klubisse kuulub Helina ja millisesse Henno?
SELECT eesnimi, perenimi, klubi, klubi.id, klubi.nimi FROM isik, klubi WHERE eesnimi= 'Helina';
SELECT eesnimi, perenimi, klubi, klubi.id, klubi.nimi FROM isik, klubi WHERE eesnimi= 'Henno';
--Selgem
SELECT eesnimi, perenimi, klubi, klubi.id,klubi.nimi FROM isik, klubi WHERE perenimi= 'Hiis'AND isik.klubi= klubi.id;
SELECT eesnimi, perenimi, klubi, klubi.id,klubi.nimi FROM isik JOIN klubi ON isik.klubi = klubi.id WHERE perenimi = 'Hiis';
--Kes mängisid valgetega ja võitsid:
SELECT DISTINCT eesnimi, perenimi, valge_tulemus FROM isik JOIN partii ON isik.id=partii.valge AND valge_tulemus=2;
--Aga  lisaks kõik teised isikud (ka need, kes valgetega ei võitnud) :
SELECT DISTINCT eesnimi, perenimi, valge_tulemus FROM isik LEFT OUTER JOIN partii ON isik.id= partii.valge AND valge_tulemus=2;
--grupeerimine
SELECT turniir, COUNT(*) FROM partii GROUP BY turniir;
--NB! Agregeeritud funktsioone ei saa kasutada koos grupeerimata väljadega
SELECT turniir.nimetus, COUNT(*) FROM turniir, partii WHERE turniir.id=partii.turniir GROUP BY turniir.nimetus;
--Kui palju on sama tähega algavaid perenimesid?
SELECT LEFT(perenimi,1) AS pn, COUNT(*) AS arv FROM isik GROUP BY pn ORDER BY arv DESC, pn ASC;
SELECT eesnimi, COUNT(*) AS arv FROM isik GROUP BY eesnimi HAVING COUNT(*)> 1;
--Ainult nimed saame päringuga:
SELECT eesnimi FROM isik GROUP BY eesnimi HAVING COUNT(*) > 1;
--Millist tähte kasutatakse enam nime alguses?  Vaadelda nii pere-kui ka eesnimesid. Järjestada tulemus 
--nime algustäht, esinemiste arv ja ‘p’ või ‘e’  (perenimi / eesnimi) mitte kasvavalt korduste arvu järgi.
SELECT LEFT(perenimi,1), COUNT(*),'p' FROM isik GROUP BY LEFT(perenimi,1) UNION  ALL  SELECT LEFT(eesnimi,1), 
COUNT(*),'e' FROM isik GROUP BY LEFT(eesnimi,1) ORDER BY 2 DESC , 1;

