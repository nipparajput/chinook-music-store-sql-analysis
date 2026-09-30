use chinook;
show tables;

-- Objective_1: Does any table have missing values or duplicates? If yes how would you handle it ?

-- album
SELECT 
    *
FROM
    album
WHERE
    album_id IS NULL OR title IS NULL
        OR artist_id IS NULL;

-- artist
SELECT 
    *
FROM
    artist
WHERE
    artist_id IS NULL OR name IS NULL;

-- customer
desc customer;
SELECT 
    *
FROM
    customer;

SELECT 
    *
FROM
    customer
WHERE
    customer_id IS NULL
        OR first_name IS NULL
        OR last_name IS NULL
        OR company IS NULL
        OR address IS NULL
        OR city IS NULL
        OR state IS NULL
        OR country IS NULL
        OR postal_code IS NULL
        OR phone IS NULL
        OR fax IS NULL
        OR email IS NULL
        OR support_rep_id IS NULL;

SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(company, 'No Company Specified') AS company,
    COALESCE(address, 'No Address Provided') AS address,
    COALESCE(city, 'No City Provided') AS city,
    COALESCE(state, 'No State Provided') AS state,
    COALESCE(country, 'No Country Provided') AS country,
    COALESCE(postal_code, 'Not Available') AS postal_code,
    COALESCE(phone, 'Not Provided') AS phone,
    COALESCE(fax, 'Not Provided') AS fax,
    email,
    COALESCE(support_rep_id, 'Not Taken') AS support_rep_id
FROM
    customer;

-- employee
desc employee;
SELECT 
    *
FROM
    employee
WHERE
    employee_id IS NULL OR last_name IS NULL
        OR first_name IS NULL
        OR title IS NULL
        OR reports_to IS NULL
        OR birthdate IS NULL
        OR hire_date IS NULL
        OR address IS NULL
        OR city IS NULL
        OR state IS NULL
        OR country IS NULL
        OR postal_code IS NULL
        OR phone IS NULL
        OR fax IS NULL
        OR email IS NULL;
 
 SELECT 
    employee_id,
    last_name,
    first_name,
    title,
    COALESCE(reports_to, 'Not Available') AS reports_to,
    birthdate,
    hire_date,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    fax,
    email
FROM
    employee;

-- genre
SELECT 
    *
FROM
    genre
WHERE
    name IS NULL;
    
-- invoice
SELECT 
    *
FROM
    invoice
WHERE
    invoice_id IS NULL
        OR customer_id IS NULL
        OR invoice_date IS NULL
        OR billing_address IS NULL
        OR billing_city IS NULL
        OR billing_state IS NULL
        OR billing_country IS NULL
        OR billing_postal_code IS NULL;
        
-- invoice line
desc invoice line;

-- Media_type
desc media_type;
SELECT 
    *
FROM
    media_type
WHERE
    name IS NULL;
    

-- Playlist
desc playlist;
SELECT 
    *
FROM
    playlist
WHERE
    name IS NULL;


-- Playlist track
desc playlist_track;


-- Track
desc track;
SELECT 
    *
FROM
    track
WHERE
    album_id IS NULL OR genre_id IS NULL
        OR composer IS NULL
        OR bytes IS NULL;
    
SELECT 
    track_id,
    name,
    album_id,
    media_type_id,
    genre_id,
    COALESCE(composer, 'Not Provided') AS composer,
    milliseconds,
    bytes,
    unit_price
FROM
    track;

-- Objective_2
-- checking top selling track
SELECT 
    *
FROM
    invoice;
SELECT 
    *
FROM
    invoice_line;
SELECT 
    *
FROM
    track;
SELECT 
    *
FROM
    customer;

SELECT 
    t.track_id, t.name, SUM(il.quantity) AS total_quantity
FROM
    track t
        INNER JOIN
    invoice_line il ON t.track_id = il.track_id
        INNER JOIN
    invoice i ON il.invoice_id = i.invoice_id
        INNER JOIN
    customer c ON i.customer_id = c.customer_id
WHERE
    c.country = 'USA'
GROUP BY t.track_id , t.name
ORDER BY total_quantity DESC;

    
-- Top Artist
SELECT 
    ar.artist_id, ar.name, SUM(il.quantity) AS total_count
