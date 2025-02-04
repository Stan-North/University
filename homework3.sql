--Таблица "заявка"
create table bid (
	id serial primary key, 
	product_type varchar(50),
	client_name varchar(100),
	is_company boolean,
	amount numeric(12,2)
);

insert into bid (product_type, client_name, is_company, amount) values
('credit', 'Petrov Petr Petrovich', false, 1000000),
('credit', 'Coca cola', true, 100000000),
('deposit', 'Soho bank', true, 12000000),
('deposit', 'Kaspi bank', true, 18000000),
('deposit', 'Miksumov Anar Raxogly', false, 500000),
('debit_card', 'Miksumov Anar Raxogly', false, 0),
('credit_card', 'Kipu Masa Masa', false, 5000),
('credit_card', 'Popova Yana Andreevna', false, 25000),
('credit_card', 'Miksumov Anar Raxogly', false, 30000),
('debit_card', 'Saronova Olga Olegovna', false, 0);

--1. Создавать таблицы на основании таблицы bid:
--Имя таблицы должно быть основано на типе продукта + является ли он компанией
--Если такая таблица уже есть, скрипт не должен падать!
--Например:
--для записи где product_type = credit, is_company = false будет создана таблица:
--person_credit, с колонками: id (новый id), client_name, amount
--для записи где product_type = credit, is_company = true:
--company_credit, с колонками: id (новый id), client_name, amount

--2. Копировать заявки в соответствующие таблицы c помощью конструкции:
--2.1 Для вставки значений можно использовать конструкцию
--insert into (col1, col2)
--select col1, col2
--from [наименование таблицы]
--2.2 Для исполнения динамического запроса с параметрами можно использовать конструкцию
--execute '[текст запроса]' using [значение параметра №1], [значение параметра №2].
--Пример:
--execute 'select * from product where product_type = $1 and is_company = $2' using 'credit', false;

DO $$
	DECLARE 
	result_row RECORD;
	product_type VARCHAR;
	table_prefix VARCHAR;
	table_title VARCHAR;
	is_company BOOLEAN;
	BEGIN
		FOR result_row IN (SELECT * FROM bid) LOOP 
		product_type := result_row.product_type;
			is_company := result_row.is_company::BOOLEAN;
			RAISE NOTICE 'is_company содержит: %', is_company;
			
			IF is_company = true 
			THEN table_prefix := 'company_';
			ELSE table_prefix := 'person_';
			END IF;
			
		table_title := table_prefix || product_type;
		
		EXECUTE FORMAT('CREATE TABLE IF NOT EXISTS %I (id SERIAL PRIMARY KEY, client_name VARCHAR(100), 
		amount NUMERIC(12,2));', table_title);
		
		RAISE NOTICE 'Table title: %, Product type: %, Is company: %', table_title, product_type, is_company;
		
		EXECUTE FORMAT('INSERT INTO %I (client_name, amount) SELECT client_name, amount FROM bid 
		WHERE product_type = %L AND is_company = %L;' ,table_title, product_type, is_company);
		END LOOP;
	END;
$$


