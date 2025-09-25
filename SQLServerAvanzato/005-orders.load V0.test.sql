use mpcorsoDB;
GO

DECLARE @MinOrders INT = 2;
DECLARE @MaxOrders INT = 10;
DECLARE @MinProds INT = 2;
DECLARE @MaxProds INT = 8;

EXEC dbo.GenerateRandomOrders 
    @year_start = 2023, 
    @year_end = 2025, -- Se l'anno corrente è 2025 o prima, usa GETDATE()
    @min_number_orders_by_customer = @MinOrders,
    @max_number_orders_by_customer = @MaxOrders,
    @min_products = @MinProds,
    @max_products = @MaxProds;
GO


