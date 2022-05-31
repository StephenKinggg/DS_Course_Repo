---------- 25.10.2021 DAwSQL Session-5 (Date & String Functions)

--Date Functions
--Data Types

CREATE TABLE t_date_time
	(
	A_time time,
	A_date date,
	A_smalldatetime smalldatetime,
	A_datetime datetime,
	A_datetime2 datetime2,
	A_datetimeoffset datetimeoffset
	)


SELECT *
FROM t_date_time


--DATEDIFF

SELECT GETDATE() --�u anki local saati g�sterir.

SELECT GETDATE() as [now]

/*
INSERT t_date_time
VALUES(Getdate(), Getdate(), Getdate(), Getdate(), Getdate(), Getdate())
*/

SELECT GETDATE() as [now]  --dtypes datetime

SELECT CONVERT(Varchar, GETDATE(), 6)  --convert datetim to varchar.

SELECT CONVERT(DATE, '25 Oct 21', 6) --Convert varchar to date, 6 burada tipi ifade ediyor.

--Functions for return date or time parts

SELECT A_date
FROM t_date_time

SELECT A_date,
		DATENAME(DW, A_date) [DAY],
		DAY (A_date) [DAY2],
		MONTH (A_date) [month],
		YEAR (A_date) [year],
		DATEPART (WEEK, A_date) WEEKDAYS2,
		A_time,
		DATEPART (NANOSECOND, A_time),
		DATEPART (MONTH, A_date)
FROM t_date_time

***************************************

---------- 28.10.2021 DAwSQL Session-6 (Date & String Functions)

/*Soldaki Tables alt�nda yer alan dbo.t_date_time �zerine sa� t�klay�p 
Script Table As-Create To-New Query Editon Window yap�nca bize tablonun script getiriyor.

USE [SampleSales]
GO

/****** Object:  Table [dbo].[t_date_time]    Script Date: 31.05.2022 14:34:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[t_date_time](
	[A_time] [time](7) NULL,
	[A_date] [date] NULL,
	[A_smalldatetime] [smalldatetime] NULL,
	[A_datetime] [datetime] NULL,
	[A_datetime2] [datetime2](7) NULL,
	[A_datetimeoffset] [datetimeoffset](7) NULL
) ON [PRIMARY]
GO

*/

SELECT *
FROM t_date_time

SELECT A_time, A_date, GETDATE(),
		DATEDIFF(MINUTE, A_time, GETDATE()) AS minute_diff,
		DATEDIFF(WEEK, A_date, '2021-11-30') AS week_diff
FROM t_date_time


SELECT *
FROM sale.orders

SELECT DATEDIFF(DAY, shipped_date, order_date) DATE_DIFF, order_date, shipped_date  
FROM sale.orders

SELECT DATEDIFF(MONTH, order_date, shipped_date) DATE_DIFF, order_date,shipped_date  -- startdate olarak tarihi k���k olan� �nce yazmam�z gerekir. Aksi takdirde sonu� eksi ��kar.
FROM sale.orders

SELECT DATEDIFF(WEEK, order_date, shipped_date) DATE_DIFF, order_date, shipped_date
FROM sale.orders


-- ABS mutlak de�eri al�yor.

SELECT ABS(DATEDIFF(DAY, order_date, shipped_date)) DATE_DIFF, order_date, shipped_date  -- k���k olan� yani yeni olan� �nce yazmam�z gerekir.
FROM sale.orders  


----DATEADD

SELECT order_date,
		DATEADD(YEAR, 5, order_date) new_date  --order_date 5 y�l ekledik. Bunlar tabloda bir de�i�iklik yapm�yor.
FROM sale.orders

SELECT order_date,
		DATEADD(DAY, 10, order_date) cargo_date --order date 10 g�n ekledik.
FROM sale.orders


SELECT GETDATE(), DATEADD(HOUR, 5, GETDATE())  --�u andaki saate 5 saat ekledik.


--EOMONTH:  ay�n son g�n�n� hesap etmek i�in kullan�l�yor.

SELECT EOMONTH(GETDATE()), EOMONTH(GETDATE(), 2) --i�inde bulundu�umuz ay�n son g�n�n�n �zerine 2 ay ilave ettik.



-- ISDATE: Girdi�imiz de�er date ise 1, de�ilse 0 d�nd�r�r.

SELECT ISDATE('2021-10-01')  --SONUC 1 �SE BU B�R DATE T�R. YOKSA 0 VER�R. VARCHAR OLAB�L�R. Bu tarih ise i�lem yap de�il ise tipini convert ile farkl� birtipe �evirebiliriz.

SELECT ISDATE('SELECT')

SELECT ISDATE('2021-13-01')  -- 0 d�nd�r�r ��nk� b�yle bir date tipi yani 13 ay yok,


--Question:
--Orders tablosuna sipari�lerin teslimat h�z�yla ilgili bir alan ekleyin.

--Bu alanda e�er teslimat ger�ekle�memi�se 'Not Shipped',

--E�er sipari� g�n� teslim edilmi�se 'Fast',

