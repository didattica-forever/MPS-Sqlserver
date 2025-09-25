use mpcorsoDB;
GO


EXEC dbo.GenerateRandomOrders 
    @year_start = 2023, 
    @year_end = 2025,
    @min_number_orders_by_customer = 1,
    @max_number_orders_by_customer = 2,
    @min_products = 2, 
    @max_products = 4;
GO


