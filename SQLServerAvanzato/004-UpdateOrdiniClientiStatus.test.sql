use mpcorsoDB;
GO


-- update customers set enabled = 0 where CustomerID = 10;

declare @ra int;

EXECUTE dbo.UpdateCustomerOrdersActiveState 10, 0, @ra out;

select @ra;
