--1. Leida klubi ‘Laudnikud’ liikmete nimekiri (eesnimi, perenimi) tähestiku järjekorras.
SELECT eesnimi, perenimi FROM isik, klubi WHERE klubi.nimi= 'Laudnikud'ORDER BY eesnimi ASC, perenimi ASC;
--2. Leida klubi ‘Laudnikud’ liikmete arv.
