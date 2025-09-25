use mpcorsoDB;
GO

/*******************************************************
 * 1. PULIZIA: DROP delle Tabelle (RILANCIABILE)
 *******************************************************/

-- drop table if exists OrderDetails;

IF OBJECT_ID('OrderDetails') IS NOT NULL
    DROP TABLE OrderDetails;

IF OBJECT_ID('Orders') IS NOT NULL
    DROP TABLE Orders;

IF OBJECT_ID('Customers') IS NOT NULL
    DROP TABLE Customers;

IF OBJECT_ID('Products') IS NOT NULL
    DROP TABLE Products;

GO


/*******************************************************
 * 2. CREAZIONE delle Tabelle
 *******************************************************/
-- Tabella Clienti
CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY IDENTITY(1,1), -- Identity(1,1) = valore auto generato (auto increment) parte da 1 e si incrementa di 1
    -- Chiave Primaria con Auto-Incremento
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    created_at datetime NOT NULL DEFAULT GETDATE(),
    updated_at datetime NOT NULL DEFAULT GETDATE()
);

-- Tabella Prodotti
CREATE TABLE Products
(
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    -- Chiave Primaria con Auto-Incremento
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    created_at datetime NOT NULL DEFAULT GETDATE(),
    updated_at datetime NOT NULL DEFAULT GETDATE()
);

-- Tabella Ordini
CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    -- Chiave Primaria con Auto-Incremento
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    -- Data e ora corrente di default
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    -- Chiave Esterna
);

-- Tabella Dettagli Ordine (Tabella di collegamento)
CREATE TABLE OrderDetails
(
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    -- Chiave Primaria con Auto-Incremento
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    -- Vincolo per non avere lo stesso prodotto due volte nello stesso ordine
    -- Spostato all'esterno nella alter table
    -- UNIQUE (OrderID, ProductID) 
);

-- Aggiunta di un vincolo di unicità sulla coppia OrderID e ProductID
-- in un ordine, nella riga di dettaglio ordine non può comparire il 
-- medesimo prodotto più  di una volta
ALTER TABLE OrderDetails
ADD CONSTRAINT UC_OrderDetails UNIQUE (OrderID, ProductID);

GO

/*******************************************************
 * MODIFICA STRUTTURA: Aggiunta Colonna 'Enabled'
 * Aggiunge la colonna BIT (booleana) per la cancellazione logica.
 * In SQL Server non esiste il tipo di dato BOOLEAN standard (ISO).
 * In SQL Server (T-SQL) il tipo di dato che si utilizza per rappresentare valori booleani (Vero/Falso, Sì/No) è il BIT.
 * Vero (True) = 1
 * Falso (False) = 0    
 *******************************************************/

-- 1. Aggiunta alla tabella Customers
ALTER TABLE Customers
ADD Enabled BIT NOT NULL DEFAULT 1;

GO

-- 2. Aggiunta alla tabella Products
ALTER TABLE Products
ADD Enabled BIT NOT NULL DEFAULT 1;

GO

/*******************************************************
 * ALTER TABLE: Aggiunta Colonna Active su Orders
 * step di modifica:
 * se il cliente viene disabilitato, disabilitare anche tutti i suoi ordini
 * se il cliente viene abilitato, abilitare anche tutti i suoi ordini
 *******************************************************/
ALTER TABLE Orders
ADD Active BIT NOT NULL DEFAULT 1;

GO