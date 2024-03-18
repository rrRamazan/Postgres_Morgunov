--CHAP 6 CONTROL QUESTION
1) --тоже можно доделать 
select count(*) from tickets;
select count(*) from tickets WHERE passenger_name LIKE '%';
select count(*) from tickets WHERE passenger_name LIKE '% % %';
select count(*) from tickets WHERE passenger_name LIKE '% %%';
select passenger_name from tickets;


2)
--Предложите шаблон поиска в операторе LIKE для выбора из этой таблицы всех
--пассажиров с фамилиями, состоящими из пяти букв
SELECT passenger_name
	FROM tickets
	WHERE passenger_name LIKE '_____ %';


6)
SELECT a.model, r.departure_airport_name, r.arrival_airport_name
FROM routes r

RIGHT OUTER JOIN aircrafts a 
	ON r.aircraft_code = a.aircraft_code

	WHERE a.model ~ '^Боинг';

7) 
select distinct least(r.departure_city, r.arrival_city) as a, greatest(r.departure_city, r.arrival_city) as b
FROM routes r
join aircrafts a on r.aircraft_code = a.aircraft_code
 WHERE a.model = 'Боинг 777-300'

SELECT DISTINCT r.departure_city, r.arrival_city
	from (select distinct b.departure_city, b.arrival_city
	from routes b 
	JOIN aircrafts c ON b.aircraft_code = c.aircraft_code
	WHERE c.model = 'Боинг 777-300'
		 ) r
	JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
	WHERE a.model = 'Боинг 777-300'
	--group by 1,2
	ORDER BY 1;

select distinct r1.departure.city, r2.arrival_city
	from routes r1, routes r2
	where routes r1 <> routes r2
	order by 1
	
	join aircrafts a on a.aircraft_code = r.aircraft_code
	and r1.departure_city <> r2.arrival_city
	order by 1 ;

8)--используем full join на тот случай ,если дальность полета самотела не известна

select f.flight_id , f.actual_arrival, a.range
from flights f
full join Aircrafts a ON f.aircraft_code = a.aircraft_code
where model = model NOT LIKE 'Боинг%'


9)
select departure_city, arrival_city, count(*)
	from routes
	where departure_city = 'Москва'
		and arrival_city = 'Санкт-Петербург'
	GROUP BY 1,2;
	
select departure_city, arrival_city, count(*)
	from routes
	where departure_city = 'Москва'
		and arrival_city = 'Санкт-Петербург'
	GROUP BY 1,2;
	
10)
select distinct least(r.departure_city, r.arrival_city) as a, greatest(r.departure_city, r.arrival_city) as b, count(*)
FROM routes r
group by 1,2

11)
select arrival_city, array_length(days_of_week, 1),
count(*) AS num_routes
FROM routes
where departure_city = 'Москва'
GROUP BY days_of_week, 1
ORDER BY 2 desc
limit 5;

12)
SELECT flight_no, unnest( days_of_week ) with ordinality K(a, v) 
FROM routes
WHERE departure_city = 'Москва'
ORDER BY flight_no;

SELECT dw.name_of_day, count(*) as num_flights
	from(
		SELECT unnest(days_of_week ) as num_of_day
			FROM routes
			WHERE departure_city = 'Москва'
		) AS r,
		unnest( 
		  '{ "Пн.", "Вт.", "Ср.", "Чт.", "Пт", "Сб.", "Вс."}'::text[]
		)with ordinality as dw( name_of_day, num_of_day )
	where r.num_of_day = dw.num_of_day
	GROUP BY r.num_of_day, dw.name_of_day
	ORDER BY r.num_of_day;

13)
SELECT f.departure_city, f.arrival_city,
		max( tf.amount ), min( tf.amount )
	FROM flights_v f
	left JOIN ticket_flights tf ON f.flight_id = tf.flight_id
	GROUP BY 1, 2
	ORDER BY 1, 2;


14)
select substr(passenger_name, strpos( passenger_name, ' ' ))
		AS firstname, count( * )
	FROM tickets
	GROUP BY 1
	ORDER BY 2 DESC;

15)

