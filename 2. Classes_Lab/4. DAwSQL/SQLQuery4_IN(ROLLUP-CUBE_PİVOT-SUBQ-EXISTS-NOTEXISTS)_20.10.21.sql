-----///    2021-10-20 DAwSQL Session 3 (Organize Complex Queries)


--- FROM THE LAST SESSION

DROP TABLE IF EXISTS sale.sales_summary;

--Summary Table

SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year,
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary
FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year


-- ROLLUP

--brand, category, model_year s�tunlar� i�in Rollup kullanarak total sales hesaplamas� yap�n.
--�� s�tun i�in 4 farkl� gruplama varyasyonu �retmek istiyoruz.

SELECT *
FROM sale.sales_summary

SELECT brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM sale.sales_summary
GROUP BY
		ROLLUP(brand, Category, Model_Year)

--brand, category, model_year s�tunlar� i�in cube kullanarak total sales hesaplamas� yap�n.

--�� s�tun i�in 8 farkl� gruplama varyasyonu olu�turuyor	



SELECT	brand, Category, Model_Year, SUM(total_sales_price) total_price
FROM	sale.sales_summary
GROUP BY
		CUBE (brand, Category, Model_Year)
ORDER BY
		brand, Category


--PIVOT 


-- �SE TEK SATIR YAZMAK ���N.
/* BUNLARIN ARASINA B�RKA� SATIR YORUM YAZMAK �STERSEK KULLANILIR. 
SH�FT TU�UNA UZUN BASIP A�A�I YUKARI GED�B�L�R�Z.*/


SELECT *
FROM sale.sales_summary

--Kategorilere ve model y�l�na g�re toplam sales miktar�n� summary tablosu �zerinden toplayal�m.

SELECT Category, Model_Year, SUM(total_sales_price) Total_Prices
FROM sale.sales_summary
GROUP BY Category, Model_Year
ORDER BY 1,2 --SELECT TEK� B�R�NC� VE �K�NC� S�TUNA G�RE. GROUP BY DA BU �ZELL�K YOK.

--Kaynak tablom a�a��daki gibidir.

SELECT Category, Model_Year, total_sales_price
FROM	SALE.sales_summary

SELECT *
FROM
	(
	SELECT Category, Model_Year, total_sales_price --Bunu burada yazmassak yukar�da SELECT sonras� yazmam�z gerekir.
	FROM	SALE.sales_summary  --Kaynak table
	) A
PIVOT
	(
	SUM(total_sales_price) --aggregate func.
	FOR Category           --category s�tunu.
	IN (                   --category alt�ndaki alt kategorileri [] i�inde yazd�m.
		[Children Bicycles],  --Shift + tab ile geri, tab ile ileri.
		[Comfort Bicycles],
		[Cruisers Bicycles],
		[Cyclocross Bicycles],
		[Electric Bikes],
		[Mountain Bikes],
		[Road Bikes]
		)
	) AS P1

-- MODEL YILLARINA G�RE

SELECT *
FROM
	(
	SELECT Category, Model_Year, total_sales_price
	FROM	SALE.sales_summary
	) A
PIVOT
	(
	SUM(total_sales_price)
	FOR model_year
	IN (
	[2018], [2019], [2020]
		)
	) AS P1


-- SUBQUERIES
--Write a query that returns the total list price by each order ids.
--order id lere g�re toplam list price lar� hesaplayal�m.

--Toplam list_price getirip her order_id nin yaz�na yazd�.

SELECT *
FROM sale.order_item


SELECT order_id,
	(SELECT SUM(list_price) FROM sale.order_item)
FROM sale.order_item

--Correlated Subquery
--A�a��da outer query ile inner queryden se�ti�im order_id de�erlerini birbirine e�itledim.

SELECT DISTINCT order_id,
		(SELECT SUM(list_price) FROM sale.order_item B WHERE A.order_id = B.order_id) SUM_PRICE
FROM	sale.order_item A

--Yukar�dakini GROUP BY ile yapt�k.

SELECT order_id, SUM(list_price)
FROM sale.order_item
GROUP BY order_id

--Bring all the staff from the store that Maria Cussona works.
--Maria Cussona n�n cal��t��� ma�azadaki t�m personelleri listeleyin.

SELECT *
FROM sale.staff


--Inner queryden d�nen sonu� single row oldu�undandolay� outer query da = kulland�k.
SELECT *
FROM sale.staff
WHERE store_id = (
					SELECT store_id
					FROM sale.staff A
					WHERE A.first_name='Maria' AND A.last_name='Cussona'
				)

--List the staff that Jane Destrey is the manager of.
--Jane Destreyin manageri oldu�u ki�ileri bulal�m.

SELECT *
FROM sale.staff

SELECT *
FROM sale.staff
WHERE manager_id = (
					SELECT staff_id
					FROM sale.staff 
					WHERE first_name='Jane' AND last_name='Destrey'
				)


/* Bazi arkadaslar goruyorum sorguda �Jane� yerine �jane� kullanmis. 
Default olarak SQL Server case-insensitive oldugu icin problem olmuyor. 
Ama database olustururken istersek �COLLATION� ile case-sensitive bir 
database olusturabiliriz. Bu da benden bir interview sorusu..*/

--Write a query that returns customers in the city where the"Sacramento Bikes" store is located.


SELECT *
FROM sale.customer
WHERE city = (
				SELECT DISTINCT city
				FROM sale.store A INNER JOIN sale.orders B ON A.store_id=B.store_id
				WHERE store_name='Sacramento Bikes'
			 )

-- List customers whose order dates are before Arla Ellis.

SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A INNER JOIN sale.customer B ON A.customer_id=B.customer_id
WHERE A.order_date < (
						SELECT order_date
						FROM sale.orders A INNER JOIN sale.customer B ON A.customer_id=B.customer_id
						WHERE A.customer_id = (
												SELECT customer_id
												FROM sale.customer
												WHERE first_name='Arla' and last_name='Ellis'
						))


--Multiple Row Subqueries

--List order dates for customers residing in the Holbrok city.
--Holbrok �ehrinde oturan m��terilerin sipari� tariherini listeleyin.



SELECT *
FROM sale.customer
WHERE city='Holbrook'



SELECT *
FROM sale.orders
WHERE customer_id IN (SELECT customer_id
					  FROM sale.customer
					  WHERE city='Holbrook'
					  )

--List all customers who orders on the same dates as Abby Parks.
-- Abby	Parks isimli m��terinin al��veri� yapt��� tarihte/tarihlerde al��veri� yapan t�m m��terileri listeleyin.
-- M��teri ad�, soyad� ve sipari� tarihi bilgilerini listeleyin.


SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A INNER JOIN sale.customer B ON A.customer_id=B.customer_id
WHERE A.order_date IN (
						SELECT order_date
						FROM sale.orders A INNER JOIN sale.customer B ON A.customer_id=B.customer_id
						WHERE A.customer_id = (
												SELECT customer_id
												FROM sale.customer
												WHERE first_name='Abby' and last_name='Parks'
						))


--Abby nin sipari� verdi�i tarihler

SELECT *
FROM sale.customer A
INNER JOIN sale.orders B ON A.customer_id=B.customer_id
WHERE A.last_name='Parks' AND A.first_name='Abby'


SELECT C.first_name, C.last_name, A.order_id, A.order_date
FROM sale.orders A
INNER JOIN (SELECT A.first_name,A.last_name,B.customer_id,B.order_id,B.order_date
			FROM sale.customer A
			INNER JOIN sale.orders B ON A.customer_id=B.customer_id
			WHERE A.last_name='Parks' AND A.first_name='Abby') B
ON A.order_date=B.order_date
INNER JOIN sale.customer C ON A.customer_id=C.customer_id

--List bikes that model year equal to 2020 and its prices more than all electric bikes.
--B�t�n elektrikli bisikletlerden pahal� olan bisikletleri listeleyin.
--�r�n ad�, model y�l� ve fiyat bilgilerini y�ksek fiyattan d���k fiyata do�ru listeleyelim.

/*
ALL ile inner query i�indeki fiyatlardan daha b�y�k olanlar� al demek istiyoruz. 4999 dan b�y�k olanlar� getirir.
ANY ile inner query i�indeki fiyatlardan en d���k olandan fazla olanlar� al�r. 1599 dan b�y�k olanlar� getirir.
*/

SELECT product_name, model_year, list_price
FROM product.product
WHERE list_price > ALL (
						SELECT	list_price
						FROM	product.product A INNER JOIN product.category B ON A.category_id = B.category_id
						WHERE	B.category_name = 'Electric Bikes')
AND model_year = 2020
					


SELECT product_name, list_price
FROM product.product
WHERE list_price > ANY (
						SELECT	list_price
						FROM	product.product A INNER JOIN product.category B ON A.category_id = B.category_id
						WHERE	B.category_name = 'Electric Bikes')	
AND model_year = 2020


/* EXIST ve NOT EXIST i�teki tablonun ne d�nd�rd��� ile 
de�il d�nd�r�p d�nd�rmedi�i ile ilgileniyor.*/

----Abby Parks isimli bir m��teri oldu�undan d��taki query d�ner.

SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A 
INNER JOIN sale.customer B 
on A.customer_id=B.customer_id
WHERE EXISTS  (
               SELECT 1  
			   FROM sale.customer A
			   JOIN sale.orders B
			   ON A.customer_id=B.customer_id
			   WHERE first_name = 'Abby' and last_name= 'Parks'
			   )

--Abby Parks isimli bir m��teri oldu�undan bo� d�ner.

SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A 
INNER JOIN sale.customer B 
on A.customer_id=B.customer_id
WHERE NOT EXISTS  (
                       SELECT 1  
					   FROM sale.customer A
					   JOIN sale.orders B
					   ON A.customer_id=B.customer_id
					   WHERE first_name = 'Abby' and last_name= 'Parks'
				  )

--AbbAy Parks isimli bir m��teri varsa bu bo� d�ner ancak yoksa d��taki query nin hepsi gelir. 

SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A 
INNER JOIN sale.customer B 
on A.customer_id=B.customer_id
WHERE NOT EXISTS  (
                       SELECT 1  
					   FROM sale.customer A
					   JOIN sale.orders B
					   ON A.customer_id=B.customer_id
					   WHERE first_name = 'AbbAy' and last_name= 'Parks'
					)


SELECT DISTINCT B.first_name, B.last_name, A.order_date
FROM sale.orders A 
INNER JOIN sale.customer B 
on A.customer_id=B.customer_id
WHERE EXISTS  (
				   SELECT 1  
 				   FROM sale.customer A
				   JOIN sale.orders B
				   ON A.customer_id=B.customer_id
				   WHERE first_name = 'AbbAy' and last_name= 'Parks'
			   )


SELECT DISTINCT B.first_name, B.last_name, A.order_date
FROM sale.orders A 
INNER JOIN sale.customer B 
on A.customer_id=B.customer_id
WHERE EXISTS  (
				   SELECT 1  
 				   FROM sale.customer C
				   JOIN sale.orders D
				   ON C.customer_id=D.customer_id
				   WHERE first_name = 'Abby' and last_name= 'Parks'
				   AND A.order_date=D.order_date
			   )