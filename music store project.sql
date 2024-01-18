                 -- SET sql_mode = '';
Create database music_store_project;
use music_store_project;

 -- QUESTION SET 1
--   Q1.who is the senior most employee based on the job title?

 select * from employee
   order by levels desc
    limit 1 
 
 --  Q2 which country have most invoice?
 
   Select count(*) as c , billing_country 
   from invoice
   group by billing_country
   order by c desc;

-- Q3 what are top 3 values of total invoice?
   select total
   from invoice
   order by total desc
   limit 3;

 -- Q4 which city has the best customers? we would like to throw a promotional music festival in the city
 -- we made the most money.write a query that return a one city that has the highest sum of invoice total
 -- return both the city name and sum of livoice total?
 
   select sum(total) as invoice_total, billing_city
   from invoice
   group by billing_city
   order by invoice_total desc
   limit 1 
 
 -- Q5 who is the best customer? the cutsomer who has spent the most money will be declare the best customer
 -- write a query that returns the person who spent a more money?

   select customer.customer_id,customer.first_name ,customer.last_name , 
   sum(invoice.total) as total
   from customer
   join invoice on customer.customer_id = invoice.customer_id
   group by customer.customer_id
   order by total desc
   limit 1

-- Question set 2
-- Q1.write a query to return the email, firstnam, lastname, and of all rock music learner. Return ur list
-- ordered alphabaticaly by email starting with A

 select distinct email,first_name,last_name 
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
 where track_id in(
 select track_id from track
 join genre on track.genre_id = genre.genre_id
 where genre.name = 'Rock')
order by email;
  
-- Q2. lets invite the artists who have written the most rock music in our dataset. 
-- write a query that returns the artist name and total track count of the top ten rock band.

  select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
  from track
  join album on album.album_id = track.album_id
  join artist on artist.artist_id = album.artist_id
  join genre on genre.genre_id = track.genre_id
  where genre.name like 'Rock'
  group by artist.artist_id
  order by number_of_songs desc
  limit 10


--  Q3. Return all track name that have a song length longer then the average song length.Return the name 
-- and miliseconds for each track order by song length with the longest song return first.

select name,milliseconds
from track
where milliseconds > (
   select avg(milliseconds) as avg_track_length
   from track 
)
order by milliseconds desc

-- Question set 3 :
-- Q1. Find how much amount spent by each customer on artists? write a query to return customer name,
-- artist name and total spent.

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

 --  Q2. we want to find ou the most popular music genre for each country. we determine the most popular 
-- genre as a  genre with the highest amount of purchases. write a query that return each country along with 
-- the top genre. for countries where the maximum number of purchases is shared retun all geners.

with popular_genre as 
( 
  select count(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
  row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) As Rowno
  from invoice_line
  join invoice on invoice.invoice_id = invoice_line.invoice_id
  join customer on customer.customer_id = invoice.customer_id
  join track on track.track_id = invoice_line.track_id
  join genre on genre.genre_id = track.genre_id
  group by 2,3,4
  order by 2 asc,1 desc
  )
  select * from popular_genre where Rowno<=1;

-- Q3.Write a query that detrmines the customer that has spent the most on music for each country. write a
-- query that returns the country along with the top customer and how much they spent for countries where 
-- the top amount spent is shared, provide all customer who spent this amount.
    
      
with customer_with_country as(
   select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
   Row_number() over (partition by billing_country order by sum(total) desc) as rowno
   from invoice 
   join customer on customer.customer_id = invoice.customer_id
   group by 1,2,3,4
   order by 4 asc , 5 desc
   )
select * from customer_with_country where rowno <=1;
   
   
   