16)
SELECT aircraft_code, 
count(*) filter (where range > 3000) as filter
from aircrafts
group by 1
order by filter desc;

17)
SELECT a.aircraft_code, a.model,
	s.fare_conditions,
	count( * )
FROM aircrafts a
JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY  1, 2, 3
ORDER BY  1, 2, 3	
	
18)

select a.aircraft_code as a_code, model, r.aircraft_code as r_code, 
	 count( r.aircraft_code ) as num_routes,
	 round((((count( r.aircraft_code ))::numeric ) / ((select count(*) from routes r)::numeric) ), 3) as fraction
	 from aircrafts a
	 LEFT join routes r on r.aircraft_code = a.aircraft_code
	 group by 1,2,3
	 order by 4 desc;
	 
19)

with recursive ranges ( min_sum, max_sum, iteration )
AS (
	VALUES( 0, 		100000, 1),
	  	  (100000, 200000, 2),
		  (200000, 300000, 3)
	UNION ALL
	SELECT min_sum + 100000, max_sum + 100000, iteration + 1
		FROM ranges
		WHERE max_sum < (SELECT max(total_amount) FROM bookings)
	)
SELECT * FROM ranges;

--заменить UNION ALL на UNION 

with recursive ranges ( min_sum, max_sum, iteration )
AS (
	VALUES( 0, 		100000, 1),
	  	  (100000, 200000, 2),
		  (200000, 300000, 3)
	UNION
	SELECT min_sum + 100000, max_sum + 100000, iteration + 1
		FROM ranges
		WHERE max_sum < (SELECT max(total_amount) FROM bookings)
	)
SELECT * FROM ranges;
--Теперь нет схожих строк
20)
WITH RECURSIVE ranges ( min_sum, max_sum )
AS ( 
	VALUES ( 0, 100000 )
	UNION ALL 
	SELECT min_sum + 100000, max_sum + 100000
		FROM ranges
		WHERE max_sum < ( SELECT max(total_amount ) FROM bookings )
 )
SELECT r.min_sum,
	   r.max_sum,
	   count( b.* )
	FROM bookings b
	RIGHT OUTER JOIN ranges r 
		ON b.total_amount >= r.min_sum
		AND b.total_amount < r.max_sum
	GROUP BY r.min_sum, r.max_sum
	ORDER BY r.min_sum;
--в 12 пункте где сумма от 1100000 до 1200000 появляется 1 в count ,если использовать просто "*",это неверно т.к подходящей суммы в этом промежутке у нас нету

21)
--И в правду ,тут EXCEPT получается,что нужный результат присутствует в первом множестве и отсутствует во втором , т.о в этом случае подходит except
SELECT city
FROM airports
WHERE city <> 'Москва'
except
SELECT arrival_city
FROM routes
WHERE departure_city = 'Москва'
ORDER BY city;

22)
SELECT aa.city, aa.airport_code, aa.airport_name
	FROM (
		SELECT city, count( * )
			FROM airports
			GROUP BY city
			HAVING count( * ) > 1
		 ) AS a 
	JOIN airports AS aa ON a.city = aa.city
	ORDER BY aa.city, aa.airport_name;

SELECT aa.city, aa.airport_code, aa.airport_name
	FROM (
		SELECT city
			FROM airports
			GROUP BY city
			HAVING count( * ) > 1
		 ) AS a 
	JOIN airports AS aa ON a.city = aa.city
	ORDER BY aa.city, aa.airport_name;

-- нет можно обойтись без функциий count в select ,а сразу задать функцию в Having

23)
WITH cte AS 
( 
(SELECT DISTINCT city FROM airports)  AS a1
join (select distinct city from airports) as a2
 	ON a1.city <> a2.city)
	
select count( * ) from cte;


with cte as( 
SELECT DISTINCT city FROM airports AS a1
JOIN SELECT DISTINCT city FROM airports AS a2
ON a1.city <> a2.city)

select count( * ) from cte;


WITH cte AS 
( 
(SELECT DISTINCT city FROM airports)  AS a1
join (select distinct city from airports) as a2
 	)
	
select count( * ) from cte
where a1.city <> a2.city

