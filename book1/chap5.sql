1)
ALTER TABLE students
	add column who_adds_row text DEFAULT current_user; --добавленный столбец 

INSERT INTO students ( record_book, name, doc_ser, doc_num )
	VALUES ( 12300, 'Иванов Иван Иванович', 0402, 543281 );

select * from students;

ALTER TABLE students
	add column when_adds_row timestamp DEFAULT current_timestamp; --время добавленния  

2)
ALTER TABLE progress
	add column test_form varchar NOT NULL;
ALTER TABLE progress
	add check ((test_form = 'экзамен' and mark IN (3, 4, 5))
	OR (test_form = 'зачет' and mark IN (0, 1))
			  );
INSERT INTO progress (record_book, subject, acad_year, test_form, term, mark)
	VALUES (12300, 'информатика', '1', 'экзамен', 1, 5 );
--Это вариант с ошибкой,тут не удовл. ограничнию,что экз IN 3,4,5
INSERT INTO progress (record_book, subject, acad_year, test_form, term, mark)
	VALUES (12300, 'информатика', '1', 'зачет', 1, 1 );

--И да тут получается конфликт ограничений ,так как при создании мы указали
--что mark от 3 до 5,но в варианте с зачетом у нас оценки 1 и 0,
--тогда удаляем старое ограничение предварительно узнав название ограничения командой \d name

ALTER TABLE progress
	drop constraint progress_mark_check;
--теперб работает
INSERT INTO progress (record_book, subject, acad_year, test_form, term, mark)
	VALUES (12300, 'информатика', '1', 'зачет', 1, 1 );	
--Еще можно добавить проверку учебного года,если мы знаем ч у нас форма обучения бакалавриат
--то учеба будет длиться от 1 до 4г

3*)
ALTER TABLE progress
	Alter column mark drop not null;
	
INSERT INTO progress (record_book, subject, acad_year, test_form, term)
	VALUES (12300, 'информатика', '1', 'зачет', 1);
-- не получается, значит в этом случае ограничение not null не нужно

4)
ALTER TABLE progress
	Alter column mark set  default 6;

INSERT INTO progress ( record_book, subject, acad_year, term )
VALUES ( 12300, 'Физика', '2016/2017',1 );
--ЕСЛИ МЫ ДОПУСТИМ ОШИБКУ ТО ОГРАНИЧЕНИЕ УАЖЕТ НАМ НА НЕЕ,
--ОШИБКА БУДЕТ ОБНАРУЖЕНА НА ЭТАПЕ СТАВКИ ДАННЫХ В ТАБЛИЦУ

5)
ALTER TABLE students
	add unique(doc_ser);
ALTER TABLE students
	add unique(doc_num);
--одинаковые null значения вставились в таблицу
INSERT INTO students ( record_book, name, doc_ser, doc_num )
values (12301, 'Артемов Артем Артемович', null, null),
	(12302, 'Антонов Антон Антонович', null, null);
--здесь не получилось так как значения действует ограничение unique на столбец doc_ser
INSERT INTO students ( record_book, name, doc_ser, doc_num )
values	(12303, 'Фролов Виктор Степанович', 1122, null),
	(12304, 'Фролов Степан Викторович', 1122, null);

6)
CREATE TABLE students
( record_book numeric( 5 ) NOT NULL UNIQUE,
name text NOT NULL,
doc_ser numeric( 4 ),
doc_num numeric( 6 ),
PRIMARY KEY ( doc_ser, doc_num )
);

CREATE TABLE progress
( doc_ser numeric( 4 ),
doc_num numeric( 6 ),
subject text NOT NULL,
acad_year text NOT NULL,
term numeric( 1 ) NOT NULL CHECK ( term = 1 OR term = 2 ),
mark numeric( 1 ) NOT NULL CHECK ( mark >= 3 AND mark <= 5 )
DEFAULT 5,
FOREIGN KEY ( doc_ser, doc_num )
REFERENCES students ( doc_ser, doc_num )
ON DELETE CASCADE
ON UPDATE CASCADE
);
INSERT INTO students
values ( 12300, 'Андреев Андрей', 1122, 112233 ),
( 12301, 'Антонов Андрей', 1123, 112234 );

