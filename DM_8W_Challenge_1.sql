--use DannyDiner;

select * from DannyDiner.[dbo].[sales];
select * from DannyDiner.[dbo].[members];
select * from DannyDiner.[dbo].[menu];
---------------------------------------------------------------------
--What is the total amount each customer spent at the restaurant?

select sales.customer_id, sum(menu.price)
from DannyDiner.[dbo].[menu] menu
join
	DannyDiner.[dbo].[sales] sales
ON menu.product_id = sales.product_id
group by sales.customer_id

------------------------------------------------------------------------
--How many days has each customer visited the restaurant?

select customer_id,count(order_date) from
(
select distinct customer_id,order_date from DannyDiner.[dbo].[sales]) as a
group by customer_id


-------------------------------------------------------------------------
--What was the first item from the menu purchased by each customer?

WITH Occurences AS 
(
    SELECT 
        *,
        ROW_NUMBER () OVER (PARTITION BY customer_id order by order_date asc ) AS "Occurence"            
    FROM DannyDiner.[dbo].[sales] 
)
SELECT 
    customer_id,Product_id
FROM Occurences 
WHERE Occurence = 1

---------------------------------------------------------------------------
--What is the most purchased item on the menu and how many times was it purchased by all customers?
select top(1) menu.product_name,count(menu.product_name) as count
from DannyDiner.[dbo].[menu] menu
join
	DannyDiner.[dbo].[sales] sales
ON menu.product_id = sales.product_id
group by menu.product_name 
order by count(menu.product_name)  desc
-----------------------------------------------------------------------------
--Which item was the most popular for each customer?

select * from DannyDiner.[dbo].[sales];
select * from DannyDiner.[dbo].[members];
select * from DannyDiner.[dbo].[menu];

select * from DannyDiner.[dbo].[sales] a
join DannyDiner.[dbo].[menu]b
on a.product_id = b.product_id




-----------------------------------------------------------------------------
--Which item was purchased first by the customer after they became a member?

select * from DannyDiner.[dbo].[sales];
select * from DannyDiner.[dbo].[members];
select * from DannyDiner.[dbo].[menu];


WITH Occurences AS(
select a.customer_id,
	   a.join_date,
	   b.order_date,
	   c.product_name, 
	   ROW_NUMBER() over (partition by a.customer_id order by a.customer_id asc) AS "Occurence"  

 from DannyDiner.[dbo].[members] a
join DannyDiner.[dbo].[sales] b
on a.customer_id = b.customer_id
join DannyDiner.[dbo].[menu] c
on b.product_id = c.product_id
where a.join_date = b.order_date  or b.order_date >  a.join_date )

select Customer_id,Product_name

from Occurences
where Occurence=1

-------------------------------------------------------------------
--Which item was purchased just before the customer became a member?
select * from DannyDiner.[dbo].[sales];
select * from DannyDiner.[dbo].[members];
select * from DannyDiner.[dbo].[menu];


WITH Occurences AS(
select a.customer_id,
	   a.join_date,
	   b.order_date,
	   c.product_name, 
	   ROW_NUMBER() over (partition by a.customer_id order by a.customer_id asc,order_date desc) AS "Occurence"  

 from DannyDiner.[dbo].[members] a
join DannyDiner.[dbo].[sales] b
on a.customer_id = b.customer_id
join DannyDiner.[dbo].[menu] c
on b.product_id = c.product_id
where  b.order_date < a.join_date 
)

select Customer_id,Product_name

from Occurences
where Occurence=1
---------------------------------------------------------------------------------
--What is the total items and amount spent for each member before they became a member?

select count(product_name),sum(price) from

(select a.customer_id,
	   a.join_date,
	   b.order_date,
	   c.product_name, 
	   c.price

 from DannyDiner.[dbo].[members] a
join DannyDiner.[dbo].[sales] b
on a.customer_id = b.customer_id
join DannyDiner.[dbo].[menu] c
on b.product_id = c.product_id
where  b.order_date < a.join_date)as d

-------------------------------------------------------------------------------------
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select a.customer_id,
	   b.product_name,
	   case 
			when product_name = 'sushi' then (price * 10) * 2
			else price * 10
	   end as points
from DannyDiner.[dbo].[sales] a
join DannyDiner.[dbo].[menu] b
on a.product_id = b.product_id

------------------------------------------------------------------------------------------
--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?


select * from DannyDiner.[dbo].[sales];
select * from DannyDiner.[dbo].[members];
select * from DannyDiner.[dbo].[menu];

select a.Customer_id,sum(points) from
(select a.customer_id,a.join_date,b.order_date,b.product_id,c.product_name,
	   case 
			when  join_date <= order_date and  order_date <= DATEADD(week,1,join_date)   then (price * 10)*2 
			when  join_date <= order_date and  order_date >= DATEADD(week,1,join_date)   then 
			case 
			    when product_name =  'sushi' then (price * 10) * 2
				else price * 10
		    end
	   end as points
 from DannyDiner.[dbo].[members] a
join DannyDiner.[dbo].[sales] b
on a.customer_id = b.customer_id
join DannyDiner.[dbo].[menu] c
on b.product_id = c.product_id
) as a
where MONTH(order_date) = 1
group by a.Customer_id

-----------------------------------------------------------------------------------------