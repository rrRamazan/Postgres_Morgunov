--КОНТРОЛЬНЫЕ ВОПРОСЫ ГЛАВА 3--
1)
create table test_numeric
(measurement numeric(5,2),
description text
);
--ПРИМЕР С ОШИБКОЙ 
INSERT into test_numeric
values (999.9999, 'Первое измерение' )
--999,90
INSERT into test_numeric
values (999.9009, 'Второе измерение' )
---999,11
INSERT into test_numeric
values (999.1111, 'Третье измерение' )
--999,00
INSERT into test_numeric
values (998.9999, 'Четвертое измерение' )
select * from test_numeric

2)--ДАННЫЕ С РАЗЛИЧНОЙ ТОЧНОСТЬЮ
DROP table test_numeric;

create table test_numeric
(measurement numeric,
description text)

insert into test_numeric
values
(1234567890.0987654321,
'Точность 20 знаков, масштаб 10 знаков' 
),
(1.5,
'Точность 2 знака, масштаб 1 знаков' 
),
(0.1234567890123456789,
'Точность 21 знак, масштаб 20 знаков'
),
(1234567890,
'Точность 10 знаков, масштаб 0 знаков (целое число)'
);

select * from test_numeric;

--3)NaN > любого другого значения
SELECT 'NaN'::numeric > 10000;

4)--real и double precision

select '5e-324'::double precision > '4e-342'::double precision;

select '5e-324'::double precision;

5)--INFINITY

select 'Inf'::double precision > 1E-307;

6)--NaN in real and double precision
select 'NaN'::real > 1E+307::double precision

7)--serial
CREATE TABLE test_serial
(
id serial,
name text
);
INSERT INTO test_serial (name) VALUES
('Вишневая'),
('Грушевая'),
('Зеленая');

select * from test_serial;

INSERT INTO test_serial values
(10, 'Прохладная');

INSERT INTO test_serial (name) values ('Луговая');

8)--Тепер столбец id это первичный ключ
CREATE TABLE test_serial2
(
id serial primary key,
name text
);
INSERT INTO test_serial2 (name) VALUES ('Вишневая');
INSERT INTO test_serial2 VALUES (2, 'Прохладная');
insert into test_serial2 (name) values ('Грушевая');
--тут был вопроc (Почему в первый раз когда я пытался вставить эту строку в столбец СУБД выдаст ошибку ,Потому что мы до этого ввели уже id=2 , и этот id был занят ,а повторение невозможно т.к это первичный ключ,а СУБД не смотрит ,какой id мы вводим сами и просто расставляет их по-порядку,но во второй раз очередь уже дошла до id = 3, а этот айдишник уже не занят)
insert into test_serial2 (name) values ('Зеленая');
delete from test_serial2 where name = 'Грушевая';
insert into test_serial2 (name) values ('Луговая');
select * from test_serial2;

9)PostgreSQL использует григорианский календарь

11)
select current_time ;
select current_time ::time(0);
select current_time ::time(3);

select current_timestamp;
select current_timestamp(0);
select current_timestamp(3);

select current_timestamp - interval '1 day';
select current_timestamp(0) - interval '1 day' ;
select current_timestamp(3) - interval '1 day' ;

12)
show datestyle;
select '18-05-2016' ::date
select '05-18-2016' ::date --ошибка у нас формат DMY а тут MDY
select '2016-05-18' ::date --год месяц день - универсальный порядок

SET datestyle to 'MDY';
select '05-18-2016' ::date
select '18-05-2016' ::date --ошибка
SET datestyle to default;

SET datestyle TO 'MDY';
SELECT '18-05-2016'::timestamp;
SELECT '05-18-2016'::timestamp;
--изменяем обе асти datestyle
set datestyle to 'Postgres, DMY';
show datestyle;
select '05-18-2016' ::date; --ошибка
select '18-05-2016' ::date;

SELECT '18-05-2016'::timestamp;
SELECT '05-18-2016'::timestamp; --ошибка

set datestyle to 'SQL, DMY';

SELECT '18-05-2016'::timestamp;
select '18-05-2016' ::date;

set datestyle to 'German, DMY';
SELECT '18-05-2016'::timestamp;
select '18-05-2016' ::date;

select current_timestamp(0);

15)
select to_char( current_timestamp, 'mi:ss');
select to_char( current_timestamp, 'dd');
select to_char( current_timestamp, 'yyyy--mm-dd');

select to_char( current_timestamp, 'yy--mi');
select to_char( current_date, 'mm--dd');

16-17 примеры недопустимых значений
select 'Jan 41, 2015'::date;
SELECT '21:15:16:22'::time;

18)
interval
SELECT ( '2016-09-16'::date - '2016-09-01'::date );

19) 
SELECT ( '20:34:35'::time - '19:44:45'::time ); -- получили интервал времени в минутах и сек.

