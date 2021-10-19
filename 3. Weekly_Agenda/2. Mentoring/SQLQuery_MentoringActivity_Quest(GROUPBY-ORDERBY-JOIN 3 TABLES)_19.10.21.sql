--1. What is the sales quantity of product according to the brands and sort them highest lowest
----1.c�z�m

SELECT A.brand_name, SUM(C.quantity) as total_of_sales
FROM product.brand A, product.product B, sale.order_item C
WHERE B.product_id = C.product_id and 
      A.brand_id = B.brand_id
GROUP BY A.brand_name
ORDER BY total_of_sales DESC

----2.��z�m
--- Brand name g�re grupland�r�p buna g�re �r�nlerin toplam sat�� miktarlar�n� bulduk.
SELECT A.brand_name, SUM(C.quantity) as total_of_sales 
FROM sale.order_item C
INNER JOIN product.product B ON C.product_id = B.product_id
INNER JOIN product.brand A ON A.brand_id = B.brand_id
GROUP BY A.brand_name
ORDER BY total_of_sales DESC

--2. Select the top 5 most expensive products 
SELECT TOP 5 A.product_id, A.product_name, A.list_price
FROM product.product A
ORDER BY A.list_price DESC

--3.What are the categories that each brand has
----1.��z�m
--brand name ve category name g�re grupland�rd�k ve her bir brand name ka� tane farkl� category var onu bulduk.
SELECT A.brand_name, COUNT(DISTINCT B.category_id) as count_of_category
FROM product.category C
INNER JOIN product.product B ON C.category_id = B.category_id
INNER JOIN product.brand A ON A.brand_id = B.brand_id
GROUP BY A.brand_name
ORDER BY count_of_category DESC
----1.��z�m
--brand name ve category name g�re grupland�rd�k ve brand name g�re s�ralad�k.
SELECT A.brand_name, C.category_name
FROM product.category C 
INNER JOIN product.product B ON C.category_id = B.category_id
INNER JOIN product.brand A ON A.brand_id = B.brand_id
GROUP BY A.brand_name, C.category_name
ORDER BY A.brand_name DESC

----2.��z�m
SELECT A.brand_name, C.category_name
FROM product.category C, product.product B, product.brand A
WHERE C.category_id = B.category_id AND A.brand_id = B.brand_id
GROUP BY A.brand_name, C.category_name
ORDER BY A.brand_name DESC

--4.Select the avg prices according to brands and categories
--brand name ve category name g�re grupland�r�p bunlar�n ortalama fiyat�n� al�p fiyata g�re s�ralad�k.
SELECT A.brand_name, C.category_name, AVG(B.list_price) as avg_list_price
FROM product.category C
INNER JOIN product.product B ON C.category_id = B.category_id
INNER JOIN product.brand A ON A.brand_id = B.brand_id
GROUP BY A.brand_name, C.category_name
ORDER BY avg_list_price DESC

--brand name ve category name g�re grupland�r�p bunlar�n ortalama fiyat�n� ald�k ve brand name g�re grupland�rd�k.
SELECT A.brand_name, C.category_name, AVG(B.list_price) as avg_list_price
FROM product.category C
INNER JOIN product.product B ON C.category_id = B.category_id
INNER JOIN product.brand A ON A.brand_id = B.brand_id
GROUP BY A.brand_name, C.category_name
ORDER BY A.brand_name DESC