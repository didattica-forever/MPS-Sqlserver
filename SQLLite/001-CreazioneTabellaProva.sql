drop table if exists prova;

create table prova (
	campo1 int,
	campo2 varchar(100)
	);

select * from prova;

insert into prova values(1, 'riga 1');
insert into prova values(2, 'riga 2');

select * from prova;

drop table if exists studenti;
create table studenti (
	matricola char(5),
	nome varchar(100),
	cognome varchar(100)
);
	
insert into studenti (matricola, nome, cognome) VALUES
('AAAA1', 'Attilio', 'Bianchi'),
('AAAA2', 'Giovanni', 'Rossi'),
('BBC3', 'Luigi', 'Verdi')
;

select * from studenti;

-- nel caso di tabelle molto grandi evitare di mettere il valore di DEFAULT
-- per risparmiare sui costi di esecuzione
alter table studenti add column enabled bool; -- default true;

select * from studenti;

/*
select matricola, cognome, nome
from studenti;

select matricola, cognome
from studenti;


select matricola, cognome
from studenti
where matricola like 'B%';

update studenti set enabled = false
where matricola = 'AAAA2';
	
select * from studenti
where enabled = true;

*/