-- selezioni sulle regioni

select * from regioni; -- proiezione

select id, nome  -- esplicitare sempre la proiezione
from regioni;

select regioni.id, regioni.nome 
from regioni;

select r.id, r.nome 
from regioni r; -- aliasing del table name (ridenominazione)

select r.id as 'Identificativo', r.nome  -- aliasing del column name (ridenominazione)
from regioni r;  -- aliasing del table name (ridenominazione)

-- selezione, applicare un filtro in uscita alla query tramite la clausola where
select r.id as 'Identificativo', r.nome
from regioni r
where r.nome like '%m%'; -- %string% (Contiene la stringa), %string (Inizia per stringa), string% (Termina per stringa)

select r.id as 'Identificativo', r.nome
from regioni r
where r.nome like '__e%'; -- seleziona totutto ciò che contiene una e alla 3^ posizione


select r.id as 'Identificativo', r.nome
from regioni r
where r.nome like '%o' or r.nome like '%e';


select * from regioni 
where id = 10;

select * from regioni 
where id >= 5 and id <= 10;

select * from regioni 
where id between 5 and 10;

select * from regioni 
where id = 3 or id = 5 or id =12;

select * from regioni 
where id in( 3, 5, 12 ); -- list/elenco di valori

select * from regioni 
where id in( 3, 5, 12 ) and nome like '%o'; -- list/elenco di valori

select * from regioni 
where id in (3, 5, 12 ) or nome like '%o';

-- sort/ordinamenti clausola order by è l'unica che consente la stabilità dell'ordinamento del risultato
select * from regioni 
where id in (3, 5, 12 ) or nome like '%o'
order by nome; -- garantisce l'ordine di uscita dei dati

select id, nome from regioni 
where id in (3, 5, 12 ) or nome like '%o'
order by nome; -- ordinamento crescente

select id, nome from regioni 
where id in (3, 5, 12 ) or nome like '%o'
order by nome desc; -- ordinamento decrescente ==> clausola desc

select id, nome from regioni 
where id in (3, 5, 12 ) or nome like '%o'
order by 2 desc; -- ordinamento decrescente ==> clausola desc

select id, nome, latitudine+longitudine as 'somma' from regioni 
where id in (3, 5, 12 ) or nome like '%o'
order by 2 desc, 3;

-- funzioni
select count(*) from regioni; -- conta quante sono le righe
select count(id) from regioni; -- conta quante sono le righe con id non null

select count(*) from province;
select count(codice_citta_metropolitana) from province; -- conta quante sono le righe con colonna not null

select sum(latitudine) from regioni;


