use mpcorsoDB;
GO

-- rimozione della funzione dal data dictionary
-- server per rendere rientrante lo script
IF OBJECT_ID('dbo.GetRandomNumber') IS NOT NULL
    DROP FUNCTION dbo.GetRandomNumber;
GO -- end of batch

CREATE FUNCTION dbo.GetRandomNumber ( -- int GetRandomNumber(int Min, int Max, float RandomSeed) {}
    @Min INT,
    @Max INT,
    @RandomSeed FLOAT -- Riceve il valore casuale (tra 0 e 1) come parametro
)
RETURNS INT
AS
BEGIN
    DECLARE @Result INT;

    -- Formula standard per generare un numero intero casuale nel range:
    -- Min + (Casuale * (Max - Min + 1))
    SET @Result = @Min + CAST(@RandomSeed * (@Max - @Min + 1) AS INT);

    RETURN @Result;
END

GO -- end of batch
