/*******************************************************
 * STORED PROCEDURE: GenerateRandomOrders (v12 - SIMULAZIONE FINALE PULITA)
 * Itera su tutti i clienti, simula la creazione degli ordini e dei dettagli.
 * Utilizza SOLO istruzioni PRINT.
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
    
    -- Dichiarazione delle variabili di controllo
    DECLARE @DateStart DATETIME;
    DECLARE @DateEnd DATETIME;
    DECLARE @DateDiffSeconds INT; 
    
    -- Variabili per il Cursor Clienti
    DECLARE @CurrentCustomerID INT;
    
    -- Variabili per la logica Ordini/Dettagli
    DECLARE @NumOrdersToGenerate INT;
    DECLARE @OrderDate DATETIME;
    DECLARE @NewOrderID INT = 999999; -- ID fittizio per la stampa
    DECLARE @NumProductsInOrder INT;
    DECLARE @OrderTotalAmount DECIMAL(10, 2); 
    
    -- Variabili per i Dettagli Prodotto
    DECLARE @ProductQuantity INT;
    DECLARE @ProductUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentProductID INT;
    
    -- Variabili per la casualità (necessarie per RAND())
    DECLARE @RandomFloat FLOAT;
    
    -- Variabile Tabella per contenere i prodotti selezionati casualmente (senza GUID)
    -- Per ogni ordine devo generare da min a max righe
    --      ogni riga deve avere un prodotto diverso
    --          devo selezionare in modo casuale n prodotti presenti
    --              prendo il minimo id
    --              prendo il massimo id
    --              seleziono n id a caso
    --                  se l'id esiste in tabella lo metto in @ProductsToOrder
    DECLARE @ProductsToOrder TABLE (
        ProductID INT,
        Price DECIMAL(10, 2),
        Id_Random INT IDENTITY(1,1) PRIMARY KEY
    );
    
    -- ------------------------------------------------------------------
    -- CALCOLI PRELIMINARI
    -- ------------------------------------------------------------------
    
    -- Calcola il range di date effettivo (fino all'ultimo giorno dell'anno o alla data odierna)
    IF @year_end >= YEAR(GETDATE()) SET @DateEnd = GETDATE();
    ELSE SET @DateEnd = DATEFROMPARTS(@year_end, 12, 31);
    
    SET @DateStart = DATEFROMPARTS(@year_start, 1, 1);
    SET @DateDiffSeconds = DATEDIFF(SECOND, @DateStart, @DateEnd);
    
    -- =======================================================
    -- 1. STAMPA PARAMETRI (Debug)
    -- =======================================================
    PRINT '--- Parametri di Generazione Ordini ---';
    PRINT 'SIMULAZIONE ATTIVA: Nessun dato verrà inserito.';
    PRINT 'Data Inizio Effettiva: ' + CONVERT(NVARCHAR, @DateStart, 120);
    PRINT 'Data Fine Effettiva: ' + CONVERT(NVARCHAR, @DateEnd, 120);
    PRINT 'Ordini/Cliente (Min/Max): ' + CAST(@min_number_orders_by_customer AS NVARCHAR) + ' / ' + CAST(@max_number_orders_by_customer AS NVARCHAR);
    PRINT 'Prodotti/Ordine (Min/Max): ' + CAST(@min_products AS NVARCHAR) + ' / ' + CAST(@max_products AS NVARCHAR);
    PRINT '---------------------------------------';

    -- =======================================================
    -- 2. CURSOR: Inizio Iterazione Clienti
    -- =======================================================
    DECLARE Customer_Cursor CURSOR LOCAL READ_ONLY FOR
    SELECT CustomerID FROM Customers WHERE Enabled = 1 ORDER BY CustomerID;
    OPEN Customer_Cursor;
    FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
    
    PRINT 'Inizio simulazione...';
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        -- A. Calcola il numero di ordini da generare per il cliente (uso FUNCTION)
        SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0; 
        SET @NumOrdersToGenerate = dbo.GetRandomNumber(@min_number_orders_by_customer, @max_number_orders_by_customer, @RandomFloat);

        PRINT NCHAR(9) + '-> Cliente ID: ' + CAST(@CurrentCustomerID AS NVARCHAR) + '. Simulazione di ' + CAST(@NumOrdersToGenerate AS NVARCHAR) + ' ordini.';

        -- B. Ciclo interno per la simulazione dei singoli ordini
        WHILE @NumOrdersToGenerate > 0
        BEGIN
            
            -- C. Generazione della Data Ordine Casuale
            SET @OrderDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % @DateDiffSeconds, @DateStart);
            
            -- D. Calcola il numero di prodotti per questo ordine (uso FUNCTION)
            SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
            SET @NumProductsInOrder = dbo.GetRandomNumber(@min_products, @max_products, @RandomFloat);
            
            -- -------------------------------------------------------------------
            -- E. SIMULAZIONE INSERIMENTO ORDINE
            -- -------------------------------------------------------------------
            SET @OrderTotalAmount = 0;
            
            PRINT NCHAR(9) + NCHAR(9) + 'SIMULAZIONE INSERT INTO Orders: ID fittizio ' + CAST(@NewOrderID AS NVARCHAR) + 
                  ' (Data: ' + CONVERT(NVARCHAR, @OrderDate, 120) + ', Prodotti: ' + CAST(@NumProductsInOrder AS NVARCHAR) + ')';
            
            -- 1. Seleziona Prodotti Casuali e li Inserisce nella Variabile Tabella
            DELETE FROM @ProductsToOrder;
            
            /* 
            --      versione completa
            SELECT TOP (10) NEWID(), ProductID, Price
            FROM Products
            ORDER BY 1; 
            --      versione compressa
            SELECT TOP (10) ProductID, Price
            FROM Products
            ORDER BY NEWID();
            */
            INSERT INTO @ProductsToOrder (ProductID, Price)
            SELECT TOP (@NumProductsInOrder) ProductID, Price
            FROM Products
            ORDER BY NEWID(); -- Selezione casuale efficiente
            
            -- 2. Itera sui Prodotti Selezionati e calcola il Totale
            DECLARE Product_Cursor CURSOR LOCAL READ_ONLY FOR
            SELECT ProductID, Price FROM @ProductsToOrder ORDER BY Id_Random; 
            
            OPEN Product_Cursor;
            FETCH NEXT FROM Product_Cursor INTO @CurrentProductID, @ProductUnitPrice; 
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Genera una quantità casuale tra min e max (uso FUNCTION)
                SET @RandomFloat = ABS(CHECKSUM(NEWID())) / 2147483647.0;
                SET @ProductQuantity = dbo.GetRandomNumber(1, 5, @RandomFloat);
                
                -- Aggiorna il totale dell'Ordine
                SET @OrderTotalAmount = @OrderTotalAmount + (@ProductUnitPrice * @ProductQuantity);
                
                -- Stampa simulazione dettaglio
                PRINT NCHAR(9) + NCHAR(9) + NCHAR(9) + '- SIMULAZIONE INSERT Detail: Prodotto ID ' + CAST(@CurrentProductID AS NVARCHAR) + 
                      ' (Qty: ' + CAST(@ProductQuantity AS NVARCHAR) + ', Prezzo: ' + CAST(@ProductUnitPrice AS NVARCHAR) + ').';

                FETCH NEXT FROM Product_Cursor INTO @CurrentProductID, @ProductUnitPrice;
            END
            
            CLOSE Product_Cursor;
            DEALLOCATE Product_Cursor;
            
            -- 3. Simulazione Aggiornamento Totale
            PRINT NCHAR(9) + NCHAR(9) + 'SIMULAZIONE UPDATE Orders: Totale finale calcolato: ' + CAST(@OrderTotalAmount AS NVARCHAR);
            
            SET @NumOrdersToGenerate = @NumOrdersToGenerate - 1;
        END

        FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
    END

    CLOSE Customer_Cursor;
    DEALLOCATE Customer_Cursor;
    
    PRINT '=======================================';
    PRINT 'SIMULAZIONE GENERAZIONE TERMINATA.';
    
END
GO