--E�er sipari�ten sonraki iki g�n i�inde teslim edilmi�se 'Normal'

--2 g�nden ge� teslim edilenler ise 'Slow'

--olarak her bir sipari�i etiketleyin.

SELECT *
FROM sale.orders


WITH T1 AS 
(
SELECT *,
		DATEDIFF(DAY, order_date, shipped_date) shipped_fast
FROM sale.orders
)

SELECT order_date, shipped_date,
		CASE  --YEN� B�R ALAN OLU�TURMAYI CASE �LE YAPAB�L�R�M.
			WHEN shipped_fast IS NULL THEN 'Not Shipped'
			WHEN shipped_fast = 0 THEN 'Fast' --sipari� g�n� ile teslimat g�n� aras�ndaki fark 0 ise ayn� g�n teslim edilmi� demektir.
			WHEN shipped_fast <= 2 THEN 'Normal'
			WHEN shipped_fast > 2 THEN 'Slow'
		END AS order_label
FROM T1




--2.y�ntem:

select  order_id,  DATEDIFF ( day, order_date, shipped_date) DATE_DIFF,
		CASE
			WHEN shipped_date is null THEN 'Not Shipped'
			WHEN DATEDIFF ( day, order_date, shipped_date) = 0 THEN 'Fast'
			WHEN DATEDIFF ( day, order_date, shipped_date) <=2 THEN 'Normal'
			WHEN DATEDIFF ( day, order_date, shipped_date) > 2 THEN 'Slow'
		END AS Labels
from sale.orders


--3.y�ntem:

select order_id, order_date, shipped_date, 
case when shipped_date is null then 'Not Shipped'
	when datediff(day, order_date, shipped_date) = 0 then 'Fast'
	when datediff(day, order_date, shipped_date) >=1 and datediff(day, order_date, shipped_date) <=2 then 'Normal'
	when datediff(day, order_date, shipped_date) >=3 then 'Slow' end as Shipping_Time
from sale.orders


--Write a query returns orders that are shipped more than two days after the ordered date.
-- 2 g�nden ge� teslim edilen sipari� bilgilerini getiriniz. 


WITH T1 AS 
(
SELECT *,
		DATEDIFF(DAY, order_date, shipped_date) shipped_fast
FROM sale.orders
)

SELECT *,
		CASE  --YEN� B�R ALAN OLU�TURMAYI CASE �LE YAPAB�L�R�M.
			WHEN shipped_fast IS NULL THEN 'Not Shipped'
			WHEN shipped_fast = 0 THEN 'Fast' --sipari� g�n� ile teslimat g�n� aras�ndaki fark 0 ise ayn� g�n teslim edilmi� demektir.
			WHEN shipped_fast <= 2 THEN 'Normal'
			WHEN shipped_fast > 2 THEN 'Slow'
		END AS order_label
FROM T1
WHERE T1.shipped_fast > 2


--2.y�ntem:

SELECT *,
		DATEDIFF(DAY, order_date, shipped_date) shipped_fast
FROM sale.orders
WHERE DATEDIFF(day,order_date,shipped_date) >2 --Burada yukar�daki alias kullanamad�k ��nk� select from-where-groupby-having-select-orderby �eklindedir s�ralama.


--Write a query that returns the number distributions of the orders in the previous query result, according to the days of the week.
--Yukar�daki sipari�lerin haftan�n g�nlerine g�re da��l�m�n� g�sterelim.

SELECT order_date, DATENAME(weekday, order_date) [weekday]
FROM sale.orders
WHERE DATEDIFF(DAY, order_date, shipped_date)>2


SELECT order_date,
	CASE 
		WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 
		END MONDAY
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2 



SELECT	SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 END) MONDAY, 
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Tuesday' THEN 1 END) TUESDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Wednesday' THEN 1 END) WEDNESDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Thursday' THEN 1 END) THURSDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Friday' THEN 1 END) FRIDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Saturday' THEN 1 END) SATURDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Sunday' THEN 1 END) SUNDAY
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2



--A�a��daki ayr�mlara dikkat!!!!

SELECT SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 ELSE 0 END) AS MONDAY -- SUM 1 OLANLARI TOPLUYOR.
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2  


SELECT COUNT(CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 ELSE 0 END) AS MONDAY -- COUNT ��� DOLAN OLAN T�M SATIRLARI SAYAR.BURADA SATIRLARA 1 VE 0 YAZDIK.
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2  

SELECT COUNT(CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1  END) AS MONDAY -- BURADA MONDAY ���N 1 YAZDI�IMIZDAN COUNT ��� DOLAN OLAN T�M SATIRLARI SAYAR.BURADA 1 OLANLARI SAYDIK.
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2 


--2.Y�NTEM:

