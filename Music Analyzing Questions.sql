-- THREE TYPE OF QUESTIONS WITH ANSWERS

--	Question Set1 - Easy Section
--Q1. Who is the most senior employee based on job title?
SELECT first_name, last_name, title, levels 
FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2. Which countries have the most invoices?
SELECT
	COUNT(*) as cnt_invoices,
	billing_country
FROM invoice
GROUP BY billing_country
ORDER BY cnt_invoices DESC;

--Q3. What are the top 3 values of total invoices?
SELECT TOTAL
FROM invoice
ORDER BY total DESC
LIMIT 3;

--Q4. Which city has the best customers? We would like to throw a promotional music festival in the city
-- We made the most money. Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name and sum of all invoice totals.
SELECT 
	billing_city,
	SUM(total) as total_invoice	
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

--Q5. Who are the top 5 best customers? The customer who has spent the most money will be declared the best customers.
-- Write a query that returns people who have spent the most money.
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

--	Question Set2 - Moderate Section
--Q1. Write query to return the email, first name, last name and genre of all rock music listeners.
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT first_name, last_name, email
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line l ON i.invoice_id = l.invoice_id
WHERE track_id IN
(
SELECT track_id FROM track
	JOIN genre g ON track.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email;

--Q2. Let's invite the artists who have written in the most rock music in our dataset.
-- Write query that returns the artist name and total track count of the top 10 rock bands.
SELECT artist.name, COUNT(artist.artist_id) as number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

--Q3. Return all the track names that have a song length longer than the average song length.
-- Return the name and milliseconds for each track order by the song length with the longest
-- songs listed first.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) as avg_track_len
	FROM track)
ORDER BY milliseconds DESC;

--	Question Set3 - Advance Section
--Q1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent.
WITH best_selling_artist AS (
	SELECT artist.artist_id as artist_id, artist.name as artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) as amount_spent
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) as Amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q2. We want to find out the most popular music genre for each country. We determine the most pupolar
-- genre as the genre with highest amount of purchases. Write a query that returns each country along
-- with the top genre. For countries where the maximum number of purchases is shared return all genres.
WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
		ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) as RowNo
	FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <=1;

--Q3. Write a query that determines the customer that has spent the most on music for each country.
-- Write query that returns the country along with top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH customer_with_country AS
(
	SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) as total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country WHERE RowNo <=1;

--END OF QUESTIONS


