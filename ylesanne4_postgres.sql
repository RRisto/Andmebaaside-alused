--1. Leida klubi ‘Laudnikud’ liikmete nimekiri (eesnimi, perenimi) tähestiku järjekorras.
SELECT eesnimi, perenimi 
FROM Isik, Klubi
WHERE Klubi.id=Isik.klubi
AND Klubi.nimi= 'Laudnikud'
ORDER BY perenimi ASC, 
eesnimi ASC;
--teine variant
SELECT eesnimi, perenimi 
FROM Isik
JOIN Klubi
ON Klubi.id=Isik.klubi
WHERE Klubi.nimi= 'Laudnikud'
ORDER BY perenimi ASC, 
eesnimi ASC;
--2. Leida klubi 'Laudnikud' liikmete arv.
SELECT COUNT(*) AS "Liikmete_arv"
FROM Isik
JOIN Klubi
ON Klubi.id=Isik.klubi
WHERE Klubi.nimi= 'Laudnikud'
--teine variant
SELECT COUNT(*) AS "Liikmete arv"
FROM Isik, Klubi
WHERE Klubi.id=Isik.klubi
AND Klubi.nimi= 'Laudnikud'
--3.Leida V-tähega algavate klubide M-tähega algavate eesnimedega isikute perekonnanimed (ja ei muud).
SELECT perenimi 
FROM Isik 
WHERE EXISTS(
	SELECT* FROM Klubi 
	WHERE Isik.klubi= Klubi.id 
	AND(LEFT(Klubi.nimi,1)= 'V' 
AND LEFT(Isik.eesnimi,1)= 'M'));
--teine variant	
SELECT perenimi 
FROM Isik, Klubi
WHERE Isik.klubi= Klubi.id 
	AND(LEFT(Klubi.nimi,1)= 'V' 
AND LEFT(Isik.eesnimi,1)= 'M');
--kolmas variant
SELECT perenimi 
FROM Isik
JOIN Klubi
	ON Isik.klubi= Klubi.id 
	AND(LEFT(Klubi.nimi,1)= 'V' 
AND LEFT(Isik.eesnimi,1)= 'M');
--4. Leida kõige esimesena alanud partii algusaeg.
SELECT MIN(algushetk) AS algusaeg
FROM Partii;
--5. Leida partiide mängijad (väljad: valge ja must), mis algasid 04. märtsil ajavahemikus 9:00 kuni 11:00.
SELECT valge, must 
FROM Partii 
WHERE algushetk 
	BETWEEN '2005-03-04 09:00:00.000' 
AND '2005-03-04 11:00:00.000';
--kui kasutada mõne funktsiooni sees, siis võib aja rohkem 'lahti' lammutada, et päeva, kuud ja aega oleks võimalik eraldi muuta:
SELECT valge, must 
FROM Partii 
WHERE EXTRACT(MONTH FROM algushetk)=3 
	AND EXTRACT (DAY FROM algushetk)=4 
	AND EXTRACT (HOUR FROM Algushetk) 
BETWEEN '09' AND '11'
SELECT * 
FROM Partii 
WHERE EXTRACT(MONTH FROM algushetk)=3 
	AND EXTRACT (DAY FROM algushetk)=4 
	AND EXTRACT (HOUR FROM Algushetk) 
BETWEEN '09' AND '10' --between viimane on inclusive!!!
--6. Leida valgetega võitnute (valge_tulemus=2) nimed (eesnimi, perenimi), kus partii kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); 
--Datediff(minute, <algus>, <lõpp>)).
SELECT eesnimi, perenimi 
FROM Isik 
WHERE EXISTS(
	SELECT* 
	FROM Partii 
	WHERE Isik.Id= Partii.valge 
	AND DATE_PART('day', lopphetk - algushetk) * 24 + 
               DATE_PART('hour', lopphetk - algushetk) * 60 +
               DATE_PART('minute', lopphetk - algushetk) BETWEEN 9 AND 11 
AND valge_tulemus=2);
--variant 2 (ei anna unikaalseid tuelemdi nagu tavalise SQLga)
SELECT eesnimi, perenimi 
FROM Isik, Partii
WHERE Isik.Id= Partii.valge 
	AND DATE_PART('day', lopphetk - algushetk) * 24 + 
               DATE_PART('hour', lopphetk - algushetk) * 60 +
               DATE_PART('minute', lopphetk - algushetk) BETWEEN 9 AND 11 
