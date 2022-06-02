--------04.11.21---
--Windows Function

--First_Value/Last_Value:

--Question: 
--What is the name of the cheapest bike?
--T�m bisikletler aras�nda En ucuz bisikletin ad�(First value fonk. kullan�n�z.)

SELECT *
FROM product.product

SELECT DISTINCT FIRST_VALUE(product_name) OVER(ORDER BY list_price) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product

--Question: 
--What is the name of the cheapest bike in each category?
--Herbir kategorideki en ucuz bisikletin ad�?

SELECT DISTINCT category_id, 
	   FIRST_VALUE(product_name) OVER(PARTITION BY category_id ORDER BY list_price) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product


--first_value ile last_value aras�ndaki �nemli fark last_value daki windows frame dir.

--Question:
--How to do the first question using last_value?


SELECT DISTINCT FIRST_VALUE(product_name) OVER(ORDER BY list_price) 
FROM product.product


--last_value en son sat�r� getirmeye �al��t��� i�in burada default olan WF kullanam�yoruz.
SELECT DISTINCT product_name,list_price,
				LAST_VALUE(product_name) OVER(ORDER BY list_price DESC) AS F_V
FROM product.product


SELECT DISTINCT 
	   LAST_VALUE(product_name) OVER(ORDER BY list_price DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product            --ROWS YER�NE RANGE de kullan�labilir.


SELECT DISTINCT 
	   LAST_VALUE(product_name) OVER(ORDER BY list_price DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product


SELECT DISTINCT 
	   LAST_VALUE(product_name) OVER(ORDER BY list_price DESC ROWS BETWEEN 1 PRECEDING AND 4 FOLLOWING) --list_price lar� s�ralad� ve en ucuz olan�n ismini getirdik.
FROM product.product  




--Question: 
--Write a query that returns the order date of the one previous sale of each staff(use the lag function)
--Herbir personelin bir �nceki sat���n�n sipari� tarihini yazd�r�n�z(LAG fonksiyonu kullan�n�z.)

SELECT *
FROM sale.staff A

SELECT *
FROM sale.orders B

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.order_date
FROM sale.staff A, sale.orders B
WHERE A.staff_id=B.staff_id 
ORDER BY A.staff_id


/*A�a��daki gibi yap�nca bize bir sonraki sipari�in tarihini getirmedi 2.sat�rda oldu�u gibi.
Buraya getirdi�i de�er order_id g�re s�ralad�ktan sonra bir sonraki order_id nin sipari� tarihidir.
T�m �al��anlar�n sipari�lerini birlikte de�erlendiriyor.
*/

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.order_date,
		LAG(order_date) OVER(ORDER BY order_id)
FROM sale.staff A, sale.orders B
WHERE A.staff_id=B.staff_id 
ORDER BY A.staff_id


--Yukar�daki sorunu ��zmek i�in her bir �al��an� ayr� ayr� de�erlendirece�iz.

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.order_date,
		LAG(order_date) OVER(PARTITION BY A.staff_id ORDER BY order_id)
FROM sale.staff A, sale.orders B                 
WHERE A.staff_id=B.staff_id                      


--Write a query that returns the order date of the one next sale of each staff(use the LEAD function)

SELECT A.staff_id, A.first_name, A.last_name, B.order_id, B.order_date,
		LEAD(order_date) OVER(PARTITION BY A.staff_id ORDER BY order_id)
FROM sale.staff A, sale.orders B                 
WHERE A.staff_id=B.staff_id 



-- Analytic Numbering Functions

--Question: 
--Write a query that assign an ordinal number to the bike prices for each category in ascending order.
--herbir kategori i�inbisikletlerin fiyat s�ralamas�n� yap�n�z.

SELECT category_id, list_price,
	   ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price)
FROM product.product

--Question: Ayn� soruyu ayn� fiyatl� bisikletler ayn� s�ra numaras�n� alacak �ekilde yap�n�z(RANK funct. kullan�n�z.)

SELECT category_id, list_price,
	   RANK() OVER(PARTITION BY category_id ORDER BY list_price) Rank_Number
FROM product.product

--RANK VE DENSE_RANK aras�ndaki farka dikkat!!!!!!

SELECT category_id, list_price,
	   DENSE_RANK() OVER(PARTITION BY category_id ORDER BY list_price) Rank_Number
FROM product.product


--Question: 
--M��terilerin sipari� ettikleri �r�n say�lar�n�n k�m�latif da��l�m�n� yaz�n�z.

SELECT *
FROM sale.orders --Buradan her bir m��terinin toplam ka� �r�n siparis etti�ini bulam�yorum.A�a��daki table ile join yapt�m.

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
SELECT DISTINCT prod_quantity, ROUND(CUME_DIST() OVER(ORDER BY prod_quantity),2) CUM_DIST --Cume_D�st ile �r�nlerin k�m�latif da��l�m�n� getirdik.
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


--Question: 

--Divide customers into 5 groups based on the quantity of product they order.
--Yukar�daki tabloya g�re m��terileri sipari� verdikleri �r�n say�s�na g�re 5 farkl� gruba b�l�n.

WITH T1 AS
(
SELECT A.customer_id,
	  SUM(quantity) prod_quantity  --m��terilerin sipari�lerinde verdi�i toplam �r�n say�s�.
FROM sale.orders A, sale.order_item B
WHERE A.order_id=B.order_id
GROUP BY A.customer_id
)
SELECT DISTINCT customer_id, prod_quantity, NTILE(5) OVER(ORDER BY prod_quantity) grp_cust --Buradaki order by ise bize ntile func uygulan�rken bunun i�inde s�ralama yapar.
FROM T1
ORDER BY 3,1  --Buradaki ile WF i�indeki order by farkl�d�r. Buradaki en son kar��m�za gelen tabloyu s�ralar.


--Question: 
--Write a query that returns both of the followings:
-- * The average product price of orders.
-- * Average net amount of orders.
--Sipari�lerin ortalama �r�n fiyatlar�n� ve t�m sipari�lerin ortalama net tutar� yani indirim d���lm�� halini yaz�n�z.

SELECT *
FROM sale.order_item


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


--Ortalama �r�n fiyatl�n�n ortalama net tutardan y�ksek oldu�u sipari�leri listeleyiniz.

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
ORDER BY 1

--Question : 
--Write a query that calculate the stores weekly cumulative number of orders for 2018.
--2018 y�l�nda store lar�n haftal�k k�m�latif sipari� say�lar�n� yazd�r�n�z.

SELECT *
FROM sale.store

SELECT *
FROM sale.orders


SELECT B.store_id, B.store_name, A.order_date, DATEPART(WEEK, A.order_date) week_of_year 
FROM sale.orders A, sale.store B
WHERE A.store_id=B.store_id
AND DATEPART(Year, order_date)=2018  --YEAR(order_date)=2018 kullan�labilir.
ORDER BY 1



SELECT DISTINCT B.store_id, B.store_name, DATEPART(WEEK, order_date) week_of_year, --A.order_date kullanm��t�k bu durumda tekrar getiriyor. DISTINCT kullan�m fark�na dikkat edelim.
		  COUNT(*) OVER(PARTITION BY B.store_id, DATEPART(WEEK, order_date))  cnt_order_per_week, --store_id ve week g�re grupland�rma yapt�k.
		  COUNT(*) OVER(PARTITION BY B.store_id ORDER BY DATEPART(WEEK, order_date))  cnt_cumulative
FROM sale.orders A, sale.store B
WHERE A.store_id=B.store_id
AND DATEPART(YEAR,order_date)=2018  --YEAR(order_date)=2018 kullan�labilir
ORDER BY 1


--Question: 
--Calculate 7-day moving average of the number of products sold between '2018-03-12' ve '2018-04-12'.
--2018-03-12' ve '2018-04-12' aras�nda sat�lan �r�n say�s�n�n 7 g�nl�k hareketli ortalamas�n� hesaplay�n. Yani sat�ra bakacak ve kendisi ve �ncesi 6 g�n�n ortalamas�n� hesaplayacak.

SELECT *
FROM sale.orders


SELECT *
FROM sale.order_item

SELECT DISTINCT A.order_date, SUM(B.quantity) OVER(PARTITION BY A.Order_date) AS Sum_Qua
FROM sale.orders A, sale.order_item B
WHERE A.order_date BETWEEN '2018-03-12' AND '2018-04-12'



SELECT A.order_date, A.Sum_Qua, AVG(A.Sum_Qua) OVER(ORDER BY A.order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Mov_7_days
FROM
(SELECT DISTINCT O.order_date, SUM(T.quantity) OVER(PARTITION BY O.Order_date) AS Sum_Qua
FROM sale.orders O 
JOIN sale.order_item T ON O.order_id=T.order_id
WHERE O.order_date BETWEEN '2018-03-12' AND '2018-04-12') A


