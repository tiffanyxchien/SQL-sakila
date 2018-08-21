USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. Find the ID number, first name, and last name of an actor whose first name is "Joe."
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. Order the rows by last name then first name.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China.
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor
ADD COLUMN description BLOB(50);

-- 3b. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Count of Actors'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name) AS 'Count of Actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. Rename actor GROUCHO WILLIAMS as HARPO WILLIAMS.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. If the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. Re-create the schema of the address table.
SHOW CREATE TABLE address;
-- Right click on the field below "Create Table" and select "Copy Field (unquoted)."
CREATE TABLE IF NOT EXISTS `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Display the first and last names, as well as the address of each staff member. 
SELECT first_name, last_name, address
FROM staff
JOIN address
USING(address_id);
 
-- 6b. Display the total amount rung up by each staff member in August of 2005.
SELECT staff_id, first_name, last_name, SUM(amount) AS 'Total Amount Rung Up'
FROM staff
JOIN payment
USING(staff_id)
WHERE payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film.
SELECT title, COUNT(actor_id) AS 'Number of Actors'
FROM film
INNER JOIN film_actor
USING(film_id)
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) AS 'Copies of Film'
FROM inventory
WHERE film_id IN
(
	SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
);

-- 6e. List the total paid by each customer alphabetically by last name.
SELECT first_name, last_name, SUM(amount) AS 'Total Paid'
FROM customer
JOIN payment
USING(customer_id)
GROUP BY customer_id
ORDER BY last_name;
	
-- 7a. Display the titles of movies starting with the letters K and Q which language is English.
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN
(
	SELECT language_id
    FROM language
    WHERE name = 'English'
);

-- 7b. Display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
	WHERE film_id IN
    (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
	)
);

-- 7c. Retrieve the names and email addresses of all Canadian customers.
SELECT first_name, last_name, email
FROM customer
JOIN address
USING(address_id)
WHERE city_id IN
(
	SELECT city_id
    FROM city
    WHERE country_id IN
    (
		SELECT country_id
        FROM country
        WHERE country = 'Canada'
	)
);

-- 7d. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
        FROM category
        WHERE name = 'Family'
	)
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(film_id) AS 'Number of Rentals'
FROM film
JOIN inventory
USING(film_id)
JOIN rental
USING(inventory_id)
GROUP BY title
ORDER BY COUNT(film_id) DESC;

-- 7f. Display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) AS 'Total Revenue'
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
GROUP BY store_id;

-- 7g. Display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
JOIN address
USING(address_id)
JOIN city
USING(city_id)
JOIN country
USING(country_id);

-- 7h. List the top five genres in gross revenue in descending order.
SELECT name, SUM(amount) AS 'Gross Revenue'
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING(category_id)
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8a. Create a view of the top five genres by gross revenue.
CREATE VIEW top_five_genres AS
SELECT name, SUM(amount) AS 'Gross Revenue'
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING(category_id)
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8b. Display the view created of the top five genres by gross revenue.
SELECT * FROM top_five_genres;

-- 8c. Delete the view created of the top five genres by gross revenue.
DROP VIEW top_five_genres;