WITH T1 AS
(
SELECT	*, DATEDIFF(DAY, order_date, shipped_date) Delivery_Time_Day
FROM	sale.orders),
T2 AS
(
SELECT	*,
		CASE
		WHEN Delivery_Time_Day IS NULL THEN 'Not Shipped'
		WHEN Delivery_Time_Day = 0 THEN 'Fast'
		WHEN Delivery_Time_Day <= 2 THEN 'Normal'
		WHEN Delivery_Time_Day > 2 THEN 'Slow'
		END AS Order_Label
FROM	T1),
T3 AS(
SELECT	*
FROM	T2
WHERE	ORDER_LABEL = 'Slow'),
T4 AS(
SELECT	DATENAME(WEEKDAY, ORDER_DATE) DAY
FROM	T3)
SELECT	DAY, COUNT(T4.DAY)
FROM	T4
GROUP BY DAY


-- 3.y�ntem:

WITH T1 AS
(
SELECT	*, DATENAME(weekday, order_date) day_name
FROM	sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2 
)
SELECT day_name, count(day_name)
FROM T1
GROUP BY day_name




--Question: 
--Write a query that returns the order numbers of the states by months.
--Aylara g�re state lerin sipari� say�lar�n� d�nd�relim.

WITH T1 AS
(
SELECT	*, DATENAME(YEAR, order_date) years, DATEPART(MONTH, order_date) months
FROM	sale.orders
)

SELECT state, years, months, count(order_id) num_of_orders
FROM T1, sale.customer A
WHERE T1.customer_id=A.customer_id
GROUP BY months, state, years
ORDER BY state, years, months



-------String Functions

--LEN

SELECT LEN(1231354658)


SELECT LEN('WELCOME')


--CHARINDEX

SELECT CHARINDEX('C','CHARACTER') --�LK G�RD��� C Y� GET�R�R.

SELECT CHARINDEX('C','CHARACTER',2) --2.KARAKTERDEN SONRAK� C N�N YER�N� GET�R�R.

SELECT CHARINDEX('CT','CHARACTER') --B�RDEN FAZLA KARAKTER SORGULAYAB�L�R�Z ANCAK B�R PATERN SORGULAYAMAYIZ.

SELECT CHARINDEX('CT%','CHARACTER') --BURADA % ��ARET�N� B�R PATERN OLARAK DE��LDE C% OLARAK B�R KARAKTER ARAR. PATINDEX gibi kullanam�yoruz.


--PATINDEX

SELECT PATINDEX('R', 'CHARACTER')  --SADECE R OLARAK ARAYAMIYORUZ.

SELECT PATINDEX('R%', 'CHARACTER')  --R �LE BA�LAYAN OLARAK ARIYOR.

SELECT PATINDEX('%R%', 'CHARACTER')

SELECT PATINDEX('%R', 'CHARACTER')

SELECT PATINDEX('_R', 'CHARACTER')  --R DEN �NCE B�R KAREKTER VAR MI ARAR.

SELECT PATINDEX('___R%', 'CHARACTER')

SELECT PATINDEX('%E%', 'CHARACTER')

SELECT PATINDEX('_______E%', 'CHARACTER') 

SELECT PATINDEX('%E_', 'CHARACTER') --E den �nce say�s�n� bilmedi�imiz kadar sonra ise bir karakter var.


--LEFT

SELECT LEFT ('CHARACTER', 3)

SELECT LEFT ('  CHARACTER', 3) -- BO�L�K OLUP OLMADI�INI BU �EK�LDE G�REB�L�R�Z.


--RIGHT

SELECT RIGHT ('CHARACTER', 1)

SELECT RIGHT ('  CHARACTER', 3)


--SUBSTRING

SELECT SUBSTRING('CHARACTER', 1, 3)  --1 DEN �T�BAREN 3 KARAKTER ALMAK �ST�YORUM.

SELECT SUBSTRING('CHARACTER', -1, 3)  --�LK KARAKTER 1 DEN BA�LAR �NCES� 0 VE -1 D�YE DEVAM EDER. YAN� -1,0,1 OLMAK �ZERE 3 KAREKTER ALIR.

SELECT SUBSTRING('CHARACTER', 0, 1) -- BO� GELD� ��NK� SUBSTRING 1 DEN BA�LAR.



--LOWER

SELECT LOWER ('CHARACTER')

--UPPER

SELECT UPPER(LEFT('character', 1)) + LOWER(SUBSTRING('character', 2, LEN('character'))) -- + string ifadeleri yanyana birle�tirir.


--STRING_SPLIT
--- Bir tablo olu�turdu�undan kurall� yaz�l�r.

SELECT value 
FROM string_split('AL�,MEHMET,AY�E',',') --virg�lle ayr�lm�� olanlar� s�tun halinde yazar.



--TRIM iki taraftaki bo�luklar� yok eder ancak aradakilere dokunmaz.
--LTRIM soldaki bo�luklar� yok eder.
--RTRIM sa�daki bo�luklar� yok eder.

SELECT TRIM('  CHA  RACTER  ') --�K� TARAFTAK� BO�LU�U ATAR ANCAK ARADAK�LERE DOKUNMAZ.

SELECT LTRIM('  CHARACTER  ') --SOLDAK� BO�LUKLARI ATAR.

SELECT RTRIM('  CHARACTER  ')

SELECT TRIM('&' FROM '& CHARACTER %&') --HER �K� TARAFTAK� & ��ARET�N� ATTI.


