--With the dataset loaded in through importing the csv, I have a look at the general data
SELECT *
FROM reviews
LIMIT 10;

--I can see there is a store_address column that isn't normalised, so first I look at how many stores this data is across:

SELECT COUNT(DISTINCT store_address)
FROM reviews;

--40, and what the store addresses are:

SELECT DISTINCT store_address
FROM reviews;

--Here I can see there was an error with one of the addresses, showing as "2476 Kal���������������". After finding out the address online, I update this:

UPDATE reviews
SET store_address = '2476 Kalakaua Ave, Honolulu, HI 96815, United States'
WHERE store_address ILIKE '2476 Kal';

--Now that is done, I can continue normalising this column
--They are multi line addresses seperated by commas, so I want to split these into different columns
SELECT DISTINCT store_address,
	SPLIT_PART(store_address,',',-4) AS line1,
	SPLIT_PART(store_address,',',-3) AS city,
	LEFT(SPLIT_PART(store_address,',',-2),3) AS state,
	RTRIM(SPLIT_PART(store_address,' ',-3),',') AS zip
FROM reviews;

--Now I've split the address, I'll create a view with the normalised addresses (category isn't included as all vaues were the same)

DROP VIEW IF EXISTS normalised_reviews;
CREATE VIEW normalised_reviews AS
SELECT 
	reviewer_id,
	store_name,
	SPLIT_PART(store_address,',',-4) AS store_line1,
	SPLIT_PART(store_address,',',-3) AS store_city,
	LEFT(SPLIT_PART(store_address,',',-2),3) AS store_state,
	rtrim(SPLIT_PART(store_address,' ',-3),',') AS store_zip,
	latitude,
	longitude,
	rating_count,
	review_time,
	review,
	rating
FROM reviews;

--Now, i'd like to see the spread of reviews per city

SELECT 
	store_city,
	rating,
	COUNT(rating)
FROM normalised_reviews
GROUP BY rating,store_city
ORDER BY store_city, rating DESC;

--I want to convert the ratings to integers as I want to be able to carry out some numerical analysis:

SELECT 
	store_line1,
	store_city,
	store_state,
	store_zip,
	CAST(SPLIT_PART(rating,' ',1) AS int) AS rating_int
FROM normalised_reviews
ORDER BY 2 DESC;

--Now I can the overall average
SELECT 
	ROUND(AVG(CAST(SPLIT_PART(rating,' ',1) AS int)),2) AS average_stars
FROM normalised_reviews;

--3.13. Now, this is the average rating per city

SELECT 
	store_city,
	ROUND(AVG(CAST(SPLIT_PART(rating,' ',1) AS int)),2) AS average_stars
FROM normalised_reviews
GROUP BY store_city
ORDER BY 2 DESC;

--and by state

SELECT 
	store_state,
	ROUND(AVG(CAST(SPLIT_PART(rating,' ',1) AS int)),2) AS average_stars
FROM normalised_reviews
GROUP BY store_state
ORDER BY 2 DESC;

--I'll create a view to allow for future visualisations:

DROP VIEW IF EXISTS store_avg_ratings;
CREATE VIEW store_avg_ratings AS
SELECT 
	store_line1,
	store_city,
	store_state,
	store_zip,
	ROUND(AVG(CAST(SPLIT_PART(rating,' ',1) AS int)),2) AS average_stars
FROM normalised_reviews
GROUP BY 
	store_line1,
	store_city,
	store_state,
	store_zip
ORDER BY 2 DESC;
