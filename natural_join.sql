create table proov (
id varchar(5),
eesnimi varchar(10))

create table proov2 (
id varchar(5),
perenimi varchar(10))

insert into proov values('yks', 'juhan')
insert into proov values('yks', 'jaan')
insert into proov2 values('yks', 'jüri')
insert into proov2 values('yks', 'kalle')

select * from proov natural join proov2