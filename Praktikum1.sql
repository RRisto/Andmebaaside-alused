
CREATE TABLE Isik (
Id integer not null default autoincrement primary key,
Eesnimi varchar(50) not null,
Perenimi varchar(50) not null,
Isikukood varchar(11),
Klubi integer,
Unique (eesnimi, perenimi)
);

CREATE TABLE Klubi (
Id integer not null default autoincrement primary key,
Nimi varchar(100) not null unique
);

CREATE TABLE Turniir(
Id integer not null default autoincrement primary key,
Nimetus varchar(100) not null unique,
Toimumiskoht varchar(100),
Alguskuupaev date not null,
Loppkuupaev date
);

CREATE TABLE Partii(
Id integer not null default autoincrement primary key,
Turniir integer not null,
Algushetk datetime not null default current timestamp,
Lopphetk datetime,
Valge integer not null,
Must integer not null,
Valge_tulemus smallint check (valge_tulemus in (0,1,2)),
Musta_tulemus smallint check (musta_tulemus in (0,1,2)),
Kokkuvote varchar(5000)
);

INPUT INTO klubi FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\klubi.txt'
FORMAT ASCII DELIMITED BY '\x09';

INPUT INTO isik FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\isik.txt'
FORMAT ASCII DELIMITED BY '\x09' (id, eesnimi, perenimi, klubi);

INPUT INTO Turniir FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\turniir.txt'
FORMAT ASCII DELIMITED BY '\x09';

ALTER TABLE turniir RENAME nimetus TO nimi;

ALTER TABLE klubi ADD asukoht varchar(50) NOT NULL DEFAULT 'Tartu'
--kitsenduse muutmine
ALTER TABLE isik ADD CONSTRAINT un_nimi UNIQUE (eesnimi, perenimi);
ALTER TABLE isik DROP CONSTRAINT un_nimi;
ALTER TABLE partii ADD CONSTRAINT vastavus CHECK (valge_tulemus+ musta_tulemus= 2);

ALTER TABLE turniir ADD CONSTRAINT un_nimi UNIQUE (nimi);

ALTER TABLE klubi ADD asukoht70 varchar(70) NOT NULL DEFAULT 'Tartu';
UPDATE klubi SET asukoht70 = asukoht;
ALTER TABLE klubi DROP asukoht;
ALTER TABLE klubi RENAME asukoht70 TO asukoht;

ALTER TABLE Partii DROP Kokkuvote; --andis millegi pärast errori kui see alles jäi

INPUT INTO Partii FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Prakitkum1\partii.txt'
FORMAT ASCII DELIMITED BY '\x09'  (Turniir, Algushetk, Lopphetk, Valge, Must, Valge_tulemus, Musta_tulemus);
ALTER TABLE Partii ADD Kokkuvote varchar(5000) DEFAULT NULL --loon lihtsalt uuesti muutuja Kokkuvõte
--neli välisvõtit
ALTER TABLE isik ADD CONSTRAINT fk_isik_2_klubi 
FOREIGN KEY (klubi) 
REFERENCES klubi(id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

--Partii -> Turniir –nii, et turniiri kustutamisel kaoksid kõik selle turniiri partiid
ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_turniir
FOREIGN KEY (Turniir) 
REFERENCES Turniir(Id) 
ON DELETE CASCADE ON UPDATE CASCADE;

--Partii -> Isik (Valgetega mängija)
ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_isikValge
FOREIGN KEY (Valge) 
REFERENCES Isik(Id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

--Partii -> Isik (Mustadega mängija)
ALTER TABLE Partii ADD CONSTRAINT fk_partii_2_isikMust
FOREIGN KEY (Must) 
REFERENCES Isik(Id) 
ON DELETE RESTRICT ON UPDATE CASCADE;

--kontroll, peab andma vea, kui piirangud töötavad
DELETE FROM klubi WHERE Nimi='Ajurebend'; 
--kontroll, peaks muutma ka isikute tabeli klubi id-d
--UPDATE klubi SET Id='100' WHERE Id='51';
--kontroll, peaks deletima ka tabelist turniir kõik id-ga 41 turniiri partiid
--DELETE FROM turniir WHERE Id=41; 

--kui tahad vaadata, mis tabelid on andmebaasis
SELECT * FROM sysobjects WHERE type = 'U'
--tabel inimesed
CREATE TABLE inimesed (
eesnimi varchar(30) not null,
perenimi varchar(100) not null,
sugu char(1) not null check (sugu in ('m', 'n')),
synnipaev date not null,
sisestatud datetime not null default current timestamp,
isikukood varchar(11),
CONSTRAINT pk_inimesed PRIMARY KEY (isikukood)
);
--lisame väärtused
INSERT INTO inimesed(eesnimi, perenimi, sugu, synnipaev , isikukood)
VALUES ('Juku', 'Mets', 'M', '1980-02-04', '38002042715');

UPDATE inimesed SET eesnimi = 'Jüri' WHERE eesnimi = 'Juku';
--see annab vea
INSERT INTO inimesed (eesnimi, perenimi, sugu, synnipaev , isikukood) VALUES ('Mati', 'Karu', 'M', '1985-02-04', '38002042715');
DELETE inimesed WHERE eesnimi = 'Juku';
DELETE inimesed WHERE eesnimi = 'Jüri';