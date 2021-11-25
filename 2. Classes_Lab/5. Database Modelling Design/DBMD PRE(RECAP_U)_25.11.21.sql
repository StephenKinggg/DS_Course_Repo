
--SQL CASE INSESITIVE dir yani b�y�k k���k harften etkilenmez.

USE TestDB    --Yukar�da soldan DB se�meden bu commit ile direkt olarak o DB ye gitmemize yarar.

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employee](
	[EmployeeID] [int] NOT NULL,
	[EmployeeName] [varchar](255) NULL,
	[EmployeeSurName] [varchar](255) NULL,
	[EmployeeDepartment] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Students](
	[StudentID] [int] NOT NULL,
	[StudentName] [varchar](25) NULL,
	[Courses] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


/*
--Constraint ler;

Bir alan�n NULL, NOT NULL olmas� durumu,

DEFAULT olmas� durumu,(Yani bo� veya girilmemi�se bunun bir default de�eri olabilir.)

PRIMARY KEY, FOREIGN KEY 

CHECK (Mesela bir de�erden daha y�ksek bir de�er girilmemesini istiyor olabiliriz.)

UNIQUE(Tek bir de�er girilebilmesini istiyor olabiliriz.)
*/




CREATE TABLE Products(
ProductID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
ProductName VARCHAR(255) DEFAULT('Other Products'),
ProductPrice INT CHECK(ProductPrice >=0),
ProductDiscount INT CHECK(ProductDiscount <=0),
ProductSerialNumber INT,
UNIQUE(ProductSerialNumber)
)

CREATE TABLE SalesTable (
SalesID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
SalesHeader NVARCHAR(25),
CustomerBankType NVARCHAR(30)
)


/*SalesTable ve SalesDetailTable diye iki table olu�turduk. Bunlar� birbirine ba�lad�k. 
�kinci tabloya bir veri girdi�imizde ilk table da PRIMARY KEY k�sm�nda bu veri olmad��� durumlarda hata verir.
*/


CREATE TABLE SalesDetailTable(
SalesDetailID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
SalesID INT FOREIGN KEY REFERENCES SalesTable(SalesID),
ProductName VARCHAR(25),
Quantity INT,
Price INT,
LineNumber INT
)

--ALTER TABLE Table_Name ADD, DROP COLUMN, ALTER COLUMN ile de�i�iklik yapabiliyoruz.

ALTER TABLE dbo.Employee ADD UNIQUE(EmployeeName)   --EmployeeName Unique yapt�k. Bu durumda ayn� isimli bir ba�ka ki�i buraya girilemez.

ALTER TABLE dbo.Employee DROP COLUMN EmployeeDepartment  --Bu column table dan sildik.

ALTER TABLE dbo.Employee ALTER COLUMN EmployeeSurname VARCHAR(20)  --EmloyeeSurName veri tipini de�i�tirdik.


--DROP

DROP TABLE dbo.Employee

DROP DATABASE

--TRUNCATE TABLE: Hi� geri d�n��� olmadan table i�indeki t�m verileri siler. ROLL BACK yap�p veriyi geri �a��ramam art�k.

TRUNCATE TABLE dbo.SalesDetailTable

--DELETE TABLE: TRUNCATE ten fark� bu da veriyi siler ancak ROLL BACK ile geri �a��rabilirim.


--SELECT

SELECT * FROM [dbo].[SalesTable]  --Buradaki * ayn� zamanda wildcard i�levi g�r�yor. 

SELECT DD.[EmployeeName] AS 'FName', DD.[EmployeeSurName]  AS 'LName'
FROM [dbo].[Employee]  AS DD  --Burada g�r�ld��� gibi hem column ler i�in hem de table i�in Alias kulland�k.

--SELECT yan�na Aggregate func. da al�yor.

USE [AdventureWorks2014]

SELECT *
FROM [Sales].[SalesOrderDetail] A
WHERE A.UnitPrice>2000 AND A.OrderQty>1

SELECT *
FROM [Sales].[SalesOrderDetail] A
WHERE A.ProductID IN (777,753)    --WHERE A.ProductID=777 OR A.ProductID=753
							      --LIKE '%R%' Kullan�m� ile R i�erenleri verir.
								  --NOT LIKE 'R%' R ile ba�lamayanlar� verir.

--INSERT 

SELECT *
FROM [Person].[CountryRegion]

INSERT INTO  [Person].[CountryRegion] --E�ER T�M COLUMN LER ���N DE�ER G�RECEKSEK AYRI AYRI COLUMN �SM� YAZMAYA GEREK YOK. 
									 --AKS� TAKD�RDE COLUMN �S�MLER�N� BEL�RTMEK GEREK�R.
VALUES (XX, MACONA, 2008-04-30 00:00:00.000)


/*
 UPDATE Table_Name
 SET Column1='value1', Column2='value2' WHERE conditions
 */

 UPDATE [Person].[CountryRegion]
 SET Name='Andora' WHERE CountryRegionCode=1

CREATE TABLE [Orderr](
OrderID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
OrderNumber VARCHAR(25),
TotalAmount INT
)

CREATE TABLE Customer(
CustomerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
FirstName VARCHAR(25),
LastName VARCHAR(25),
City VARCHAR(25),
Country VARCHAR(25)
)

SELECT OrderID, FirstName, LastName, City, Country
FROM Orderr O JOIN Customer C ON O.CustomerID=C.CustomerID

CREATE TABLE RENK(
ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
C1 VARCHAR(25),
C2 VARCHAR(25),
C3 VARCHAR(25)
)

SELECT * FROM RENK
WHERE 'Yellow' IN (C1, C2, C3)

--DISTINCT 

SELECT DISTINCT StoreID
FROM [Sales].[Customer]
ORDER BY StoreID ASC   --DESC

SELECT *, FirstName+ ' '+ MiddleName+ ' ' + LastName AS Name,
		CAST((AccountKey AS VARCHAR) + AccountDescription) AS 'KEY' --BURADA CAST �LE AccountKey veri tipini VARCHAR �evirdik.
FROM [Person].[Person]

