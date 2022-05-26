---- 16.10.2021 Session-2 (Advanced Grouping Operations) ---------

---Join

-- Ma�aza �al��anlar�n� yapt�klar� sat��lar ile birlikte listeleyin


SELECT *
FROM sale.staff S

SELECT *
FROM sale.orders O

--A�a��daki query ile ma�aza �al��anlar�ndan sadece sipari� alanlar� getirdim. ��nk� Inner Join kulland�m. 
--Sipari� almayan ma�aza �al��anlar�n� getirmedi. Bundan dolay� InnerJoin i�ime yaram�yor.

SELECT A.staff_id, A.first_name, A.last_name, B.staff_id, B.order_id --id ler ile �al��mak her zaman �al��mam�z�n do�rulu�unu art�r�r.
FROM sale.staff A
INNER JOIN sale.orders B ON A.staff_id=B.staff_id
ORDER BY A.staff_id -- Default ASC

-- Ma�aza �al��anlar�ndan hangileri sat�� yap�yor ona bakt�k.

SELECT A.staff_id, A.first_name, A.last_name, B.staff_id, B.order_id 
FROM sale.staff A
LEFT JOIN sale.orders B ON A.staff_id=B.staff_id
ORDER BY A.staff_id


SELECT COUNT(A.staff_id), COUNT(B.staff_id) -- Sat�r say�s�n� getirdi.
FROM sale.staff A
INNER JOIN sale.orders B ON A.staff_id=B.staff_id


--INNER JOIN VE LEFT JOIN ile bak�nca aradaki farka dikkat edelim.
--INNER JOIN de ikiside ayn� iken LEFT JOIN de staff tablosu tamam� gelirken yani 10, orders sipari� alanlar geliyor.

SELECT COUNT(DISTINCT A.staff_id), COUNT(DISTINCT B.staff_id) --
FROM sale.staff A
INNER JOIN sale.orders B ON A.staff_id=B.staff_id


SELECT COUNT(DISTINCT A.staff_id), COUNT(DISTINCT B.staff_id) --
FROM sale.staff A
LEFT JOIN sale.orders B ON A.staff_id=B.staff_id

------ CROSS JOIN ------

-- Hangi markada hangi kategoride ka�ar �r�n oldu�u bilgisine ihtiya� duyuluyor

SELECT DISTINCT A.brand_id, A.brand_name, C.category_id, C.category_name
FROM product.brand A
LEFT JOIN product.product B ON A.brand_id=B.brand_id
CROSS JOIN product.category C
ORDER BY A.brand_id

------ SELF JOIN ------

-- Personelleri ve �eflerini listeleyin
-- �al��an ad� ve y�netici ad� bilgilerini getirin

SELECT *
FROM sale.staff

SELECT B.first_name, A.first_name AS manager_name
FROM sale.staff A
INNER JOIN sale.staff B ON A.staff_id=B.manager_id


