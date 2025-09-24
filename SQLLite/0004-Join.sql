drop table if exists cjdA;
drop table if exists cjdB;

create table cjdA (x char);
insert into cjdA values('A');
insert into cjdA values('B');
insert into cjdA values('C');
insert into cjdA values('D');

create table cjdB (x char);
insert into cjdB values('1');
insert into cjdB values('2');
insert into cjdB values('3');
insert into cjdB values('4');

select *
from cjdA, cjdB;

select *
from cjdA a, cjdA b;

select *
from cjdA a, cjdA b
where a.x != b.x;

select *
from cjdA a, cjdA b
where a.x = b.x;

select count(*), 20*110 -- 20*110
from regioni r, province p;

select count(*), 1*110 -- 110
from regioni r, province p
where r.nome = 'Toscana';

select r.id, r.nome, p.id, p.nome
from regioni r, province p
where r.nome = 'Toscana' 
and r.id = p.id_regione; -- INNER EQUI JOIN


drop table if exists clienti;

create table
		clienti ( id_cliente int primary key,
		nome varchar(50),
		cognome varchar(50),
		email varchar(50),
		indirizzo varchar(100),
		citta varchar(50),
		provincia varchar(4),
		cap int );
	
insert into clienti VALUES (1,'Giuseppe','Verdi','gverdi@aol.com','Roncole Verdi','Busseto','PR',43011);
insert into clienti VALUES (2,'Gioacchino','Rossini','gioacchino@libero.it','Via del Duomo','Pesaro','PU',61122);
insert into clienti VALUES (3,'Giacomo','Puccini','gpuccini@gmail.com','Corte San Lorenzo, 9 ','Lucca','LU',55100);
insert into clienti VALUES (4,'Gaetano','Donizetti','gaetano@walla.com','Via Don Luigi Palazzolo, 88','Bergamo','BG',24122);
insert into clienti VALUES (5,'Vincenzo','Bellini','bellini@bellini.org','Piazza San Francesco d’Assisi, 3','Catania','CT',95100);
		
drop table if exists ordini;
create table ordini (id_ordine int primary key, data date,valore decimal(10,2),id_cliente int);
insert into ordini values (1, date('10/10/2018', 'DD-MM-YYYY') ,345.67,   1);
insert into ordini values (2, date('31/12/2017', 'DD-MM-YYYY') ,176.00,   3);
insert into ordini values (3, date('01/01/2019', 'DD-MM-YYYY') ,33.88,    2);
insert into ordini values (4, date('24/11/2018', 'DD-MM-YYYY') ,4589.00,  3);
insert into ordini values (5, date('13/07/2018', 'DD-MM-YYYY') ,230.00,  10);
insert into ordini values (6, date('01/06/2018', 'DD-MM-YYYY') ,144.00,   9);


select count(*) from clienti;
select count(*) from ordini;

select a.nome, a.cognome, b.data, b.valore 
from clienti a 
inner join ordini b 
on a.id_cliente = b.id_cliente;

-- left join (null al posto dei dati della tabella DX)
select nome, cognome, data, valore 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente;

-- left join with exclusion (null al posto dei dati della tabella DX)
select nome, cognome, data, valore 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente
where b.valore is null;


-- right join
select nome, cognome, data, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente;

-- right join with exclusion
select nome, cognome, data, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente
where a.id_cliente is null;


