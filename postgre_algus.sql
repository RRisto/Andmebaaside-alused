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
Musta_tulemus smallint check (musta_tulemus in (0,1,2)),
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



