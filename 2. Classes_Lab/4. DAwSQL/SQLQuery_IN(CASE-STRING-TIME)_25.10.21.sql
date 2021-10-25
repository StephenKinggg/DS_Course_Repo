--25.10.21 
-- EXCEPT
-- 2018 model bisiklet markalar�ndan hangilerinin 2019 model bisikleti yoktur?



SELECT COUNT(DISTINCT brand_id)
FROM product.product
WHERE model_year= 2018

SELECT COUNT(DISTINCT brand_id)
FROM product.product
WHERE model_year= 2019

SELECT brand_id, brand_name    --Sonra brand tablosundan brand_id lerin isimlerini buluyoruz.
FROM product.brand
WHERE brand_id IN(
SELECT brand_id          --2018 y�l�nda �retilen markalar�n id sine bakt�k.
FROM product.product
WHERE model_year= 2018

EXCEPT                  -- 2018 den 2019 ��kard�k.

SELECT brand_id           --2019 y�l�nda �r�telin markalar�n id sine bakt�k.
FROM product.product
WHERE model_year= 2019)

SELECT DISTINCT model_year
FROM product.product
WHERE brand_id=5

--Question:
--Sadece 2019 y�l�nda sipari� verilen di�er y�llarda verilmeyen �r�nler hangileridir?
-- Sadece dedi�i zaman bu hususa dikkat etmek gerekir.

SELECT C.product_id, C.product_name  --��kan sonucu product tablosu ile �nner join yap�p buradan product_id ve name �ekiyoruz.
FROM product.product C
INNER JOIN(
SELECT A.product_id  --2019 y�l�nda sipari� verilen �r�nleri bulduk.
FROM sale.order_item A, sale.orders B
WHERE A.order_id=B.order_id
AND B.order_date BETWEEN '2019-01-01' AND '2019-12-31'  --LIKE '2019%' da kullanabiliriz.

EXCEPT

SELECT A.product_id  --2019 y�l� d���nda sipari� verilen �r�nleri bulduk.ve bunu 2019 y�l�ndan ��kar�nca kalan sadece 2019 y�l�nda verilen di�er y�llarda verilmeyenlerdir.
FROM sale.order_item A, sale.orders B
WHERE A.order_id=B.order_id
AND B.order_date NOT BETWEEN '2019-01-01' AND '2019-12-31'
) D
ON C.product_id=D.product_id


--CASE Expression
--Question:
-- Order_Status isimli alandaki de�erlerin ne anlama geldi�ini i�eren yeni bir alan olu�turum.
--1=Pending, 2=Processing, 3=Rejected, 4=Completed

SELECT *
FROM sale.orders

SELECT order_id, order_status,
       CASE order_status    --�al��t���m�z s�tun belirttik.
			WHEN 1 THEN 'Pending'   --s�tunu belirtince burada sadece i�eri�indeki de�erleri yazmam�z yeterli
			WHEN 2 THEN 'Processing'
			WHEN 3 THEN 'Rejected'
			ELSE 'Completed'
	   END AS order_status_mean  --s�tunu isim veriyoruz.
FROM sale.orders
ORDER BY order_status

--Question:
--Staff tablosuna �al��anlar�n ma�aza isimlerini ekleyin.
--1 = sacramento bikes, 2: buffalo bikes, 3: san angelo bikes
--SINGLE CASE

SELECT first_name, last_name,
       CASE store_id   --�al��t���m�z s�tun belirttik.
			WHEN 1 THEN 'Sacramento Bikes'   --s�tunu belirtince burada sadece i�eri�indeki de�erleri yazmam�z yeterli
			WHEN 2 THEN 'Buffalo Bikes'
			ELSE 'San Angelo Bikes'  --ELSE �art ko�ulmaz.
	   END AS store_name  --s�tunu isim veriyoruz.
FROM sale.staff
ORDER BY store_name


--Staff tablosuna �al��anlar�n ma�aza isimlerini ekleyin.
--1 = sacramento bikes, 2: buffalo bikes, 3: san angelo bikes
--SEARCHED CASE

SELECT first_name, last_name,
		CASE   --Single dan fark� buraya s�tun ad� yazm�yoruz.
			WHEN store_id=1 THEN 'Sacramento Bikes'   --s�tunu burada belirtiyoruz.
			WHEN store_id=2 THEN 'Buffalo Bikes'
			WHEN store_id=3 THEN 'San Angelo Bikes'
	   END AS store_name  --s�tunu isim veriyoruz.
FROM sale.staff
ORDER BY store_name

--Question:
--Customer tablosundaki email adreslerinden gmail, yahoo ve hotmail olanlar d���ndakiler i�in other kullanal�m. 


SELECT A.first_name, A.last_name, email,
	CASE
		WHEN email LIKE '%yahoo.com%' THEN 'Yahoo' 
		WHEN email LIKE '%hotmail.com%' THEN 'Hotmail'
		WHEN email LIKE '%gmail.com%' THEN 'Gmail'
		WHEN email IS NULL THEN 'Others'   --NULL DEGERLER DI�INDAK�LER ���N OTHERS YAZIYOR.
	END AS email_service_provier  
FROM sale.customer A

--2.��z�m

SELECT email, substring(email,
        charindex('@',email,1)+1,
        charindex('.',email,charindex('@',email,1)+1)-charindex('@',email,1)-1) as email_service_provider
FROM sale.customer


--Question:
-- Ayn� sipari�te hem Electric Bikes, hem Comfort Bicycles hem de Children Bicycles �r�nlerini sipari� veren m��terileri bulunuz.