AND valge_tulemus=2
--kolmas variant
SELECT eesnimi, perenimi 
FROM Isik 
JOIN Partii 
	ON Isik.Id= Partii.valge 
	AND DATE_PART('day', lopphetk - algushetk) * 24 + 
               DATE_PART('hour', lopphetk - algushetk) * 60 +
               DATE_PART('minute', lopphetk - algushetk) BETWEEN 9 AND 11  
AND valge_tulemus=2;
--7. Leida rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
SELECT perenimi 
FROM Isik 
GROUP BY perenimi 
HAVING COUNT(*) > 1;
--8. Leida klubid, kus on alla 4 liikme
SELECT Klubi.nimi, COUNT(*) AS "liikmete arv"
FROM Klubi 
JOIN Isik 
ON Isik.klubi= Klubi.id
GROUP BY Klubi.nimi 
HAVING COUNT(*) < 4;
--9. Leida kõigi Arvode poolt valgetega mängitud partiide arv.
SELECT COUNT(*) AS "Arvod valgetega partiid"
FROM Partii 
WHERE EXISTS(
SELECT* FROM Isik 
WHERE Partii.valge= Isik.id 
AND Isik.eesnimi='Arvo');
--teine võimalus
SELECT COUNT(*) AS "Arvod valgetega partiid"
FROM Partii, Isik 
WHERE Partii.valge= Isik.id 
AND Isik.eesnimi='Arvo';
--kolmas võimalus -JOIN
SELECT COUNT(*) AS "Arvod valgetega partiid"
FROM Partii 
JOIN Isik 
ON Partii.valge= Isik.id 
AND Isik.eesnimi='Arvo';
--10. Leida kõigi Arvode poolt valgetega mängitud partiide arv turniiride lõikes.
SELECT Turniir.nimetus, COUNT(*) AS "Arvod valgetega partiid"
FROM Partii 
JOIN Turniir 
ON Turniir.id=Partii.turniir
WHERE EXISTS(
	SELECT* FROM Isik 
	WHERE Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo') 
GROUP BY nimetus;
--või JOINiga
SELECT Turniir.nimi, COUNT(*) AS "Arvod valgetega partiid"
FROM Partii 
JOIN Turniir 
ON Turniir.id=Partii.turniir
JOIN Isik 
	ON Partii.valge= Isik.id 
	AND Isik.eesnimi='Arvo' 
GROUP BY nimi;
--11. Leida kõigi Mariade mustadega mängitud mängudest saadud punktide arv (tulemus = 2 on võit ja annab 1 punkti, 
--tulemus = 1 on viik ja annab pool punkti).
SELECT SUM(
	CASE WHEN musta_tulemus=2 THEN 1 
	WHEN musta_tulemus=1 THEN 0.5 
	ELSE musta_tulemus END) 
AS 'musta tulemus' 
FROM Partii 
WHERE EXISTS(
	SELECT* FROM Isik 
	WHERE Partii.must= Isik.id 
AND isik.Eesnimi='Maria'); 
--11. Leida kõigi Mariade mustadega mängitud mängudest saadud punktide arv (tulemus = 2 on võit ja annab 1 punkti, 
SELECT SUM(
	CASE WHEN musta_tulemus=2 THEN 1 
	WHEN musta_tulemus=1 THEN 0.5 
	ELSE musta_tulemus END) 
AS "musta tulemus" 
FROM Partii 
WHERE EXISTS(
	SELECT* FROM Isik 
	WHERE Partii.must= Isik.id 
AND isik.Eesnimi='Maria'); 
--JOINiga
SELECT SUM(
	CASE WHEN musta_tulemus=2 THEN 1 
	WHEN musta_tulemus=1 THEN 0.5 
	ELSE musta_tulemus END) 
AS "musta tulemus"
FROM Partii 
JOIN Isik 
	ON Partii.must= Isik.id 
AND isik.Eesnimi='Maria'; 
--12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga: turniiri nimi, keskmine partii pikkus) 
SELECT Turniir.nimetus AS "turniiri nimi", 
	AVG(DATE_PART('day', lopphetk - algushetk) * 24 + 
               DATE_PART('hour', lopphetk - algushetk) * 60 +
               DATE_PART('minute', lopphetk - algushetk)) AS "keskmine partii pikkus"
FROM Partii 
JOIN Turniir 
ON Turniir.id=Partii.turniir
GROUP BY Turniir.nimetus;

