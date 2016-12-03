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