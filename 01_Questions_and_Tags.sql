-- How many questions does a tag have?
-- What about the tags themselves - how often does the substring show up in the tag?

-- 506,055 rows (title based match)
-- 509,345 rows (tag based match)
-- try to get single row per doc, title field, tags field

--outcome
-- keyword in title AND in tags
-- keyword in title NOT in tags
-- keyword NOT in title and in tags
-- keyword not in title or in tags

WITH base_table AS(
SELECT 
    DISTINCT id, 
    title, 
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT tag), " ") as tag_content 
FROM `cms-1145.sampledata.top_questions` 
GROUP BY 1,2
), language_table AS(

SELECT
id,
CASE 
    WHEN title LIKE '%python%' AND tag_content LIKE '%python%' THEN 'python_in_both'
    WHEN title LIKE '%python%' AND tag_content NOT LIKE '%python%' THEN 'python_title_only'
    WHEN title NOT LIKE '%python%' AND tag_content LIKE '%python%' THEN 'python_tag_only'

    WHEN title LIKE '%sql%' AND tag_content LIKE '%sql%' THEN 'sql_in_both'
    WHEN title LIKE '%sql%' AND tag_content NOT LIKE '%sql%' THEN 'sql_title_only'
    WHEN title NOT LIKE '%sql%' AND tag_content LIKE '%sql%' THEN 'sql_tag_only'

    WHEN title LIKE '%javascript%' AND tag_content LIKE '%javascript%' THEN 'javascript_in_both'
    WHEN title LIKE '%javascript%' AND tag_content NOT LIKE '%javascript%' THEN 'javascript_title_only'
    WHEN title NOT LIKE '%javascript%' AND tag_content LIKE '%javascript%' THEN 'javascript_tag_only'

    ELSE NULL
    END as language
FROM base_table 
ORDER BY 1
)

SELECT COALESCE(language, "no_match"), COUNT(*) as number_of_questions -- because there are so many null returns, easier to group things by count
FROM language_table
GROUP BY 1
ORDER BY 2 DESC
