--28.10.21

SELECT *
FROM t_date_time

SELECT GETDATE()

SELECT A_time, A_date, GETDATE()
		DATEDIFF(MINUTE, A_time, GETDATE()) AS minute_diff
		DATEDIFF(WEEK, A_TIME, '2011-11-30') AS week_diff
FROM t_date_time


SELECT DATEDIFF(DAY,shipped_date, order_date) DATE_DIFF, order_date,shipped_date  -- b�y�k olan� �nce yazmam�z gerekir.
FROM sale.orders

SELECT DATEDIFF(MONTH,shipped_date, order_date) DATE_DIFF, order_date,shipped_date  -- b�y�k olan� �nce yazmam�z gerekir.
FROM sale.orders


-- ABS mutlak de�eri al�yor.

SELECT ABS(DATEDIFF(DAY,order_date, shipped_date)) DATE_DIFF, order_date,shipped_date  -- k���k olan� yani yeni olan� �nce yazmam�z gerekir.
FROM sale.orders  

SELECT ORDER_DATE,
		DATEADD(YEAR, 5, order_date)  --order date 5 y�l ekledik. Bunlar tabloda bir de�i�iklik yapm�yor.
FROM sale.orders

SELECT ORDER_DATE,
		DATEADD(DAY, 10, order_date)  --order date 10 g�n ekledik.
FROM sale.orders


SELECT GETDATE(), DATEADD(HOUR, 5, GETDATE())  --�u andaki saate 5 saat ekledik.

--EOMONTH  ay�n son g�n�n� hesap etmek i�in kullan�l�yor.

SELECT EOMONTH(GETDATE()), EOMONTH(GETDATE(),2) --i�inde bulundu�umuz ay�n son g�n�n� bulduk. Bunun �zerine 2 ay ilave ettik.

-- ISDATE

SELECT ISDATE('2021-10-01')  --SONUC 1 �SE BU B�R DATE T�R. YOKSA 0 VER�R. VARCHAR OLAB�L�R. Bu tarih ise i�lem yap de�il ise tipini convert ile farkl� birtipe �evirebiliriz.

SELECT ISDATE('SELECT')

SELECT ISDATE('2021-10-01')  -- 0 d�nd�r�r ��nk� b�yle bir date tipi yani 13 ay yok,

----Orders tablosuna sipari�lerin teslimat h�z�yla ilgili bir alan ekleyin.

--Bu alanda e�er teslimat ger�ekle�memi�se 'Not Shipped',

--E�er sipari� g�n� teslim edilmi�se 'Fast',

--E�er sipari�ten sonraki iki g�n i�inde teslim edilmi�se 'Normal'

--2 g�nden ge� teslim edilenler ise 'Slow'

--olarak her bir sipari�i etiketleyin.

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
		WHEN DATEDIFF ( day, order_date, shipped_date) <3 THEN 'Normal'
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
WHERE DATEDIFF(day,order_date,shipped_date) >2

-- �nceki sonuca g�re g�nlere g�re da��l�m�n� g�sterelim.

SELECT *, DATENAME(weekday, order_date)
FROM sale.orders

SELECT CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 END AS MONDAY
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2  -- BUNUN �LE S�PAR���N VER�LD��� G�N�N PTES� OLANLARI ���N YAZDIK.

SELECT SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Monday' THEN 1 END) MONDAY,   --Buna g�re 
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Tuesday' THEN 1 END) TUESDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Wednesday' THEN 1 END) WEDNESDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Thursday' THEN 1 END) THURSDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Friday' THEN 1 END) FRIDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Saturday' THEN 1 END) SATURDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) ='Sunday' THEN 1 END) SUNDAY
FROM sale.orders
WHERE DATEDIFF(DAY,order_date,shipped_date) >2  -- BUNUN �LE S�PAR���N VER�LD��� G�N�N PTES� OLANLARI ���N YAZDIK.

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


--Question: Aylara g�re state lerin sipari� say�lar�n� d�nd�relim.

--STRING

SELECT LEN('WELCOME')

--CHARINDEX

SELECT CHARINDEX('C','CHARACTER') --�LK G�RD��� C Y� GET�R�R.

SELECT CHARINDEX('C','CHARACTER',2) --2.KARAKTERDEN SONRAK� C N�N YER�N� GET�R�R.

SELECT CHARINDEX('CT','CHARACTER') --B�RDEN FAZLA KARAKTER SORGULAYAB�L�R�Z ANCAK B�R PATERN SORGULAYAMAYIZ.

SELECT CHARINDEX('CT%','CHARACTER') --BURADA % ��ARET�N� B�R PATERN OLARAK DE��LDE B�R KARAKTER OLARAK ALGILIYOR.

--PATINDEX

SELECT PATINDEX('R', 'CHARACTER')

SELECT PATINDEX('R%', 'CHARACTER')

SELECT PATINDEX('%R%', 'CHARACTER')

SELECT PATINDEX('%R', 'CHARACTER')

SELECT PATINDEX('_R', 'CHARACTER')

SELECT PATINDEX('___R%', 'CHARACTER')

SELECT PATINDEX('%E%', 'CHARACTER')

SELECT PATINDEX('_______E%', 'CHARACTER') 

SELECT PATINDEX('%E_', 'CHARACTER') --E den �nce say�s�n� bilmedi�imiz kadar sonra ise bir karakter var.

--LEFT

SELECT LEFT ('CHARACTER', 3)

SELECT LEFT ('  CHARACTER', 3) -- BO�L�K OLUP OLMADI�INI BU �EK�LDE G�REB�L�R�Z.

RIGHT

SELECT RIGHT ('CHARACTER', 1)

SELECT RIGHT ('  CHARACTER', 3)

--SUBSTRING

SELECT SUBSTRING('CHARACTER', 1,3)  --1 DEN �T�BAREN 3 KARAKTER ALMAK �ST�YORUM.

SELECT SUBSTRING('CHARACTER', -1,3)  --�LK KARAKTER 1 DEN BA�LAR �NCES� 0 VE -1 D�YE DEVAM EDER.


