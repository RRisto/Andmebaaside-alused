--1. Leida klubi ‘Laudnikud’ liikmete nimekiri (eesnimi, perenimi) tähestiku järjekorras.
SELECT eesnimi, perenimi 
FROM Isik, Klubi
WHERE Klubi.nimi= 'Laudnikud'
ORDER BY eesnimi ASC, 
perenimi ASC;
--2. Leida klubi ‘Laudnikud’ liikmete arv.
SELECT Klubi.nimi, COUNT(*) AS 'liikmete arv'
FROM Klubi 
KEY JOIN Isik 
GROUP BY Klubi.nimi 
HAVING nimi='Laudnikud';
--3.Leida V-tähega algavate klubide M-tähega algavate eesnimedega isikute perekonnanimed (ja ei muud).
SELECT perenimi 
FROM Isik 
WHERE EXISTS(
	SELECT* FROM Klubi 
	WHERE Isik.klubi= Klubi.id 
	AND(LEFT(Klubi.nimi,1)= 'V' 
	AND LEFT(Isik.eesnimi,1)= 'M'));
--4. Leida kõige esimesena alanud partii algusaeg.
SELECT MIN(algushetk) AS algusaeg
FROM Partii;
--5. Leida partiide mängijad (väljad: valge ja must), mis algasid 04. märtsil ajavahemikus 9:00 kuni 11:00.
SELECT valge, must 
FROM Partii 
WHERE algushetk 
	BETWEEN '2005-03-04 09:00:00.000' 
	AND '2005-03-04 11:00:00.000';

SELECT valge, must 
FROM Partii 
WHERE MONTH(algushetk)=3 
	AND DAY(algushetk)=4 
	AND CONVERT(TIME,Algushetk) 
	BETWEEN '09:00' AND '11:00'
--6. Leida valgetega võitnute (valge_tulemus=2) nimed (eesnimi, perenimi), kus partii kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); 
--Datediff(minute, <algus>, <lõpp>)).
SELECT eesnimi, perenimi FROM Isik 
WHERE EXISTS(
	SELECT* FROM Partii 
	WHERE Isik.Id= Partii.valge 
	AND Datediff(minute, algushetk, lopphetk) 
	BETWEEN 9 AND 11 AND valge_tulemus=2);
--7. Leida rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
SELECT eesnimi 
FROM Isik 
GROUP BY eesnimi 
HAVING COUNT(*) > 1;
--8. Leida klubid, kus on alla 4 liikme
SELECT Klubi.nimi, COUNT(*) AS 'liikmete arv'
FROM Klubi 
KEY JOIN Isik 
GROUP BY Klubi.nimi 
HAVING COUNT(*) < 4;
--9. Leida kõigi Arvode poolt valgetega mängitud partiide arv.
SELECT COUNT(*) AS 'valgetega partiide arv'
FROM Partii 
WHERE EXISTS(
SELECT* FROM Isik 
WHERE Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo');
--10. Leida kõigi Arvode poolt valgetega mängitud partiide arv turniiride lõikes.
SELECT Turniir.nimi, COUNT(*) AS 'Arvod valgetega partiid' 
FROM Partii 
KEY JOIN Turniir 
WHERE EXISTS(
	SELECT* FROM Isik 
	WHERE Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo') 
GROUP BY nimi;
--11. Leida kõigi Mariade mustadega mängitud mängudest saadud punktide arv (tulemus = 2 on võit ja annab 1 punkti, 
--tulemus = 1 on viik ja annab pool punkti).
SELECT SUM(
	CASE WHEN musta_tulemus=2 THEN 1 
	WHEN musta_tulemus=1 THEN 0.5 
	ELSE musta_tulemus END) 
musta_tulemus 
FROM Partii 
WHERE EXISTS(
	SELECT* FROM Isik 
	WHERE Partii.must= Isik.id 
	AND isik.Eesnimi='Maria'); 
--12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga: turniiri nimi, keskmine partii pikkus) 
SELECT Turniir.nimi AS 'turniiri nimi', 
	AVG(Datediff(minute, aLgushetk, lopphetk)) AS 'keskmine partii pikkus' 
FROM Partii 
KEY JOIN Turniir 
GROUP BY nimi;