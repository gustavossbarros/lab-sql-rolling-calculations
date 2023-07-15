-- Lab SQL Rolling Calculations
-- In this lab, you will be using the Sakila database of movie rentals.
use sakila;
-- 1. Get number of monthly active customers.

create or replace view sakila.customer_activity as
select customer_id, rental_date as Activity_date,
date_format(rental_date, '%m') as Activity_Month,
date_format(rental_date, '%Y') as Activity_year
from sakila.rental;

select * from sakila.customer_activity;

create or replace view sakila.Monthly_active_customers as
select Activity_year, Activity_Month, 
count(distinct customer_id) as Active_customers 
from sakila.customer_activity
group by Activity_year, Activity_Month
order by Activity_year, Activity_Month;

select * from sakila.Monthly_active_customers;


-- 2. Active users in the previous month.
select *
from (
select Active_customers, lag(Active_customers,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
from sakila.monthly_active_customers
)sub
where last_month is not null;


-- 3. Percentage change in the number of active customers.
with cte_activity as (
  select active_customers, lag(Active_customers,1) over (partition by Activity_year) as last_month, Activity_year, Activity_month
  from sakila.Monthly_active_customers
)
select *, concat(((active_customers - last_month) / active_customers) * 100, '%') as variation
from cte_activity
where last_month is not null;


-- 4. Retained customers every month.
create or replace view sakila.retained_customers_view as
with distinct_customers as (
  select distinct customer_id , Activity_Month, Activity_year
  from sakila.customer_activity
)
select dc1.Activity_year, dc1.Activity_Month, count(distinct dc1.customer_id) as Retained_customers
from distinct_customers dc1
join distinct_customers dc2 on dc1.customer_id = dc2.customer_id
and dc1.activity_year = dc2.activity_year
and dc1.activity_Month = dc2.activity_Month + 1
group by dc1.Activity_Month, dc1.Activity_year
order by dc1.Activity_year, dc1.Activity_Month;

select * from sakila.retained_customers_view;
