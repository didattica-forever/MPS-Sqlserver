-- nested/inner select

-- elencare le province della lombardia
select id from regioni where nome in ( 'Lombardia', 'Toscana');

select id_regione, nome, sigla_automobilistica 
from province 
where id_regione in
	(
		select id from regioni where nome in ( 'Lombardia', 'Toscana')
	)
order by nome desc
;

select id_regione, nome, sigla_automobilistica 
from province 
where id_regione =
	(
		select id from regioni where nome in ( 'Toscana')
	)
order by nome desc
;


create temp table temp_id (
	id INT
	);
	
-- calcolo l'elenco degli id come risultato intermedio
insert into temp_id (id) 
select id from regioni where nome in ('Lombardia', 'Toscana');

select id, id_regione, nome, codice_catastale 
from comuni 
where id_provincia in
	( select id from province where id_regione in (
			select id from temp_id -- riutilizzo il risultato intermedio
		)
	)
order by id_regione desc, nome
;


select count(*) from regioni;
select count(*) from province;
select count(*) from comuni;

select 'Regioni', count(*) from regioni
union
select 'Province', count(*) from province
union
select 'Comuni', count(*) from comuni;

select
	( select count(*) from regioni ) as '# Regioni',
	( select count(*) from province ) as '# Province',
	( select count(*) from comuni ) as '# Comuni';

	
SELECT id, id_regione, nome as 'provincia', codice_citta_metropolitana, sigla_automobilistica as 'targa'
from province
where id_regione in(
	select id from regioni where nome in ('Lombardia', 'Toscana')
	);
	
	

SELECT id, id_regione, nome as 'provincia', codice_citta_metropolitana, sigla_automobilistica as 'targa'
from province
where id_regione in(
	select id from regioni where nome in ('Lombardia', 'Toscana')
);

-- targa e id_regione dove esiste la città metropolitana
select inner_query.targa, inner_query.id_regione
from
(
	SELECT id, id_regione, nome as 'provincia', codice_citta_metropolitana, sigla_automobilistica as 'targa'
	from province
	where id_regione in(
		select id from regioni where nome in ('Lombardia', 'Toscana')
	)
) inner_query
where inner_query.codice_citta_metropolitana is not null;


