--REPLACE

SELECT REPLACE('CHARACTER STRING', ' ','/')

SELECT REPLACE(123123123555, 123, 88)


--STR

SELECT STR(5454)  --10 KARAKTERDEN AZ G�RERSEK KALAN BO�LUKLA DOLDURUR.

SELECT STR(5454,4)  --4 HANEL� GET�R�R.

SELECT STR(5454.475, 7)  --7 HANEL� �STED�K AMA NOKTADAN SONRASINI D�KKATE ALMADI.

SELECT STR(5454.475, 7, 3 ) --NOKTADAN SONRA NOKTA DAH�L KA� KARAKTER GET�RECE��M�Z� DE YAZDIK.

SELECT REPLACE(1232435464, 123, 'aha')+1

SELECT REPLACE(1232435464, 123, 123)+1

SELECT ISNUMERIC (REPLACE(1232435464, 123, 222))  --numeric ise 1 d�nd�r�r.

SELECT ISNUMERIC (REPLACE(1232435464, 123, 'aha'))  --numeric de�ilse 0 d�nd�r�r.


--CAST

SELECT CAST(123135 AS VARCHAR)

SELECT CAST(0.33333 AS NUMERIC(3,2)) --3 haneli rak�m 2 tanesi virg�lden sonra gelsin.

SELECT CAST(10.33333 AS NUMERIC(5,3)) 


--CONVERT

SELECT CONVERT(INT, 30.48)  --integer d�n��t�rd�.

SELECT CONVERT(DATETIME, '2021-10-10')  --datetime d�n��t�rd�.

SELECT CONVERT(VARCHAR, '2021-10-10', 6) --bunu �al��t�ramad�k sorun oldu.


--COALESCE

SELECT COALESCE(NULL, NULL, 'Ahmet', NULL) --return the first non null argument.



--NULLIF

SELECT NULLIF(10,10)  --ilk expression ikincisine e�it ise NULL getiriyor.

SELECT NULLIF(10,9)  --de�ilse ilkini getiriyor.


--ROUND

SELECT ROUND(432.368,2) --NOKTADAN SONRA �K� HANEYE YUVARLADI.

SELECT ROUND(432.368,3)

SELECT ROUND(432.368,2,1) -- �K�NC� ARG�MANI YAZMAZSAK DEFAULT OLARAK YUKARI YUVARLAR.

SELECT ROUND(432.368,1) --NOKTADAN SONRA B�R�NC� HANEDEN SONRASINI YUKARI YUVARLADI.

SELECT ROUND(432.364,1)


--QUEST�ON:

--How many yahoo mails in customers email column?Use Case Expression and Pathindex() function
-- Customer email s�tununda ka� tane yahoo maili var?

SELECT *
FROM sale.customer

SELECT email, PATINDEX('%@yahoo%', email) --yahoo varsa indeksini getiriyor yoksa 0 getiriyor.
FROM sale.customer

SELECT SUM(CASE WHEN PATINDEX('%@yahoo%', email) >0 THEN 1 ELSE 0 END) --yahoo varsa indeksini getiriyor yoksa 0 getiriyor.
FROM sale.customer



--2.Y�NTEM:

SELECT count(*)
FROM sale.customer
WHERE email LIKE '%@yahoo%'


--3. Y�ntem:

SELECT 
SUM(CASE WHEN PATINDEX('%@yahoo%', email) > 0 AND PATINDEX('%@yahoo%', email) IS NOT NULL THEN 1 ELSE 0 END) AS YAHOO
FROM sale.customer



-- QUESTION: 

--Write a query that returns the characters before the '.' character in the email column.
--Mail adresinde ilk noktaya kadar olan k�sm� al�n�z.

SELECT email, SUBSTRING(email, 1, CHARINDEX('.', email)-1 )
FROM sale.customer

--2.Y�ntem:

SELECT email, CHARINDEX('.', email)-1  --noktan�n indeksini bulduk ve bunu 1 azaltarak string ifadenin uzunlu�unu bulduk.
FROM sale.customer

SELECT email, LEFT(email, CHARINDEX('.', email)-1 )
FROM sale.customer

