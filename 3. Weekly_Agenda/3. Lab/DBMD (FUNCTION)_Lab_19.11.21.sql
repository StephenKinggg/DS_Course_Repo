
--Sipari�leri, tahmini teslim tarihleri ve ger�ekle�en teslim tarihlerini k�yaslayarak
--'Late','Early' veya 'On Time' olarak s�n�fland�rmak istiyorum.
--E�er sipari�in ORDER_TBL tablosundaki EST_DELIVERY_DATE' i (tahmini teslim tarihi) 
--ORDER_DELIVERY tablosundaki DELIVERY_DATE' ten (ger�ekle�en teslimat tarihi) k���kse
--Bu sipari�i 'LATE' olarak etiketlemek,
--E�er EST_DELIVERY_DATE>DELIVERY_DATE ise Bu sipari�i 'EARLY' olarak etiketlemek,
--E�er iki tarih birbirine e�itse de bu sipari�i 'ON TIME' olarak etiketlemek istiyorum.





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
						(7, 7, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 8, 'Johnson',GETDATE(), GETDATE()+5 )



CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- tamamlanan delivery date
);
SET NOCOUNT ON
INSERT ORDER_DELIVERY VALUES (1, GETDATE()-6 ),
				(2, GETDATE()-2 ),
				(3, GETDATE()-2 ),
				(4, GETDATE() ),
				(5, GETDATE()+2 ),
				(6, GETDATE()+3 ),
				(7, GETDATE()+5 ),
				(8, GETDATE()+5 )

SELECT * 
FROM ORDER_TBL

SELECT *
FROM ORDER_DELIVERY

--order_id   input olacak
--etiket/stat�    output olacak
--tahmini teslim tarihi ile ger�ekle�en teslim tarihleri aras�ndaki fark



CREATE FUNCTION dbo.fn_statuoforders (@order_id INT)              --parametre giriyorum

RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @ORDER_STATUS VARCHAR(10)   --3 TANE DE���KEN TANIMLADIM
	DECLARE @EST_DEL_DATE DATE             --BU PARAMETREN�N B�R DE�ER ALMASI GEREK�YOR.
	DECLARE @DEL_DATE DATE

	SELECT	@EST_DEL_DATE = EST_DELIVERY_DATE
	FROM	ORDER_TBL
	WHERE	ORDER_ID = @order_id        --burada order_id ye g�re bu de�erler de�i�ecek. sabit bir tarihe g�re de�il de order_id ye g�re i�lem yapmas�n� istiyoruz.

	SELECT	@DEL_DATE = DELIVERY_DATE
	FROM	ORDER_DELIVERY
	WHERE	ORDER_ID = @order_id        --bu iki i�lem ile girdi�im her bir order_id i�in bir est_del_date ve del_date atayacak. Sonra bunlar� birbiri ile kar��la�t�rmam gerekir.

	IF @EST_DEL_DATE < @DEL_DATE
		BEGIN
			SET @ORDER_STATUS = 'LATE'     --TEK B�R SATIR YAZIYORSAK BEGIN-END YAZMAYA GEREK YOK.
		END
	ELSE IF @EST_DEL_DATE > @DEL_DATE
		BEGIN
			SET @ORDER_STATUS = 'EARLY'
		END
	ELSE
		BEGIN
			SET @ORDER_STATUS = 'ON TIME'
		END
	RETURN @ORDER_STATUS
END


SELECT *,dbo.fn_statuoforders(ORDER_ID) FROM ORDER_DELIVERY

SELECT * FROM ORDER_TBL WHERE dbo.fn_statuoforders(ORDER_ID) = 'ON TIME'


CREATE TABLE ON_TIME_TABLE   --SADECE ZAMANINDA TESL�M ED�LEN S�PAR��LER ���N B�R TABLE OLU�TURACA�IZ.
(
ORDER_ID INT,
ORDER_STATUS VARCHAR(10),
CONSTRAINT check_status CHECK (dbo.fn_statuoforders(ORDER_ID) = 'ON TIME')

  --column constraint// ��ER�S�NE YAZILAN CONSTRAINT SA�LANIP SA�LANMADI�INA BAKIYOR. ORDER_ID STATUSU ONTIME �SE BU ORDER_ID KABUL EDECEK.
)


SELECT * FROM ON_TIME_TABLE

SELECT * FROM ORDER_TBL

INSERT ON_TIME_TABLE VALUES(5,'ON TIME')  --ORDER_ID Y� DE���T�REREK HANG�LER�N� INSERT ED�P ETMED���NE BAKAB�L�R�Z. HATALI OLAN ���N UYARI VER�R.

--CONSTRAINT LER TABLE ���NE ALACA�IMIZ VER�LER�N UYGUN OLUP OLMADI�INI DENETL�YOR. AYRICA NOT NULL, UNIQUE G�B� OLANLARDA CONSTRAINTLERD�R. 
--AYRICA FK �SE REFERANS ALINAN TABLODAK� DE�ERLER�N DAH�L ED�L�P ED�LEMEYECE��N� BEL�RLER.
--PK DA AYRI B�R CONSTRAINT TIR.



--TABLE VALUED FUNCTION

--Zaman�nda teslim edilen sipari�lerin order_tbl tablosundaki bilgilerini d�nd�ren bir fonksiyon yaz�n�z.

CREATE FUNCTION dbo.fn_on_time_orders (@ORDER_ID INT)
RETURNS @table1 TABLE  --B�R TABLE VALUE OLDU�UNDAN DOLAYI TABLE TARZINDA B�R YAPI D�ND�RMES� LAZIM SONU�TA. TABLE OLACA�INDAN DOLAYI S�TUNLARINI BEL�RLEMEK GEREK�R.
(
ORDER_ID TINYINT,
CUSTOMER_ID TINYINT,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE
)
AS
	BEGIN
		IF EXISTS (SELECT 1 FROM ON_TIME_TABLE WHERE ORDER_ID = @ORDER_ID)  --G�RD���M HERHANG� B�R ORDERID ON_TIME_TABLE ORDER ID �LE AYNI MI DE��L M�?
			BEGIN
				INSERT @table1
				SELECT * FROM ORDER_TBL WHERE ORDER_ID = @ORDER_ID
			END
	RETURN
END 


SELECT * FROM dbo.fn_on_time_orders(2)   --2 ve 5 i�in insert yapmad�.