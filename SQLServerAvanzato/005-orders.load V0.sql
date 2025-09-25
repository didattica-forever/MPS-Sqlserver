/*******************************************************
 * STORED PROCEDURE: GenerateRandomOrders (v2 - Introduzione Cursore)
 * Itera su ogni cliente attivo per dimostrare il ciclo.
 *******************************************************/

IF OBJECT_ID('dbo.GenerateRandomOrders') IS NOT NULL
    DROP PROCEDURE dbo.GenerateRandomOrders;
GO

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
    
    --
    -- definire il range di date da utilizzare per la generazione
    -- Variabili per il calcolo del range di date effettivo
    --

    DECLARE @DateStart DATETIME;
    DECLARE @DateEnd DATETIME;

    -- Calcola la data di fine
    IF @year_end >= YEAR(GETDATE())
        SET @DateEnd = GETDATE();
    ELSE
        SET @DateEnd = DATEFROMPARTS(@year_end, 12, 31);
    
    -- Calcola la data di inizio
    SET @DateStart = DATEFROMPARTS(@year_start, 1, 1);


    
    -- Variabili per il Cursor e l'iterazione sui clienti
    DECLARE @CurrentCustomerID INT;
    DECLARE @TotalCustomers INT;
    -- Calcola il numero totale di clienti attivi su cui ciclare (per debug)
    SET @TotalCustomers = (SELECT COUNT(*) FROM Customers WHERE Enabled = 1);
    
    -- =======================================================
    -- 1. STAMPA PARAMETRI (Debug)
    -- =======================================================

    PRINT '--- Parametri di Generazione Ordini ---';
    PRINT 'Data Inizio Effettiva: ' + CONVERT(NVARCHAR, @DateStart, 120);
    PRINT 'Data Fine Effettiva: ' + CONVERT(NVARCHAR, @DateEnd, 120);
    PRINT 'Clienti Attivi Trovati: ' + CAST(@TotalCustomers AS NVARCHAR);
    PRINT 'Ordini/Cliente (Min/Max): ' + CAST(@min_number_orders_by_customer AS NVARCHAR) + ' / ' + CAST(@max_number_orders_by_customer AS NVARCHAR);
    PRINT 'Prodotti/Ordine (Min/Max): ' + CAST(@min_products AS NVARCHAR) + ' / ' + CAST(@max_products AS NVARCHAR);
    PRINT '---------------------------------------';
    
    
    -- =======================================================
    -- 2. CURSOR: Itera su ogni Cliente Attivo (Per la Didattica)
    -- =======================================================
    
    -- 2.1 DICHIARAZIONE: Definisce il cursore, specificando il set di dati da scansionare.
    -- Usiamo LOCAL per isolare il cursore dalla transazione, e READ_ONLY per l'efficienza.
    DECLARE Customer_Cursor CURSOR LOCAL READ_ONLY FOR
    SELECT CustomerID
    FROM Customers
    WHERE Enabled = 1
    ORDER BY CustomerID; -- Ordine per chiarezza nel debug
    
    -- 2.2 APERTURA: Carica il set di risultati in memoria.
    OPEN Customer_Cursor;
    
    -- 2.3 PRIMO FETCH: Legge la prima riga e inserisce il valore nella variabile @CurrentCustomerID.
    FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
    
    PRINT 'Inizio iterazione clienti...';
    
    -- 2.4 CICLO WHILE: Continua finché @@FETCH_STATUS è 0 (ovvero, finché ci sono righe).
    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        -- LOGICA DI DEBUG (Solo Stampa per ora):
        PRINT NCHAR(9) + '-> Sto elaborando il Cliente ID: ' + CAST(@CurrentCustomerID AS NVARCHAR) + 
              '. Stato: Abilitato.';

        -- Qui verrà inserita la logica per generare gli ordini
        -- calcolare un numero di ordini casuale da generare per ogni cliente
        -- per ogni ordine:
        --    calcolare una data casuale
        --    calcolare quante righe devo generare in modo casuale
        --       per ogni riga in modo casuale devo generare la quantità di prodotto comprata

        -- 2.5 FETCH SUCCESSIVO: Legge la riga successiva per continuare il ciclo.
        FETCH NEXT FROM Customer_Cursor INTO @CurrentCustomerID;
    END

    -- 2.6 CHIUSURA e DEALLOCAZIONE: Libera le risorse usate dal cursore. ESSENZIALE!
    CLOSE Customer_Cursor;
    DEALLOCATE Customer_Cursor;
    
    PRINT '=======================================';
    PRINT 'ITERAZIONE CLIENTI TERMINATA.';
    
END
GO