--Question: 
/*
--Add a new column to the customers table that contains the customers contact information. 
If the phone is not null, the phone information will be printed, if not, 
the email information will be printed.
*/
--Customer tablosundan contact bilgilerine bakarak e�erek tel bilgisi null de�ilse telefon bilgisini, e�er null ise email bilgisini getir.
--her m��teriye ula�abilece�im telefon veya email bilgisini istiyorum.
--M��terinin telefon bilgisi varsa email bilgisine gerek yok.
--telefon bilgisi yoksa email adresi ileti�im bilgisi olarak gelsin.
--beklenen s�tunlar: customer_id, first_name, last_name, contact

SELECT *, COALESCE(phone, email) as contact
FROM sale.customer


SELECT *
FROM sale.customer
WHERE email IS NULL   --email in null oldu�u de�er yok.

SELECT email, NULLIF(email, 'emily.brooks@yahoo.com')   --e�er email bu adres ise NULL yazd�r�yor. De�ilse emaili yaz�yor.
FROM sale.customer

SELECT *, COALESCE(phone, NULLIF(email, 'emily.brooks@yahoo.com'), 'a') contact
FROM sale.customer    --burada ise bu null de�erine a yazd�k.

SELECT *, COALESCE(phone, NULLIF(email, 'emily.brooks@yahoo.com')) contact --burada ilk emaili NULLIF ile NULL �evirdik. Phone da NULL oldu�undan dolay� contact NULL d�nd�.
FROM sale.customer



--Question:
--Write a query that returns streets. The third character of the streets is numerical.
--Street s�tununda soldan ���nc� karakterin rakam oldu�u kay�tlar� getiriniz.

SELECT street
FROM sale.customer

SELECT street, SUBSTRING(street, 3, 1)
FROM sale.customer

SELECT street, ISNUMERIC(SUBSTRING(street, 3, 1)) 
FROM sale.customer
WHERE ISNUMERIC(SUBSTRING(street, 3,1)) = 1

--2.y�ntem:

SELECT street, SUBSTRING(street, 3, 1)  --3.karakterde olan say�lar� getirdi bize.
FROM sale.customer
WHERE SUBSTRING(street, 3,1) LIKE '[0-9]'

--3.Y�NTEM

SELECT street, SUBSTRING(street, 3, 1)
FROM sale.customer
WHERE SUBSTRING(street, 3,1) NOT LIKE '[a-z]' --3.karakteri harf olmayanlar� yazd�rd�.

--4.y�ntem

SELECT street, SUBSTRING(street, 3, 1)
FROM sale.customer
WHERE SUBSTRING(street, 3, 1) NOT LIKE '[^0-9]' --'[^0-9]' aras�nda kalanlar�n d���nda olanlar demek. 


--WINDOW FUNCTIONS

--Question: 
--Write a query that returns stock amounts of products(only stock tabele)(Use both Group by and WF)
--Stock tablosundaki �r�nlerin stok miktarlar�n� getiriniz.


SELECT product_id  --3 farkl� ma�azada toplam 939 tane sat�r oldu�unu g�rd�k.
FROM product.stock


--Using Group By : 3 ma�azadaki de�erleri toplad� ve 313 sat�ra d��t�.

SELECT product_id, SUM(quantity) cnt_stock
FROM product.stock
GROUP BY product_id
ORDER BY product_id  --ORDER BY 1 kullan�labilir.



--2.y�ntem WF
-- Her bir �r�n� hangi ma�azada varsa o kadar olan miktar� getirdi. Ayr�ca toplam miktar�n�da getirdi.
-- Mevcut tablonun yan�n� grupland�rma yap�l�rsa ��kan sonucu ayr� bir s�tun olarak yan�na yaz�yor.

SELECT *, 
SUM(quantity) OVER (PARTITION BY product_id) total_stock
FROM product.stock

SELECT DISTINCT product_id,  --313 sat�ra d��t�.
SUM(quantity) OVER (PARTITION BY product_id) total_stock
FROM product.stock

--Question: 
--Write a query that returns what is the cheapest bike price.
--En ucuz bisiklet fiyat� nedir?

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


---Window Frames

SELECT	category_id, product_id,
		COUNT(*) OVER() NOTHING,
		COUNT(*) OVER(PARTITION BY category_id) countofprod_by_cat,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id) countofprod_by_cat_2,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) prev_with_current,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) current_with_following,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) whole_rows,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) specified_columns_1,
		COUNT(*) OVER(PARTITION BY category_id  ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_columns_2
FROM	product.product
ORDER BY category_id, product_id