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