FROM
    customer c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
        INNER JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        INNER JOIN
    track t ON il.track_id = t.track_id
        INNER JOIN
    album a ON t.album_id = a.album_id
        INNER JOIN
    artist ar ON a.artist_id = ar.artist_id
WHERE
    c.country = 'USA'
GROUP BY ar.artist_id , ar.name
ORDER BY total_count DESC;

-- Famous genre

with top_artist as(select ar.artist_id, ar.name, t.genre_id, sum(il.quantity) as total_count
                   from 
	                   customer c
				       inner join
	                   invoice i on c.customer_id= i.customer_id
				       inner join
                       invoice_line il on i.invoice_id= il.invoice_id
                       inner join
                       track t on il.track_id= t.track_id
				       inner join
                       album a on t.album_id= a.album_id
                       inner join
                       artist ar on a.artist_id= ar.artist_id
					where c.country= 'USA'
                    group by ar.artist_id, ar.name, t.genre_id
                    order by total_count desc
                  )
select t.genre_id,artist_id, g.name as genre_type, total_count
from
	top_artist t
	inner join 
	genre g on t.genre_id= g.genre_id
order by total_count desc;

-- Objective_3
-- Customer Demographic Breakdown
SELECT 
    country,
    COALESCE(state, 'NA') AS state,
    city,
    COUNT(customer_id) AS count_of_customer
FROM
    customer
GROUP BY country , state , city
ORDER BY COUNT(customer_id) DESC;

-- Objective_4
-- Total revenue and number of invoices for each country, state, and city
SELECT 
    c.country,
    COALESCE(c.state, 'NA') AS state,
    c.city,
    SUM(i.total) AS total_revenue,
    COUNT(i.invoice_id) count_invoice
FROM
    customer c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.country , c.state , c.city
ORDER BY total_revenue DESC , count_invoice DESC;


-- Objective_5
-- Top 5 Customers by total revenue in each country
with customer_rank as(select
	c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.country,
    sum(i.total) as total_revenue,
    rank() over(partition by c.country order by sum(i.total) desc) as ranking
from
	customer c
    inner join
    invoice i on c.customer_id= i.customer_id
    group by c.customer_id, c.country)
select 
	customer_id,
    customer_name,
    country,
    total_revenue
from customer_rank
where ranking<=5
order by country,ranking;

-- Objective_6
-- Identify the top-selling track for each customer
with customer_total_tracks as (select
	c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    sum(il.quantity) as total_quantity
  from
  customer as c
  join 
  invoice i on c.customer_id = i.customer_id
  join 
  invoice_line il on i.invoice_id = il.invoice_id
  group by c.customer_id, customer_name
)
select
  customer_id,
  customer_name,
  track_name,
  round(total_quantity,2) as total_quantity
from customer_tracks 
where top_rank = 1
order by customer_id;
  
  -- Objective_7
   --  frequency of purchases
   SELECT 
    c.customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    YEAR(i.invoice_date) AS years,
    COUNT(i.invoice_id) AS purchase_quantity
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , customer_name , years
ORDER BY c.customer_id , years ASC;
    
    -- Average order value
    SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    AVG(i.total) AS average_value
FROM
    customer c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , customer_name
ORDER BY average_value DESC;
    
    
-- Objective_8
-- Customer churn rate
with invoice_years as(select
	customer_id,
	year(invoice_date) as year
	from 
	invoice
	group by customer_id, year),
year_pairs as (select distinct
	prev.year as prev_year,
	next.year as next_year
				from invoice_years prev
				join invoice_years next on next.year = prev.year + 1
				),
latest_pair as (select *
				from
					year_pairs
				order by prev_year desc
				limit 1
),
active_prev_year as (select customer_id
                      from invoice_years
                    where year = (select prev_year from latest_pair)
                   ),
active_next_year as (select 
						customer_id
					from invoice_years
					where year = (select next_year from latest_pair)
                    ),
churned_customers as (select 
						customer_id
						from active_prev_year
						where customer_id not in (select customer_id from active_next_year)
					)
select
  (select count(*) from churned_customers) * 100.0 /
  (select count(*) from active_prev_year) as churn_rate_percent;

-- Objective_9
-- Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.

