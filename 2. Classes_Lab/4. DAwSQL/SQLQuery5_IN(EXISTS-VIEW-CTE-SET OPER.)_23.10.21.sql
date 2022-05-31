--23.10.21
-- Exists/Not Exists

--Write a query that returns State where 'Trek Remedy 9.8-2019' product is not ordered.
--Trek Remedy 9.8 -2019 �r�n�n sipari� verilmedi�i state/stateleri getiriniz.

-- �nce bu �r�n�n tablosundan sipari� bilgileri tablosuna oradan sipari�in m��teri numaras�ndan bunun verenlerin �lke bilgilerine gidece�im.

SELECT *
FROM product.product
WHERE product.product_name='Trek Remedy 9.8 - 2019'


SELECT A.product_id, A.product_name, B.product_id, B.order_id, C.order_id, C.customer_id, D. *
FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE A.product_id=B.product_id 
AND B.order_id=C.order_id
AND C.customer_id=D.customer_id
AND A.product_name='Trek Remedy 9.8 - 2019'

--A�a��da inner query bir de�er d�nd�rd���nden dolay� NOT EXISTS sonucu bo� d�ner.
SELECT *
FROM sale.customer X
WHERE NOT EXISTS ( SELECT A.product_id, A.product_name, B.product_id, B.order_id, C.order_id, C.customer_id, D. *
					FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
					WHERE A.product_id=B.product_id 
					AND B.order_id=C.order_id
					AND C.customer_id=D.customer_id
					AND A.product_name='Trek Remedy 9.8 - 2019'
					)
					
--NOT EXISTS in bo� d�nmesini engellemek i�in inner join i�ine bo� d�necek bir query yazd�k.). Bu durumda bize bu �r�n� i�ermeyen sipari�lerin bilgileri gelmi� oldu.				
SELECT *
FROM sale.customer X
WHERE NOT EXISTS ( SELECT A.product_id, A.product_name, B.product_id, B.order_id, C.order_id, C.customer_id, D. *
					FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
					WHERE A.product_id=B.product_id 
					AND B.order_id=C.order_id
					AND C.customer_id=D.customer_id
					AND A.product_name='Trek Remedy 9.8 - 2019'
					AND X.state=D.state
					)


--V�EWS

-- 2019 y�l�nda �retilen �r�nlerin bulundu�u bir NEW_PRODUCTS view olu�turun.

CREATE VIEW NEW_PRODUCTS AS
SELECT A.*
FROM product.product A
WHERE A.model_year =  '2019'

SELECT * 
FROM NEW_PRODUCTS


--CTE(Common Table Expression)

--List customers who have an order prior to the last order of a customer named Sharyn Hopkins and are residents of the city of San Diego.
--Sharyn Hopkins isimli m��terinin son sipari�inden �nce sipari� vermi� ve San Diego �ehrinde ikamet eden m��terileri listeleyin.

SELECT *
FROM sale.customer

-- �nce Sharyn Hopkins isimli m��terinin son sipari� tarihini bulduk. Order_id b�y�k olan veya order_date yeni olan

SELECT *
FROM sale.customer A, sale.orders B
WHERE A.customer_id=B.customer_id
AND A.first_name='Sharyn'
AND A.last_name='Hopkins'


SELECT max(order_date) last_purchase    -- SELECT TOP 1 B.order_date last_purchase  kullanabiliriz.
FROM sale.customer A, sale.orders B   -- Burada bir join yapm�� olduk.
WHERE A.customer_id=B.customer_id
AND A.first_name='Sharyn' 
AND A.last_name='Hopkins'
--ORDER BY order_date DESC



WITH T1 AS  --A�a��daki query bir sonraki query de yani bir �st query de kullanaca��m. Buna T1 dedim.
(SELECT max(order_date) last_purchase     -- max(order_date) bana buradan tarih almam laz�m.
FROM sale.customer A, sale.orders B   -- Burada bir join yapm�� olduk.
WHERE A.customer_id=B.customer_id
AND A.first_name='Sharyn' 
AND A.last_name='Hopkins'
)
SELECT DISTINCT A.order_date, A.order_id, B.customer_id, B.first_name, B.last_name, B.city
FROM sale.orders A, sale.customer B, T1
WHERE A.customer_id=B.customer_id
AND A.order_date < T1.last_purchase   --order_date nin T1 den gelen order_date k���k olanlar� ald�k.
AND B.city='San Diego' 


--2.��z�m

with last_cust 
as 
(
    select max(o.order_date) as aaa
    from sale.customer c join sale.orders o on c.customer_id=o.customer_id
    where first_name = 'Sharyn' and last_name = 'Hopkins'
)
select a.first_name, a.last_name, b.order_date, a.city
from sale.customer a join sale.orders b on a.customer_id=b.customer_id
where b.order_date < (select * from last_cust) and a.city = 'San Diego'


--Question:

--List all customers who orders on the same dates as Abby Parks.
--Abby	Parks isimli m��terinin al��veri� yapt��� tarihte/tarihlerde al��veri� yapan t�m m��terileri listeleyin.
--M��teri ad�, soyad� ve sipari� tarihi bilgilerini listeleyin.

WITH T1 AS  --A�a��daki query bir sonraki query de yani bir �st query de kullanaca��m. Buna T1 dedim.
(SELECT A.order_date purchase    -- max(order_date) bana buradan tarih almam laz�m.
FROM sale.customer B, sale.orders A   -- Burada bir join yapm�� olduk.
WHERE A.customer_id=B.customer_id
AND B.first_name='Abby' 
AND B.last_name='Parks'

)
SELECT DISTINCT A.order_date, B.first_name, B.last_name
FROM sale.orders A, sale.customer B, T1
WHERE A.customer_id=B.customer_id
AND A.order_date IN (T1.purchase)   --order_date, T1 den gelen order_dateleri i�erecek. = kullan�labilir. 



