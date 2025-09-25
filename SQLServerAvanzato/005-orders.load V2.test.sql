use mpcorsoDB;
GO


delete from OrderDetails;
delete from Orders;
go


EXEC dbo.GenerateRandomOrders 
    @year_start = 2023, 
    @year_end = 2025,
    @min_number_orders_by_customer = 20,
    @max_number_orders_by_customer = 40,
    @min_products = 2, 
    @max_products = 10;
GO

select 'Orders', count(*) from Orders
UNION
select 'OrderDetails', count(*) from OrderDetails;
go

select c.CustomerID, c.LastName, ord.OrderID 
from Customers C
left join Orders ORD
on ord.CustomerID = c.CustomerID
where ord.OrderID is null;