WITH SalesGenreRankUSA AS (
	SELECT
		g.name AS genre, ar.name AS artist, SUM(i.total) AS genre_sales,
        DENSE_RANK() OVER( PARTITION BY g.name ORDER BY SUM(i.total) DESC) AS genre_rank	
	FROM genre g
    LEFT JOIN track t ON g.genre_id = t.genre_id
    LEFT JOIN invoice_line il ON t.track_id = il.track_id
    LEFT JOIN invoice i ON il.invoice_id = i.invoice_id
    LEFT JOIN album a ON t.album_id = a.album_id
    LEFT JOIN artist ar ON a.artist_id = ar.artist_id
    WHERE i.billing_country = 'USA'
    GROUP BY 1,2
),

TotalSalesUSA AS (
	SELECT 
		SUM(i.total) AS total_sales
	FROM invoice_line il 
    LEFT JOIN invoice i ON il.invoice_id = i.invoice_id
    WHERE i.billing_country = 'USA'
)

SELECT s.genre,s.artist,s.genre_sales,t.total_sales, ROUND((s.genre_sales / t.total_sales)* 100,2) AS percent_sales
FROM SalesGenreRankUSA s JOIN TotalSalesUSA t
ORDER BY s.genre_sales DESC, s.genre ASC;

-- Objective_10
-- Customer who purchase atleast 3 genre

SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ',c.last_name) AS customer,
	COUNT(DISTINCT t.genre_id) AS genre_count,
	COUNT(DISTINCT t.track_id) AS track_count
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id,c.first_name,c.last_name
HAVING COUNT(DISTINCT g.genre_id) >=3
ORDER BY genre_count DESC;

-- Objective_11
-- Rank genre based on their sales performance in the USA

WITH SalesWiseGenreRank AS (
	SELECT
		g.name AS genre,
        SUM(i.total) AS total_sales,
        DENSE_RANK() OVER(ORDER BY SUM(i.total) DESC) AS genre_rank	
	FROM genre g
    LEFT JOIN track t ON g.genre_id = t.genre_id
    LEFT JOIN invoice_line il ON t.track_id = il.track_id
    LEFT JOIN invoice i ON il.invoice_id = i.invoice_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.name
)    

SELECT
	genre,total_sales,genre_rank
FROM SalesWiseGenreRank
ORDER BY genre_rank;

-- Objective_12
-- Identify customers who have not made a purchase in the last 3 months   
 
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM
    customer c
        LEFT JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , customer_name
HAVING MAX(i.invoice_date) < DATE_ADD(CURDATE(), INTERVAL - 3 MONTH);


-- Subjective_1
-- Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.

select
	g.name as genre_name,
    a.title as album_name,
    sum(i.total) as total_sales,
    dense_rank() over (order by sum(i.total) desc) as ranks
from 
	customer c
	inner join
    invoice i on c.customer_id= i.customer_id
	inner join
    invoice_line il on i.invoice_id= il.invoice_id
	inner join 
    track t on il.track_id= t.track_id
	inner join
    genre g on t.genre_id= g.genre_id
	inner join
    album a on t.album_id= a.album_id
    where 
		c.country = 'USA'
	group by genre_name, album_name
    order by ranks 
    limit 3;
    
  
-- Subjective_2
 --    Determine the top-selling genre in countries other than the USA and identify any commonalities or differences.
 SELECT 
    g.name AS genre_name, SUM(il.quantity) AS quantity
FROM
    customer c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
        INNER JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        INNER JOIN
    track t ON il.track_id = t.track_id
        INNER JOIN
    genre g ON t.genre_id = g.genre_id
        INNER JOIN
    album a ON t.album_id = a.album_id
WHERE
    c.country <> 'USA'
GROUP BY genre_name
ORDER BY quantity DESC;

-- Subjective_3
-- Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers

with purchase_stat as(select
    c.customer_id,count(il.invoice_id) as purchase_quantity,sum(il.quantity) as total_product_purchase,sum(i.total) as total_spent,
    avg(i.total) as avg_spent_per_order,
    datediff(max(i.invoice_date), min(i.invoice_date)) as customer_lifetime_days
from customer c
	inner join
    invoice i on c.customer_id= i.customer_id
	inner join
    invoice_line il on i.invoice_id= il.invoice_id
    group by c.customer_id),