WITH cte AS 
( 
SELECT DISTINCT city FROM airports  AS a1
select distinct city from a as a2
	join airports as a
 	ON a1.city <> a2.city)
	
select count( * ) from cte;


24)
SELECT * from flights 
	WHERE status = any (
	VALUES ('Delayed'), ( 'Cancelled' )
	);

SELECT * FROM aircrafts 
	WHERE model = any (
	SELECT model from aircrafts where model like 'Боинг%'
	);

select * from aircrafts 
	where range > all( SELECT range from aircrafts where range = 3000) ;
--можно использовать <>all , >all , etc

25)

WITH tickets_seats 
AS (
	SELECT f.flight_id,
		f.flight_no,
		f.departure_city,
		f.arrival_city,
		f.aircraft_code,
	
		(SELECT count(s.seat_no)
			FROM seats s
			WHERE s.fare_conditions = 'Business') as total_business,
		(SELECT count(s.seat_no)
			FROM seats s
			WHERE s.fare_conditions = 'Economy') as total_economy,
		(SELECT count(s.seat_no)
			FROM seats s
			WHERE s.fare_conditions = 'Comfort') as total_comfort,
	
		 (SELECT count(s.seat_no)
		 	from seats s
		 	WHERE fare_conditions = 'Business'
			AND s.aircraft_code = f.aircraft_code) as fact_business,
		 (SELECT count(s.seat_no)
		 	from seats s
		 	WHERE fare_conditions = 'Comfort'
			AND s.aircraft_code = f.aircraft_code) as fact_comfort,
		 (SELECT count(s.seat_no)
		 	from seats s
		 	WHERE fare_conditions = 'Economy'
			AND s.aircraft_code = f.aircraft_code) as fact_economy,	 
	
		count( tf.ticket_no ) AS fact_passengers,
		( SELECT count(s.seat_no)
			FROM seats s
			WHERE s.aircraft_code = f.aircraft_code
		) AS total_seats
	FROM flights_v f
	JOIN ticket_flights tf ON f.flight_id = tf.flight_id
	WHERE f.status = 'Arrived'
	
	GROUP BY 1, 2, 3, 4, 5
)
SELECT ts.departure_city,
	   ts.arrival_city,
	   
	   sum( ts.total_business ) as sum_Tbusiness,
	   sum( ts.total_comfort ) as sum_Tcomfort,
	   sum( ts.total_economy ) as sum_Teconomy,
	   sum( ts.fact_business) as sum_Fbusiness,
	   sum( ts.fact_comfort) as sum_Fcomfort,
	   sum( ts.fact_economy) as sum_Feconomy,
	   
	   round( sum( ts.fact_business )::numeric / 
				sum(ts.total_business)::numeric, 3) as fracBusiness,
	   round( sum( ts.fact_comfort )::numeric / 
				sum(ts.total_comfort)::numeric, 3) as fracComfort,
	   round( sum( ts.fact_economy )::numeric / 
				sum(ts.total_economy)::numeric, 3) as fracEconomy,
	   
	   sum( ts.fact_passengers ) AS sum_pass,
	   sum( ts.total_seats ) AS sum_seats,
	   round( sum(ts.fact_passengers)::numeric /
			  sum( ts.total_seats )::numeric, 2 ) AS frac
	FROM tickets_seats ts
	GROUP BY ts.departure_city, ts.arrival_city
	ORDER BY ts.departure_city;

26)
with p as(
SELECT t.passenger_name, b.seat_no, tf.fare_conditions ,
t.contact_data->'email' AS email
FROM (
ticket_flights tf
JOIN tickets t ON tf.ticket_no = t.ticket_no
)
JOIN boarding_passes b
ON tf.ticket_no = b.ticket_no
AND tf.flight_id = b.flight_id
WHERE tf.flight_id = 27584
) 

SELECT  s.seat_no, p.passenger_name, p.email, p.fare_conditions
FROM p
right join seats s ON s.seat_no = p.seat_no
WHERE s.aircraft_code = 'SU9'
ORDER BY
left( s.seat_no, length( s.seat_no ) - 1 )::integer,
right( s.seat_no, 1 );