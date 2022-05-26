
--------Advanced Grouping Operations

----Write a query that checks if any product id is repeated in more than one row in the products table.
----product tablosunda herhangi bir product id' nin �oklay�p �oklamad���n� kontrol ediniz.

SELECT *
FROM product.product

SELECT product_id, COUNT(*) CNT_ROW
FROM product.product 
GROUP BY product_id
HAVING COUNT(*) > 1 --Agg.sonucu ortaya ��kan yeni s�tunda bir filtreleme yap�yorum.

--Write a query that returns category ids with a max list price above 4000 or a min list price below 500.
--maximum list price' � 4000' in �zerinde olan veya minimum list price' � 500' �n alt�nda olan categori id' leri getiriniz
--category name' e gerek yok.


SELECT category_id, MAX(list_price) MAX_PRICE, MIN(list_price) MIN_PRICE
FROM product.product
GROUP BY category_id

SELECT category_id, list_price
FROM product.product
ORDER BY 1,2 

SELECT category_id, MAX(list_price) MAX_PRICE, MIN(list_price) MIN_PRICE
FROM product.product
GROUP BY category_id
HAVING MAX(list_price) > 4000 OR MIN(list_price) < 500

SELECT category_id, MAX(list_price) MAX_PRICE, MIN(list_price) MIN_PRICE
FROM product.product
GROUP BY category_id
HAVING MAX(list_price) > 4000 AND MIN(list_price) < 500

--Find the average product prices of the brands.
--Markalara ait ortalama �r�n fiyatlar�n� bulunuz.
--ortalama fiyatlara g�re azalan s�rayla g�steriniz.

SELECT B.brand_name, AVG(A.list_price) AVG_PRICE
FROM product.product A
INNER JOIN product.brand B ON A.brand_id=B.brand_id
GROUP BY B.brand_name
ORDER BY AVG(A.list_price) DESC

///***
SELECT	B.brand_id, B.brand_name, AVG(A.list_price) avg_price
FROM	product.product A, product.brand B
WHERE	A.brand_id = B.brand_id
GROUP BY
		B.brand_id, B.brand_name
ORDER BY 
		avg_price DESC
***///

---Write a query that returns BRANDS with an average product price of more than 1000.
---ortalama �r�n fiyat� 1000' den y�ksek olan MARKALARI getiriniz

SELECT B.brand_name, AVG(A.list_price) AVG_PRICE
FROM product.product A
INNER JOIN product.brand B ON A.brand_id=B.brand_id
GROUP BY B.brand_name
HAVING AVG(A.list_price) > 1000
ORDER BY AVG(A.list_price) ASC  --AVG_PRICE da kullanabilirdik.


--Write a query that returns the net price by the customer for each order.(Dont neglect discounts and quantities)
--bir sipari�in toplam net tutar�n� getiriniz. (m��terinin sipari� i�in �dedi�i tutar)
--discount' � ve quantity' yi ihmal etmeyiniz.


SELECT *
FROM sale.order_item

SELECT *
FROM sale.orders

--Herbir m��teri taraf�ndan verilen sipari� toplamlar�
SELECT A.customer_id, A.order_id, SUM ((B.list_price*(1-B.discount))*B.quantity)
FROM sale.orders A
INNER JOIN sale.order_item B ON A.order_id=B.order_id
GROUP BY A.customer_id, A.order_id
ORDER BY A.customer_id

--Verilen her bir sipari�in toplam tutar�
SELECT A.order_id, SUM ((B.list_price*(1-B.discount))*B.quantity)
FROM sale.orders A
INNER JOIN sale.order_item B ON A.order_id=B.order_id
GROUP BY A.order_id
ORDER BY A.order_id


--SELECT ... INTO FROM ...
--A�a��da 4 tabloyu kullanarak a�a��daki columnleri i�eren brand name, category name, model year g�re bir gruplama yaparak yeni �zet bir tablo olu�turuyoruz.

SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year,
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary
FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year


-----GROUPING SETS

SELECT *
FROM	sale.sales_summary

----1. Toplam sales miktar�n� hesaplay�n�z.


SELECT	SUM(total_sales_price)
FROM	sale.sales_summary


--2. Markalar�n toplam sales miktar�n� hesaplay�n�z

SELECT brand, SUM(total_sales_price) total_sales
FROM sale.sales_summary
GROUP BY brand


--3. Kategori baz�nda yap�lan toplam sales miktar�n� hesaplay�n�z

SELECT Category, SUM(total_sales_price) total_sales
FROM sale.sales_summary
GROUP BY Category

--4. Marka ve kategori k�r�l�m�ndaki toplam sales miktar�n� hesaplay�n�z

SELECT brand, Category, SUM(total_sales_price) total_sales
FROM sale.sales_summary
GROUP BY brand, Category
ORDER BY brand

SELECT brand, category, SUM(total_sales_price) total_sales
FROM sale.sales_summary
GROUP BY 
	GROUPING SETS(
	         (brand, category), -- yukar�daki brand ve category g�re grupland�rma
			 (brand),           -- yukar�daki brand g�re grupland�rma
			 (category),        -- yukar�daki category g�re grupland�rma
			 ()                 -- yukar�daki grupland�rma yapmadan toplam sales verir.
			 )
ORDER BY brand, category

--Yukar�daki query g�re ��kan tabloda () olunca sadece total_sales yazacak,category veya branda g�re bu sat�rlar dolu olacak, category ve brand g�re iki s�tun dolu olacak.


--brand, category, model_year s�tunlar� i�in Rollup kullanarak total sales hesaplamas� yap�n�z.
--�� s�tun i�in 4 farkl� gruplama varyasyonu incelemeye �al���n�z.

SELECT brand, category,model_year, SUM(total_sales_price) total_sales
FROM sale.sales_summary
GROUP BY 
	ROLLUP (brand, category, model_year) 