--tabelid
CREATE TABLE Faculty(
Id INTEGER NOT NULL DEFAULT 
AUTOINCREMENT PRIMARY KEY,
Name VARCHAR(50) NOT NULL,
Address VARCHAR(30),
DeanId INTEGER,
ViceDeanId INTEGER,
UNIQUE(Name)
);

CREATE TABLE Person(
Id INTEGER NOT NULL DEFAULT 
AUTOINCREMENT 
PRIMARY KEY,
FirstName VARCHAR(30) NOT NULL,
LastName VARCHAR(30) NOT NULL,
FacultyId INTEGER NOT NULL,
SSN VARCHAR(11),
UNIQUE(FirstName,LastName));

CREATE TABLE Registration(
Id INTEGER NOT NULL DEFAULT 
AUTOINCREMENT PRIMARY KEY,
CourseId INTEGER NOT NULL,
PersonId INTEGER NOT NULL,
FinalGrade VARCHAR(1));

CREATE TABLE Lecturer(
Id INTEGER NOT NULL DEFAULT
AUTOINCREMENT PRIMARY KEY,
CoursesId INTEGER,
PersonsId INTEGER NOT NULL,
Responsible SMALLINT);

CREATE TABLE Course(
Id INTEGER NOT NULL DEFAULT
AUTOINCREMENT PRIMARY KEY,
FacultyId INTEGER NOT NULL,
Name VARCHAR(50) NOT NULL,
Code VARCHAR(20),
EAP INTEGER,
GradeType VARCHAR(8));

--andmed sisse
INPUT INTO Person FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\edu\person.txt' FORMAT ASCII DELIMITED BY '\x09'
INPUT INTO Faculty FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\edu\faculty.txt' FORMAT ASCII DELIMITED BY '\x09'
INPUT INTO Registration FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\edu\registrations.txt' FORMAT ASCII DELIMITED BY '\x09'
INPUT INTO Lecturer FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\edu\lecturers.txt' FORMAT ASCII DELIMITED BY '\x09'
INPUT INTO Course FROM 'C:\Users\Risto\Documents\Infotehnoloogia mitteinformaatikutele\Andmebaaside alused\Andmebaaside-alused\edu\course.txt' FORMAT ASCII DELIMITED BY '\x09'

