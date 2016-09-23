SELECT eesnimi FROM isik WHERE len(eesnimi)<6 GROUP BY eesnimi HAVING count(eesnimi)>1 ORDER BY eesnimi 
SELECT eesnimi, perenimi FROM isik;
SELECT DISTINCT eesnimi FROM isik;
SELECT DISTINCT eesnimi, perenimi FROM isik ;
SELECT DISTINCT klubi FROM isik;
SELECT nimi, 0, CURRENT DATE, NULL FROM klubi; --konstandid
SELECT perenimi ||', '|| eesnimi, klubi + id FROM isik; 
SELECT perenimi +', '+eesnimi, klubi+id FROM isik;
SELECT IF eesnimi='Maria' THEN '***'ELSE eesnimi ENDIF, perenimi FROM isik; --IF
SELECT LEFT (eesnimi,1),SUBSTRING(perenimi, 2, 4),YEAR(CURRENT DATE ) FROM isik;
---agregeerivad funktsioonid
SELECT COUNT(*) FROM isik; --kirjete arv isikute tabelis
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
SELECT * FROM isik WHERE isikukood IS NULL;
SELECT * FROM isik WHERE isikukood IS NOT NULL;

SELECT* FROM isik WHERE eesnimi LIKE 'm%';
SELECT* FROM isik WHERE eesnimi LIKE '_alle';
SELECT * FROM isik WHERE eesnimi LIKE'a__[aeiouõäöü]%';
SELECT * FROM isik WHERE id  LIKE'[8-9][1,3-4]';

--LIKE ohud
SELECT* FROM klubi WHERE nimi LIKE 'valge mask';
SELECT* FROM klubi WHERE nimi= 'valge mask';

SELECT * FROM klubi WHERE nimi LIKE 'valge mask%'; --kasutab indeksit
SELECT * FROM klubi WHERE nimi LIKE '%valge mask'; --ei kasuta indeksit
SELECT * FROM klubi WHERE nimi LIKE '%valge mask%'; --ei kasuta indeksit

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

--WHERE vs JOIN
SELECT eesnimi, perenimi, klubi, klubi.id,klubi.nimi FROM isik JOIN klubi ON isik.klubi = klubi.id WHERE perenimi =  'Hiis';
SELECT eesnimi, perenimi, klubi, klubi.id,klubi.nimi FROM isik KEY JOIN klubi WHERE perenimi = 'Hiis';
--AGA, kui on mitu välisvõtit samasse tabelisse:
SELECT *  FROM isik  KEY JOIN partii; --VIGANE!

SELECT* FROM isik NATURAL JOIN klubi; --Toimub sidumine  isik.id = klubi.id(antud ülesande kontekstis pole selline seos mõtestatud).

--Kes mängisid valgetega ja võitsid:
SELECT DISTINCT eesnimi, perenimi, valge_tulemus FROM isik JOIN partii ON isik.id=partii.valge AND valge_tulemus=2;

--Aga  lisaks kõik teised isikud (ka need, kes valgetega ei võitnud) :
SELECT DISTINCT  eesnimi, perenimi,  valge_tulemus FROM isik LEFT OUTER JOIN partii ON  isik.id= partii.valge AND valge_tulemus=2;

--grupeerimine
SELECT turniir, COUNT(*) FROM partii GROUP BY turniir;
--NB! Agregeeritud funktsioone ei saa kasutada koos grupeerimata väljadega

SELECT turniir.nimi, COUNT(*) FROM turniir, partii WHERE turniir.id=partii.turniir GROUP BY turniir.nimi;
--või:
SELECT nimi, COUNT(*) FROM turniir KEY JOIN partii GROUP BY nimi;

--Kui palju on sama tähega algavaid perenimesid?
SELECT LEFT(perenimi,1)  AS pn, COUNT(*) AS arv FROM isik GROUP BY pn ORDER BY arv DESC, pn ASC;

--Palju on klubides liikmeid:
SELECT klubi.nimi,  COUNT(*) FROM klubi KEY JOIN isik GROUP BY klubi.nimi ORDER BY klubi.nimi;

--piirang grupile
SELECT eesnimi,  COUNT(*) AS arv FROM isik GROUP BY  eesnimi HAVING arv> 1;

--Ainult nimed saame päringuga:
SELECT eesnimi FROM isik GROUP BY eesnimi HAVING COUNT(*) > 1;

--Millist tähte kasutatakse enam nime alguses?  Vaadelda nii pere-kui ka eesnimesid. Järjestada tulemus 
--nime algustäht, esinemiste arv ja ‘p’ või ‘e’  (perenimi / eesnimi) mitte kasvavalt korduste arvu järgi.
SELECT LEFT(perenimi,1), COUNT(*),'p' FROM isik GROUP BY LEFT(perenimi,1) UNION  ALL  SELECT LEFT(eesnimi,1), 
COUNT(*),'e' FROM isik GROUP BY LEFT(eesnimi,1) ORDER BY 2 DESC , 1;

