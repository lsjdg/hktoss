-- CH04. 자동차 매출 데이터를 이용한 리포트 작성
-- 일별 매출액 조회
USE classicmodels;
SELECT
	A.Orderdate,
    priceeach * quantityordered AS 매출액
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber;
-- GROUP BY절 활용해서
-- 일별 매출액
SELECT
	A.Orderdate,
    SUM(priceeach * quantityordered) AS 매출액
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
-- SUBSTR() : Python의 슬라이싱 개념
-- 인덱스 번호가 1부터 시작
--
SELECT SUBSTR("ABCDE", 1, 2);
SELECT SUBSTR('2003-01-06', 6, 2);
-- 월별 매출액
SELECT
	SUBSTR(A.Orderdate, 1, 7) AS 월별,
    SUM(priceeach * quantityordered) AS 매출액
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
-- 연도별 매출액
SELECT
	SUBSTR(A.Orderdate, 1, 4) AS 월별,
    SUM(priceeach * quantityordered) AS 매출액
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
-- 91p
-- 일자별, 월별, 연도별 구매자 수
SELECT
	COUNT(ordernumber) N_ORDERS,
    COUNT(DISTINCT ordernumber) N_ORDERS_DISTINCT
FROM
	ORDERS;
SELECT
	orderdate,
    COUNT(DISTINCT customernumber) 구매고객수,
    COUNT(ordernumber) 주문건수
FROM orders
GROUP BY orderdate
ORDER BY orderdate;
-- 연도, 구매고객수, 매출액
-- orders, orderdetails
SELECT
	SUBSTR(A.Orderdate, 1, 4) AS 연도별,
    COUNT(DISTINCT A.customernumber) AS 구매고객수,
    SUM(B.priceeach * B.quantityordered) AS 매출액
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
SELECT *
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
LEFT JOIN products C
ON B.productcode = C.productcode;
-- 연도별 매출액과 구매자 수
SELECT
	SUBSTR(A.orderdate, 1, 4) AS YY,
    COUNT(DISTINCT A.customernumber) AS 구매고객수,
    SUM(B.priceeach * B.quantityOrdered) AS 매출
FROM orders A
LEFT JOIN orderdetails B
ON A.orderNumber = B.orderNumber
GROUP BY 1
ORDER BY 1;
-- 인당 구매금액
SELECT
	SUBSTR(A.Orderdate, 1, 4) AS 연도별,
    COUNT(DISTINCT A.customerNumber) AS 구매고객수,
    SUM(B.priceeach * B.quantityordered) AS 매출액,
    SUM(B.priceeach * B.quantityordered) / COUNT(DISTINCT A.customerNumber) AS AMV
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
-- 건당 구매금액
SELECT
	SUBSTR(A.Orderdate, 1, 4) AS 연도별,
    COUNT(DISTINCT A.orderNumber) AS 주문건수,
    SUM(B.priceeach * B.quantityordered) AS 매출액,
    SUM(B.priceeach * B.quantityordered) / COUNT(DISTINCT A.orderNumber) AS 건당
FROM
	orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1;
-- 국가별, 도시별 구매금액
SELECT C.country, C.city, SUM(B.priceeach * B.quantityordered) AS 매출
FROM orders A
LEFT JOIN orderdetails B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers C
ON A.customerNumber = C.customerNumber
GROUP BY 1, 2
ORDER BY 1, 2;
-- CASE WHEN
-- 조건문, IF-ELSE를 대신함
-- 북미 vs 비북미 매출액 비교
SELECT
	CASE WHEN country IN ('USA', 'Canada') Then 'North America'
    ELSE 'Others' END country_grp, SUM(B.priceeach * B.quantityordered) AS 매출
FROM orders A
LEFT JOIN orderdetails B
ON A.orderNumber = B.orderNumber
LEFT JOIN customers C
ON A.customerNumber = C.customerNumber
GROUP BY 1
ORDER BY 1;
-- Step 3: Use CASE WHEN in a query
SELECT
	 name,
     department,
     salary,
     CASE
		WHEN salary < 50000 THEN 'Low'
        WHEN salary BETWEEN 50000 AND 60000 THEN 'Medium'
        ELSE 'High'
	 END AS salary_category
