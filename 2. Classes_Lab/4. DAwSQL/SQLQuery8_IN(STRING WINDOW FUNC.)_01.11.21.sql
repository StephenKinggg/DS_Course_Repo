--REPLACE

SELECT REPLACE('CHARACTER STRING', ' ','/')

SELECT REPLACE(123123123555, 123, 88)

--STR

SELECT STR(5454)  --10 KARAKTERDEN AZ G�RERSEK KALAN BO�LUKLA DOLDURUR.

SELECT STR(5454,4)  --4 HANEL� GET�R�R.

SELECT STR(5454.475, 7)  --7 HANEL� �STED�K AMA NOKTADAN SONRASINI D�KKATE ALMADI.

SELECT STR(5454.475, 7,3 ) --NOKTADAN SONRA NOKTA DAH�L KA� KARAKTER GET�RECE��M�Z� DE YAZDIK.

SELECT REPLACE(1232435464, 123, 'aha')

SELECT REPLACE(1232435464, 123, 123)+1

SELECT ISNUMERIC (REPLACE(1232435464, 123, 222))

SELECT ISNUMERIC (REPLACE(1232435464, 123, 'aha'))

--CAST

SELECT CAST(123135 AS VARCHAR)

SELECT CAST(0.33333 AS NUMERIC(3,2))


--CONVERT

SELECT CONVERT(INT, 30.48)

SELECT CONVERT(DATETIME, '2021-10-10')

SELECT CONVERT(VARCHAR, '2021-10-10', 6)

--COALESCE

SELECT COALESCE(NULL, NULL, 'Ahmet', NULL)

--NULLIF

SELECT NULLIF(10,9)

--ROUND

SELECT ROUND(432.368,2) --NOKTADAN SONRA �K� HANEYE YUVARLADI.

SELECT ROUND(432.368,3)

SELECT ROUND(432.368,2,1) -- �K�NC� ARG�MANI YAZMAZSAK DEFAULT OLARAK YUKARI YUVARLAR.

SELECT ROUND(432.368,1) --NOKTADAN SONRA B�R�NC� HANEDEN SONRASINI YUKARI YUVARLADI.

SELECT ROUND(432.364,1)

--QUEST�ON:

-- Customer email s�tununda ka� tane yahoo maili var?

SELECT 
SUM(CASE WHEN PATINDEX('%@yahoo%', email) > 0 AND PATINDEX('%@yahoo%', email) IS NOT NULL THEN 1 ELSE 0 END) AS YAHOO
FROM sale.customer

--2.Y�NTEM:

SELECT count(*)
FROM sale.customer
WHERE email LIKE '%@yahoo%'

--3. Y�ntem:

SELECT 
SUM(CASE WHEN PATINDEX('%@yahoo%', email) > 0 THEN 1 ELSE 0 END) AS YAHOO
FROM sale.customer

-- QUESTION: Mail adresinde ilk noktaya kadar olan k�sm� al�n�z.

SELECT email, SUBSTRING(email, 1, CHARINDEX('.', email)-1 )
FROM sale.customer

--2.Y�ntem:

SELECT email, LEFT(email,CHARINDEX('.', email)-1 )
FROM sale.customer

--Question: Customer tablosundan contact bilgilerine bakarak e�erek tel bilgisi null de�ilse telefon bilgisini, e�er null ise email bilgisini getir.

SELECT *, COALESCE(phone, email) as contact
FROM sale.customer

SELECT *
FROM sale.customer
WHERE email IS NULL   --email in null oldu�u de�er yok.

SELECT *, COALESCE(phone, NULLIF(email, 'emily.brooks@yahoo.com')) contact
FROM sale.customer

SELECT email, NULLIF(email, 'emily.brooks@yahoo.com')   --bu adresi NULL �evirdik.
FROM sale.customer

SELECT *, COALESCE(phone, NULLIF(email, 'emily.brooks@yahoo.com'), 'a') contact
FROM sale.customer    --burada ise bu null de�erine a yazd�k.

--Question:street s�tununda soldan ���nc� karakterin rakam oldu�u kay�tlar� getiriniz.

SELECT street
FROM sale.customer

SELECT street, ISNUMERIC(SUBSTRING(street, 3,1)) 
FROM sale.customer
WHERE ISNUMERIC(SUBSTRING(street, 3,1)) =1

--2.y�ntem:

SELECT street, SUBSTRING(street, 3,1)
FROM sale.customer
WHERE SUBSTRING(street, 3,1) LIKE '[0-9]'

--3.Y�NTEM

SELECT street, SUBSTRING(street, 3,1)
FROM sale.customer
WHERE SUBSTRING(street, 3,1) LIKE '[a-z]'

--4.y�ntem

SELECT street, SUBSTRING(street, 3,1)
FROM sale.customer
WHERE SUBSTRING(street, 3,1) LIKE '[^0-9]'

--WINDOW FUNCTIONS

--Question: Stock tablosundaki �r�nlerin stok miktarlar�n� getiriniz.


SELECT product_id
FROM product.stock

SELECT product_id
FROM product.stock
GROUP BY product_id

SELECT product_id, SUM(quantity) cnt_stock
FROM product.stock
GROUP BY product_id
ORDER BY 1

--2.y�ntem WF
-- Her bir �r�n� hangi ma�azada varsa o kadar olan miktar� getirdi. Ayr�ca toplam miktar�n�da getirdi.
-- PMevcut tablonun yan�n� grupland�rma yap�l�rsa ��kan sonucu ayr� bir s�tun olarak yan�na yaz�yor.

SELECT *, 
SUM(quantity) OVER (PARTITION BY product_id) total_stock
FROM product.stock

SELECT DISTINCT product_id,
SUM(quantity) OVER (PARTITION BY product_id) total_stock
FROM product.stock

--Question: En ucuz bisiklet fiyat� nedir?

SELECT *
FROM product.product

SELECT MIN(list_price)  --DISTINCT YAPTI.
FROM product.product

SELECT MIN(list_price) OVER ()   -- HERB�R SATIRIN KAR�ISINA BUNU EKLED�.
FROM product.product

--Herbir kategorideki en ucuz bisikletin fiyat�?

SELECT category_id, MIN(list_price) OVER(PARTITION BY category_id)
FROM product.product

SELECT DISTINCT category_id, MIN(list_price) OVER(PARTITION BY category_id)
FROM product.product