7*)
--ON UPDATE CASCADE
update students
	set record_book = 12100 where name = 'Иванов Иван Иванович';
	insert into students 
		values(12100, 'Иванов Иван', '0002', 112233)
--проверим ссылающуюся таблицу	
select * from progress;  --данные изменились

-- ON UPDATE RESTRICT - запрещает удаление строки которая является ссылочной
--тут я случайно сделал с удалением ,но смысл тот же
insert into progress
values (101, 101, '2023-2024', 1, 5, 'экзамен' );
select * from students, progress;
alter table progress 
	drop constraint progress_record_book_fkey;
alter table progress
	add foreign key (record_book)
	references students(record_book) on update restrict;
begin
delete from students
	where record_book = 12100;
commit --ИТОГ: ограничение RESTRICT не дает удалить ссылочную таблицу
--ON UPDATE SET NULL при удалении записи в сылочной строке, в ссылающейся будет значение NULL
alter table progress 
	drop constraint progress_record_book_fkey;
alter table progress
	add foreign key (record_book)
	references students(record_book)ON UPDATE SET NULL;
begin 
update students 
	set record_book = 12101
	where record_book = 12100;
	--не получилось так как у нас стоит ограничение NOT NULL ,попробуем удалить его и повторить запрос 
	alter table progress 
		alter column record_book set not  null;
	alter table progress
		alter column subject_id set not  null;
	alter table progress
		alter column acad_year set not null;
	alter table progress
		alter column term set not null;
	alter table progress
		alter column test_form set not null;
update students 
	set record_book = 12101
	where record_book = 12100;
	select * from students, progress;
	rollback
--ТЕПЕРЕ ON UPDATE SET DEFAULT ,теперь вместо null будет default знач
alter table progress 
	drop constraint progress_record_book_fkey;
alter table progress
	add foreign key (record_book)
	references students(record_book)ON UPDATE SET DEFAULT;
	
	alter table progress
	alter column record_book set default 12301;
	
	begin
	update students 
	set record_book = 12101
	where record_book = 12100;
	select * from students, progress;
	--после операции ссылающимся страницам с record_book = 12100 присвоилось default значение
	rollback
	
	
8)
create table subjects
(
subject_id integer,
subject text,
primary key (subject_id),
unique (subject)
);


insert into subjects
values ('101', 'математика'),
	('102', 'информатика');

select * from students, progress;
--изменяем тип данных и заменяем значения
ALTER TABLE progress
ALTER COLUMN subject SET DATA TYPE integer
USING ( CASE WHEN subject = 'Информатика' THEN 102
ELSE 101
END );
--переименуем измененный атрибут 
ALTER TABLE progress
rename column subject to subject_id;

--добавим ссылку
alter table progress
	add foreign key (subject_id) 
	references subjects (subject_id);
	
insert into progress (record_book, subject_id, acad_year, term, mark, test_form)
values (12300, 101, '2021-2022', 1, 4, 'экзамен' ),
	(12300, 102, '2021-2022', 1, 0, 'зачет' );
	
9)
ALTER TABLE students ADD CHECK ( name <> '' );
INSERT INTO students ( record_book, name, doc_ser, doc_num )
VALUES ( 12300, '', 0402, 543281 );

INSERT INTO students VALUES ( 12346, ' ', 0406, 112233 );
INSERT INTO students VALUES ( 12347, '  ', 0407, 112234 );

delete from students 
	where record_book in ( 12346, 12347);

SELECT *, length( name ) FROM students;

--прежде удалим неподходящих студентов
delete from students 
	where record_book in ( 12346, 12347);
	
ALTER TABLE students ADD CHECK (name = trim(both from name));

10)
alter table students
	alter column doc_ser set data type varchar;
-- операция прошла без затруднений

11*)
 
alter table flights
	drop constraint "flights_check1";
	
ALTER TABLE flights
ADD CHECK ( actual_arrival IS NULL OR
( 
actual_departure IS NOT NULL AND
actual_arrival > actual_departure
)
);
select * from flights;

