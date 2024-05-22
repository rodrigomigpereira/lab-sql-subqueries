LAB | SQL Subqueries

## In this lab, you will be using the Sakila database of movie rentals.

use sakila; ## Use the database sakila 

## Instructions
## How many copies of the film Hunchback Impossible exist in the inventory system?

select * from inventory; ## columns --- inventory_id, film_id, store_id, last_update
select * from film; ## columns --- film_id, title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update

select * 
	from film
		where title = "Hunchback Impossible"; ## film Hunchback Impossible has the film_id "439"
        
        
select f.film_id, f.title, count(i.inventory_id) copies_in_the_inventory
	from film f
		join inventory i
        on f.film_id = i.film_id
			where f.title = "Hunchback Impossible"
				group by f.film_id; ## There are 6 copies of the film Hunchback Impossible in the inventory system
				

## List all films whose length is longer than the average of all the films.

	## query 1 
select avg(f.length) as average_length
	from film f;  ## average length is 115.2720
    
    ## query 2
select film_id, title, length
	from film
		where length > (select avg(f.length) as average_length
						from film f)
			order by length desc;
    

## Use subqueries to display all actors who appear in the film Alone Trip.

select * from film; ## columns --- film_id, title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update
select * from film_actor; ## columns --- actor_id, film_id, last_update
select * from actor; ## columns --- actor_id, first_name, last_name, last_update

select a.actor_id, a.first_name, a.last_name
	from actor a
		where a.actor_id in (        ## The IN operator allows you to specify multiple values in a WHERE clause. https://www.w3schools.com/sql/sql_in.asp
			select fa.actor_id
			from film_actor fa
			join film f 
            on fa.film_id = f.film_id
			where f.title = 'Alone Trip'
		);

## Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from category; ## columns --- category_id, name, last_update
select * from film_category; ## columns --- film_id, category_id, last_update
select * from film; ## columns --- film_id, title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update

select f.film_id, f.title
	from film f
		where f.film_id in (
			select fc.film_id
			from film_category fc
			join category c
            on fc.category_id = c.category_id
			where c.name = 'Family'
		);
				
	## Another alternative for the exercise above:
    SELECT f.film_id, f.title
	FROM film f
	JOIN film_category fc ON f.film_id = fc.film_id
	JOIN category c ON fc.category_id = c.category_id
	WHERE c.name = 'Family';

## Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select * from customer; ## columns --- customer_id, store_id, first_name, last_name, email, address_id, active, create_date, last_update
select * from address; ## columns --- address_id, address, address2, district, city_id, postal_code, phone, location, last_update
select * from city; ## columns ---  city_id, city, country_id, last_update
select * from country; ## columns --- country_id, country, last_update

	## using Subqueries:
SELECT first_name, last_name, email
	FROM customer
		WHERE address_id IN (
			SELECT address_id
			FROM address
			WHERE city_id IN (
				SELECT city_id
				FROM city
				WHERE country_id = (
					SELECT country_id
					FROM country
				WHERE country = 'Canada'
				)
			)
		);

	# using Joins:
SELECT c.first_name, c.last_name, c.email
	FROM customer c
		JOIN address a 
        ON c.address_id = a.address_id
			JOIN city ci 
            ON a.city_id = ci.city_id
				JOIN country co 
                ON ci.country_id = co.country_id
					WHERE co.country = 'Canada';

## Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select * from film_actor;
select * from film;

select fa.actor_id, count(fa.film_id)
		from film_actor fa
            group by actor_id
				limit 1;  ## "limit 1" as I would like to filter only the most prolific actor

select f.title, fa.actor_id, count(fa.film_id) as number_of_films
	from film f
		join film_actor fa
        on f.film_id = fa.film_id
			where fa.actor_id = (			   
				select fa.actor_id
                from film_actor fa
				group by fa.actor_id
                order by count(fa.film_id) desc
				limit 1
			)
		group by f.title, fa.actor_id;
	
    ## Or:
select f.title
	from film f
		join film_actor fa
        on f.film_id = fa.film_id
			where fa.actor_id = (			   
				select fa.actor_id
                from film_actor fa
				group by fa.actor_id
                order by count(fa.film_id) desc
				limit 1
			)
		group by f.title;


## Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer (ie the customer that has made the largest sum of payments)

select * from payment; ## columns --- payment_id, customer_id, staff_id, rental_id, amount, payment_date, last_update
select * from customer; ## columns --- customer_id, store_id, first_name, last_name, email, address_id, active, create_date, last_update
select * from rental; ## columns --- rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update
select * from inventory; ## columns --- inventory_id, film_id, store_id, last_update
select * from film; ## columns --- film_id, title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update

	select p.customer_id
		from payment p
			group by p.customer_id
				order by sum(p.amount) desc
					limit 1; ## 526 is the customer_id of teh most profitable customer

select sum(p.amount) as sum_of_payments, c.customer_id, c.first_name, c.last_name
	from customer c
		join payment p
        on c.customer_id = p.customer_id
			where c.customer_id = (
				select p.customer_id
				from payment p
				group by p.customer_id
				order by sum(p.amount) desc
                limit 1
			)
	group by c.customer_id, c.first_name, c.last_name; ## 221.55 is the sum of payments of the customer_id 526 (Karl Seal)

select f.film_id, f.title
	from film f
		join inventory i
        on f.film_id = i.film_id
			join rental r
            on i.inventory_id = r.inventory_id
				join customer c
                on r.customer_id = c.customer_id
					join payment p
                    on c.customer_id = p.customer_id
						where c.customer_id = (
							select p.customer_id
							from payment p
							group by p.customer_id
							order by sum(p.amount) desc
							limit 1
						)
		group by f.film_id
        order by f.film_id asc;
		   

## Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

select avg(sum_of_payment)
	from(
		select p.customer_id, sum(p.amount) as sum_of_payment
		from payment p
		group by p.customer_id
		) as average_of_the_total_amount;  ## 112.531820 is the average of total payments of clients

select sum(p.amount) as sum_of_payments, c.customer_id, c.first_name, c.last_name

select sum(p.amount) as sum_of_payments, c.customer_id, c.first_name, c.last_name
	from customer c
		join payment p
        on c.customer_id = p.customer_id
			group by c.customer_id
				having sum(p.amount) > (
									select avg(sum_of_payment)
									from(
										select p.customer_id, sum(p.amount) as sum_of_payment
										from payment p
										group by p.customer_id
									) as average_total_amount    ## 112.531820 is the average of total payments of clients
				)
                order by sum_of_payments asc;  ## Gettng the client_id, first_name, last_name, and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client

## Out of curiosity, I counted below 285 clients (from 599 clients) who spent more than the average.

select count(customer_id)
	from (
		select p.customer_id, sum(p.amount)
		from payment p
		group by p.customer_id
        ) as sum_amount_per_client; ## there are 599 who paid anything to the store

select count(sum_of_payments)
from (
select sum(p.amount) as sum_of_payments, c.customer_id, c.first_name, c.last_name
	from customer c
		join payment p
        on c.customer_id = p.customer_id
			group by c.customer_id
				having sum(p.amount) > (
									select avg(sum_of_payment)
									from(
										select p.customer_id, sum(p.amount) as sum_of_payment
										from payment p
										group by p.customer_id
									) as average_total_amount    ## 112.531820 is the average of total payments of clients
				)
                order by sum_of_payments asc  ## Gettng the client_id, first_name, last_name, and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client
	) as clients_spent_more_than_average;  ## if I did not specify "as....", i would get the error code 1248: "Every derived table must have its own alias"
## 285 clients spent more than the average of cients

        