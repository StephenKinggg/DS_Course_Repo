Date types
Oct 25th
*/

SELECT GETDATE();

CREATE TABLE t_date_time (
	A_time time,
	A_date date,
	A_smalldatetime smalldatetime,
	A_datetime datetime,
	A_datetime2 datetime2,
	A_datetimeoffset datetimeoffset
	)

SELECT * FROM t_date_time;

INSERT INTO t_date_time (
  [A_time]
, [A_date]
, [A_smalldatetime]
, [A_datetime]
, [A_datetime2]
, [A_datetimeoffset])
VALUES (
GETDATE(),
GETDATE(),
GETDATE(),
GETDATE(),
GETDATE(),
GETDATE()
)

INSERT INTO t_date_time (
  [A_time]
, [A_date]
, [A_smalldatetime]
, [A_datetime]
, [A_datetime2]
, [A_datetimeoffset])
VALUES (
'12:00:00',
'2021-10-25',
'2021-10-25',
'2021-10-25',
'2021-10-25',
'2021-10-25'
)

SELECT *
FROM sale.orders

SELECT  order_id, 
		order_date,
		CONVERT(CHAR(20),order_date,6),
		DATENAME(DW,order_date) + ' ' + ---https://docs.microsoft.com/en-us/sql/t-sql/functions/datename-transact-sql?view=sql-server-2017
		DATENAME(DD,order_date) + ' ' +
		DATENAME(MM,order_date) + ' ' +
		DATENAME(YY,order_date)
FROM sale.orders


SELECT	order_id, 
		order_date, 
		GETDATE() get_date,   --bug�n�n tarihini ald�k.
		DATEDIFF(DD, order_date, GETDATE()) now_order_day,   --orderdan bug�ne ka� g�n olmu�.
		DATEDIFF(YY, order_date, GETDATE()) now_order_year,   --order y�l�ndan bu g�ne ka� y�l olmu�.
		DATEADD(YY,DATEDIFF(YY, order_date, GETDATE()), order_date) order_date_dated�ff,   --order date �zerine order y�l�ndan bug�ne ge�en y�l� ilave ettik.
		CASE 
			WHEN DATEADD(YY,DATEDIFF(YY, order_date, GETDATE()), order_date) >   --e�er yukar�daki buldu�umuz de�er bug�nden b�y�kse y�l say�s�n� bir azalltt�k 
				GETDATE()
			THEN DATEDIFF(YY, order_date, GETDATE()) -1
			ELSE DATEDIFF(YY, order_date, GETDATE())
		END
FROM sale.orders
