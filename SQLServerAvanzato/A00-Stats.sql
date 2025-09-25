use mpcorsoDB;
GO

select 'Orders', count(*) from Orders
UNION
select 'OrderDetails', count(*) from OrderDetails;
go

-- qual'e il valore globale degli ordini emessi
select 'Valore Ordini', sum(ord.TotalAmount)
from Orders ord;

-- qual'e il valore globale degli ordini emessi per anno
select year(ord.OrderDate), sum(ord.TotalAmount)
from Orders ord
GROUP BY year(ord.OrderDate)
order by 1;

-- qual'e il valore globale degli ordini emessi per cliente
select c.CustomerID, c.FirstName, c.LastName, sum(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
order by 4 desc;


-- qual'e il valore globale degli ordini emessi per cliente/anno
select year(ord.OrderDate) as 'Anno', c.CustomerID, c.FirstName, c.LastName,  sum(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY year(ord.OrderDate), c.CustomerID, c.FirstName, c.LastName
order by 5 desc;

--
-- la having è la where dei dati aggregati
--
-- qual'e il valore globale degli ordini emessi per anno degli ordini con un valore > 100
select year(ord.OrderDate), sum(ord.TotalAmount)
from Orders ord
where ord.TotalAmount > 10000 -- screma le righe in ingresso al totalizzatore (alla sum)
GROUP BY year(ord.OrderDate)
order by 1;

-- qual'e il valore globale degli ordini emessi per cliente/anno comprendendo solo i totali > 40000
select year(ord.OrderDate) as 'Anno', c.CustomerID, c.FirstName, c.LastName,  sum(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY year(ord.OrderDate), c.CustomerID, c.FirstName, c.LastName
having sum(ord.TotalAmount) > 40000 -- having lavora sul dato aggregato
order by 5 desc;

-- ordinato medio per Anno/Customer
select year(ord.OrderDate) as 'Anno', c.CustomerID,  avg(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY year(ord.OrderDate), c.CustomerID
order by 3 desc;

-- ordinato medio per Anno
select year(ord.OrderDate) as 'Anno',  avg(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY year(ord.OrderDate)
order by 2 desc;

-- ordinato medio
select avg(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
;

-- ordinato medio per Anno/Customer con valore ordinato superiore alla media
select year(ord.OrderDate) as 'Anno', c.CustomerID,  avg(ord.TotalAmount) as 'Totale Ordinato'
from Orders ord
inner join Customers C
on ord.CustomerID = c.CustomerID
GROUP BY year(ord.OrderDate), c.CustomerID
having avg(ord.TotalAmount) > (
    select avg(ord.TotalAmount) as 'Totale Ordinato'
    from Orders ord
)
order by 3 desc;


-- statistiche sui prodotti venduti
select '2025', p.ProductID, p.ProductName, sum(od.Quantity) 'Totale Quantità', sum(od.UnitPrice) 'Totale'
from Products p 
inner join OrderDetails od
on p.ProductID = od.ProductID
inner join Orders ORD 
on ord.OrderID = od.OrderID
where year(ord.OrderDate) = 2025
group by p.ProductID, p.ProductName
having sum(od.UnitPrice) > 8000
order by 5 desc, 4 desc
;

-- prodotti che non sono stati ordinati
select p.ProductID, p.ProductName
from Products p 
left join OrderDetails od
on p.ProductID = od.ProductID
where od.OrderID is null;

select 'Prodotti utilizzati',  count(distinct od.ProductID)
from OrderDetails od
union
select 'Prodotti a catalogo',  count(distinct p.ProductID)
from Products p
;