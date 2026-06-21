select * from customer;
select * from transaction_data
--1. Retrieve All Transactions for a Specific Customer
--Description: Query to retrieve all transactions for a customer with ID 204152, ordered by the transaction date in ascending order.

select c.customer_id,
       t.transaction_id,
	   t.transaction_date,
	   t.total_balance,
	   t.transaction_amount,
	   t.investment_amount 
from customer as c 
join transaction_data as t
	on c.customer_id = t.customer_id 
where t.customer_id=204152 
order by t.transaction_date asc;


--2. Top 5 customers based on total number of transaction
select t.customer_id,
       count(*) as total_transaction
from customer as c 
join transaction_data as t 
	on c.customer_id = t.customer_id 
group by t.customer_id 
order by 2 desc 
limit 5;

-- 3. Calculate the Total Balance for All Accounts
--Description: Calculate the total balance across all accounts.

select sum(total_balance) as total_balance from transaction_data;



--4. Find Customers with a investment Amount Greater Than $150000

select customer_id,
       sum(investment_amount) as invest_amount 
from transaction_data 
group by customer_id 
having sum(investment_amount)>150000;

--5. Top 5 investor based on total_amount
select customer_id,account_type,
       sum(investment_amount) as invest_amount,count(*) as times_of_saving,
	   round(sum(investment_amount)*100/sum(sum(investment_amount)) over(),2) as pct_of_revenue
from transaction_data 
group by 1,2
order by 3 desc
limit 5;

--6. Identify Duplicate Accounts
--Description: Find duplicate accounts in the system based on account numbers.

select customer_id ,count(*) as number from customer group by customer_id having count(*)>1;

--7. investment analysis 

with investment_analysis as(
select customer_id,sum(investment_amount) as investment_amount from transaction_data group by customer_id
)

select 
      count(*) total_investor,
      round(avg(investment_amount),2) as avg_investment,
	  percentile_cont(.25) within group(order by investment_amount) as investor_25,
	  percentile_cont(.50) within group(order by investment_amount) as investor_50,
	  percentile_cont(.75) within group(order by investment_amount) as investor_75
from investment_analysis

--8. Find All Transactions That Occurred in the Last 30 Days

select * from transaction_data where transaction_date > current_date -interval '30days';

--9. Calculate the average investment_amount   by account_type


select account_type,
       round(avg(investment_amount),2) as avg_investment_amount 
from transaction_data
group by account_type

--10.customer who does not make any TRANSACTION

select c.customer_id ,t.transaction_date
from customer as c 
left join transaction_data as t 
	on c.customer_id = t.customer_id 
where t.transaction_id is null;


--11.top-3 customers based on account type and transaction amount

select customer_id,
       account_type,
	   total_amount,
	   rnk 
	   from(select customer_id,
                   account_type,
				   sum(transaction_amount) as total_amount,
	               rank() over(partition by account_type order by sum(transaction_amount) desc) as rnk
             from transaction_data 
			 group by 
			 customer_id,account_type
)t 
where rnk<4;

--12.top-5 customers with the highest account balance


select customer_id,
       sum(total_balance-transaction_amount) as total_amount 
from transaction_data
group by customer_id 
order by 2 desc 
limit 5;

--13.top-5 investor based on no_of_invest
select customer_id,
       investment_type,
	   count(*) as no_of_invest 
from transaction_data 
group by 1,2 
order by 3 desc
limit 5;


--14.customer who make back to back transaction 
with transaction_history as (
select customer_id,
       round(avg(gap),2) as avg_of_each_customer 
	   from (
	   select customer_id,
                    transaction_date,
	                lag(transaction_date) over(partition by customer_id order by transaction_date) as prev_date,
	                (transaction_date-lag(transaction_date) over(partition by customer_id order by transaction_date)) as gap
       from transaction_data) group by customer_id order by avg_of_each_customer
)

select * 
from transaction_history 
where avg_of_each_customer=1

--15. Retrieve the Investment history for a customer


select customer_id,
	investment_amount,
	investment_type,
	transaction_date 
from transaction_data 
where customer_id=204152 
order by transaction_date


--16. Calculate the Total Number of Accounts by Account Type


select account_type,
       count(*) as total_account from transaction_data 
group by account_type

--17.which branch make more transaction based on no_of_transacton and amount
select c.branch_id,
       count(*) as not_of_transaction,
	   sum(t.transaction_amount) as transaction_amount 
	   from transaction_data as t 
	   join customer as c 
	   on t.customer_id=c.customer_id
	   group by c.branch_id
	   order by 3 desc,2 desc;
