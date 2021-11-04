--------04.11.21---
--Windows Function

--Question: T�m bisikletler aras�nda En ucuz bisikletin ad�(First value fonk. kullan�n�z.)

SELECT *
FROM product.product

SELECT DISTINCT FIRST_VALUE(product_name) OVER(ORDER BY list_price) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product

--Question: Herbir kategorideki en ucuz bisikletin ad�?

SELECT DISTINCT category_id,
	   FIRST_VALUE(product_name) OVER(PARTITION BY category_id ORDER BY list_price) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product


--first_value ile last_value aras�ndaki �nemli fark last_value daki windows frame dir.

SELECT DISTINCT LAST_VALUE(product_name) OVER(ORDER BY list_price) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product

SELECT DISTINCT 
	   LAST_VALUE(product_name) OVER(ORDER BY list_price DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product            --ROWS YER�NE RANGE de kullan�labilir.

SELECT DISTINCT 
	   LAST_VALUE(product_name) OVER(ORDER BY list_price DESC RANGE BETWEEN 1 PRECEDING AND 4 FOLLOWING) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product  

--Question: Herbir personelin bir �nceki sat���n�n sipari� tarihini yazd�r�n�z(LAG fonksiyonu kullan�n�z.)

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.order_date,
		LAG(order_date) OVER(PARTITION BY A.staff_id ORDER BY order_id)  --order_date kullanmam�z uygun olmayabilir bunun yerine order_id ile bir s�ralama yapmam�z gerekiyor.
FROM sale.staff A, sale.orders B                 --order_id ye g�re s�ralad���m�zda bir �nceki sat�r�n order_date getiriyor ancak bu gelen sat�r o ki�iye ait olmayabilir. B�t�n sipari�leri b�t�n olarak de�erlendirdi.
WHERE A.staff_id=B.staff_id                      --Bundan partition by yapmam�z gerekir.
ORDER BY A.staff_id

--Question: Herbir personelin bir sonraki sat���n�n sipari� tarihini yazd�r�n�z.

SELECT B.order_id,A.staff_id, A.first_name, A.last_name, B.order_date,
		LEAD(order_date) OVER(PARTITION BY A.staff_id ORDER BY order_id)  --order_date kullanmam�z uygun olmayabilir bunun yerine order_id ile bir s�ralama yapmam�z gerekiyor.
FROM sale.staff A, sale.orders B                 --order_id ye g�re s�ralad���m�zda bir �nceki sat�r�n order_date getiriyor ancak bu gelen sat�r o ki�iye ait olmayabilir. B�t�n sipari�leri b�t�n olarak de�erlendirdi.
WHERE A.staff_id=B.staff_id                      --Bundan partition by yapmam�z gerekir.
ORDER BY A.staff_id


-- Analytic Numbering Functions

--Question: herbir kategori i�inbisikletLER�N F�YAT SIRALAMASINI yap�n�z.

SELECT category_id, list_price,
	   ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price)
FROM product.product

--Question: Ayn� soruyu ayn� fiyatl� bisikletler ayn� s�ra numaras�n� alacak �ekilde yap�n�z.

SELECT category_id, list_price,
	   RANK() OVER(PARTITION BY category_id ORDER BY list_price) Rank_Number
FROM product.product
--RANK VE DENSE_RANK aras�ndaki farka dikkat!!!!!!
SELECT category_id, list_price,
	   DENSE_RANK() OVER(PARTITION BY category_id ORDER BY list_price) Rank_Number
FROM product.product


--Question: M��terilerin sipari� ettikleri �r�n say�lar�n�n k�m�latif da��l�m�n� yaz�n�z.

SELECT *
FROM sale.orders

SELECT *
FROM sale.order_item

WITH T1 AS
(
SELECT A.customer_id,
	  SUM(quantity) prod_quantity  --m��terilerin sipari�lerinde verdi�i toplam �r�n say�s�.
FROM sale.orders A, sale.order_item B
WHERE A.order_id=B.order_id
GROUP BY A.customer_id
)
SELECT DISTINCT prod_quantity, ROUND(CUME_DIST() OVER(ORDER BY prod_quantity),2) CUM_DIST
FROM T1
ORDER BY 1


WITH T1 AS
(
SELECT A.customer_id,
	  SUM(quantity) prod_quantity  --m��terilerin sipari�lerinde verdi�i toplam �r�n say�s�.
FROM sale.orders A, sale.order_item B
WHERE A.order_id=B.order_id
GROUP BY A.customer_id
)
SELECT DISTINCT prod_quantity, ROUND(PERCENT_RANK() OVER(ORDER BY prod_quantity),2) CUM_DIST
FROM T1
ORDER BY 1

--Question: Yukar�daki tabloya g�re m��terileri sipari� verdikleri �r�n say�s�na g�re 5 farkl� gruba b�l�n.

WITH T1 AS
(
SELECT A.customer_id,
	  SUM(quantity) prod_quantity  --m��terilerin sipari�lerinde verdi�i toplam �r�n say�s�.
FROM sale.orders A, sale.order_item B
WHERE A.order_id=B.order_id
GROUP BY A.customer_id
)
SELECT DISTINCT customer_id, prod_quantity, NTILE(5) OVER(ORDER BY prod_quantity) CUM_DIST --Buradaki order by ise bize ntile func uygulan�rken bunun i�inde s�ralama yapar.
FROM T1
ORDER BY 1  --Buradaki order by en son kar��m�za gelen tabloyu s�ralar.


-- Question: Sipari�lerin ortalama �r�n fiyatlar�n� ve t�m sipari�lerin ortalama net tutar� yani indirim d���lm�� halini yaz�n�z.


SELECT *, list_price*quantity*(1-discount)
FROM sale.order_item

SELECT DISTINCT order_id, 
AVG(list_price) OVER(PARTITION BY order_id) Avg_Price,
AVG(list_price*quantity*(1-discount)) OVER() Avg_Net_Amount  --T�m tablonun ortalama net tutarlar�n� getirdik.
FROM sale.order_item


SELECT DISTINCT order_id, 
AVG(list_price) OVER(PARTITION BY order_id) Avg_Price,
AVG(list_price*quantity*(1-discount)) OVER(PARTITION BY order_id) Avg_Net_Amount   --Burada ise sipari�lerin ortalama net tutarlar�n� getirdik.
FROM sale.order_item



WITH T1 AS
(
SELECT DISTINCT order_id, 
AVG(list_price) OVER(PARTITION BY order_id) Avg_Price,
AVG(list_price*quantity*(1-discount)) OVER() Avg_Net_Amount   --Burada ise sipari�lerin ortalama net tutarlar�n� getirdik.
FROM sale.order_item
)
SELECT *
FROM T1
WHERE Avg_Price > Avg_Net_Amount 

--Question : 2018 y�l�nda store lar�n haftal�k k�m�latif sipari� say�lar�n� yazd�r�n�z

SELECT *
FROM sale.store

SELECT *
FROM sale.orders


SELECT B.store_id, B.store_name, A.order_date, DATEPART(WEEK, order_date) week_of_year,
		  COUNT(*) OVER(PARTITION BY B.store_id, DATEPART(WEEK, order_date))  cnt_order_per_week,
		  COUNT(*) OVER(PARTITION BY B.store_id ORDER BY DATEPART(WEEK, order_date))
FROM sale.orders A, sale.store B
WHERE A.store_id=B.store_id
AND DATEPART(YEAR,order_date)=2018  --YEAR(order_date)=2018 kullan�labilir
ORDER BY 1,3