customer_segment as(select
		customer_id,purchase_quantity,total_product_purchase,
        total_spent,
        avg_spent_per_order,
        customer_lifetime_days,
        case 
        when customer_lifetime_days < 365 then 'recent'
        else 'long-term'
        end as customer_category
        from purchase_stat
    )
    select 
		customer_category,
		round(avg(purchase_quantity),2) as avg_purchase_frequncy,
		round(avg(total_product_purchase),2) as avg_basket_size,
		round(avg(total_spent),2) as avg_spending,
		round(avg(avg_spent_per_order),2) as avg_order_value
	from customer_segment
    group by customer_category;
    
-- for checking the first purchasing date because all the customer show as long_term(old) customer    
SELECT 
    c.customer_id,
    c.first_name,
    MAX(i.invoice_date),
    MIN(invoice_date)
FROM
    customer c
        INNER JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , c.first_name
ORDER BY c.customer_id;
    
-- Subjective_4
-- affinity of genre
with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1  join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
combine_genre as(select t1.genre_id as genre1, t2.genre_id as genre2, count(*) time_of_purchase_together
from 
	track_combine as t
	inner join track t1 on t.track1= t1.track_id 
	inner join track t2 on t.track2= t2.track_id
    where t1.genre_id<>t2.genre_id
	group by genre1, genre2)
    select 
		g1.name as genre_name1, g2.name as genre_name2, time_of_purchase_together
    from 
		combine_genre cg
		inner join
        genre as g1 on cg.genre1= g1.genre_id
		inner join 
        genre as g2 on cg.genre2= g2.genre_id
	order by time_of_purchase_together desc;
    
    
    -- affinity of artist
    with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1  join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
artist_combination as(select ar1.artist_id as artist1, ar2.artist_id as artist2, count(*) time_of_purchase_together
from 
	track_combine as t
	inner join track t1 on t.track1= t1.track_id 
	inner join track t2 on t.track2= t2.track_id
	inner join album a1 on t1.album_id= a1.album_id
	inner join album a2 on t2.album_id= a2.album_id
	inner join artist ar1 on a1.artist_id= ar1.artist_id
	inner join artist ar2 on a2.artist_id= ar2.artist_id
where ar1.artist_id<> ar2.artist_id
group by artist1, artist2)
select ar1.name as artist_name_1,
		ar2.name as artist_name_2, time_of_purchase_together
from 
	artist_combination ar
	inner join artist ar1 on ar.artist1= ar1.artist_id
	inner join artist ar2 on ar.artist2= ar2.artist_id
order by time_of_purchase_together desc;


-- album affinity analysis
 with track_combine as(select 
	il1.track_id as track1,
    il2.track_id as track2,
    count(*) as purchase_toagrther
from 
	invoice_line il1  join invoice_line il2 on il1.invoice_id= il2.invoice_id and il1.track_id<il2.Track_id
	group by track1,track2),
album_combination as(select a1.album_id as album1, a1.album_id as album2, count(*) time_of_purchase_together
from 
	track_combine as t
	inner join track t1 on t.track1= t1.track_id 
	inner join track t2 on t.track2= t2.track_id
	inner join album a1 on t1.album_id= a1.album_id
	inner join album a2 on t2.album_id= a2.album_id
where a1.album_id<> a2.album_id
group by album1,album2)
select a.title as album_name,
		a1.title as album_name,
        time_of_purchase_together
from 
	album_combination ac
	inner join album a on ac.album1= a.album_id
	inner join album a1 on ac.album2= a1.album_id
order by time_of_purchase_together desc;
    
    
-- subjective_5
-- customer purchasing behaviour by region
with customer_purchase as (select 
    c.customer_id,
    c.country,
    coalesce(c.state, 'not available') as state,
    c.city,
    count(i.invoice_id) as total_purchases,
    sum(i.total) as total_spending,
    avg(i.total) as avg_order_value
  from customer c
inner join 
  invoice i on c.customer_id = i.customer_id
  group by c.customer_id, c.country, c.state, c.city)
select 
  country,
  state,
  city,
  count(customer_id) as total_customers,
  sum(total_purchases) as total_purchases,
  round(sum(total_spending),2) as total_spending,
  round(avg(avg_order_value),2) as avg_order_value,
  round(avg(total_purchases),2) as avg_purchase_frequency
from customer_purchase
group by country, state, city
order by total_spending desc;


