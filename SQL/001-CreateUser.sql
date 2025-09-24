--
-- per eseguire la procedura
-- occorre collegarsi come sa
-- oppure con un utente avente ruolo sysadmin
--


/*
Al primo avvio di SQL Server, probabilmente si utilizza l'account di amministratore predefinito (sa) 
oppure un utente autenticato con i permessi di sysadmin. 
*/

-- procedura di reset begin
-- Sposta il contesto nel database 'master' per non essere bloccato nel database da eliminare
USE master;
GO

-- 1. Elimina il Database se esiste
-- Questo comando interrompe tutte le connessioni al database per permetterne l'eliminazione
-- Lo user viene eliminato automaticamente quando si esegue il DROP DATABASE 
-- perché è un'entità di sicurezza che esiste solo all'interno di quel database.
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'mpcorsoDB')
BEGIN
    ALTER DATABASE mpcorsoDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE mpcorsoDB;
    print 'droppato database';
END
GO

-- 2. Elimina il Login se esiste
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'mpcorso')
BEGIN
    DROP LOGIN mpcorso;
    print 'droppato login';
END
GO
-- procedura di reset end




-- Passo 1: Creazione del Login 👤
-- Per prima cosa, creare un Login a livello di server. 
-- Questo è il nome utente e la password che verranno utilizzati per connettersi a SQL Server. 
-- Scegliere un nome login e una password sicura.
/*
If Password validation failed:
The password does not meet SQL Server password policy requirements because it is not complex enough. 
The password must be at least 8 characters long 
and contain characters from three of the following four sets: 
    Uppercase letters, 
    Lowercase letters, 
    Base 10 digits, 
    Symbols.
*/
CREATE LOGIN mpcorso
WITH PASSWORD = 'MPScorso25';
print 'creato login';
GO



-- Passo 2: Creazione del Database 🗄️
CREATE DATABASE mpcorsoDB;
PRINT 'creato database';
GO  


-- Passo 3: Creazione dell'Utente e Assegnazione come Proprietario del Database
-- Entrare nel contesto del database appena creato e creare un Utente che verrà associato al login del Passo 1. 
-- Successivamente, impostare questo utente come proprietario del database (dbo).

-- 3.1 Entrare nel contesto del database
USE mpcorsoDB;
PRINT 'entrato nel database';
GO

-- 3.2 Creazione dell'Utente associato al login
CREATE USER mpcorso FOR LOGIN mpcorso;
print 'creato utente';
GO

-- 3.3 Impostare l'Utente come Proprietario del Database
-- In questo modo, il nuovo utente avrà tutti i diritti amministrativi
-- su questo specifico database
-- ALTER AUTHORIZATION ON DATABASE::mpcorsoDB TO mpcorso;
-- PRINT 'impostato proprietario';
-- GO

ALTER ROLE db_owner ADD MEMBER mpcorso;
PRINT 'impostato proprietario';
GO





-- Fine della procedura di creazione dell'utente e assegnazione come proprietario del database

SELECT * FROM sys.server_principals WHERE name = 'mpcorso';
SELECT * FROM sys.database_principals WHERE name = 'mpcorso';
GO
