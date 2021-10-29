DROP TABLE IF EXISTS conver_rate1
CREATE TABLE conver_rate1
	(Visitor_ID INT NOT NULL,
	Adv_ID VARCHAR(50),
	Actionn VARCHAR(50)
	)

INSERT INTO conver_rate1(Visitor_ID, Adv_ID, Actionn )
VALUES  (1, 'A', 'Left'),
		(2, 'A', 'Order'),
		(3, 'B', 'Left'),
		(4, 'A', 'Order'),
		(5, 'A', 'Review'),
		(6, 'A', 'Left'),
		(7, 'B', 'Left'),
		(8, 'B', 'Order'),
		(9, 'B', 'Review'),
		(10, 'A','Review')


WITH T1 AS 
(SELECT *
FROM (VALUES  
		(1, 'A', 'Left'),
		(2, 'A', 'Order'),
		(3, 'B', 'Left'),
		(4, 'A', 'Order'),
		(5, 'A', 'Review'),
		(6, 'A', 'Left'),
		(7, 'B', 'Left'),
		(8, 'B', 'Order'),
		(9, 'B', 'Review'),
		(10, 'A','Review')
	) A (Visitor_id, Adv_ID, Actionn)
), T2 AS
(
SELECT Adv_ID, 
	   COUNT(*) total_count,
	   SUM(CASE WHEN Actionn= 'Order' THEN 1 ELSE 0 END) AS cnt_order
FROM T1
GROUP BY Adv_ID
)
SELECT Adv_ID, CONVERT(NUMERIC(3,2), 1.0*cnt_order /total_count) conversion_rate
FROM T2

--2.y�ntem

SELECT	A.Adv_Type, CAST(CAST(B.Action_Count AS float) / COUNT(A.Action) AS NUMERIC(3,2)) Order_Ratio
FROM	Actions A, (
			SELECT	Adv_Type, Action, COUNT(Action) Action_Count
			FROM	Actions
			WHERE	Action = 'Order'
			GROUP BY Adv_Type, Action) B
WHERE	A.Adv_Type = B.Adv_Type
GROUP BY A.Adv_Type, B.Action_Count


--Question: Ayn� sipari�te Children Bicycle ve Comfort Bicycle categorisinde bisiklet sipari� veren m��terileri getiriniz.

--Bu �r�nleri category tablosundan bulduk, buradan bunlar�n bulundu�u productlar� bulduk, 
--bu productlardan da sipari�leri bulmal�y�z yani order_item tablosuna gidiyoruz.
/*
product.category
product.product
sale.order_item
sale.orders
sale.customer
*/

SELECT C.order_id,
		SUM(CASE WHEN A.category_name='Comfort Bicycles' THEN 1 ELSE 0 END) AS comfort_bike,
		SUM(CASE WHEN A.category_name='Children Bicycles' THEN 1 ELSE 0 END) AS children_bike
FROM product.category A, product.product B, sale.order_item C
WHERE category_name IN ('Children Bicycles', 'Comfort Bicycles')
AND A.category_id = B.category_id
AND B.product_id = C.product_id
AND comfort_bike 
GROUP BY C.order_id --group by yapmasak her bir �r�n i�in sipari� id sini ayr� ayr� yaz�yordu. 
--Bunu engellemek i�in order_id ye grupland�rd�k ve bike kategorilerine g�re o sipari�teki �r�n say�lar�n� bullduk.


WITH T1 AS
(
SELECT C.order_id,
		SUM(CASE WHEN A.category_name='Comfort Bicycles' THEN 1 ELSE 0 END) AS comfort_bike,
		SUM(CASE WHEN A.category_name='Children Bicycles' THEN 1 ELSE 0 END) AS children_bike
FROM product.category A, product.product B, sale.order_item C
WHERE category_name IN ('Children Bicycles', 'Comfort Bicycles')
AND A.category_id = B.category_id
AND B.product_id = C.product_id
GROUP BY C.order_id
)
SELECT *
FROM T1
WHERE comfort_bike != 0 and children_bike != 0


SELECT C.order_id,
		SUM(CASE WHEN A.category_name='Comfort Bicycles' THEN 1 ELSE 0 END) AS comfort_bike,
		SUM(CASE WHEN A.category_name='Children Bicycles' THEN 1 ELSE 0 END) AS children_bike
FROM product.category A, product.product B, sale.order_item C
WHERE category_name IN ('Children Bicycles', 'Comfort Bicycles')
AND A.category_id = B.category_id
AND B.product_id = C.product_id
GROUP BY C.order_id
HAVING
		Sum(CASE WHEN A.category_name = 'Comfort Bicycles' THEN 1 ELSE 0 END) >= 1  --BURADA YUKARIDAK� ALIAS LARI KULLANAMADIK ��NK SELECT HAVING DEN SONRA GEL�R.
AND		SUM(CASE WHEN A.category_name = 'Children Bicycles' THEN 1 ELSE 0 END) >= 1