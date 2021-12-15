-- Moving averages
-- [50 day, 200 day, is the 50 > 200 day?]
-- Buy and Hold vs trade on the x-over

WITH base_table AS (
    SELECT sp.*,
    AVG(sp.close) OVER(ORDER BY sp.Date
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS fifty_ma,
    AVG(sp.close) OVER(ORDER BY sp.Date
        ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS two_hundred_ma,
    FROM `cms-1145.sampledata.stock_prices` sp 
), signals AS (
    SELECT bt.*, 
    IF(bt.fifty_ma > bt.two_hundred_ma, 'Buy', 'Sell') AS signal -- IF TRUE, buy, else sell
    FROM base_table bt
)

SELECT * FROM (
    SELECT s.*,
        LAG(s.signal) OVER(ORDER BY s.Date) AS prev_signal,
        LAG(s.signal) OVER(ORDER BY s.Date) <> s.signal AS changed_signal 
    FROM signals s
ORDER By 1
) WHERE changed_signal = true