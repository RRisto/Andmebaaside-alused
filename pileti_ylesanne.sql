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

--variant, mis näitab iga turniiri kohta korraga, kes on min ajaga mängija
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
