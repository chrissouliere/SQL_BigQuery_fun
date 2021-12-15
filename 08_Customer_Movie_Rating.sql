-- For each customer, their top 2 movie ratings by rental revenue for each month
-- meaning, customer_id, PG-13, 1
--          customer_id, R,     2

with base_table AS (
SELECT 
p.payment_id AS p_payment_id,
p.amount AS p_amount,
p.customer_id AS p_customer_id,
p.rental_id AS p_rental_id,
p.payment_date AS p_payment_date,
i.film_id AS i_film_id,
f.title AS f_title_id,
f.rating AS f_rating
FROM `cms-1145.sampledata.payments` p
    JOIN `cms-1145.sampledata.rental` r ON p.rental_id = r.rental_id
    JOIN `cms-1145.sampledata.inventory` i ON r.inventory_id = i.inventory_id
    JOIN `cms-1145.sampledata.film` f ON i.film_id = f.film_id
), summary_table AS (

SELECT bt.p_customer_id, bt.f_rating, 
    EXTRACT(MONTH FROM DATE(bt.p_payment_date)) AS month, 
    SUM(bt.p_amount) AS rental_revenue,
FROM base_table bt
GROUP BY 1, 2, 3
ORDER BY 1, 3 

)

SELECT * FROM (
SELECT st.*,
ROW_NUMBER() OVER(PARTITION BY st.p_customer_id, st.month 
    ORDER BY st.month, st.rental_revenue DESC) AS rating_customer_revenue_month
FROM summary_table st
ORDER BY 1, 3, 5
) t WHERE t.rating_customer_revenue_month < 3
