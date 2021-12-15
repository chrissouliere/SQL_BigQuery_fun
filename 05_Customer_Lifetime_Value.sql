-- 1) Customers, Lifetime Value
-- [customerid, first order date, total revenue, 1st order revenue]
-- mainly what I need

WITH customer_first_orders AS (

    SELECT * FROM (
        SELECT customer_id, amount, payment_date,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS order_nth
        FROM `cms-1145.sampledata.payments`
        ORDER BY 1  
    ) WHERE order_nth = 1
), summary_so_far AS (

    SELECT p.customer_id,
    c.amount AS first_order_amount,
    MIN(p.payment_date) AS first_payment, 
    SUM(p.amount) AS total_revenue, -- can use `SELECT DISTINCT customer_id` if you want to see if customer_id (i.e., rows) are duplicated
    c.amount / sum(p.amount) AS first_as_pct_total_rev

FROM `cms-1145.sampledata.payments` p
    JOIN customer_first_orders c ON c.customer_id = p.customer_id
GROUP BY 1,2

)

-- 2) Customers, orders within the first 30, 60, 90 days of their 1st purchase

SELECT sf.*, (
    SELECT sum(p2.amount)
    FROM `cms-1145.sampledata.payments` p2
    WHERE p2.customer_id = sf.customer_id 
    AND DATE(p2.payment_date) BETWEEN DATE(sf.first_payment) AND 
    DATE(sf.first_payment) + 30 -- DATE_ADD(DATE(sf.first_payment), INTERVAL 30 DAY) 
) AS customer_TV_first_30, -- customer_total_value_after_first_purchase

(
    SELECT sum(p2.amount)
    FROM `cms-1145.sampledata.payments` p2
    WHERE p2.customer_id = sf.customer_id 
    AND DATE(p2.payment_date) BETWEEN DATE(sf.first_payment) 
    AND DATE_ADD(DATE(sf.first_payment), INTERVAL 60 DAY) --AND DATE(sf.first_payment) + 60
) AS customer_TV_first_60,

( 
    SELECT sum(p2.amount)
    FROM `cms-1145.sampledata.payments` p2
    WHERE p2.customer_id = sf.customer_id
    AND DATE(p2.payment_date) BETWEEN DATE(sf.first_payment) 
    AND DATE_ADD(DATE(sf.first_payment), INTERVAL 90 DAY) --AND DATE (sf.first_payment) + 90
) AS customer_TV_first_90

FROM summary_so_far sf
ORDER BY 1







