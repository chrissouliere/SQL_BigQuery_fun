-- Get information about the orders
-- Join to customers
-- Filter the table for customers whose customer_order_number max is > 1

WITH base_table AS (
    SELECT 
        customer_unique_id, 
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER(PARTITION BY customer_unique_id -- iterates (counts) over n, here being the customer_unique_id
        ORDER BY o.order_purchase_timestamp) as customer_order_number,  -- order clause to tell on you want the iterated data (ascending here) to be organsized and create a new column
    FROM `cms-1145.sampledata.customers` c
    JOIN `cms-1145.sampledata.orders` o ON o.customer_id = c.customer_id
ORDER BY 1, 2
), exclude_these AS ( -- gets customers have have only one order, which will be excluded in the last query below
    SELECT customer_unique_id, max(customer_order_number) as max_customer_order_number
    FROM base_table
    GROUP BY customer_unique_id
    HAVING max(customer_order_number) = 1
    ORDER BY max_customer_order_number DESC
)

SELECT * 
FROM base_table 
WHERE customer_unique_id NOT IN (SELECT  -- basically excluded unique customers who have purchase > 1 order
customer_unique_id FROM exclude_these)
ORDER BY customer_unique_id, customer_order_number


