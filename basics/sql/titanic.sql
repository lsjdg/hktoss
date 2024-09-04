use titanic;
select * from titanic;
-- 중복값 유무 확인
select count(PassengerId), count(distinct PassengerId)
from titanic
;
-- 요인별 생존 여부 집계 (0은 사망, 1은 생존)
-- 성별에 따른 승객 수와 생존자 수 구하기
select sex, count(distinct PassengerId) as passengers, sum(survived) as survivors,
round(sum(survived) / count(distinct PassengerId), 3) as survive_rate 
from titanic
group by sex
;
-- 연령대별 승객수, 생존자수, 비율 구하기
select floor(age / 10) * 10 as age_group, count(distinct PassengerId) as passengers,
sum(survived) as survivors, round(sum(survived) / count(distinct PassengerId), 3) as survive_rate
from titanic
group by age_group
;
-- 남자 정보만 추출
select floor(age / 10) * 10 as age_group, sex, count(distinct PassengerId) as passengers,
sum(survived) as survivors, round(sum(survived) / count(distinct PassengerId), 3) as survive_rate
from titanic
group by 1, 2
having sex = 'male'
order by 1, 2
;
-- 연령대별 성별 간 생존율 차이 => where, having 사용하는 경우 정리해보기
select male_survivors.age_group, male_survive_rate, female_survive_rate, 
round(female_survive_rate - male_survive_rate, 3) as diff
from (select floor(age / 10) * 10 as age_group, sex, 
round(sum(survived) / count(distinct PassengerId), 3) as male_survive_rate
from titanic
where sex = 'male'
group by 1, 2) male_survivors
left join 
(select floor(age / 10) * 10 as age_group, sex, 
round(sum(survived) / count(distinct PassengerId), 3) as female_survive_rate
from titanic
where sex = 'female'
group by 1, 2) female_survivors
on male_survivors.age_group = female_survivors.age_group
;
-- 필드명 embarked : 승선 항구명
-- 승선 항구별 승객 수
select embarked, count(distinct PassengerId)
from titanic
group by 1
;
-- 승선 항구별, 성별 승객 수
select embarked, sex, count(distinct PassengerId)
from titanic
group by 1, 2
;
-- 승선 항구별, 성별 승객 비중(%)
select male_info.embarked, male_cnt, female_cnt, round(male_cnt / female_cnt, 3) as ratio
from (
select embarked, sex, count(distinct PassengerId) as male_cnt
from titanic
group by 1, 2
having sex = 'male') male_info
left join
(select embarked, sex, count(distinct PassengerId) as female_cnt
from titanic
group by 1, 2
having sex = 'female') female_info
on male_info.embarked = female_info.embarked