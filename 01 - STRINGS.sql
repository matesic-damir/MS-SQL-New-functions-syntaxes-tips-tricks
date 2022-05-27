/* STRINGS */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* MS SQL STRING_SPLIT */
-- Get all ingredients for a mojito cocktail separated by comma 
SELECT value AS "Ingredients" FROM STRING_SPLIT(N'1 1/2 oz White rum,6 leaves of Mint,Soda Water,1 oz Fresh lime juice,2 teaspoons Sugar',',');

-- Get all ingredients for a mojito cocktail. There are two separators between the Mint and Soda with no text between
SELECT value AS "Ingredients" FROM STRING_SPLIT(N'1 1/2 oz White rum,6 leaves of Mint,,Soda Water,1 oz Fresh lime juice,2 teaspoons Sugar',',');

-- Split by two characters :(
SELECT value FROM STRING_SPLIT(N'Value 1..Value2..Value3','..');

-- Get all tags for stock items using CROSS APPLY (originally JSON)
USE WideWorldImporters;
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.value as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;

-- Get all Invoices that have at least one of the stock items in the list (WHERE IN)
DECLARE @StockItemIDs NVARCHAR(MAX) = N'68,121,54'
SELECT 
    IL.InvoiceID
FROM
    [Sales].[InvoiceLines] IL
WHERE
    EXISTS (SELECT 1 FROM STRING_SPLIT(@StockItemIDs, ',') WHERE CAST(value AS INT) = IL.StockItemID)
GROUP BY 
    IL.InvoiceID
ORDER BY 
    IL.InvoiceID;

-- Create the old test function
CREATE OR ALTER FUNCTION [dbo].[SplitString] (@Data NVARCHAR(MAX), @Delimiter NVARCHAR(5))
RETURNS @Table TABLE ( Data NVARCHAR(MAX) , ItemNo INT IDENTITY(1, 1))
AS
BEGIN

    DECLARE @TextXml XML;
    SELECT @TextXml = CAST('<d>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Data, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'), '''', '&apos;'), @Delimiter, '</d><d>') + '</d>' AS XML);

    INSERT INTO @Table (Data)
    SELECT Data = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(T.split.value('.', 'nvarchar(max)'))), '&amp;', '&'), '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&apos;', '''')
    FROM @TextXml.nodes('/d') T(Split)

    RETURN
END
GO

SELECT * FROM [dbo].[SplitString]('Gin and tonic', ' ');

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Turn on statistics
-- Discard results after execution
-- Enable Execution plan

-- 1. The old way using XML
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.Data as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY [dbo].[SplitString](REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;

-- 2. The new way using STRING_SPLIT
SELECT 
	SI.StockItemID
	, SI.StockItemName
	, SP.value as Tag
FROM 
	[Warehouse].[StockItems] SI
	CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(REPLACE(Tags,'[',''), ']',''), '"', ''), ',') SP;






/* MS SQL STRING_AGG */

-- Aggregate values
SELECT STRING_AGG(value, ' ') AS Result FROM (VALUES('Gin'),('and'),('tonic')) AS I(value);

-- Real database data - error
USE [WideWorldImporters];
-- Aggregate customer names
SELECT STRING_AGG(C.[CustomerName], ',') AS Result FROM [Sales].[Customers] AS C;

-- Aggregate customer names
SELECT STRING_AGG(CAST(C.[CustomerName] AS nvarchar(max)), ',') AS Result FROM [Sales].[Customers] AS C;

-- Aggregate NULL values
SELECT STRING_AGG(value, ' ') AS Result FROM (VALUES('Gin'),(NULL),('tonic')) AS I(value);

-- delimited invoiceID for every customerID in the table
SELECT
    [CustomerID]
    , STRING_AGG([InvoiceID], ',')  AS InvoicesList
FROM
    [Sales].[Invoices] I
GROUP BY
    [CustomerID]
ORDER BY
    [CustomerID] ASC;

-- delimited and sorted invoiceID for every customerID in the table with order by
SELECT
    [CustomerID]
    , STRING_AGG([InvoiceID], ',') WITHIN GROUP(ORDER BY [InvoiceID] DESC) AS InvoicesList
FROM
    [Sales].[Invoices] I
GROUP BY
    [CustomerID]
ORDER BY
    [CustomerID] ASC;

-- Performances
USE [WideWorldImporters];
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Turn on statistics
-- Discard results after execution
-- Enable Execution plan
 
