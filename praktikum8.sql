--loome tudengi kasutaja
GRANT CONNECT TO tudeng IDENTIFIED BY 'tud'
--loome grupi õigustega ja anname ligipääsu tudengile (on selles grupis)
GRANT GROUP TO dba
GRANT MEMBERSHIP IN GROUP dba TO tudeng
--anname selecti õiguse tabelile isik
grant select on isik to tudeng
--inimeste tabelist saab eesnime valida
GRANT SELECT (eesnimi) ON inimesed TO tudeng
--anda mingi õigus kõigile grupi liikmetele
GRANT SELECT ON isik TO dba
--ühe kasutaja eemaldamine grupis
REVOKE MEMBERSHIP IN GROUP dba FROM tudeng
--Grupi mõiste kaotamiseks, üksiti eemaldatakse kõik kasutajad grupist
REVOKE GROUP FROM dba
--Tabeli vaatamise keelamiseks 
REVOKE SELECT ON inimesed FROM tudeng
REVOKE ALL ON isik from tudeng

--teeme 2 gruppi
sp_addgroup grup1
sp_addgroup grup2

grant resource to grup1
grant resource to grup2

--ajutne tabel
CREATE GLOBAL TEMPORARY TABLE paha (
nimi VARCHAR(40) NOT NULL, 
CONSTRAINT pk_paha PRIMARY KEY (nimi)) 
ON COMMIT PRESERVE ROWS;

INSERT INTO paha (nimi) VALUES ('Mari');
SELECT * FROM paha;