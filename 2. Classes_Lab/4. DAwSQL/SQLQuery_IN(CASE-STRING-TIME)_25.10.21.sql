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

--Question:
--