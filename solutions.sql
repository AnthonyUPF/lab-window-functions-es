use sakila;

-- 1. calcular la duración media del alquiler (en días) para cada película:

select
    title,
    rental_duration,
    avg(rental_duration) over () as avg_rental_duration
from
    film;
    
-- 2. calcular el importe medio de los pagos para cada miembro del personal:

select
    staff_id,
    avg(amount) over (partition by staff_id) as avg_payment_amount
from
    payment;
    
-- 3. calcular los ingresos totales para cada cliente, mostrando el total acumulado dentro del historial de alquileres de cada cliente:

select
    payment.customer_id,
    rental_id,
    rental_date,
    amount,
    sum(amount) over (partition by customer_id order by rental_date) as running_total
from
    payment
    join rental using (rental_id)
order by
    customer_id, rental_date;

-- 4. determinar el cuartil para las tarifas de alquiler de las películas:

select
    title,
    rental_rate,
    ntile(4) over (order by rental_rate) as quartile
from
    film;
    
-- 5. determinar la primera y última fecha de alquiler para cada cliente:

select
    customer_id,
    min(rental_date) over (partition by customer_id) as first_rental_date,
    max(rental_date) over (partition by customer_id) as last_rental_date
from
    rental;
    
-- 6. calcular el rango de los clientes basado en el número de sus alquileres:

select
    customer_id,
    rental_count,
    rank() over (order by rental_count desc) as rental_count_rank
from (
    select
        customer_id,
        count(rental_id) as rental_count
    from
        rental
    group by
        customer_id
) as rental_counts;

-- 7. calcular el total acumulado de ingresos por día para la categoría de películas 'familiar':

select
    film_category,
    rental_date,
    amount,
    sum(amount) over (partition by rental_date order by rental_date) as daily_revenue
from (
    select
        f.title as film_category,
        r.rental_date,
        p.amount
    from
        film as f
        join inventory as i on f.film_id = i.film_id
        join rental as r on i.inventory_id = r.inventory_id
        join payment as p on r.rental_id = p.rental_id
    where
        f.rating = 'g'
) as daily_revenue;

-- 8. asignar un id único a cada pago dentro del historial de pagos de cada cliente:

select
    customer_id,
    payment_id,
    row_number() over (partition by customer_id order by payment_date) as payment_sequence_id
from
    payment;
    
-- 9. calcular la diferencia en días entre cada alquiler y el alquiler anterior para cada cliente:

select
    customer_id,
    rental_id,
    rental_date,
    lag(rental_date) over (partition by customer_id order by rental_date) as previous_rental_date,
    datediff(rental_date, lag(rental_date) over (partition by customer_id order by rental_date)) as days_between_rentals
from
    rental
order by
    customer_id, rental_date;