--  Churn Rate by Region 
with region_churn_rate as (select 
	c.customer_id,c.country,
	coalesce(c.state,"Not Available") as state,
	c.city,max(i.invoice_date) as latest_date_purchased
from 
    customer c 
	inner join 
    invoice i on c.customer_id = i.customer_id
group by c.customer_id,c.country,state,c.city),
churn_customer as (select 
	country,state,city,
	count(customer_id) as churn_customer
from region_churn_rate
where 
	latest_date_purchased < date_sub(curdate() , interval 1 year)
group by country,state,city)
select 
	cc.country,
    cc.state,
    cc.city,cc.churn_customer,
	count(c.customer_id) as total_customer,
	cc.churn_customer/count(c.customer_id)*100 as churn_rate
from 
	churn_customer cc
	inner join 
	customer c on cc.country = c.country and cc.state = c.state and cc.city = c.city
group by cc.country,cc.state,cc.city,cc.churn_customer;



-- Subjective_6
-- Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history)
with latest_invoice_date as (select 
	max(invoice_date) as latest_date
from invoice
),
customer_purchase_summary as (select c.customer_id, c.country, coalesce(c.state,'Not Available') as state, c.city, count(i.invoice_id) as total_orders,
	sum(i.total) as total_spent, avg(i.total) as avg_purchase_amount, sum(il.quantity) as total_quantity,
	avg(il.quantity) as avg_quantity, max(i.invoice_date) as last_purchase_date
    from 
    customer c  join 
    invoice i on c.customer_id = i.customer_id
     join invoice_line il on i.invoice_id = il.invoice_id
    group by c.customer_id, c.country, state, c.city
),
customer_risk_profile as (select 
	c.*,
	case 
		when c.last_purchase_date < date_sub((select latest_date from latest_invoice_date), interval 1 year) 
		then 'Risk'
		when c.total_spent < 1000
		then 'Medium Risk'
		else 'Low Risk'
        end as risk_level
from customer_purchase_summary c
)
select *
from customer_risk_profile
order by risk_level desc, total_spent;


-- Subjective_7
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COALESCE(c.state, 'Not Available') AS state,
    MIN(i.invoice_date) AS first_purchase,
    MAX(i.invoice_date) AS last_purchase,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure,
    COUNT(i.invoice_id) AS purchase_count,
    SUM(i.total) AS total_spend,
    ROUND(AVG(i.total), 2) AS avrage_spend,
    CASE
        WHEN MAX(i.invoice_date) < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) THEN 'churn'
        ELSE 'active'
    END AS status,
    CASE
        WHEN SUM(i.total) >= 100 THEN 'high value'
        WHEN SUM(i.total) >= 50 THEN 'mid value'
        ELSE 'low value'
    END AS spending_segment,
    CASE
        WHEN
            COUNT(DISTINCT invoice_id) >= 12
                AND DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) > 90
        THEN
            'frequent'
        WHEN COUNT(DISTINCT invoice_id) BETWEEN 6 AND 11 THEN 'occasional'
        ELSE 'rare'
    END AS frequency_segment,
    ROUND(AVG(i.total) * COUNT(i.invoice_id) * DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) / 365,
            2) AS customer_lifetime_value
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , state , c.country;

-- Subjective_10
-- How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album
alter table album 
add column releaseyear integer;
SELECT 
    *
FROM
    album;
    
-- some id updated 2017
UPDATE album 
SET 
    releaseyear = 2017
WHERE
    album_id IN (1 , 3, 4, 6, 7);

-- some id updated 2018
UPDATE album 
SET 
    releaseyear = 2018
WHERE
    album_id IN (2 , 5, 8, 9, 10);



-- Subjective_11
with purchase_summary as(select 
	c.customer_id,
	c.country,
	sum(il.quantity) as total_tracks,
	sum(i.total) as total_spent
from 
	customer c
	inner join 
    invoice i on c.customer_id = i.customer_id
	inner join 
    invoice_line il on i.invoice_id = il.invoice_id
    group by c.customer_id, c.country)
select 
    country,
    count(distinct customer_id) as number_of_customers,
    round(sum(total_tracks), 2) as total_tracks,
    round(avg(total_tracks), 2) as average_tracks_purchased_per_customer,
    round(sum(total_spent), 2) as total_amount_spent,
    round(avg(total_spent), 2) as average_amount_spent_per_customer
from purchase_summary
group by country
order by average_amount_spent_per_customer desc;