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