SELECT ( '20:34:35'::time + '01:01:01'::time ); -- одинаковые типы можно указывать только в случае interval + interval
SELECT ( '20:34:35'::interval + '01:01:01'::interval ); --например так

20)
select ( current_timestamp - '2016-01-01'::timestamp)
as new_date;
--выдаст ответ в значении типа timestamp
select ('2021-01-01'::timestamp + '1 day'::interval);

21)
--просто выведет соответствующее число и слебующий по счету месяц
SELECT ( '2016-01-31'::date + '1 mon'::interval ) AS new_date;
SELECT ( '2016-02-29'::date + '1 mon'::interval ) AS new_date;

22)
show intervalstyle;
set intervalstyle to 'iso_8601';
select '1 mon' :: interval;
select '01:02:03' :: interval;

set intervalstyle to 'sql_standard';
select '1 day' :: interval;
select '2016:11:24' :: interval;

set intervalstyle to default;

23)
SELECT ( '2016-09-16'::date - '2015-09-01'::date ); 
SELECT ( '2016-09-16'::timestamp - '2015-09-01'::timestamp ); --просто в это случае мы получаем ответ типа interval

24)
SELECT ( '20:34:35'::time - 1 ); --мы не можем просто отнять целое число с типа 'time',чтобы не было ошибки мы можем сделать так 'time - interval' или 'time - time'
select ('20:34:35'::time - '1 sec' :: interval) ; --например так
SELECT ( '2016-09-16'::date - 1 );

25)
select ( date_trunc( 'sec',
				   timestamp '1999-11-27 12:34:56.987654'));
select ( date_trunc( 'microsecond',
		timestamp '1999-11-27 12:34:56.987654'));
select ( date_trunc( 'millisecond',
		timestamp '1999-11-27 12:34:56.987654'));				   
select ( date_trunc( 'second',
		timestamp '1999-11-27 12:34:56.987654'));					   
select ( date_trunc( 'minute',
		timestamp '1999-11-27 12:34:56.987654'));				   
select ( date_trunc( 'hour',
		timestamp '1999-11-27 12:34:56.987654'));					   
select ( date_trunc( 'day',
		timestamp '1999-11-27 12:34:56.987654'));					   
select ( date_trunc( 'week',
		timestamp '1999-11-27 12:34:56.987654'));	
select ( date_trunc( 'month',
		timestamp '1999-11-27 12:34:56.987654'));					   
select ( date_trunc( 'year',
		timestamp '1999-11-27 12:34:56.987654'));
select ( date_trunc( 'decade',
		timestamp '1999-11-27 12:34:56.987654'));			
select ( date_trunc( 'century',
		timestamp '1999-11-27 12:34:56.987654'));			
select ( date_trunc( 'millennium',
		timestamp '1999-11-27 12:34:56.987654'));			

27)
select extract(
	'microsecond' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'millisecond' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'second' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'minute' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'hour' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'day' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'week' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'month' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'year' from timestamp '1999-11-27 12:34:56.123459'
);
select extract(
	'decade' from timestamp '1999-11-27 12:34:56.123459'
);		
select extract(
	'century' from timestamp '1999-11-27 12:34:56.123459'
);		
select extract(
	'millennium' from timestamp '1999-11-27 12:34:56.123459'
);		

30)
create table test_bool
(
a boolean,
b text
);
29)
нет в случае с 'SELECT * FROM databases WHERE NOT is_open_source;'мы выводим варианты false,а в остальных случаях это все true

30)
CREATE TABLE test_bool
( a boolean,
b text
);	
INSERT INTO test_bool VALUES ( TRUE, 'yes' );
INSERT INTO test_bool VALUES ( yes, 'yes' ); --тут должно быть TRUE
INSERT INTO test_bool VALUES ( 'yes', true );
INSERT INTO test_bool VALUES ( 'yes', TRUE );
INSERT INTO test_bool VALUES ( '1', 'true' );
INSERT INTO test_bool VALUES ( 1, 'true' ); boolean значение должно быть записано в виде '1',а в этом случае это как тип integer
INSERT INTO test_bool VALUES ( 't', 'true' );
INSERT INTO test_bool VALUES ( 't', truth ); у нас нет столбца truth и это не логический тип
INSERT INTO test_bool VALUES ( true, true );
INSERT INTO test_bool VALUES ( 1::boolean, 'true' );
INSERT INTO test_bool VALUES ( 111::boolean, 'true' );		

31)
CREATE TABLE birthdays
( person text NOT NULL,
birthday date NOT NULL );

INSERT INTO birthdays VALUES ( 'Ken Thompson', '1955-03-23' );
INSERT INTO birthdays VALUES ( 'Ben Johnson', '1971-03-19' );
INSERT INTO birthdays VALUES ( 'Andy Gibson', '1987-08-12' );
		
SELECT * FROM birthdays
WHERE extract( 'mon' from birthday ) = 3;
		
