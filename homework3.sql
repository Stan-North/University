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

--создание таблиц и копирование заявок
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

--Скрипт №2 - Начисление процентов по кредитам за день
DO $$
	DECLARE
	result_row RECORD;
	base_credit_rate NUMERIC(12,2) := 0.1;
	var_client_name VARCHAR;
	var_result_interest NUMERIC(12,2);
	var_total_interest NUMERIC(12,2) := 0.0;
	BEGIN
		EXECUTE 'CREATE TABLE IF NOT EXISTS credit_percent 
		(client_name VARCHAR(100) PRIMARY KEY, interest_amount NUMERIC(12,2))';
	
		--расчет для физ.лиц
		FOR result_row IN (SELECT client_name, amount FROM person_credit) LOOP
			var_client_name := result_row.client_name;
			var_result_interest := (COALESCE(result_row.amount, 0) * (base_credit_rate + 0.05) / 365);
			
			INSERT INTO credit_percent(client_name, interest_amount) VALUES(var_client_name, var_result_interest)
			ON CONFLICT (client_name)
			DO UPDATE SET interest_amount = EXCLUDED.interest_amount;
			var_total_interest := (var_total_interest + var_result_interest);
		END LOOP;
	
		--расчет для компаний
		FOR result_row IN (SELECT client_name, amount FROM company_credit) LOOP
			var_client_name := result_row.client_name;
			var_result_interest := ((COALESCE(result_row.amount, 0) * base_credit_rate) / 365);
			INSERT INTO credit_percent(client_name, interest_amount) VALUES(var_client_name, var_result_interest)
			ON CONFLICT (client_name)
			DO UPDATE SET interest_amount = EXCLUDED.interest_amount;
			var_total_interest := (var_total_interest + var_result_interest);
		END LOOP;
		RAISE NOTICE 'общая сумма начисленных процентов: %', var_total_interest;
	END;
$$


--Создать view которая отображает только заявки компаний
CREATE VIEW company_bid AS (SELECT product_type, client_name AS company_name, amount FROM bid WHERE IS_COMPANY = true);