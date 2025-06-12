# Netflix Movies and TV Shows Data Analysis using SQL

![Logo_Image](https://github.com/vinayraghu1c/Netflix_content_analysis_SQL/blob/main/Netflix%20Logo.jpg)!


## Overview
This project presents a comprehensive analysis of Netflix's movies and TV shows dataset using SQL. The objective is to extract meaningful insights and address various business-related queries through structured data exploration. This README outlines the project’s aim, approach, and the range of problems tackled during the analysis.

## Objectives

- Analyze the distribution between Movies and TV Shows.
- Identify the most frequent content ratings.
- Explore content by release year, country, and duration.
- Categorize content based on genres and keywords.
- Address specific business queries related to content trends, metadata gaps, and cast/director insights

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS NETFLIX;
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows.

```sql
SELECT
	TYP,
	COUNT(TYP)
FROM
	NETFLIX
GROUP BY
	TYP;
```
**Objective:** Determine the distribution of content types on Netflix.


### 2. Find the Most Common Rating for Movies and TV Shows.
```sql
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
```
**Objective:** Identify the most frequently occurring rating for each type of content.


### 3. List All Movies Released in a Specific Year (e.g., 2020).
```sql
SELECT title,
release_year,
typ FROM Netflix
WHERE release_year='2020' AND typ ='Movie';
```
**Objective:** Retrieve all movies released in a specific year.
.
### 4. Find the top 5 countries with the most content on Netflix.
```sql
WITH country_cte as 
(SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country 
FROM Netflix)
SELECT country, 
count(country) as total_content 
from country_cte 
group by country 
order by total_content 
desc limit 5;
```
**Objective:** Identify the top 5 countries with the highest number of content items.


### 5. Identify the Longest Movie.
```sql
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
```
**Objective:** Find the movie with the longest duration.


### 6. Identify the TV Show with highest no. of Seasons.
```sql
select title,duration from 
(SELECT
	TITLE,
	DURATION,
	CAST(SPLIT_PART(DURATION, ' ', 1) AS INTEGER) AS Seasons
FROM
	NETFLIX
WHERE
	TYP = 'TV Show'
	AND DURATION ILIKE '%Season%') as result
  order by Seasons DESC limit 1;
```
**Objective:** Find the TV Show with the highest seasons


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'.
```sql
SELECT title,
typ,
director FROM Netflix
 WHERE director ILIKE '%Rajiv Chilaka%'; 
```
**Objective:** List all content directed by 'Rajiv Chilaka'.


### 8. List All TV Shows with More Than 5 Seasons.
```sql
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
```
**Objective:** Identify TV shows with more than 5 seasons.


### 9. Count the Number of Content Items in Each Genre.
```sql
SELECT
UNNEST(STRING_TO_ARRAY(listed_in,','))
as Genre,
count(title) as total_content
FROM Netflix
group by Genre
order by total_content DESC;
```
**Objective:** Count the number of content items in each genre.


### 10.Find each year and the numbers of content release in India on netflix. 
### return top 5 year with highest content release!
```sql
SELECT 
EXTRACT(YEAR FROM date_added) as Netflix_release_year,
COUNT(title) as Total_content 
FROM Netflix 
WHERE country ILIKE '%India%' 
GROUP BY Netflix_release_year
ORDER BY 2 DESC limit 5 ;
```
**Objective:** Calculate and rank years by the average number of content releases by India.


### 11. List All Movies that are Documentaries
```sql
SELECT title,
listed_in from Netflix
WHERE listed_in ILIKE '%Documentaries%'
and typ ILIKE '%Movie%';
```
**Objective:** Retrieve all movies classified as documentaries.


### 12. Find All Content Without a Director
```sql
SELECT title,
director FROM Netflix
WHERE director is NULL;
```
**Objective:** List content that does not have a director.


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
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
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
SELECT TRIM(actor_name) as actor,
COUNT(actor_name) as total_movies from 
(SELECT UNNEST(STRING_TO_ARRAY(casting,',')) 
AS actor_name from Netflix 
WHERE typ = 'Movie' 
AND country ILIKE '%india%') 
GROUP BY actor 
ORDER BY total_movies
DESC LIMIT 10;
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
WITH categoriesed_cte AS (SELECT title,
	(CASE WHEN description ILIKE '%Kill%'
    OR description ILIKE '%violence%' 
	  THEN 'Bad Content'
	  ELSE 'Good Content' END ) AS Category,
	  description FROM Netflix)
  	SELECT category, count(title) as total_content
     from categoriesed_cte group by category;
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


### 16. Find content added in the last 5 years
```sql
SELECT title,
date_added 
FROM Netflix 
WHERE EXTRACT(YEAR FROM date_added) 
BETWEEN EXTRACT(YEAR FROM CURRENT_DATE) - 5 
AND EXTRACT(YEAR FROM CURRENT_DATE) 
ORDER BY date_added ASC;
```
**Objective:** content added in the last 5 years.


### Findings and Conclusion

- **Content Variety:** Netflix offers a wide mix of movies and TV shows across different genres and formats.
- **Audience Targeting:** The most frequent content ratings reveal patterns in audience segmentation and preferences.
- **Regional Trends:** Country-wise insights, especially India's contribution, shed light on regional content distribution and growth.
- **Thematic Analysis:** Keyword-based categorization provides a lens into the tone and themes prevalent in the catalog.

Overall, this analysis offers valuable insights into Netflix’s content landscape and supports data-driven content planning and strategy.

### MY LINKEDIN : https://www.linkedin.com/in/vinay-raghuwanshi
