/* GREATEST() */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

SELECT GREATEST ( 3, 14, 1979 ) AS  "Greatest Value"; 
GO 
SELECT GREATEST ('John', N'Doe', 'The example') AS "Greatest String";  
GO  

-- Create test table and fill with data
DROP TABLE IF EXISTS dbo.TT;
GO

CREATE TABLE dbo.TT (
	ID INT IDENTITY(1,1) NOT NULL, CONSTRAINT [PK_TT] PRIMARY KEY CLUSTERED (ID ASC),
	Value1 INT,
	Value2 INT,
	Value3 INT
);
GO

INSERT INTO dbo.TT
(
	Value1,
	Value2,
	Value3
)
SELECT 
	Value1 = ABS(CHECKSUM(NEWID())) % 100000 
	, Value2 = ABS(CHECKSUM(NEWID())) % 100000 
	, Value3 = ABS(CHECKSUM(NEWID())) % 100000 
FROM 
	sys.columns;
GO

SELECT
	T.ID
	, GREATEST (T.Value1, T.Value2, T.Value3)  AS  "Greatest Value"
	, T.Value1
	, T.Value2
	, T.Value3
FROM 
	dbo.TT T;
GO 

DROP TABLE IF EXISTS dbo.TT;
GO

-- All expressions in the list of arguments must be of a data type that is comparable and that can be implicitly converted to the data type of the argument with the highest precedence.

SELECT GREATEST ( '3', '14', 1979 ) AS  "Greatest Value"; 
GO 

-- Implicit conversion of all arguments to the highest precedence data type takes place before comparison. If implicit type conversion between the arguments is not supported, the function will fail and return an error.

SELECT GREATEST ( '3', '14.', 1979 ) AS  "Greatest Value"; 
GO 
SELECT GREATEST ( 'aa', '14', 1979 ) AS  "Greatest Value"; 
GO 

-- If one or more arguments are not NULL, then NULL arguments will be ignored during comparison. If all arguments are NULL, then GREATEST will return NULL.

SELECT GREATEST ( 3, 14, NULL) AS  "Greatest Value"; 
GO 
SELECT GREATEST ( NULL, NULL, NULL) AS  "Greatest Value"; 
GO 

-- The following types are not supported for comparison in GREATEST: varchar(max), varbinary(max) or nvarchar(max) exceeding 8,000 bytes, cursor, geometry, geography, image, non-byte-ordered user-defined types, ntext, table, text, and xml.

DECLARE @LargeString NVARCHAR(MAX) = REPLICATE('A',4096);
SELECT GREATEST ( @LargeString, @LargeString, @LargeString) AS  "Greatest Value"; 
GO
DECLARE @XML XML = (SELECT * FROM sys.tables FOR XML AUTO)
SELECT GREATEST ( @XML, @XML, @XML) AS  "Greatest Value"; 
GO

/* LEAST() */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

SELECT LEAST( 3, 14, 1979 ) AS  "Least Value"; 
GO 
SELECT LEAST('John', N'Doe', 'The example') AS "Least String";  
GO  

-- Create test table and fill with data
DROP TABLE IF EXISTS dbo.TT;
GO

CREATE TABLE dbo.TT (
	ID INT IDENTITY(1,1) NOT NULL, CONSTRAINT [PK_TT] PRIMARY KEY CLUSTERED (ID ASC),
	Value1 INT,
	Value2 INT,
	Value3 INT
);
GO

INSERT INTO dbo.TT
(
	Value1,
	Value2,
	Value3
)
SELECT 
	Value1 = ABS(CHECKSUM(NEWID())) % 100000 
	, Value2 = ABS(CHECKSUM(NEWID())) % 100000 
	, Value3 = ABS(CHECKSUM(NEWID())) % 100000 
FROM 
	sys.columns;
GO

SELECT
	T.ID
	, LEAST(T.Value1, T.Value2, T.Value3)  AS  "Least Value"
	, T.Value1
	, T.Value2
	, T.Value3
FROM 
	dbo.TT T;
GO 

DROP TABLE IF EXISTS dbo.TT;
GO

-- All expressions in the list of arguments must be of a data type that is comparable and that can be implicitly converted to the data type of the argument with the highest precedence.

SELECT LEAST( '3', '14', 1979 ) AS  "Least Value"; 
GO 

-- Implicit conversion of all arguments to the highest precedence data type takes place before comparison. If implicit type conversion between the arguments is not supported, the function will fail and return an error.

SELECT LEAST( '3', '14.', 1979 ) AS  "Least Value"; 
GO 
SELECT LEAST( 'aa', '14', 1979 ) AS  "Least Value"; 
GO 

-- If one or more arguments are not NULL, then NULL arguments will be ignored during comparison. If all arguments are NULL, then Least will return NULL.

SELECT LEAST( 3, 14, NULL) AS  "Least Value"; 
GO 
SELECT LEAST( NULL, NULL, NULL) AS  "Least Value"; 
GO 

-- The following types are not supported for comparison in GREATEST: varchar(max), varbinary(max) or nvarchar(max) exceeding 8,000 bytes, cursor, geometry, geography, image, non-byte-ordered user-defined types, ntext, table, text, and xml.

DECLARE @LargeString NVARCHAR(MAX) = REPLICATE('A',4096);
SELECT LEAST( @LargeString, @LargeString, @LargeString) AS  "Least Value"; 
GO
DECLARE @XML XML = (SELECT * FROM sys.tables FOR XML AUTO)
SELECT LEAST( @XML, @XML, @XML) AS  "Least Value"; 
GO