--для начала добавим строки в airports так как у нас есть ссылающиеся строки в столбце flights
insert into airports
values ( 'A01', 'SVO', 'Moscow', 1, 1, 'Moscow'),
( 'A02', 'VKO', 'Moscow', 1, 1, 'Moscow'),
( 'A03', 'DME', 'Moscow', 1, 1, 'Moscow');
--возможные исходы
INSERT INTO flights 
values(101, 'A0001', '2023-12-07 12:00:00', '2023-12-07 14:00:00', 'A03', 'A01', 'On Time', '733', '2023-12-07 12:00:00', '2023-12-07 14:00:00' );
--actual_arrival>actual_departure
INSERT INTO flights 
values(102, 'A0002', '2023-12-07 13:00:00', '2023-12-07 15:00:00', 'A02', 'A03', 'On Time', '763', '2023-12-07 15:00:00', '2023-12-07 13:00:00' );	
--act_arr = 0
INSERT INTO flights 
values(103, 'A0003', '2023-12-07 13:00:00', '2023-12-08 15:00:00', 'A02', 'A03', 'On Time', '773', '2023-12-07 15:00:00');	
select current_timestamp(0);
select current_timestamp;


12)
ALTER TABLE flights
	RENAME to flights_new;
--После проверки через командную строку командой \d видно ,что названия ограничений не изменились 
--но при необходимости можно также переименовать и внешние ключи

13)

DROP TABLE airports;
drop table flights; 
--таблица routes не изменится так как она не имеет внешних ключей
14)
CREATE OR REPLACE VIEW aircrafts_v AS
	SELECT aircraft_code, model, range, speed
	FROM aircrafts 
	order by range desc;
	
select * from aircrafts_v;
insert into aircrafts_v
values (368, 'Boeing 777-300', 8200, 865);

update aircrafts_v 
	set range = 870 
	where aircraft_code = '368';

delete from  aircrafts_v
	where range = 870;

16)
--материализованные представления не синхронизируются с изменениями в исходных таблицах для этого нужно примерять команду REFRESH MATERIALIZED VIEW _
create materialized view aircrafts_vm AS
	SELECT aircraft_code, model
	range,speed,
	count( * )
	FROM aircrafts 
	group by aircraft_code
	order by range desc;

select * from aircrafts_vm;

update aircrafts 
	set speed = 360 
	where aircraft_code = 'CN1';
select * from aircrafts_vm;

REFRESH MATERIALIZED VIEW aircrafts_vm;
--теперь данные обновились
select * from aircrafts_vm;

17)
create view pilots_v15 as
	select pilot_name, schedule from pilots
	where schedule @> '{1, 5}';
	drop view pilots_v15;
select * from pilots_v15;

create view airports_locationM as
	select airport_code ,airport_name , city
	from airports
	where city = 'Moscow';

18*)
ALTER TABLE aircrafts ADD COLUMN specifications jsonb;

UPDATE aircrafts 
SET specifications = 
'{
"crew": 2,
"engines": { "type": "IAE V2500", 
			"num": 2
			}}'::jsonb
where aircraft_code = '320';

select model, specifications
	FROM aircrafts
	where aircraft_code = '320';

select model, specifications->'engines' AS engines 
	FROM aircrafts
	where aircraft_code = '320';

SELECT model, specifications #> '{engines, type }'
	FROM aircrafts
	WHERE aircraft_code = '320';

ALTER TABLE airports add column airport_addition jsonb;
UPDATE airports
	set airport_addition = '{
	"Оценка": 4.9,
	"местоположение": {"адрес": "шереметьевское шоссе 37",
	"горизонт": "северо-запад"}
	}':: jsonb
where airport_name = 'SVO';
--допустим оценка изменилась
update airports
set airport_addition = jsonb_set( airport_addition, '{ Оценка }', '4.5')
where airport_name = 'SVO';
select airport_addition from airports;

alter table aircrafts add column aircraft_addition jsonb;
update aircrafts
	set aircraft_addition = '{
	"производитель": "германия",
	"пассажировместимость": {"престиж": 8, "эконом": 165}
	}' :: jsonb
	where model = 'Boeing 737-300';
select * from aircrafts;
--допустим количество мест для эконом класса уменьшилось,а в престиж класс за счет этого добавили еще 2 места 
update aircrafts
set aircraft_addition = jsonb_set( aircraft_addition, '{ пассажировместимость, престиж }', '10')
where model = 'Boeing 737-300';
update aircrafts
set aircraft_addition = jsonb_set( aircraft_addition, '{ пассажировместимость, эконом }', '160')
where model = 'Boeing 737-300';
select aircraft_addition from aircrafts;

















