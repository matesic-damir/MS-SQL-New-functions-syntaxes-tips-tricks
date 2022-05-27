/* MS SQL COMPRESS AND DECOMPRESS */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* COMPRESS */

-- One compress example
DECLARE @Input NVARCHAR(MAX) = N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam mollis maximus quam, quis malesuada felis sollicitudin eget. Nunc feugiat nisi et elit blandit, eget vulputate quam faucibus. Nullam vitae commodo nisi. Cras consequat sapien et urna malesuada rhoncus. Sed feugiat ornare ultricies. Nulla neque velit, tristique pretium erat ut, fermentum consequat nulla. Fusce pellentesque ornare lacus, tempor molestie libero tincidunt nec. Pellentesque ac purus mattis, semper sapien id, rhoncus elit. Morbi sagittis sapien sit amet condimentum mollis. Maecenas in mollis eros.'
SELECT COMPRESS(@Input) AS Compressed

-- Efficiency  
DECLARE @Input NVARCHAR(MAX) = N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam mollis maximus quam, quis malesuada felis sollicitudin eget. Nunc feugiat nisi et elit blandit, eget vulputate quam faucibus. Nullam vitae commodo nisi. Cras consequat sapien et urna malesuada rhoncus. Sed feugiat ornare ultricies. Nulla neque velit, tristique pretium erat ut, fermentum consequat nulla. Fusce pellentesque ornare lacus, tempor molestie libero tincidunt nec. Pellentesque ac purus mattis, semper sapien id, rhoncus elit. Morbi sagittis sapien sit amet condimentum mollis. Maecenas in mollis eros.'
SELECT
	DATALENGTH(@Input) AS "Original size"
	, DATALENGTH(COMPRESS(@Input)) AS "Compressed size"
	, CAST((DATALENGTH(@Input) - DATALENGTH(COMPRESS(@Input)))*100.0/DATALENGTH(@Input) AS DECIMAL(5,2)) AS "Compression rate"

-- Small string compression
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	DATALENGTH(@Input) AS "Original size"
	, DATALENGTH(COMPRESS(@Input)) AS "Compressed size"
	, CAST((DATALENGTH(@Input) - DATALENGTH(COMPRESS(@Input)))*100.0/DATALENGTH(@Input) AS DECIMAL(5,2)) AS "Compression rate"




































/*
-- Compare COMPRESS with ROW and PAGE compression
USE [WideWorldImporters];

DROP TABLE IF EXISTS [Sales].[OrderLines_Copy]

-- Test table
CREATE TABLE [Sales].[OrderLines_Copy]
(
	[OrderLineID] [int] NOT NULL,
	[Description] [nvarchar](256) NOT NULL
		CONSTRAINT [PK_Sales_OrderLines_Copy] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)
) 
GO

DROP TABLE IF EXISTS [Sales].[OrderLines_Compress]

-- Test table COMPRESS
CREATE TABLE [Sales].[OrderLines_Compress]
(
	[OrderLineID] [int] NOT NULL,
	[Description] [varbinary](max) NOT NULL
		CONSTRAINT [PK_Sales_OrderLines_Compress] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)
) 
GO


-- Insert test records
INSERT INTO [Sales].[OrderLines_Copy]
	([OrderLineID], [Description])
SELECT O1.[OrderLineID], FORMATMESSAGE('%s %s', O1.[Description], O2.[Description])
FROM [Sales].[OrderLines] O1 LEFT JOIN [Sales].[OrderLines] O2 ON O1.OrderLineID = O2.OrderLineID + 1;

INSERT INTO [Sales].[OrderLines_Compress]
	([OrderLineID], [Description])
SELECT O1.[OrderLineID], COMPRESS(FORMATMESSAGE('%s %s', O1.[Description], O2.[Description]))
FROM [Sales].[OrderLines] O1 LEFT JOIN [Sales].[OrderLines] O2 ON O1.OrderLineID = O2.OrderLineID + 1;
GO
*/

SELECT TOP(100) *
FROM [Sales].[OrderLines_Copy]
SELECT TOP(100) *
FROM [Sales].[OrderLines_Compress]
GO

-- NO Compression -> data 43200 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = NONE
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]';

-- ROW Compression -> data 22600 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = ROW
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]';

-- PAGE Compression -> data 22248 KB
ALTER TABLE [Sales].[OrderLines_Copy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)

EXEC sp_spaceused N'[Sales].[OrderLines_Copy]';

-- COMPRESS -> data 32656 KB
EXEC sp_spaceused N'[Sales].[OrderLines_Compress]';






/* XML DATA */
/*
DROP TABLE IF EXISTS [Sales].[OrderLines_XML]
DROP TABLE IF EXISTS [Sales].[OrderLines_XML_Compress]

SELECT
	A.[OrderLineID]
, CAST((SELECT D.*
	FROM [Sales].[OrderLines] D
	WHERE D.OrderLineID = A.OrderLineID
	FOR XML AUTO, ELEMENTS) AS XML) AS Details
INTO [Sales].[OrderLines_XML]
FROM
	[Sales].[OrderLines] A

SELECT
	A.[OrderLineID]
, COMPRESS(CAST((SELECT D.*
	FROM [Sales].[OrderLines] D
	WHERE D.OrderLineID = A.OrderLineID
	FOR XML AUTO, ELEMENTS) AS NVARCHAR(MAX))) AS Details
INTO [Sales].[OrderLines_XML_Compress]
FROM
	[Sales].[OrderLines] A
*/

SELECT TOP(100) * FROM [Sales].[OrderLines_XML]
SELECT TOP(100) * FROM [Sales].[OrderLines_XML_Compress]
GO

-- 156.544 KB
EXEC sp_spaceused N'[Sales].[OrderLines_XML]';
--  79.808 KB
EXEC sp_spaceused N'[Sales].[OrderLines_XML_Compress]';
GO



























/* DECOMPRESS */

-- Example
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	DECOMPRESS(COMPRESS(@Input)) AS "Decompressed value"

-- Example with cast
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS nvarchar(max)) AS "Decompressed value"

-- Example with change nvarchar to varchar (GRID and TEXT)
DECLARE @Input NVARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS varchar(max)) AS "Decompressed value"

-- Example with change from varchar to nvarchar
DECLARE @Input VARCHAR(MAX) = N'Damir like Gin and tonic!'
SELECT
	CAST(DECOMPRESS(COMPRESS(@Input)) AS nvarchar(max)) AS "Decompressed value"







-- Look at the execution times and Execution plan !!!
SELECT TOP(100) OrderLineID, Details
FROM [Sales].[OrderLines_XML];
SELECT TOP(100)  OrderLineID, CAST(DECOMPRESS(Details) AS XML) AS Details
FROM [Sales].[OrderLines_XML_Compress];

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT OrderLineID, Details
FROM [Sales].[OrderLines_XML] WHERE [OrderLineID] <= 10000;
SELECT OrderLineID, CAST(DECOMPRESS(Details) AS XML) AS Details
FROM [Sales].[OrderLines_XML_Compress] WHERE [OrderLineID] <= 10000;
GO



DROP TABLE [Sales].[OrderLines_XML];
DROP TABLE [Sales].[OrderLines_XML_Compress];
GO