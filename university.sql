CREATE TABLE faculty (
						faculty_id INT NOT NULL, 
						faculty_name VARCHAR(50) NOT NULL, 
						education_cost MONEY,
						PRIMARY KEY(faculty_id)
						);

--создание таблицы с курсами
CREATE TABLE course (
					course_id INT NOT NULL,
					course_number INT NOT NULL,
					faculty_id INT NOT NULL,
					PRIMARY KEY(course_id),
					FOREIGN KEY(faculty_id) REFERENCES faculty(faculty_id)
					);

--создание enum c типами учеников
CREATE TYPE payment AS ENUM ('бюджетник', 'частник');

--создание таблицы с учениками
CREATE TABLE student (
						student_id int NOT NULL,
						first_name VARCHAR(20) NOT NULL, 
						last_name VARCHAR(20) NOT NULL,
						patronymic VARCHAR(20),
						payment_type payment NOT NULL,
						course_id INT NOT NULL,
						PRIMARY KEY (student_id),
						FOREIGN KEY(course_id) REFERENCES course(course_id)
						);

--Создать два факультета: Инженерный (30 000 за курс) , Экономический (49 000 за курс)
INSERT INTO faculty VALUES(1, 'Инженерный', 30000);
INSERT INTO faculty VALUES(2, 'Экономический', 49000);

--Создать 1 курс на Инженерном факультете: 1 курс
INSERT INTO course VALUES(1, 1, 1);

--Создать 2 курса на экономическом факультете: 1, 4 курс
INSERT INTO course VALUES(2, 1 , 2);
INSERT INTO course VALUES(3, 4 , 2);

--4. Создать 5 учеников:
--Петров Петр Петрович, 1 курс инженерного факультета, бюджетник
--Иванов Иван Иваныч, 1 курс инженерного факультета, частник
--Михно Сергей Иваныч, 4 курс экономического факультета, бюджетник
--Стоцкая Ирина Юрьевна, 4 курс экономического факультета, частник
--Младич Настасья (без отчества), 1 курс экономического факультета, частник
INSERT INTO student VALUES(1, 'Петр', 'Петров', 'Петрович', 'бюджетник', 1);
INSERT INTO student VALUES(2, 'Иван', 'Иванов', 'Иваныч', 'частник', 1);
INSERT INTO student VALUES(3, 'Сергей', 'Михно', 'Иваныч', 'бюджетник', 3);
INSERT INTO student VALUES(4, 'Ирина', 'Стоцкая', 'Юрьевна', 'частник', 3);
INSERT INTO student VALUES(5, 'Настасья', 'Младич', NULL, 'частник', 2);

--1. Вывести всех студентов, кто платит больше 30_000.
SELECT student_id, first_name, last_name, patronymic, faculty_name, education_cost
FROM student
JOIN course ON student.course_id = course.course_id
JOIN faculty ON course.faculty_id = faculty.faculty_id
WHERE CAST(education_cost AS decimal) > 30000 AND payment_type = 'частник';

--2. Перевести всех студентов Петровых на 1 курс экономического факультета.
UPDATE student SET course_id = 2
WHERE last_name = 'Петров';

--3. Вывести всех студентов без отчества или фамилии.
SELECT *
FROM student
WHERE last_name IS NULL OR patronymic IS NULL;

--4. Вывести всех студентов содержащих в фамилии или в имени или в отчестве "ван". 
--(пример name like '%Петр%' - найдет всех Петров, Петровичей, Петровых)
SELECT *
FROM student
WHERE first_name LIKE '%ван' OR last_name LIKE '%ван' OR patronymic LIKE '%ван';

--5. Удалить все записи из всех таблиц.
DELETE FROM student;
DELETE FROM course;
DELETE FROM faculty;