-- 1. The old way using XML and STUFF
SELECT
C.[CustomerID]
, STUFF((
        SELECT
            ',' + CAST(I.[InvoiceID] AS NVARCHAR(MAX)) 
        FROM 
            [Sales].[Invoices] I
        WHERE
            I.[CustomerID] = C.[CustomerID]
        ORDER BY
            I.[InvoiceID] ASC
        FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'') AS InvoicesList
FROM
    [Sales].[Customers] AS C
ORDER BY
    C.[CustomerID] ASC;
 
-- 2. The new way using STRING_AGG for aggregation inside sub select (simmilar to the old way)
SELECT
    C.[CustomerID]
    , (
        SELECT
            STRING_AGG([InvoiceID], ',') WITHIN GROUP(ORDER BY [InvoiceID] ASC) AS InvoicesList
        FROM
            [Sales].[Invoices] I
        WHERE
            I.[CustomerID] = C.[CustomerID]
)
FROM
    [Sales].[Customers] AS C
ORDER BY
    C.[CustomerID] ASC;
 








/* MS SQL STRING_ESCAPE */

-- Example of STRING_ESCAPE
DECLARE @InputValue NVARCHAR(MAX) = N'
https://blog.matesic.info
C:\\MS SQL STRING ESCAPE
TAB:	';
SELECT STRING_ESCAPE(@InputValue,'JSON') AS Result;

-- Control character escape
SELECT STRING_ESCAPE(CHAR(7),'JSON') AS Result;

-- Escape of NULL value
SELECT STRING_ESCAPE(NULL,'JSON') AS Result;









/* MS SQL FORMATMESSAGE */
-- non elegant concatenation
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
SELECT @person_name + ' likes ' + @drink_name + '. Cheers!' AS Result;

-- one more variable of different type
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT @person_name + ' will order ' + CAST(@number_of_drinks AS nvarchar(max)) + 'x ' + @drink_name + '. Cheers!' AS Result;

-- NULL
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT @person_name + ' will order ' + CAST(@number_of_drinks AS nvarchar(max)) + 'x ' + @drink_name + '. Cheers!' AS Result;

-- Bullet proof solution :)
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT ISNULL(@person_name, '') + ' will order ' + ISNULL(CAST(@number_of_drinks AS nvarchar(max)), '') + 'x ' + ISNULL(@drink_name, '') + '. Cheers!' AS Result;

-- FORMATMESSAGE function
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT FORMATMESSAGE('%s will order %sx %s. Cheers!', @person_name, CAST(@number_of_drinks AS NVARCHAR(MAX)), @drink_name) AS Result;

-- NULL value
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT FORMATMESSAGE('%s will order %sx %s. Cheers!', @person_name, CAST(@number_of_drinks AS NVARCHAR(MAX)), @drink_name) AS Result;

-- Genertate drop statements for all user tables in database
USE [WideWorldImporters];
SELECT FORMATMESSAGE('DROP TABLE IF EXISTS [%s].[%s];', SCHEMA_NAME(schema_id), name) AS "Drop Statement" FROM sys.tables WHERE type = 'U';

















































/* MS SQL TRIM */
-- input value
DECLARE @StringValue nvarchar(max) = '  remove spaces from both sides of this string  ';
-- string with spaces
SELECT @StringValue AS Result UNION ALL
-- old way before introducing TRIM
SELECT LTRIM(RTRIM(@StringValue)) AS Result UNION ALL
-- new way with TRIM
SELECT TRIM(@StringValue) AS Result;



SELECT TRIM('a' from 'a sgdf a')










/* MS SQL TRANSLATE */

