/* OTHER */
/* Damir Matešiæ - https://blog.matesic.info */
/* ######################################### */

/* MS SQL CREATE OR ALTER */

-- stored procedure that already exist
CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END
GO

CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END
GO

-- Check if the object exists, drop and create
IF OBJECT_ID(N'dbo.sp_SQLNewFunctions','P') IS NOT NULL
EXEC('DROP PROCEDURE dbo.sp_SQLNewFunctions');
GO
CREATE PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END

-- CREATE OR ALTER
CREATE OR ALTER PROCEDURE dbo.sp_SQLNewFunctions
AS
BEGIN
    SELECT 'This demo is cool :)' AS Result
END
Go

EXEC('DROP PROCEDURE dbo.sp_SQLNewFunctions');
GO




/* MS SQL DROP IF EXISTS (a.k.a. DIE) */


-- drop non existing table
DROP TABLE dbo.SQLNewFunctions;

-- Check if the object exists and drop it
IF OBJECT_ID('dbo.SQLNewFunctions','U') IS NOT NULL DROP TABLE dbo.SQLNewFunctions

-- Using IF EXISTS
DROP TABLE IF EXISTS dbo.SQLNewFunctions
DROP PROCEDURE IF EXISTS dbo.sp_SQLNewFunctions




-- Thanks! - Erland Sommarskog

CREATE TABLE SecretTable(a int NOT NULL)
CREATE TABLE OfficialTable(a int NOT NULL)
go
CREATE USER PlainUser WITHOUT LOGIN
GRANT SELECT ON OfficialTable TO PlainUser
go
EXECUTE AS USER = 'PlainUser'
go
DROP TABLE SecretTable
go
DROP TABLE OfficialTable
go
DROP TABLE NoSuchTable

-- This results in three error messages. Thus, PlainUser cannot dedude whether SecretTable exists or not.

DROP TABLE IF EXISTS SecretTable
go
DROP TABLE IF EXISTS OfficialTable
go
DROP TABLE IF EXISTS NoSuchTable
go

REVERT;
DROP USER PlainUser;
GO

DROP TABLE IF EXISTS SecretTable
go
DROP TABLE IF EXISTS OfficialTable
go
DROP TABLE IF EXISTS NoSuchTable
go






/* MS SQL DATEDIFF_BIG */

-- Using DATEDIFF
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT 
	DATEDIFF(WK , @StartDate, @EndDate) AS "Week diff"
	, DATEDIFF(DD , @StartDate, @EndDate) AS "Day diff"
	, DATEDIFF(HH , @StartDate, @EndDate) AS "Hour diff"
	, DATEDIFF(MI, @StartDate, @EndDate) AS "Minute diff"
	, DATEDIFF(SS, @StartDate, @EndDate) AS "Second diff"
	, DATEDIFF(MS, @StartDate, @EndDate ) AS "Millisecond diff"
	
-- DATEDIFF overflow
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT DATEDIFF(MCS, @StartDate, @EndDate ) AS "Microsecond diff"


-- Using DATEDIFF_BIG
DECLARE @StartDate DATETIME = GETDATE()
DECLARE @EndDate DATETIME = DATEADD(day, 1, @StartDate)

SELECT 
	DATEDIFF_BIG(WK , @StartDate, @EndDate) AS "Week diff"
	, DATEDIFF_BIG(DD , @StartDate, @EndDate) AS "Day diff"
	, DATEDIFF_BIG(HH , @StartDate, @EndDate) AS "Hour diff"
	, DATEDIFF_BIG(MI, @StartDate, @EndDate) AS "Minute diff"
	, DATEDIFF_BIG(SS, @StartDate, @EndDate) AS "Second diff"
	, DATEDIFF_BIG(MS, @StartDate, @EndDate ) AS "Millisecond diff"
	, DATEDIFF_BIG(MCS, @StartDate, @EndDate ) AS "Microsecond diff"
	, DATEDIFF_BIG(NS, @StartDate, @EndDate ) AS "Nanosecond diff"










/* MS SQL HASHBYTES */


USE [WideWorldImporters];
GO

-- Basic example
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value];
GO

-- All the hashing algorithms
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('MD2', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD2', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('MD4', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD4', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('MD5', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('MD5', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA1', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA1', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_256', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_256', @TestData)) AS [Data lenght];
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value], DATALENGTH(HASHBYTES ('SHA2_512', @TestData)) AS [Data lenght];
GO

-- No salt
DECLARE @TestData NVARCHAR(MAX) = 'My test data'
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', @TestData) AS [Hash value 2];

-- Different data types
SELECT HASHBYTES ('SHA2_512', N'Gin tonic') AS [Hash value 1];
SELECT HASHBYTES ('SHA2_512', 'Gin tonic') AS [Hash value 2];

-- Get hashes for customer invoices
USE [WideWorldImporters];
GO
SELECT TOP(100)
	C.CustomerID
	, HASHBYTES ('SHA2_512', (
		SELECT 
			*
		FROM 
			[Sales].[Invoices] I 
			INNER JOIN [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID
		WHERE 
			I.CustomerID = C.CustomerID 
		FOR JSON AUTO)
		) AS [Invoices hash]
FROM 
	[Sales].[Customers] C

-- Compare records with HASHBYTES
;WITH CTE AS(
	SELECT 1 AS ID, 'John' AS Name, NULL AS Address, '1979-03-14 17:20' AS BornOn UNION ALL
	SELECT 2 AS ID, 'Dan' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn UNION ALL
	SELECT 3 AS ID, 'John' AS Name, 'Coling street' AS Address, '1922-02-24 12:20' AS BornOn UNION ALL
	SELECT 4 AS ID, 'Carl' AS Name, 'Philadelphia street' AS Address, '1933-03-14 11:11' AS BornOn UNION ALL
	SELECT 5 AS ID, 'John' AS Name, NULL AS Address, '1979-03-14 17:20' AS BornOn UNION ALL
	SELECT 6 AS ID, 'Dan' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn UNION ALL
	SELECT 7 AS ID, 'DaN' AS Name, 'Unknown street' AS Address, '1973-05-12 00:20' AS BornOn
)
, CTEHash AS (
SELECT 
	ID
	, Name
	, Address
	, BornOn
	, (SELECT * FROM CTE WHERE CTE.ID = D.ID FOR JSON AUTO, INCLUDE_NULL_VALUES) AS JSON
	, HASHBYTES ('SHA2_512', (SELECT C.Name, C.Address, C.BornOn FROM CTE C WHERE C.ID = D.ID FOR JSON AUTO, INCLUDE_NULL_VALUES)) AS Hash
FROM
	CTE D
)
SELECT * FROM CTEHash ORDER BY Hash, ID;








