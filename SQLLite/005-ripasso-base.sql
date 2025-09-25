-- reprise istruzioni base

drop table if exists studenti;

-- creazione di una tabella
create table studenti (
	id integer primary key, -- auto increment per sqlite definire la colonna in questo modo
	matricola char(5) not null, -- not null e univoca
	nome varchar(100) not null, -- CONSTRAINT deve esistere il valore
	cognome varchar(100) not NULL
	);
	
-- insert
-- insert into studenti values('A01', 'Rossi', 'Mario'); -- 1^ modalità di insert non utilizzabile con l'autop increment

insert into studenti (matricola, nome, cognome) values('A01', 'Mario', 'Rossi');
insert into studenti (matricola, nome, cognome) values('B01', 'Arturo', 'Bianchi');

insert into studenti (matricola, nome, cognome) values -- da usare per gli inserimentio massivi
('C01', 'Luigi','Verdi'),
('D01', 'Giovanni', 'Rossi');

-- update 
update studenti
set nome = 'Paolo'
where matricola = 'D01'; -- sempre la where clause


-- delete 
delete from studenti
where matricola = 'D01'; -- sempre la where clause

--
-- interrogazione
--
select * from studenti;

select nome, cognome
from studenti
order by Cognome;

-- inner SELECT
select * from province
where id_regione in (
	select id from regioni where nome in ('Toscana', 'Umbria')
)
order by province.nome;

-- inner join SELECT
select r.nome as 'Regione', p.nome as 'Provincia', p.sigla_automobilistica as 'Targa' 
from province p
inner join regioni r
on p.id_regione = r.id
where r.nome in ('Toscana', 'Umbria')
order by r.nome, p.nome;


-- left join
-- left join (null al posto dei dati della tabella DX)
-- prende tutte le righe abbinate + le righe non abbinate della tabella di SX
select nome, cognome, valore 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente;

-- elenco clienti che non hanno ordini
select nome, cognome 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente
where valore is null;

-- right join (null al posto dei dati della tabella SX)
-- prende tutte le righe abbinate + le righe non abbinate della tabella di DX
select nome, cognome, id_ordine, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente;

-- elenco ordini errati
select id_ordine, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente
where nome is null;


-- right join by left join
select nome, cognome, id_ordine, valore 
from ordini b
left join  clienti a 
on a.id_cliente = b.id_cliente;

-- inner join  by left join
select nome, cognome, id_ordine, valore 
from ordini b
left join  clienti a 
on a.id_cliente = b.id_cliente
where nome is not null;

-- full join
select nome, cognome, id_ordine, valore 
from ordini b
full join  clienti a 
on a.id_cliente = b.id_cliente;


-- full join by left union right join
-- left
select nome, cognome, id_ordine, valore 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente
union -- operatore insiemistico esclude i doppi
select nome, cognome, id_ordine, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente
;

select nome, cognome, id_ordine, valore 
from clienti a 
left join ordini b 
on a.id_cliente = b.id_cliente
union all -- operatore non insiemistico non esclude i doppi
select nome, cognome, id_ordine, valore 
from clienti a 
right join ordini b 
on a.id_cliente = b.id_cliente
;


-- SQL linguaggio dichiarativo
-- dichiariamo cosa vogliamo ottenere
-- non possiamo dire come ottenerlo

-- regione(1), provincia(2), targa, comune(3), codice_catastale (selezione ==> where regione = 'Toscana')

select r.nome, p.nome
from regioni r
inner join province p
on p.id_regione = r.id
where r.nome = 'Toscana'
;

select r.nome, p.nome
from province p
inner join regioni r
on p.id_regione = r.id
where r.nome = 'Toscana'
;

select r.nome as 'Regione', p.nome as 'Provincia', p.sigla_automobilistica as 'Targa', c.nome as 'Comune', c.codice_catastale as 'Codice Catastale'
from regioni r
inner join province p
on p.id_regione = r.id
inner join comuni c
on c.id_provincia = p.id
where r.nome = 'Toscana'
order by r.nome, p.nome, c.nome
;


select r.nome as 'Regione', p.nome as 'Provincia', p.sigla_automobilistica as 'Targa', c.nome as 'Comune', c.codice_catastale as 'Codice Catastale'
from regioni r
inner join comuni c
on c.id_provincia = p.id
inner join province p
on p.id_regione = r.id
where r.nome = 'Toscana'
order by r.nome, p.nome, c.nome
;

-- join errata perchè non lega comuni a province
-- causa un prodotto cartesiano replicando i 279 per le 10 province
select r.nome as 'Regione', p.nome as 'Provincia', p.sigla_automobilistica as 'Targa', c.nome as 'Comune', c.codice_catastale as 'Codice Catastale'
from regioni r
inner join comuni c
on c.id_regione = r.id
inner join province p
on p.id_regione = r.id
where r.nome = 'Toscana'
order by r.nome, p.nome, c.nome
;

select (select count(*) from comuni where id_regione = 9) * (select count(*) from province where id_regione = 9); -- 2790

select r.nome as 'Regione', p.nome as 'Provincia', p.sigla_automobilistica as 'Targa', c.nome as 'Comune', c.codice_catastale as 'Codice Catastale'
from regioni r
inner join comuni c
on c.id_regione = r.id and c.id_provincia = p.id
inner join province p
on p.id_regione = r.id
where r.nome = 'Toscana'
order by r.nome, p.nome, c.nome
;


