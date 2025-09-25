use mpcorsoDB;
GO

IF OBJECT_ID('index_customerId_orders') IS NOT NULL
    DROP index index_customerId_orders on Orders;
go

create index index_customerId_orders on Orders(CustomerID);
go



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