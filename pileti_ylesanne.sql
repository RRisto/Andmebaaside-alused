--ÜLESANNE: leida andmebaasist ope isik, kes konkreetsel turniiril kulutas kõige rohkem aega
--algne versioon, turniiril 47 kõige rohkem aeg kulutanud isiku nimi
select top 1 eesnimi+' '+  perenimi as nimi from (
	select valge as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg 
	from partii where turniir=47 
	group by isik
union
	select must as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg 
	from partii 
	where turniir=47 
	group by isik
) as tabel 
join isik on isik.id=tabel.isik
group by nimi 
order by sum(aeg) desc;

--funktsioonina (anna ainult turniiri id ette)
CREATE FUNCTION f_pikim_aeg(turniir_id integer)
RETURNS varchar(50) 
NOT DETERMINISTIC
BEGIN
DECLARE nimi varchar(50);
select top 1 eesnimi+' '+  perenimi as nimi INTO nimi from (
	select valge as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg 
	from partii 
	where turniir=turniir_id 
	group by isik
union
	select must as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg 
	from partii 
	where turniir=turniir_id 
	group by isik
) as tabel 
join isik on isik.id=tabel.isik
group by nimi 
order by sum(aeg) desc;
RETURN nimi;
END;

--variant, mis näitab iga turniiri kohta korraga, kes on min ajaga mängija (mõtlesin ise välja)
--koodi lühendamiseks oleks mõistlik protseduure/vaateid kasutada
select f.turniir, f.isik, f.ajasumma as minaeg from (
--see osa leiab iga turniiri min aja
   select turniir, min(ajasumma) as ajasumma from (
		select isik, turniir, sum(aeg) as ajasumma from (
			select valge as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg , turniir
			from partii  
			group by isik, turniir
		union
		select must as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg,turniir 
			from partii   
			group by isik, turniir) y
		group by isik, turniir
		order by turniir, ajasumma, isik) as tabel
	group by turniir) as x 
--ühendame tabelid
inner join 
--see osa leiab kõikide mängijate ajasumma igal turniiril
	(select isik, turniir, sum(aeg) as ajasumma from (
		select valge as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg , turniir
			from partii  
			group by isik, turniir
		union
		select must as isik, sum(datediff(minute, algushetk, lopphetk)) as aeg,turniir 
			from partii   
			group by isik, turniir) y
	group by isik, turniir) as f 
--ühendame kaks tabelit turniiride järgi ja leiam read kus on min ajakulu
on f.turniir = x.turniir and f.ajasumma = x.ajasumma;


--teine pileti ülesanne, ülesanne umbes midagi sellist: leida konkreetsel turniiril
--konkreetses klubis mängijate paremusjärjestus punktide järgi, esitada lahendus protseduurina
create procedure sp_edetabel (IN a_turniir int, IN a_klubi int)
RESULT (Nimi VARCHAR(100), Tulemus double)
BEGIN
	select distinct m.isik_nimi, e.punkte
	from v_edetabel as e, v_mangija as m
	where e.turniir=a_turniir
	and m.klubi_id=a_klubi
	and e.mangija=m.isik_nimi
	order by e.punkte desc;
END
--näidisülesanne õisis
--Koosta päring: Suurim punktisumma. Näidata infot kujul:
--„Perenimi, Eesnimi ”, Punkte (kahe veeruna),  kelle punktisumma (üle kõikide partiide) on kõige suurem. Kui neid on mitu, siis see, kes on perenime järgi tähestikus eespool.
select isik.perenimi +', '+isik.eesnimi as nimi, sum(punkt) as punkte 
from v_punkt 
join isik on v_punkt.mangija=isik.id
group by nimi
order by sum(punkt) desc, nimi 