FROM employees;
-- p.103 매출 Top 5 국가 및 매출
-- row_number, rank, dense_rank
CREATE TABLE CLASSICMODELS.STAT AS
SELECT C.COUNTRY, SUM(PRICEEACH*QUANTITYORDERED) SALES
FROM CLASSICMODELS.ORDERS A
LEFT JOIN CLASSICMODELS.ORDERDETAILS B
ON A.ORDERNUMBER = B.ORDERNUMBER
LEFT JOIN CLASSICMODELS.CUSTOMERS C
ON A.CUSTOMERNUMBER = C.CUSTOMERNUMBER
GROUP BY 1
ORDER BY 2 DESC;
SELECT * FROM stat;
SELECT
	country,
    sales,
    DENSE_RANK() OVER(ORDER BY SALES DESC) RNK
FROM stat;
-- Query 실행 순서
-- FROM -> WHERE -> GROUP BY -> HAVING ->SELECT
CREATE TABLE stat_rnk AS
SELECT
	country,
    sales,
    DENSE_RANK() OVER(ORDER BY SALES DESC) RNK
FROM stat;
SELECT * FROM stat_rnk
WHERE RNK BETWEEN 1 AND 5;
-- 서브 쿼리
SELECT lastName, firstName
FROM employees
WHERE officeCode IN (
	SELECT officeCode
    FROM offices
    WHERE country = 'USA'
);
-- USA에 거주하는 직원의 이름을 출력하세요
SELECT E.lastName, E.firstName, O.country
FROM employees E
LEFT JOIN offices O
ON E.officeCode = O.officeCode
WHERE O.country = 'USA';
-- 문제, amount가 최대값인 것을 조회
SELECT customerNumber, checkNumber, amount
FROM payments
GROUP BY customerNumber, checkNumber
ORDER BY amount DESC
LIMIT 1;
SELECT customerNumber, checkNumber, amount
FROM payments
WHERE amount = (SELECT MAX(amount) FROM payments);
-- 전체 고객 중 주문을 하지 않은 고객
-- 테이블: customers, orders
-- 조회해야 할 필드명: customerName
SELECT customerName
FROM customers
WHERE customerNumber IN (
	SELECT DISTINCT customerNumber
    FROM orders
);
SELECT DISTINCT customerNumber FROM orders;
-- 각 주문건당 최소, 최대, 평균
 SELECT
	MIN(items),
    MAX(items),
    AVG(items)
FROM (
	SELECT
		ordernumber,
		COUNT(ordernumber) AS items
	FROM orderdetails
    GROUP BY 1
) A;
SELECT C.COUNTRY,
SUBSTR(A.ORDERDATE,1,4) YY,
COUNT(DISTINCT A.CUSTOMERNUMBER) BU_1,
COUNT(DISTINCT B.CUSTOMERNUMBER) BU_2,
COUNT(DISTINCT B.CUSTOMERNUMBER)/COUNT(DISTINCT A.CUSTOMERNUMBER)
RETENTION_RATE
FROM CLASSICMODELS.ORDERS A
LEFT
JOIN CLASSICMODELS.ORDERS B
ON A.CUSTOMERNUMBER = B.CUSTOMERNUMBER AND SUBSTR(A.ORDERDATE,1,4)
= SUBSTR(B.ORDERDATE,1,4)-1
LEFT
JOIN CLASSICMODELS.CUSTOMERS C
ON A.CUSTOMERNUMBER = C.CUSTOMERNUMBER
GROUP
BY 1,2
;
-- 셀프 조인
SELECT *
FROM orders A
LEFT JOIN orders B
ON A.customerNumber = B.customerNumber;

-- best seller
-- 미국 고객의 retention rate 가 제일 높음 확인
-- 미국에 집중
-- 미국의 top 5 차량 모델 추출

select *
from orders A
left join customers B on A.customerNumber = B.customerNumber
left join orderdetails C on A.ordernumber = C.orderNumber
left join products D on C.productCode = D.productCode
where B.country = 'USA'
;