/*******************************************************
 * STORED PROCEDURE: GenerateRandomOrders (v13 - INSERIMENTO REALE + PRINT)
 * Inserisce dati reali in Orders e OrderDetails mantenendo il debug.
 *******************************************************/

IF OBJECT_ID('dbo.GenerateRandomOrders') IS NOT NULL
    DROP PROCEDURE dbo.GenerateRandomOrders;
GO

-- ASSUNZIONE: La Funzione dbo.GetRandomNumber deve esistere
-- e accettare (@Min INT, @Max INT, @RandomSeed FLOAT)

CREATE PROCEDURE dbo.GenerateRandomOrders
    @year_start INT,
    @year_end INT,
    @min_number_orders_by_customer INT,
    @max_number_orders_by_customer INT,
    @min_products INT,
    @max_products INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variabili di controllo e per il Cursor Clienti
    DECLARE @DateStart DATETIME;
    DECLARE @DateEnd DATETIME;
    DECLARE @DateDiffSeconds INT;
    DECLARE @CurrentCustomerID INT;

    -- Variabili per la logica Ordini/Dettagli
    DECLARE @NumOrdersToGenerate INT;
    DECLARE @OrderDate DATETIME;
    DECLARE @NewOrderID INT;
    -- Rimosso il valore fittizio
    DECLARE @NumProductsInOrder INT;
    DECLARE @OrderTotalAmount DECIMAL(10, 2);

    -- Variabili per i Dettagli Prodotto
    DECLARE @ProductQuantity INT;
    DECLARE @ProductUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentProductID INT;

    -- Variabili per la casualità
    DECLARE @RandomFloat FLOAT;

    -- Variabile Tabella per contenere i prodotti selezionati casualmente
    -- La variabile tabella è una struttura di memoria temporanea 
    -- che si comporta in modo molto simile a una tabella reale su disco.
    -- Il suo scopo principale è quello di servire da buffer intermedio tra la selezione casuale dei prodotti e l'inserimento finale nei dettagli dell'ordine.
    -- Esiste solo per la durata dell'esecuzione della Stored Procedure e viene distrutta automaticamente alla fine dell'esecuzione.
    DECLARE @ProductsToOrder TABLE (
        ProductID INT,
        Price DECIMAL(10, 2),
        Id_Random INT IDENTITY(1,1) PRIMARY KEY
    );

    -- ------------------------------------------------------------------
    -- CALCOLI PRELIMINARI
    -- ------------------------------------------------------------------

    IF @year_end >= YEAR(GETDATE()) SET @DateEnd = GETDATE();
    ELSE SET @DateEnd = DATEFROMPARTS(@year_end, 12, 31);

    SET @DateStart = DATEFROMPARTS(@year_start, 1, 1);
    SET @DateDiffSeconds = DATEDIFF(SECOND, @DateStart, @DateEnd);

    -- =======================================================
    -- 1. STAMPA PARAMETRI (Debug)
    -- =======================================================
    PRINT '--- Parametri di Generazione Ordini ---';
    PRINT 'MODALITÀ: INSERIMENTO DATI REALE CON DEBUG ATTIVO.';
    PRINT 'Data Inizio Effettiva: ' + CONVERT(NVARCHAR, @DateStart, 120);
    PRINT 'Data Fine Effettiva: ' + CONVERT(NVARCHAR, @DateEnd, 120);
    PRINT '---------------------------------------';

    -- =======================================================
    -- 2. CURSOR: Inizio Iterazione Clienti
    -- =======================================================
    DECLARE Customer_Cursor CURSOR LOCAL READ_ONLY FOR
    SELECT CustomerID
    FROM Customers
    WHERE Enabled = 1
    ORDER BY CustomerID;
    OPEN Customer_Cursor;
    FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;

    PRINT 'Inizio elaborazione e inserimento dati...';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- X. NUOVO BLOCCO: Salto Casuale basato su multiplo di 5
        SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
        DECLARE @RandomSkipNumber INT = dbo.GetRandomNumber(1, 100, @RandomFloat);

        IF @RandomSkipNumber % 5 = 0 -- se RandomSkipNumber è multiplo di 5
        BEGIN
            PRINT NCHAR(9) + '-> Cliente ID: ' + CAST(@CurrentCustomerID AS NVARCHAR) + 
              '. Numero casuale ' + CAST(@RandomSkipNumber AS NVARCHAR) + 
              ' è multiplo di 5. SALTO l''inserimento ordini. (CONTINUE)';

            -- Salta il resto del codice per il cliente corrente
            FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
            CONTINUE;
        END
        -- A. Calcola il numero di ordini da generare per il cliente
        -- genera un numero decimale (float) casuale compreso tra 0 e 1
        -- NEWID(): L'origine della casualità
        -- CHECKSUM(): Converte il GUID in un numero intero (positivo o negativo)
        -- ABS(): Converte il numero in un valore assoluto (positivo)
        -- Divisione per 2147483647.0 (INT max, INT È DI 32 BIT) per ottenere un valore tra 0 e 1
        SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
        SET @NumOrdersToGenerate = dbo.GetRandomNumber(@min_number_orders_by_customer, @max_number_orders_by_customer, @RandomFloat);

        PRINT NCHAR(9) + '-> Cliente ID: ' + CAST(@CurrentCustomerID AS NVARCHAR) + '. Inserimento di ' + CAST(@NumOrdersToGenerate AS NVARCHAR) + ' ordini.';

        -- B. Ciclo interno per la generazione dei singoli ordini
        WHILE @NumOrdersToGenerate > 0
        BEGIN

            -- C. Generazione della Data Ordine Casuale
            SET @OrderDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % @DateDiffSeconds, @DateStart);

            -- D. Calcola il numero di prodotti per questo ordine
            SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
            SET @NumProductsInOrder = dbo.GetRandomNumber(@min_products, @max_products, @RandomFloat);

            -- -------------------------------------------------------------------
            -- E. INSERIMENTO ORDINE REALE
            -- -------------------------------------------------------------------
            SET @OrderTotalAmount = 0;

            -- 1. INSERT INTO Orders (con TotalAmount temporaneamente a 0)
            INSERT INTO Orders
                (CustomerID, OrderDate, TotalAmount, Active)
            VALUES
                (@CurrentCustomerID, @OrderDate, @OrderTotalAmount, 1);

            -- Cattura il nuovo OrderID generato automaticamente
            SET @NewOrderID = SCOPE_IDENTITY();

            PRINT NCHAR(9) + NCHAR(9) + 'INSERT Ordine ID ' + CAST(@NewOrderID AS NVARCHAR) + 
                  ' ESEGUITO (Data: ' + CONVERT(NVARCHAR, @OrderDate, 120) + ', Prodotti: ' + CAST(@NumProductsInOrder AS NVARCHAR) + ')';

            -- 2. Seleziona Prodotti Casuali e li Inserisce nella Variabile Tabella
            DELETE FROM @ProductsToOrder;

            INSERT INTO @ProductsToOrder
                (ProductID, Price)
            -- analoga a SELECT TOP (10) NEWID(), ProductID, Price FROM Products ORDER BY 1;
            SELECT TOP (@NumProductsInOrder)
                ProductID, Price
            FROM Products
            ORDER BY NEWID();

            -- 3. Itera sui Prodotti Selezionati e Inserisce i Dettagli
            DECLARE Product_Cursor CURSOR LOCAL READ_ONLY FOR
            SELECT ProductID, Price
            FROM @ProductsToOrder
            ORDER BY Id_Random;

            OPEN Product_Cursor;
            FETCH NEXT FROM Product_Cursor INTO @CurrentProductID, @ProductUnitPrice;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Genera una quantità casuale tra 1 e 5
                SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
                SET @ProductQuantity = dbo.GetRandomNumber(1, 5, @RandomFloat);

                -- INSERT INTO OrderDetails
                INSERT INTO OrderDetails
                    (OrderID, ProductID, Quantity, UnitPrice)
                VALUES
                    (@NewOrderID, @CurrentProductID, @ProductQuantity, @ProductUnitPrice);

                -- Aggiorna il totale dell'Ordine
                SET @OrderTotalAmount = @OrderTotalAmount + (@ProductUnitPrice * @ProductQuantity);

                -- Stampa dettaglio
                PRINT NCHAR(9) + NCHAR(9) + NCHAR(9) + '- INSERT Dettaglio: Prodotto ID ' + CAST(@CurrentProductID AS NVARCHAR) + 
                      ' (Qty: ' + CAST(@ProductQuantity AS NVARCHAR) + ', Prezzo: ' + CAST(@ProductUnitPrice AS NVARCHAR) + ').';

                FETCH NEXT FROM Product_Cursor INTO @CurrentProductID, @ProductUnitPrice;
            END

            CLOSE Product_Cursor;
            DEALLOCATE Product_Cursor;

            -- 4. UPDATE del TotalAmount finale nell'Ordine
            UPDATE Orders
            SET TotalAmount = @OrderTotalAmount
            WHERE OrderID = @NewOrderID;

            PRINT NCHAR(9) + NCHAR(9) + 'UPDATE Totale Ordine ' + CAST(@NewOrderID AS NVARCHAR) + ' aggiornato a: ' + CAST(@OrderTotalAmount AS NVARCHAR);

            SET @NumOrdersToGenerate = @NumOrdersToGenerate - 1;
        END

        FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
    END

    CLOSE Customer_Cursor;
    DEALLOCATE Customer_Cursor;

    PRINT '=======================================';
    PRINT 'GENERAZIONE COMPLETATA. Controllare le tabelle Orders e OrderDetails.';

END
GO




