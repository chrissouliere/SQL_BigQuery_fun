-- Customer Orders part 2
-- For customers with > 1 order, avg time in days between orders
-- LAG() the over purchase timestamp along the customer

with base_table AS (
    SELECT 
        customer_unique_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(PARTITION BY customer_unique_id
        ORDER BY o.order_purchase_timestamp) as customer_order_number
    FROM `cms-1145.sampledata.customers` c
    JOIN `cms-1145.sampledata.orders` o ON o.customer_id = c.customer_id
    ORDER BY customer_unique_id, order_purchase_timestamp

), exclude_these AS (
    SELECT customer_unique_id, max(customer_order_number) as max_customer_order_number
    FROM base_table
    GROUP BY customer_unique_id
    HAVING max(customer_order_number) = 1
    ORDER BY max_customer_order_number DESC

), prev_data_table AS (
    SELECT 
        customer_unique_id,
        order_purchase_timestamp,
        customer_order_number,
        EXTRACT(day FROM
            (DATE(order_purchase_timestamp) - LAG(DATE(order_purchase_timestamp)) OVER (PARTITION BY customer_unique_id ORDER BY customer_order_number))
            ) as date_diff
        FROM base_table 
    WHERE customer_unique_id NOT IN (SELECT  -- basically subquery which include unique customers who have purchase > 1 order
    customer_unique_id FROM exclude_these)
    ORDER BY customer_unique_id, customer_order_number
    )

SELECT
customer_order_number,
AVG(pd.date_diff) as mean_number_days_between_orders, -- I presume null iterations are excluded
COUNT(DISTINCT customer_unique_id) as unique_customers
FROM prev_data_table pd
GROUP BY customer_order_number
ORDER BY customer_order_number