-- TRANSLATE replaces ) with (
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace :) with :(';
SELECT TRANSLATE(@StringValue, ')', '(') AS Result;

-- replace a character with an empty string
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace spaces with empty string.';
-- result of TRANSLATE
SELECT TRANSLATE(@StringValue, ' ', '.') AS Result;

-- the old way using replace
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace spaces with empty string.';
-- result of REPLACE
SELECT TRANSLATE(@StringValue, ' ', '') AS Result;

-- replace multiple characters (strings) at once
-- input value
DECLARE @StringValue nvarchar(max) = 'Replace all brackets with parentheses in [database].[schema].[table_name].';
-- result of TRANSLATE
SELECT TRANSLATE(@StringValue, '[]', '()') AS Result
-- implementation of REPLACE
SELECT REPLACE(REPLACE(@StringValue,'[','('), ']', ')') AS Result;

-- replace multiple characters (strings) at once
-- input value
DECLARE @StringValue nvarchar(max) = 'Raaaeplaccccce :( with ;)';
-- benefit of replace
SELECT TRANSLATE(@StringValue, 'ac(', 'fh!') AS Result;




/* MS SQL CONCAT vs CONCAT_WS */

/* CONCAT */

-- a minimum of two input values, otherwise, an error is raised
SELECT CONCAT('Damir') AS Result;

-- example
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = 'Gin and tonic';
DECLARE @number_of_drinks int = 3;
SELECT CONCAT(@person_name, ' will order ', @number_of_drinks, 'x ', @drink_name, '. Cheers!') AS Result;

-- NULL values
DECLARE @person_name nvarchar(max) = 'Damir';
DECLARE @drink_name nvarchar(max) = NULL;
DECLARE @number_of_drinks int = 3;
SELECT CONCAT(@person_name, ' will order ', @number_of_drinks, 'x ', @drink_name, '. Cheers!') AS Result;

-- Real example
USE [WideWorldImporters];
-- Genertate drop statements for all user tables in database
SELECT CONCAT('DROP TABLE IF EXISTS [', SCHEMA_NAME(schema_id), '].[', name, '];') AS "Drop Statement" FROM sys.tables WHERE type = 'U';

/* CONCAT_WS */

-- a minimum of three input values (a separator and two arguments), otherwise, an error is raised
SELECT CONCAT_WS(';', 'Value 1') AS Result;

-- Genertate CSV file with table names
USE [WideWorldImporters];
SELECT 'Schema name,Table name,Type desc' AS Result UNION ALL
SELECT CONCAT_WS(',', SCHEMA_NAME(schema_id), name, type_desc COLLATE database_default) FROM sys.tables WHERE type = 'U';

-- NULL values
USE [WideWorldImporters];
SELECT 'Schema name,Table name,Type desc' AS Result UNION ALL
SELECT CONCAT_WS(',', SCHEMA_NAME(schema_id), NULL, type_desc COLLATE database_default) FROM sys.tables WHERE type = 'U';

SELECT 'Schema name,Table name,Type desc' AS Result UNION ALL
SELECT CONCAT_WS(',', SCHEMA_NAME(schema_id), ISNULL(NULL, ''), type_desc COLLATE database_default) FROM sys.tables WHERE type = 'U';







































/* String or binary data would be truncated */

USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140;
GO
USE [WideWorldImporters];
GO
DROP TABLE IF EXISTS [dbo].[Data];
GO
CREATE TABLE Data(
	FirstName NVARCHAR(64) 
	, LastName NVARCHAR(6)
);

INSERT INTO Data(FirstName, LastName) VALUES ('Bob' , 'Marley'),('John' , 'Doe'),('Jack' , 'Daniels');
GO

USE [master];
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 150;
GO
USE [WideWorldImporters];
GO

INSERT INTO Data(FirstName, LastName) VALUES ('Bob' , 'Marley'),('John' , 'Doe'),('Jack' , 'Daniels');
GO
DROP TABLE IF EXISTS [dbo].[Data];
GO














/* UTF8 */

-- available UTF-8 collations
SELECT Name, Description FROM fn_helpcollations() WHERE Name LIKE '%UTF8';
GO



EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'UTF8';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'NONUTF8';
GO
USE [master];
GO

DROP DATABASE IF EXISTS [UTF8];
GO
DROP DATABASE IF EXISTS [NONUTF8];
GO
CREATE DATABASE [UTF8] COLLATE Latin1_General_100_CI_AS_SC_UTF8;
CREATE DATABASE [NONUTF8] COLLATE Latin1_General_100_CI_AS_SC;
GO

-- SQL2019 supports UTF8 collation -> SQL2019 поддерживает сопоставление UTF8

USE NONUTF8
GO

DECLARE @v VARCHAR(100) = 'SQL2019 поддерживает сопоставление UTF8';
SELECT @v AS String, DATALENGTH(@v) AS DataLengthValue;
DECLARE @nv NVARCHAR(100) = N'SQL2019 поддерживает сопоставление UTF8';
SELECT @nv AS String, DATALENGTH(@nv) AS DataLengthValue;
GO

USE UTF8;
GO

DECLARE @8v VARCHAR(100) = 'SQL2019 поддерживает сопоставление UTF8';
SELECT @8v AS String, DATALENGTH(@8v) AS DataLengthValue;
DECLARE @8nv NVARCHAR(100) = N'SQL2019 поддерживает сопоставление UTF8';
SELECT @8nv AS String, DATALENGTH(@8nv) AS DataLengthValue;
GO

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'UTF8';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'NONUTF8';
GO
USE [master];
GO

DROP DATABASE IF EXISTS [UTF8];
GO
DROP DATABASE IF EXISTS [NONUTF8];
GO