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
SELECT Valge, Must FROM partii WHERE MONTH(Algushetk)=3 AND DAY(Algushetk)=4 AND CONVERT(TIME,Algushetk) BETWEEN '09:00' AND '11:00'
--6. Leida valgetega võitnute (valge_tulemus=2) nimed (eesnimi, perenimi), kus partii kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); 
--Datediff(minute, <algus>, <lõpp>)).
SELECT* FROM isik WHERE EXISTS(SELECT* FROM partii WHERE isik.Id= partii.valge AND Datediff(minute, Algushetk, Lopphetk) BETWEEN 9 AND 11 AND Valge_tulemus=2);
--7. Leida rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
SELECT eesnimi FROM isik GROUP BY eesnimi HAVING COUNT(*) > 1;
--8. Leida klubid, kus on alla 4 liikme
SELECT klubi.nimi,  COUNT(*) FROM klubi KEY JOIN isik GROUP BY klubi.nimi HAVING COUNT(*) < 4;
--9. Leida kõigi Arvode poolt valgetega mängitud partiide arv.
SELECT COUNT(*) FROM partii WHERE EXISTS(SELECT* FROM isik WHERE partii.Valge= isik.id AND isik.Eesnimi='Arvo');
--10. Leida kõigi Arvode poolt valgetega mängitud partiide arv turniiride lõikes.
SELECT COUNT(*) AS 'Arvod valgetega',partii.Turniir FROM partii WHERE EXISTS(SELECT* FROM isik WHERE partii.Valge= isik.id AND isik.Eesnimi='Arvo') GROUP BY partii.Turniir;
--11. Leida kõigi Mariade mustadega mängitud mängudest saadud punktide arv (tulemus = 2 on võit ja annab 1 punkti, tulemus = 1 on viik ja annab pool punkti).
SELECT SUM(CASE WHEN Musta_tulemus=2 THEN 1 WHEN Musta_tulemus=1 THEN 0.5 ELSE Musta_tulemus END) musta_tulemus FROM partii 
WHERE EXISTS(SELECT* FROM isik WHERE partii.Must= isik.id AND isik.Eesnimi='Maria'); 
--12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga: turniiri nimi, keskmine partii pikkus) 
SELECT turniir.nimi AS 'turniiri nimi', AVG(Datediff(minute, ALgushetk, Lopphetk)) AS 'keskmine partii pikkus' FROM partii KEY JOIN turniir GROUP BY nimi;