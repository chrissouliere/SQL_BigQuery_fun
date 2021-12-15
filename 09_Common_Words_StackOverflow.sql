-- Most common words used in stackoverflow titles
-- group by TAG

-- unigrams: "the dog ran quickly", ['the', 'dog', 'ran', 'quickly']
-- bigrams: ['the dog', 'dog ran', 'ran quickly']

-- n = 1 -- unigram, n = 2 -- bigram, n = 3 -- trigram
--SELECT ML.NGRAMS(['the', 'dog', 'ran', 'quickly'], [1, 2]) as unigrams_bigrams

--SELECT regexp_extract_all(title, r'\w+') -- r meaning string literal; regexp is slow
WITH base_table AS (
    SELECT tag, title, id, ML.NGRAMS(split(title,  ' '), [1, 3]) as words -- generate unigrams, bigrams, trigrams as repeated field; split title on empty space
    FROM `cms-1145.sampledata.top_questions`
), words_table AS (

SELECT DISTINCT tag, title, lower(trim(word)) AS word
    FROM base_table, UNNEST(words) word 
ORDER BY tag

), ngrams_table AS (

SELECT * FROM (
    SELECT tag, word, COUNT(*) word_frequency,
        ROW_NUMBER() OVER(PARTITION BY tag ORDER BY count(*) DESC) as tag_word_rank
    FROM words_table
    WHERE word NOT in ('a', 'in', 'and', 'or', 'the', 'it', 'if', 'i', 'to', 'for', 'what', 'that', 'with') -- AND lower(tag) = 'python'  -- packages for stop word removal
    GROUP BY 1, 2
    --HAVING COUNT(*) > 1 -- control top N with this count
    ORDER BY 1, 3 DESC
) WHERE tag_word_rank < 20
ORDER BY 1, 4

)

SELECT nt.*
FROM ngrams_table nt
WHERE ARRAY_LENGTH(split(word, ' ')) > 2  -- keep ngrams that are three words
