-- Unnest, Running Totals & Correlated subquery

--SELECT val, SUM(val) OVER(ORDER BY val) as cumulative_sum
--FROM UNNEST(GENERATE_ARRAY(1, 5)) as val  -- will unnest repeated fields into seperate fields, hence will unnest into distinct rows
--GROUP BY val

WITH base_table AS (
    SELECT dollars, index 
    FROM UNNEST(GENERATE_ARRAY(1, 5)) dollars WITH OFFSET AS INDEX
)

-- correlated subquery
SELECT bt.*, -- outer query
( -- inner query which is correlated(uses some information) from outer table, here using something to do with row index
    SELECT SUM(bt2.dollars)
    FROM base_table bt2
    WHERE bt2.index <= bt.index
) as running_dollars_total
FROM base_table bt