select *, birthday + '40 years'::interval
from birthdays;
where birthday + '40 years'::interval < current_timestamp;
		
select *, birthday + '40 years'::interval
from bithdays
where birthday + '40 years'::interval < current_date
		
--вариант в примере ( определить точный возраст каждого человека на текущий момент времени)		
SELECT *, ( current_date::timestamp - birthday::timestamp )::interval
FROM birthdays;		
--с помощью раздела 9.9		
select *,age(birthday::timestamp)	
from birthdays;
--еще можно такой вариант применить		
select extract('years' from (current_date::timestamp)) - extract('years' from birthday ::timestamp)		
from birthdays;
					
32)		
SELECT array_cat( ARRAY[ 1, 2, 3 ], ARRAY[ 3, 5 ] ); --обьединение массивов
		
SELECT array_remove( ARRAY[ 1, 2, 3 ], 3 );	--удаление	
		
33)		
create table pilots
(
pilot_name text,
schedule integer[],
meal text[]
);
insert into pilots
values ('Ivan','{1, 3, 5, 6, 7 }'::integer[],
		'{"сосиска", "макароны", "кофе" }'::text[]
		),
		('Petr', '{1, 2, 5, 7 }'::integer[],
		'{"котлета", "каша", "кофе" }'::text[]
		),
		('Pavel', '{2, 5 }'::integer[],
		 '{"сосиска", "каша", "кофе" }'::text[]
		),
		('Boris', '{3, 5, 6 }'::integer[],
		 '{"котлета", "каша", "чай" }'::text[]
		);
select * from pilots;		
select * from pilots
where meal @> '{"сосиска"}' ; --мой вариант
SELECT * FROM pilots WHERE meal[ 1 ] = 'сосиска'; --из книги

--ЗАДАНИЕ
create table pilots1
(
pilot_name1 text,
schedule1 integer[],
meal1 text[][]
);
		
insert into pilots1
values ('Ivan','{1, 3, 5, 6}'::integer[],
		'{{"сосиска", "макароны", "кофе"},
		{"котлета", "каша", "кофе" },
		{"каша", "кофе", "роллы"},
		{"устрицы", "роллы", "каша"}}'::text[][]
		);	
select * from pilots1;		
		
insert into pilots1
values ('Petr','{1, 3, 5, 6}'::integer[],
		'{{"картошка", "макароны", "кофе"},
		{"котлета", "яйцо", "кофе" },
		{"устрицы", "кофе", "роллы"},
		{"устрицы", "кальмар", "каша"}}'::text[][]
		),
		('Pavel','{1, 3, 5, 6}'::integer[],
		'{{"мохито", "макароны", "кофе"},
		{"котлета", "круассан", "кофе" },
		{"латте", "кофе", "роллы"},
		{"устрицы", "кальмар", "бутерброд"}}'::text[][]
		),
		('Boris','{1, 3, 5, 6}'::integer[],
		'{{"картошка", "яйцо", "кофе"},
		{"котлета", "кальмар", "кофе" },
		{"ананас", "кофе", "роллы"},
		{"устрицы", "кальмар", "творог"}}'::text[][]
		);
		
select * from pilots1;	
select * from pilots1
where meal1 @> '{"латте"}';		
select * from pilots1
where meal1[1][4] = '{"кофе"}';			
		
select pilot_name1 from pilots1
where meal1[1][3] <> meal1[2][3];
		
select meal1[1][2] from pilots1
where pilot_name1 = 'Petr' ;
		
SELECT array_dims(meal1) FROM pilots1 WHERE pilot_name1 = 'Ivan';		
		
Update pilots1 set meal1 = '{{"арбуз", "яйцо", "кофе"},
		{"котлета", "апельсин", "кофе" },
		{"ананас", "кофе", "роллы"},
		{"устрицы", "кальмар", "творог"}}'::text[][]		
	    where pilot_name1 = 'Boris';

Update pilots1 set meal1[1][2] = '{"кетчуп"}'
where pilot_name1 = 'Pavel' ;
		
34)
update pilot_hobbies
set hobbies = jsonb_set( hobbies, '{ home_lib }', 'false')
where pilot_name = 'Boris';
	   
select * from pilot_hobbies;	   
	   
36)-- тут в условии требовалось изменить таблицу pilots1, но у нас до эта таблица имеет вид JSON ,а команда || работает только для JSONB.Я не понял какая в итоге имелась ввиду таблица pilots ,поэтому отредактировал таблицу pilot_hobbies
update pilot_hobbies
set hobbies = (hobbies || '{"kids": 2}' ) :: jsonb
		where pilot_name = 'Boris'			
		
37)удалим то же самое значение,что и добавляли
update pilot_hobbies
set hobbies = (hobbies - '{"kids": 2}' ) :: jsonb
		where pilot_name = 'Boris'
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		