--foreign key
--Person tabeli kirje kustutamisel kustutatakse tema 
--registreeringud ainetele
ALTER TABLE Registration ADD CONSTRAINT
fk_registration_person FOREIGN KEY (PersonId)
REFERENCES Person (Id) ON DELETE 
CASCADE
ON UPDATE CASCADE;
--Dekaani kirje kustutamisel ei kustutata tema teaduskonda
ALTER TABLE Faculty ADD CONSTRAINT
fk_faculty_person_dean FOREIGN KEY (DeanId)
REFERENCES Person (Id) ON DELETE SET 
NULL
ON UPDATE CASCADE;
--Registration → Course
ALTER TABLE Registration ADD CONSTRAINT
fk_registration_course FOREIGN KEY (CourseId)
REFERENCES Course (Id) ON DELETE 
CASCADE
ON UPDATE CASCADE;
--Lecturer → Person
ALTER TABLE Lecturer ADD CONSTRAINT
fk_lecturer_person FOREIGN KEY (PersonsId)
REFERENCES Person (Id) ON DELETE 
CASCADE
ON UPDATE CASCADE;
--Lecturer → Course (tühista seos)
ALTER TABLE Lecturer ADD CONSTRAINT
fk_lecturer_course FOREIGN KEY (CoursesId)
REFERENCES Course (Id) ON DELETE 
SET NULL
ON UPDATE CASCADE;
--Course → Faculty
ALTER TABLE Course ADD CONSTRAINT
fk_course_faculty FOREIGN KEY (FacultyId)
REFERENCES Faculty (Id) ON DELETE 
CASCADE
ON UPDATE CASCADE;
--Faculty (ViceDeanId) → Person (tühista seos
ALTER TABLE Faculty ADD CONSTRAINT
fk_vicedean_person FOREIGN KEY (ViceDeanId)
REFERENCES Person (Id) ON DELETE 
SET NULL
ON UPDATE CASCADE;
--Person → Faculty
ALTER TABLE Person ADD CONSTRAINT
fk_person_faculty FOREIGN KEY (FacutltyId)
REFERENCES Faculty (Id) ON DELETE 
CASCADE
ON UPDATE CASCADE;
--päringud
--Dekaanid teaduskondadest, kus oli olemas ka prodekaan:
SELECT * FROM person
WHERE EXISTS(
SELECT * FROM faculty 
WHERE faculty.deanId = person.id AND
faculty.viceDeanId IS NOT NULL);
--mitme päringu siduine ühte tabelisse
SELECT  firstName, lastName, name,faculty.id,DeanId 
FROM person, faculty 
WHERE firstName= 'Mati'AND deanId = person.id
--kui palju on iga eap väärtusega aineid?
SELECT eap, count(*) FROM course  GROUP BY  eap
--Kui palju on igale kursusele registreerunud inimesi?
SELECT name, count(*) FROM course, registration
WHERE course.id = registration.courseId 
GROUP BY course.name
--kui palju on sama tähega algavaid perenimesid?
SELECT LEFT (lastName,1) AS pn, COUNT(*) AS arv 
FROM person 
GROUP BY pn 
ORDER BY arv DESC, pn ASC;
--Millist tähte kasutatakse enam nime alguses? Vaadelda nii pere- kui ka eesnimesid. Järjestada tulemus nime algustäht , esinemiste arv ja ‘p’ või ‘e’ (perenimi / eesnimi) mitte kasvavalt korduste arvu järgi
SELECT LEFT (lastName,1), COUNT(*),'p' 
FROM person
GROUP BY LEFT(lastName,1)
UNION ALL
SELECT LEFT(firstName,1), 
COUNT(*),'e' 
FROM person
GROUP BY LEFT (firstName,1)
ORDER BY 2 DESC, 1;
--vaated
CREATE VIEW v_oigusteaduskonna_opilased AS
SELECT * FROM person WHERE facultyId = 2

CREATE VIEW  v_oigusteaduskonna_opilased_mini(eesnimi,perenimi) AS
SELECT FirstName,LastName 
FROM person WHERE facultyId = 2

CREATE VIEW  v_persons_faculty AS
SELECT p.FirstName, p.LastName, f.Name as FacultyName, 
f.Address as FacultyAddress
FROM person as p
JOIN faculty as f ON (p.facultyId = f.id)

CREATE VIEW v_faculty_deans(FacultyName,DeanName, ViceDeanName) AS
SELECT f.Name, d.FirstName+' '+d.LastName as deanName, v.FirstName+' '+v.LastName as viceDeanName
FROM Faculty as f
JOIN Person as d ON (f.deanId = d.id)
JOIN Person as v ON (f.viceDeanId = v.id)
ORDER BY f.Name
--lisame uue kursuse
INSERT INTO Course VALUES (101,9,'Sissejuhatus informaatikasse','MTAT.05.074',3,'Arvestus')
--Lisame kursusele samad inimesed kes osalevad kursusel Sissejuhatus ettevõtte majandusse
INSERT INTO registration(CourseId,PersonId,FinalGrade) 
SELECT 101, p.id, NULL
FROM Course as c
JOIN Registration as r ON (c.Id= r.CourseId)
JOIN Person as p ON (r.PersonId=p.Id)
WHERE c.Name= 'Sissejuhatus ettevõttemajandusse'
--kuvame mõlemal kursusel õppivad õpilased
SELECT p.FirstName+' '+p.LastName as 
PersonName, c.Name as CourseName
FROM Course as c
JOIN Registration as r ON (r.CourseId = c.Id) 
JOIN Person as p ON (r.PersonId = p.Id)
WHERE c.Id = 101 OR c.Id = 75
ORDER BY PersonName 

--1.Luua vaade v_persons_atleast_4eap  (FirstName , LastName) õpilastest, kes õpivad Matemaatika-informaatikateaduskonna ainetel, mis annavad vähemalt 4 EAP -d
CREATE VIEW  v_persons_atleast_4eap (FirstName , LastName) AS
SELECT DISTINCT firstName, lastName FROM Faculty 
JOIN course ON faculty.id=course.facultyID 
JOIN registration ON registration.courseId=course.Id
JOIN person ON registration.personId=person.Id
WHERE faculty.name='Matemaatika-informaatikateaduskond' and course.eap>=4
ORDER BY lastname;
--2.Luua vaade v_mostA(FirstName, LastName ,NrOfA ) õpilastest, kes on saanud kõige rohkem A-sid Matemaatika-informaatikateaduskonna ainetest
CREATE VIEW  v_mostA(FirstName, LastName ,NrOfA ) AS
SELECT DISTINCT firstname, lastname, COUNT(*) AS NrOfA FROM Faculty 
JOIN course ON faculty.id=course.facultyID 
JOIN registration ON registration.courseId=course.Id
JOIN person ON registration.personId=person.Id
WHERE faculty.name='Matemaatika-informaatikateaduskond' AND finalGrade='A'
GROUP BY lastname, firstname
ORDER BY NrOfA DESC;
--3.Luua uus kursus "Andmebaaside teooria".Matemaatika-informaatikateaduskond, MTAT.03.998, 6EAP, Arvestus Lisada sinna kõik õpilased, kes said aines  Andmebaasid arvestuse (A)
INSERT INTO Course(facultyId, name, code, eap,gradetype) VALUES (9,'Andmebaaside teooria','MTAT.03.998',6,'Arvestus')

INSERT INTO registration(CourseId,PersonId,FinalGrade) 
SELECT 102, personId, NULL
FROM registration 
JOIN  course  ON course.id=registration.CourseId 
JOIN person ON registration.PersonId=Person.id
WHERE course.name='Andmebaasid' AND FinalGrade='A'
--4.Luua vaade v_andmebaasideTeooria õpilastest,kes õpivad ainet andmebaasideteooria. (PersonId, FirstName, LastName)
CREATE VIEW  v_andmebaasideTeooria (PersonId, FirstName, LastName) AS
SELECT  PersonId, FirstName, LastName FROM course 
JOIN registration ON registration.courseId=course.Id
JOIN person ON registration.personId=person.Id
WHERE course.name='Andmebaaside teooria'
ORDER BY lastname;
--5.Luua vaade v_top20A (FirstName, LastName, nrOfA) päringule TOP 20 õpilastest, kes on saanud kõige rohkem A-sid
CREATE VIEW  v_top20A (FirstName, LastName, nrOfA) AS
SELECT TOP 20 firstname, lastname, COUNT(*) AS arv FROM registration 
JOIN person ON registration.personId=person.Id WHERE finalgrade='A'
GROUP BY firstname, lastname ORDER BY arv DESC;
--6.Luua vaade v_top20Students(FirstName, LastName, AverageGrade) päringule TOP 20 õpilastest,kelle keskmine hinne on  kõige kõrgem.
CREATE VIEW  v_top20Students(FirstName, LastName, AverageGrade) AS
SELECT TOP 20 firstname, lastname, AVG(CASE WHEN finalgrade='A' THEN 5 
	WHEN finalgrade='B' THEN 4 
	WHEN finalgrade='C' THEN 3
	WHEN finalgrade='D' THEN 2
	WHEN finalgrade='E' THEN 1
	WHEN finalgrade='F' THEN 0 
	ELSE NULL END) AS arv FROM registration 
JOIN person ON registration.personId=person.Id where finalgrade is not null
GROUP BY firstname, lastname ORDER BY arv DESC;









