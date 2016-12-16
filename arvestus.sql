--leida isikute nimed, kas etteantud turniiril 	ei saanud ühtegi võitu ja kaotust
-- ainult nimi
select eesnimi, perenimi from(	
SELECT isik.eesnimi as eesnimi, isik.perenimi as perenimi, f_mangija_voite_turniiril(mangija, turniir) AS 'võite',
	f_mangija_viike_turniiril(mangija, turniir) AS 'viike',f_mangija_kaotusi_turniiril(mangija, turniir) AS 'kaotusi'
	FROM v_punkt 
	JOIN isik 
	ON mangija=isik.id
	WHERE turniir = 47 
	and kaotusi=0
	and võite=0
	GROUP BY turniir, mangija , perenimi, eesnimi
	order by perenimi) 	as tabel
	
	
	

