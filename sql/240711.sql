-- Churn Rate(%) 구하기
use classicmodels;

-- 각 고객의 마지막 구매일
select customernumber, max(orderdate) last_order_date
from orders
group by 1
;

-- 현재 시점 2005-06-01 기준으로 마지막 구매일이 얼마나 오래 됐는지
select customernumber, '2005-06-01' as today, max(orderdate) last_order_date, 
datediff('2005-06-01', max(orderdate)) term
from orders
group by 1
;

-- 정해진 날짜가 아니라, 당일의 날짜로 update
select customernumber, curdate() as today, max(orderdate) last_order_date, 
datediff(curdate(), max(orderdate)) term
from orders
group by 1
;

-- 90일간 미접속 시, 이탈 (churn) 으로 간주
select
	*, case when term >= 90 then 'Y' else 'N' end 'churn'
from(
	select customernumber, '2005-06-01' as today, max(orderdate) last_order_date, 
	datediff('2005-06-01', max(orderdate)) term
	from orders
	group by 1
) order_term
;

-- chrun cnt
select churn, count(distinct customernumber)
from(
	select
	*, case when term >= 90 then 'Y' else 'N' end 'churn'
	from(
		select customernumber, '2005-06-01' as today, max(orderdate) last_order_date, 
		datediff('2005-06-01', max(orderdate)) term
		from orders
		group by 1
	) order_term
) is_churn
group by 1 order by 1 desc
;

CREATE TABLE CLASSICMODELS.CHURN_LIST AS
SELECT CASE WHEN DIFF >= 90 THEN 'CHURN' ELSE 'NON-CHURN' END CHURN_TYPE,
CUSTOMERNUMBER
FROM
(SELECT CUSTOMERNUMBER,
MX_ORDER,
'2005-06-01' END_POINT,
DATEDIFF('2005-06-01',MX_ORDER) DIFF
FROM
(SELECT CUSTOMERNUMBER,
MAX(ORDERDATE) MX_ORDER
FROM CLASSICMODELS.ORDERS
GROUP
BY 1) BASE) BASE
;
-- churn 고객이 가장 많이 구매한 productline 추출
SELECT 
	D.churn_type
	, C.productline,
	COUNT(DISTINCT B.customernumber) BU
FROM orderdetails A
LEFT
JOIN orders B
ON A.ordernumber = B.ordernumber
LEFT
JOIN products C
ON A.productcode = C.productcode
LEFT JOIN CHURN_LIST D
ON B.customernumber = D.customernumber
GROUP
BY 1, 2
HAVING churn_type = 'CHURN'
;
-- 더 효율적으로?
SELECT 
	C.productline,
	COUNT(DISTINCT B.customernumber) BU
FROM orderdetails A
LEFT JOIN orders B ON A.ordernumber = B.ordernumber
LEFT JOIN products C ON A.productcode = C.productcode
LEFT JOIN CHURN_LIST D ON B.customernumber = D.customernumber
WHERE D.churn_type = 'CHURN'
GROUP BY 1
;

-- chapter 2
use my_data;
select *
from dataset2
;
select `Department Name`, avg(RATING) avg_rate
from dataset2
group by 1
;

-- trend dept. 에서 평점 3점 이하인 것 조회
select *
from dataset2
where `Department Name` = 'Trend' and rating <= 3
;
-- 연령대를 10세 단위로 grouping => case when 을 쓰기엔 너무 경우가 많다
select floor(age / 10) * 10 age_group, age
from dataset2
;
-- 평점 3점 이하인 사람 수
select floor(age / 10) * 10 age_group, count(*) as cnt
from dataset2
where rating <= 3 and `Department Name` = 'Trend'
group by 1 order by 1 asc
;
-- 50대 중 trend 에 대한 평점 3점 이하인 항목의 review 추출
select rating, `Review Text`
from dataset2
where floor(age / 10) = 5 and rating <= 3
order by 1 asc