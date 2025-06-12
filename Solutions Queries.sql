
CREATE TABLE NETFLIX (
	SHOW_ID VARCHAR PRIMARY KEY,
	TYP VARCHAR,
	TITLE VARCHAR,
	DIRECTOR VARCHAR,
	CASTING VARCHAR,
	COUNTRY VARCHAR,
	DATE_ADDED DATE,
	RELEASE_YEAR INT,
	RATING VARCHAR,
	DURATION VARCHAR,
	LISTED_IN VARCHAR,
	DESCRIPTION TEXT
);

SELECT
	*
FROM
	NETFLIX;

-- 1. Count the number of Movies vs TV Shows
SELECT
	TYP,
	COUNT(TYP)
FROM
	NETFLIX
GROUP BY
	TYP;

-- 2. Find the most common rating for movies and TV shows
WITH
	RNK_CTE AS (
		SELECT
			TYP,
			RATING,
			COUNT(RATING) AS RATING_COUNT,
			RANK() OVER (
				PARTITION BY
					TYP
				ORDER BY
					COUNT(RATING) DESC
			) AS RNK
		FROM
			NETFLIX
		GROUP BY
			TYP,
			RATING
	)
SELECT
	TYP,
	RATING,
	RATING_COUNT
FROM
	RNK_CTE
WHERE
	RNK = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT title,release_year,typ FROM Netflix WHERE release_year='2020' AND typ ='Movie';

-- 4. Find the top 5 countries with the most content on Netflix
WITH country_cte as 
(SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country 
FROM Netflix)
SELECT country, 
count(country) as total_content 
from country_cte 
group by country 
order by total_content 
desc limit 5;

-- 5. Identify the longest movie

SELECT title,duration from (SELECT
	TITLE,
	DURATION,
	CAST(SPLIT_PART(DURATION, ' ', 1) AS INTEGER) AS MINUTES
FROM
	NETFLIX
WHERE
	TYP = 'Movie'
	AND DURATION ILIKE '%min'
ORDER BY
	MINUTES DESC) as result;

-- 6. Identify the TV Show with highest no. of Seasons
select title,duration from 
(SELECT
	TITLE,
	DURATION,
	CAST(SPLIT_PART(DURATION, ' ', 1) AS INTEGER) AS Seasons
FROM
	NETFLIX
WHERE
	TYP = 'TV Show'
	AND DURATION ILIKE '%Season%') as result order by Seasons DESC limit 1;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT title,typ,director FROM Netflix WHERE director ILIKE '%Rajiv Chilaka%'; 

-- 8. List all TV shows with more than 5 seasons
WITH season_cte as 
	(SELECT 
	title,typ,
	CAST(SPLIT_PART(duration,' ',1) as INTEGER)
	AS total_seasons from Netflix WHERE
	TYP = 'TV Show'
	AND DURATION ILIKE '%Season%') 
	SELECT * FROM season_cte
	WHERE total_seasons > 5 
	order by total_seasons asc;

-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as Genre,count(title) as total_content FROM Netflix group by Genre order by total_content DESC;

/* 10.Find the numbers of content released each year in India on netflix. 
return top 5 year with highest content release! */
SELECT 
EXTRACT(YEAR FROM date_added) as Netflix_release_year,
COUNT(title) as Total_content 
FROM Netflix 
WHERE country ILIKE '%India%' 
GROUP BY Netflix_release_year
ORDER BY 2 DESC limit 5 ;

-- 11. List all movies that are documentaries
SELECT title,listed_in from Netflix WHERE listed_in ILIKE '%Documentaries%' and typ ILIKE '%Movie%';

-- 12. Find all content without a director
SELECT title,director FROM Netflix WHERE director is NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT title,
release_year,
casting 
FROM Netflix
WHERE casting ILIKE '%Salman Khan%' 
AND typ = 'Movie'
AND release_year 
BETWEEN EXTRACT(YEAR FROM CURRENT_DATE) - 10 
AND EXTRACT(YEAR FROM CURRENT_DATE) 
ORDER BY release_year;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT TRIM(actor_name) as actor,
COUNT(actor_name) as total_movies from 
(SELECT UNNEST(STRING_TO_ARRAY(casting,',')) 
AS actor_name from Netflix 
WHERE typ = 'Movie' 
AND country ILIKE '%india%') 
GROUP BY actor 
ORDER BY total_movies
DESC LIMIT 10;


/* 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */
WITH categoriesed_cte AS (SELECT title,
	(CASE WHEN description ILIKE '%Kill%' OR description ILIKE '%violence%' 
	THEN 'Bad Content'
	ELSE 'Good Content' END ) AS Category,
	description FROM Netflix)
	SELECT category, count(title) as total_content from categoriesed_cte group by category;


-- 16. Find content added in the last 5 years
SELECT title,
date_added 
FROM Netflix 
WHERE EXTRACT(YEAR FROM date_added) 
BETWEEN EXTRACT(YEAR FROM CURRENT_DATE) - 5 
AND EXTRACT(YEAR FROM CURRENT_DATE) ORDER BY date_added ASC;