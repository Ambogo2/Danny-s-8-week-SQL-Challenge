/*What is the total amount each customer spent at the restaurant?*/
SELECT a.customer_id, SUM(b.price) as total_spent
FROM sales a
INNER JOIN menu b ON a.product_id = b.product_id
GROUP BY a.customer_id
ORDER BY total_spent DESC;

/*How many days has each customer visited the restaurant?*/
SELECT customer_id,  count(DISTINCT order_date) as numberofdays
FROM sales as a 
GROUP BY customer_id
ORDER BY numberofdays;

/*What was the first item from the menu purchased by each customer?*/
WITH final AS (
	SELECT a.*, b.product_name, 
	RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS ranking
    FROM sales AS a
    JOIN menu AS b
    ON a.product_id = b.product_id
)
SELECT * FROM final
WHERE ranking = 1;

/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
SELECT b.product_name, count(*)
FROM sales AS a
JOIN menu AS b
ON a.product_id = b.product_id
GROUP BY b.product_name 

/*Which item was the most popular for each customer?*/

WITH final AS (
	SELECT a.customer_id, b.product_name, COUNT(*) AS total
	FROM sales AS a
	JOIN menu AS b
	ON a.product_id = b.product_id
	GROUP BY a.customer_id, b.product_name
)  
SELECT customer_id, product_name, total,
RANK() OVER (PARTITION BY customer_id ORDER BY total DESC) AS ranking
FROM final;

/*Which item was purchased just before the customer became a member?*/
WITH final as (
	SELECT a.*, b.customer_id as customerid, b.join_date,
	rank() over (PARTITION BY a.customer_id ORDER BY order_date) AS ranking,
	c.product_name
    FROM sales AS a
    LEFT JOIN members AS b
    ON a.customer_id = b.customer_id
    JOIN menu AS c
    ON a.product_id =c.product_id
    WHERE a.order_date>=b.join_date
    )
    SELECT customer_id, ranking, product_name FROM final WHERE ranking=1
    
    
 /* What are the total items and amount spent for each member before they became a member?*/
    SELECT a.*, b.customer_id as customerid, b.join_date, rank() over (PARTITION BY a.customer_id ORDER BY order_date) AS ranking, c.product_name
    FROM sales AS a
    LEFT JOIN members AS b
    ON a.customer_id = b.customer_id
    JOIN menu AS c
    ON a.product_id =c.product_id
    WHERE a.order_date<b.join_date
    
  /*What are the total items and amount spent for each member before they became a member?*/
    WITH memberdata as (
	SELECT a.customer_id,a.order_date,b.join_date,c.price,c.product_name
	FROM sales AS a
	LEFT JOIN members AS b
	on a.customer_id=b.customer_id
	join menu AS c
	on a.product_id=c.product_id
	WHERE a.order_date<b.join_date
	)
  
 SELECT customer_id, sum(price) as amount_spent ,count(distinct product_name) as  items
 FROM memberdata
 GROUP BY customer_id
 
 /*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
 WITH points as(
SELECT a.customer_id, a.order_date, c.product_name,c.price,
  CASE WHEN product_name = 'sushi' THEN 2 * c.price
       ELSE c.price END AS newprice
FROM sales AS a
JOIN menu AS c
ON a.product_id = c.product_id
)
SELECT customer_id, sum(newprice)*10 as points_received from points
GROUP BY customer_id 
ORDER BY points_received DESC;

 
 /*In the first week after a customer joins the program (including their join date) 
 they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?*/
 WITH finalpoints as(
SELECT a.customer_id, a.order_date, c.product_name,c.price,
  CASE WHEN product_name = 'sushi' THEN 2 * c.price
  WHEN a.order_date between b.join_date and (b.join_date+ interval 6 day) then 2*c.price
       ELSE c.price END AS newprice
FROM sales AS a
JOIN menu AS c
ON a.product_id = c.product_id
JOIN MEMBERS AS b
ON a.customer_id=b.customer_id
WHERE a.order_date<='2021-01-31'
)
SELECT customer_id, sum(newprice)*10 as points_received from finalpoints
GROUP BY customer_id 
ORDER BY points_received DESC;
 
 


  
  
  
  
  
  
