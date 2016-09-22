--1. Leida klubi ‘Laudnikud’ liikmete nimekiri (eesnimi, perenimi) tähestiku järjekorras.
SELECT eesnimi, perenimi FROM isik, klubi WHERE klubi.nimi= 'Laudnikud'ORDER BY eesnimi ASC, perenimi ASC;
--2. Leida klubi ‘Laudnikud’ liikmete arv.
SELECT klubi.nimi, COUNT(*) FROM klubi KEY JOIN isik GROUP BY klubi.nimi HAVING nimi='Laudnikud';
--Leida V-tähega algavate klubide M-tähega algavate eesnimedega isikute perekonnanimed (ja ei muud).
SELECT Perenimi FROM isik WHERE EXISTS(SELECT* FROM klubi WHERE isik.klubi= klubi.id AND(LEFT(klubi.Nimi,1)= 'V' AND LEFT(Isik.Eesnimi,1)= 'M'));
--4. Leida kõige esimesena alanud partii algusaeg.
SELECT MIN(Algushetk) FROM partii;
--5. Leida partiide mängijad (väljad: valge ja must), mis algasid 04. märtsil ajavahemikus 9:00 kuni 11:00.
SELECT Valge, Must FROM partii WHERE Algushetk BETWEEN '2005-03-04 09:00:00.000' AND '2005-03-04 11:00:00.000';
--6. Leida valgetega võitnute (valge_tulemus=2) nimed (eesnimi, perenimi), kus partii kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); 
--Datediff(minute, <algus>, <lõpp>)).