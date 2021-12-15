-- Regular Expressions regexp: pattern matching logic

WITH base_table AS (
SELECT *,
    regexp_extract(occurrence_range, r'\d+') AS low_char,-- '\d+' is one or more digit 
    regexp_extract(occurrence_range, r'\D(\d+)') AS high_char, -- non-digit followed by () creates a capture group
    array_length(regexp_extract_all(datafield, character)) AS nbr_matches -- UNNEST is more complicated
FROM `cms-1145.sampledata.aoc2017day2`
), second_table AS(
    SELECT *, 
SUBSTR(datafield, cast(low_char as INT64), 1) AS datafield_at_low,
SUBSTR(datafield, cast(high_char as INT64), 1) AS datafield_at_high
FROM base_table 
)

--case 1, datafield_at_low = character OR datafield_at_high = character  [one equal]
--case 2, datafield_at_low != character AND datafield_at_high != character [neither equal]
--case 1, datafield_at_low = character AND datafield_at_high = character   [both equal]
SELECT * FROM (
SELECT *, 
    CASE
        WHEN datafield_at_low = character AND datafield_at_high = character THEN False
        WHEN datafield_at_low = character OR datafield_at_high = character THEN True
        ELSE False
    END AS outcome
FROM second_table 
) WHERE outcome = True




