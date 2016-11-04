--before trigger
CREATE TRIGGER tg_turniiriaeg1 BEFORE 
INSERT, UPDATE ON turniir
REFERENCING NEW as  uus
FOR EACH ROW
WHEN (uus.loppkuupaev< uus.alguskuupaev)
BEGIN SET uus.loppkuupaev= uus.alguskuupaev;
END
--after trigger
CREATE TRIGGER tg_turniiriaeg2 AFTER
INSERT, UPDATE ON turniir
REFERENCING NEW AS uus
FOR EACH ROW
WHEN (uus.loppkuupaev< uus.alguskuupaev)
BEGIN UPDATE turniir
SET loppkuupaev=alguskuupaev
WHERE id = uus.id;
END
--kui tahad trigereid näha
SELECT * FROM sysobjects
WHERE TYPE = 'TR'
--testime, peaks loppkuupaeva tegema samaks, mis alguskuupäev
INSERT INTO turniir(nimi, toimumiskoht, alguskuupaev, loppkuupaev) VALUES ('proov','Tapa', '2010-10-14','2010-10-10')
--kustutame ka rea ära
DELETE FROM turniir WHERE nimi='proov'
--syseventtype
select * from syseventtype
