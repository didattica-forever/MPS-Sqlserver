use mpcorsoDB;
GO

-- Rimuove la Stored Procedure esistente
IF OBJECT_ID('dbo.UpdateCustomerOrdersActiveState') IS NOT NULL
    DROP PROCEDURE dbo.UpdateCustomerOrdersActiveState;
GO

-- Elimina il vecchio trigger se esiste per ricrearlo
IF OBJECT_ID('TR_Customer_Orders_ActiveState') IS NOT NULL
    DROP TRIGGER TR_Customer_Orders_ActiveState;
GO


/*******************************************************
 * 4. STORED PROCEDURE: Aggiornamento Stato Ordini Cliente
 * Mette Active=0 o Active=1 a tutti gli ordini del cliente
 * Restituito il numero di righe modificate tramite OUTPUT
 *******************************************************/
CREATE PROCEDURE dbo.UpdateCustomerOrdersActiveState
    @CustomerID INT,
    @NewActiveState BIT,
    @RowsAffected INT OUTPUT -- Parametro di OUTPUT per il conteggio
AS
BEGIN
    SET NOCOUNT ON;

    -- Aggiorna la colonna Active nella tabella Orders
    -- prendi tutti gli ordini di un cliente e mettigli lo stato a on oppure a off
    -- update orders set active = 0 where CustomerID = 35; (disabilita ordine)
    -- update orders set active = 1 where CustomerID = 35; (abilita ordine)
    UPDATE Orders
    SET Active = @NewActiveState
    WHERE CustomerID = @CustomerID;

    -- Assegna il numero di righe modificate al parametro di OUTPUT
    SET @RowsAffected = @@ROWCOUNT;
    print('messaggio dal server')
    print(@RowsAffected);

END
GO

--
-- creazione di un trigger che lanci automaticamente la procedura sovrastante
--

/*******************************************************
 * 5. TRIGGER: Aggiornamento basato sui SET di Dati
 *******************************************************/
CREATE TRIGGER TR_Customer_Orders_ActiveState
ON Customers
AFTER UPDATE -- BEFORE e AFTER, scatta per INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDisactivated INT;
    DECLARE @RowsReactivated INT;
    
    IF UPDATE(Enabled) -- Eseguiamo l'azione solo se la colonna 'Enabled' è cambiata
    BEGIN
        
        -- A) Aggiornamento Ordini per Clienti DISABILITATI (Enabled: 1 -> 0)
        UPDATE ORD
        SET Active = 0 -- disabilito la riga
        FROM Orders ORD
        JOIN DELETED D ON ORD.CustomerID = D.CustomerID -- DELETED la ROW della tabella prima della modifica
        JOIN INSERTED I ON ORD.CustomerID = I.CustomerID -- INSERTED la ROW della tabella dopo la modifica
        -- Controlliamo che il vecchio stato fosse 1 e il nuovo sia 0
        WHERE D.Enabled = 1 AND I.Enabled = 0; -- se lo stato del Customer è passato da 1 a 0, allora disabilita ordine

        SET @RowsDisactivated = @@ROWCOUNT;
        
        -- B) Aggiornamento Ordini per Clienti RIABILITATI (Enabled: 0 -> 1)
        UPDATE ORD
        SET Active = 1
        FROM Orders ORD
        JOIN DELETED D ON ORD.CustomerID = D.CustomerID
        JOIN INSERTED I ON ORD.CustomerID = I.CustomerID
        -- Controlliamo che il vecchio stato fosse 0 e il nuovo sia 1
        WHERE D.Enabled = 0 AND I.Enabled = 1;
        
        SET @RowsReactivated = @@ROWCOUNT;
        
        -- Stampa il riepilogo delle modifiche
        PRINT 'Trigger TR_Customer_Orders_ActiveState eseguito:';
        PRINT '- Ordini disattivati: ' + CAST(@RowsDisactivated AS NVARCHAR);
        PRINT '- Ordini riattivati: ' + CAST(@RowsReactivated AS NVARCHAR);

    END
END
GO

-- Elimina il vecchio trigger se esiste per ricrearlo
IF OBJECT_ID('TR_Customer_Orders_ActiveState') IS NOT NULL
    DROP TRIGGER TR_Customer_Orders_ActiveState;
GO

/*******************************************************
 * TRIGGER DEFINITIVO e PERFORMANTE
 * Sfrutta la logica set-based con una singola UPDATE.
 *******************************************************/

-- Elimina il vecchio trigger se esiste per ricrearlo
IF OBJECT_ID('TR_Customer_Orders_ActiveState') IS NOT NULL
    DROP TRIGGER TR_Customer_Orders_ActiveState;
GO

CREATE  TRIGGER TR_Customer_Orders_ActiveState
ON Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsAffected INT;
    
    IF UPDATE(Enabled) -- Esegue la logica solo se la colonna 'Enabled' è stata modificata
    BEGIN
        
        -- Singola UPDATE che sincronizza lo stato 'Active' dell'Ordine
        -- con il nuovo stato 'Enabled' del Cliente.
        UPDATE ORD
        SET Active = I.Enabled
        FROM Orders ORD
        JOIN DELETED D ON ORD.CustomerID = D.CustomerID
        JOIN INSERTED I ON ORD.CustomerID = I.CustomerID
        -- Il filtro essenziale: solo se lo stato Enabled è cambiato.
        WHERE D.Enabled != I.Enabled; 

        SET @RowsAffected = @@ROWCOUNT;
        
        -- Stampa il riepilogo delle modifiche
        PRINT 'Trigger TR_Customer_Orders_ActiveState eseguito:';
        PRINT CAST(@RowsAffected AS NVARCHAR) + ' righe Ordini sincronizzate con lo stato Cliente.';

    END
END
GO