--18.which branch has more investment and investment_no
select c.branch_id,
       count(*) as not_of_investment,
	   sum(t.investment_amount) as total_investment_amount 
	   from transaction_data as t 
	   join customer as c 
	   on t.customer_id=c.customer_id
	   group by c.branch_id
	   order by 3 desc,2 desc;

select * from bank
--19.Find each branch hold which investment type of money more?
with investment_info as (
select c.branch_id,
       t.investment_type,
	   sum(t.investment_amount) as total_investment_amount ,
	   rank() over(partition by c.branch_id order by sum(t.investment_amount) desc) as rnk
	   from transaction_data as t 
	   join customer as c 
	   on t.customer_id=c.customer_id
	   group by 1,2
)
select * from investment_info where rnk=1
--20.Find  which region make more revenue?
select region ,
       sum(firm_revenue) as total_revenue 
from bank 
group by region 
order by 2 desc;

select * from customer
--21.which region consist how many customer
select region ,
       count(*) as total_customer 
from customer 
group by region 
order by 2 desc;


--22 Find percentage of how many customers dont make transaction based on region
with no_transaction_history as (
	select c.customer_id ,
	       c.region 
	from customer as c 
	left join transaction_data as t 
	on c.customer_id=t.customer_id 
	where t.transaction_date is null
),
ranking as(
	select region,
	       count(*) as total_customer,
		   rank() over(order by region) as rnk
	from no_transaction_history group by region order by region
),
total_customers as (
	select region as main_region,
	       count(*) as total_m_customer,
		   rank() over(order by region) as rnk_c
	from customer group by region order by region
),
result as(
	select r.region,
	round((r.total_customer*100.0)/t.total_m_customer,2) as pct_of_total_customer 
	from ranking as r 
	join total_customers as t 
		on r.rnk=t.rnk_c 
)

select * from result;


--23. Detect Suspicious Transactions
--Description: Identify transactions marked as suspicious, where the amount is greater than $5,000 and the transaction type is Withdrawal.
select * from transaction_data where transaction_amount >5000

--24. Find Accounts That Are Overdrawn
--Description: Retrieve accounts with a negative balance.
select * from transaction_data where total_balance <0


--25. Identify Customers with Multiple nvestment
--Description: Find customers who have more than one investment

select customer_id,count(*) as no_of_investment from transaction_data group by customer_id having count(*)>1

--26. Identify top Customers ivestment
--Description: Find top customer all investment who have more than one investment
with investment_info as (
select customer_id,
       count(*) as no_of_investment ,
	   rank() over(order by  count(*)  desc) as rnk
	   from transaction_data 
	   group by customer_id 
	   order by 2 desc
)

select t.customer_id,
       t.investment_amount,
	   t.investment_type 
	   from transaction_data as t 
	   join investment_info as i 
	   on t.customer_id=i.customer_id 
	   where rnk=1
	   

--27 who make more investment based on account type

select account_type,
       count(*) as no_of_investment,
	   round(avg(investment_amount) ,2)  as average_investment
from transaction_data 
group by account_type


--28 see which age group make more investment
select
      case 
	  when c.age between 10 and 30 then '10-30'
	  when c.age between 31 and 40 then '31-40'
	  when c.age between 41 and 50 then '41-50'
	  when c.age between 51 and 60 then '51-60'
	  else '70+'
	  end as age_status ,
	  count(*) as number
from customer as c 
join transaction_data as t 
	on c.customer_id=t.customer_id 
where t.investment_type='Fixed Deposit' 
group by age_status
  


--29.Top city of each zone based on number of transaction and amount

select * from transaction_data
select * from bank


select * from (select b.region,
       b.city,
	   count(*) as no_of_transaction ,
	   sum(t.transaction_amount) as amount,
	   rank() over(partition by b.region order by count(*) desc) as rnk
from transaction_data as t 
join customer as c 
on t.customer_id=c.customer_id 
join bank as b 
on c.branch_id=b.branch_id 
group by 1,2)t where rnk=1

--30.top transaction month of the each year

select * from (select extract(year from transaction_date) as year_m,
       extract(month from transaction_date) as month_number,
	   sum(transaction_amount) as amount,
	   rank() over(partition by extract(year from transaction_date) order by sum(transaction_amount) desc) as rnk
from transaction_data group by 1,2
)t where rnk=1


















	   
