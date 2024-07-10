select *
from customers
where customerName like '%Gift%'
;

select *
from customers
where customerName REGEXP 'La.'
;

select customerNumber, country, city
from customers
where country = 'USA' and city = 'NYC'
;

select *
from payments
where amount between 10000 and 50000
and paymentDate between '2003-06-05' and '2004-12-31'
and checkNumber like '%JM%'
;

-- IN 연산자
select *
from offices
where country not in ('USA', 'France', 'UK')
;

-- order by
select *
from orders
order by orderNumber asc
;

select customerNumber, orderNumber
from orders
order by 1 asc, 2 desc -- 첫 번째 필드는 오름차순, 두 번째 필드는 내림차순
;

-- group by, having
select distinct status -- 중복값 제거, 아래 query 와 동일한 결과
from orders
;

select status, count(*) as cnt
from orders
group by status
having cnt >= 5
order by 2 desc
;

select country, count(*) as cnt
from customers
group by country
;