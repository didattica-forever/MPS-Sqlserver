use mpcorsoDB;
GO

/* step seguiti
select NEWID(); -- genera un GUID random

select checksum(newid()); -- non determinisca, non possono utilizzate all'interno di function

select abs(checksum(newid())); -- non determinisca, non possono utilizzate all'interno di function

select abs(checksum(newid())) / 2147483647.0; -- devo dividerlo per il massimo valore contenibile in un int di 32 bit
*/

declare @rnd float;

set @rnd = abs(checksum(newid())) / 2147483647.0;

select dbo.GetRandomNumber(0, 100, @rnd); 