--2.��z�m:

with new_query as 
(
    select o.order_date
    from sale.orders o join sale.customer c on o.customer_id=c.customer_id
    where c.first_name = 'Abby' and c.last_name = 'Parks'
)
select a.first_name, a.last_name, b.order_date
from sale.customer a join sale.orders b on a.customer_id=b.customer_id
where b.order_date in (select * from new_query)



--Recursive CTE:

WITH T1 AS   -- AS unutma
(SELECT 1 AS NUM  --�lk olarak 1 atad�k. Bu birinci query
 UNION ALL     --Bunun ile iki query birle�tiriyoruz.
 SELECT NUM+1   -- Bu ikinci query. Ka�ar ka�ar art�rmak istiyorsak.
 FROM T1
 WHERE NUM < 9   --Iterasyonu sonland�racak rakam� yazmam�z laz�m yoksa sonsuza kadar gider.
)
SELECT *
FROM T1


--SET OPERATORS

--List Customer's last names in Sacramento and Monroe
--Sacramento �ehrindeki m��teriler ile Monroe �ehrindeki m��terilerin soyisimlerini listeleyin.


--UNION ALL

SELECT last_name   -- 1.tablo
FROM sale.customer
WHERE city='Sacramento'

UNION ALL          -- iki tabloyu birle�tirdik. Ayn� olanlar� getirir.

SELECT last_name   --2.tablo
FROM sale.customer
WHERE city='Monroe'
ORDER BY last_name   -- s�ralamay� en sona manuel olarak yazd�k.

--UNION
--Union All dan farkl� olarak ayn� olanlar� tek sat�r olarak getirdi ve s�ralamay� kendi yapt�.

SELECT last_name   -- 1.tablo
FROM sale.customer
WHERE city='Sacramento'

UNION           -- iki tabloyu birle�tirdik. Ayn� olanlar� getirmedi. S�ralamay� kendi yapt�.

SELECT last_name   --2.tablo
FROM sale.customer
WHERE city='Monroe'  


--Write a query that returns customers who first name is 'Carter' or last name is 'Carter'(dont use 'OR')
-- ADI CARTER VEYA SOYADI CARTER OLAN M��TER�LER� L�STELEY�N ANCAK OR KULLANMAYIN.

SELECT first_name,last_name   -- 1.tablo
FROM sale.customer
WHERE first_name='Carter' 

UNION ALL  --Bu �rnekte UNION da ayn� sonucu veriyor.    

SELECT first_name,last_name   --2.tablo
FROM sale.customer
WHERE last_name='Carter'



SELECT first_name,last_name, customer_id   -- 1.tablo
FROM sale.customer
WHERE first_name='Carter' 

UNION ALL  --Bu �rnekte UNION da ayn� sonucu veriyor.    

SELECT first_name,last_name,customer_id   --2.tablo
FROM sale.customer
WHERE last_name='Carter'

--NOT: Yukar�da Select i�indeki columlerin s�ras� �ok �nemli. Aksi takdirde dtypes hatas� alabiliriz.


--INTERSECT

--Write a query that returns brands that have products for both 2018 and 2019.
-- hem 2018 hem 2019 y�l�nda �r�n� olan markalar� listeleyiniz.


SELECT B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id
AND A.model_year='2018'

INTERSECT  --hem 18 hem de 19 da �r�n� olan markalar dedi�i i�in kesi�im olmal�.

SELECT B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id
AND A.model_year='2019'



SELECT B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id
AND A.model_year='2018'

UNION  --iki y�lda da �r�n� olan markalarI DUPL�CATE eleyerek getiriyor.

SELECT B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id
AND A.model_year='2019'

--Write a query that returns customers who have orders for both 2018,2019 and 2020.
--Question: 2018,2019 VE 2020 y�llar�n�n t�m�nde sipari�i olan m��terilerin bilgilerini getiren bir liste.

--Bu �ekilde ��z�nce 3 kere customer tablosuna gitti�imizden dolay� bu alltakine g�re daha uzun s�r�yor.

SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B  
WHERE A.customer_id=B.customer_id
AND B.order_date BETWEEN '2018-01-01' AND '2018-12-31'

INTERSECT

SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B  
WHERE A.customer_id=B.customer_id
AND B.order_date BETWEEN '2019-01-01' AND '2019-12-31'

INTERSECT

SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B  
WHERE A.customer_id=B.customer_id
AND B.order_date BETWEEN '2020-01-01' AND '2020-12-31'


--2.y�ntem(Subquery and set operator)
-- Bu ��z�mde ise sadece customer tablosuna bir kez gidiyoruz. 

SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2018-01-01' AND '2018-12-31'
INTERSECT
SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31'
INTERSECT
SELECT customer_id
FROM sale.orders
WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31'


SELECT first_name, last_name, customer_id
FROM sale.customer
WHERE customer_id IN( SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2018-01-01' AND '2018-12-31'
					INTERSECT
					SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31'
					INTERSECT
					SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31')

--3.y�ntem(CTE and set operator):

WITH T1 AS
( SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2018-01-01' AND '2018-12-31'
					INTERSECT
					SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31'
					INTERSECT
					SELECT customer_id
					FROM sale.orders
					WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31')
SELECT first_name, last_name
FROM sale.customer A, T1
WHERE A.customer_id=T1.customer_id