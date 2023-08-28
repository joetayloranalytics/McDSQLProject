--With the dataset loaded in through importing the csv, I have a look at the general data
SELECT *
FROM reviews
LIMIT 10;

--I can see there is a store address that isn't normalised, so first I look at how many stores this data is accross:

SELECT COUNT(DISTINCT store_address)
FROM reviews;

--40, and what the store addresses are:

SELECT DISTINCT store_address
FROM reviews;

--They are multi line addresses seperated by commas, so I want to split these into different columns
SELECT DISTINCT store_address,
	SPLIT_PART(store_address,',',-4) AS line1,
	SPLIT_PART(store_address,',',-3) AS city,
	LEFT(SPLIT_PART(store_address,',',-2),3) AS state,
	RTRIM(SPLIT_PART(store_address,' ',-3),',') AS zip
FROM reviews;

--Now I've split the address, I'll create a view with the normalised addresses (category isn't included as all vaues were the same)

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
