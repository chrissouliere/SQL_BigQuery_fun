-- Which language has seen the greatest increase in views YoY?
-- Which language is becoming more popular with time?

WITH base_table AS(
    SELECT  
        DISTINCT 
            CASE 
            when title LIKE '%python%' then 'python'
            when title LIKE '%sql%' then 'sql'
            when title LIKE '%javascript%' then 'javascript'
            when title LIKE '%ruby%' then 'ruby'
            ELSE NULL
        end as language, id, quarter, quarter_views
        FROM `cms-1145.sampledata.top_questions`  
), summary_table AS (

SELECT COALESCE(language, "no_match") as language, extract(year from quarter) as year, sum(quarter_views) as views
FROM base_table
-- 'WHERE language is not null' replaces COALESCE
GROUP BY 1,2 -- need to group year because extract doesn't do so
ORDER BY 1,2 DESC

)

-- Numbering function, window function, analytic function, LAG, ROW_NUMBER, RANK, LEAD
SELECT st.*, round((views / LAG(views) OVER (PARTITION BY language ORDER BY YEAR) - 1) * 100, 2) || '%' as pct_change_yoy
FROM summary_table st
