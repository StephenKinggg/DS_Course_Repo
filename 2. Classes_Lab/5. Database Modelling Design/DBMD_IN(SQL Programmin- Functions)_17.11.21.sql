--17.11.21 SQL Programming

CREATE PROCEDURE sp_sample1
AS
BEGIN

	SELECT 'HELLO WORLD' col1   --s�tun ismi verdik, i�ine sat�r olarak veriyi yazd�k. Begin-End aras�na yazd�k.

END

sp_sample1

EXEC sp_sample1

EXECUTE sp_sample1


ALTER PROCEDURE sp_sample1  --de�i�iklik yapt�k.
AS
BEGIN

	SELECT 'HELLO GUYS!' col1   --s�tun ismi verdik, i�ine sat�r olarak veriyi yazd�k. Begin-End aras�na yazd�k.

END

sp_sample1


CREATE TABLE ORDER_TBL
(
ORDER_ID TINYINT NOT NULL,
CUSTOMER_ID TINYINT NOT NULL,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE--estimated delivery date
);


INSERT ORDER_TBL VALUES (1, 1, 'Adam', GETDATE()-10, GETDATE()-5 ),
						(2, 2, 'Smith',GETDATE()-8, GETDATE()-4 ),
						(3, 3, 'John',GETDATE()-5, GETDATE()-2 ),
						(4, 4, 'Jack',GETDATE()-3, GETDATE()+1 ),
						(5, 5, 'Owen',GETDATE()-2, GETDATE()+3 ),
						(6, 6, 'Mike',GETDATE(), GETDATE()+5 ),
						(7, 6, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 7, 'Johnson',GETDATE(), GETDATE()+5 )

SELECT * FROM ORDER_TBL



CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- tamamlanan delivery date
);


SET NOCOUNT ON    --Mesaj k�sm�nda ka� sat�r�n etkilendi�ini yazd�rmamak i�in bu kullan�l�r.
INSERT ORDER_DELIVERY VALUES (1, GETDATE()-6 ),
				(2, GETDATE()-2 ),
				(3, GETDATE()-2 ),
				(4, GETDATE() ),
				(5, GETDATE()+2 ),
				(6, GETDATE()+3 ),
				(7, GETDATE()+5 ),
				(8, GETDATE()+5 )

SELECT * FROM ORDER_DELIVERY


CREATE PROC sp_cnt_order (@DATE DATE)  --Prosed�r parametresi girdik @ i�areti ile bunu parametre oldu�unu anl�yor.
AS
BEGIN
	
	SELECT COUNT(ORDER_ID) TOTAL_ORDER FROM ORDER_TBL WHERE ORDER_DATE = @DATE    --istedi�im bir tarihteki sipari� miktar�n� bulmak i�in girdi�im prosed�r parametresini order_date e�itliyorum.
END


sp_cnt_order '2021-11-17'  --prosed�r� �a��r�nca i�ine arg�man� girdim ve bu tarihteki sipari� say�s� getirdi.

--***parametre prosed�r yan�nda �retilirse �a��r�rken i�ine de�er alabilir. i�eride �retilirse i�ine de�er almaz.

DECLARE @P1 INT, @P2 INT, @SUM INT

SET @P1 = 3

SELECT @P2 = 7 --SELECT ile hem de�er atayabilir hemde toplam�n� �a��rabiliriz.

SET @SUM = @P1+@P2

SELECT @SUM   --KODU B�T�N OLARAK �A�IRAB�L�R�Z.

SELECT @P1 = 3, @P2 = 7 , @SUM = @P1 +@P2

DECLARE @P1 INT = 3 , @P2 INT = 7, @SUM  INT = @P1 +@P2

--
DECLARE @P3 INT =5 , @P4 INT = 7

PRINT @P3 +@P4

----

DECLARE @CUSTOMER VARCHAR(100)

SET @CUSTOMER ='Adam'

SELECT *
FROM ORDER_TBL
WHERE CUSTOMER_NAME=@CUSTOMER

-- IF-ELSE
-- KODU B�T�N OLARAK �ALI�TIRALIM!!!
DECLARE @CUST INT

SET @CUST=5

IF @CUST=3   --IF �LE MUTLAKA BEGIN END KULLANILIR ANCAK BU ARAYA GELECEK OLAN TEK SATIRDA YAZILMI� �SE BEGIN END KULLANMAYA GEREK YOK. ANCAK HER�EYE RA�MEN KULLANMAKTA FAYDA VAR.
	BEGIN 

		SELECT * FROM ORDER_TBL WHERE CUSTOMER_ID=@CUST
	END
ELSE IF @CUST =4   --ELSE IF �LEDE BEGIN END KULLANMAMIZ GEREK�R.
	BEGIN
		SELECT * FROM ORDER_TBL WHERE CUSTOMER_ID=@CUST
	END
ELSE
	PRINT('The number not equal to 3 or 4')


SELECT *
FROM ORDER_TBL
WHERE CUSTOMER_ID=3


--WHILE

DECLARE @NUM INT=1

WHILE @NUM < 50  --BEGIN VE END ARASINA YAZILIR.
	BEGIN
		SELECT @NUM
		SET @NUM +=1
	END


--FUNCTIONS

CREATE FUNCTION fn_uppertext1
(@inputtext VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	RETURN UPPER(@inputtext)

END

SELECT dbo.fn_uppertext1('WELCOME')   --FUNC schema ad� ile �a��rmam�z gerekiyor.


SELECT dbo.fn_uppertext1(CUSTOMER_NAME) FROM ORDER_TBL --HEPS�N� B�Y�K HARF YAPTI.


CREATE FUNCTION fn_date_info
(@DATE DATE)
RETURNS TABLE  --BURADA TABLO DE���KEN� OLU�TURMUYORSAK BEGIN END YAZMIYORUZ.
AS
	RETURN SELECT * FROM ORDER_TBL WHERE ORDER_DATE = @DATE

SELECT * FROM fn_date_info('2021-11-17')  --TABLO D�ND�RD��� ���N BU �EK�LDE �A�IRDIK. 

--AYNI VIEW G�B� SANAL TABLO OLARAK D���NEB�L�R�Z. FUNC OBJECT OLARAK KAYDED�L�YOR. SONRA TEKRAR TEKRAR KULLANAB�L�YORUZ.

