--. Создание таблицы party_guest
CREATE TABLE party_guest (name VARCHAR(50) NOT NULL, 
	email VARCHAR(50) NOT NULL UNIQUE CHECK (email <> ''), 
	id SERIAL PRIMARY KEY, 
	is_coming BOOL DEFAULT false);

---- 2. Создать пользователя manager. 
CREATE USER manager WITH PASSWORD '1234';

--manager может заносить данные в таблицу с гостями, а так же смотреть список гостей.
GRANT SELECT, INSERT, UPDATE ON TABLE party_guest TO manager;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE party_guest_id_seq TO manager;

--права на работу со схемой public
GRANT USAGE, CREATE ON SCHEMA public TO manager;

-- 3. Создать view party_guest_name. Должны быть только имена гостей.
CREATE VIEW party_guest_name AS (SELECT name FROM party_guest);

-- 4. Создать пользователя guard.
CREATE USER guard WITH PASSWORD '4321';

--Он может смотреть только view party_guest_name.
GRANT SELECT ON TABLE party_guest_name TO guard;

SET ROLE manager;

SELECT current_user;

INSERT INTO party_guest (name, email)
VALUES 
	('Charles', 'charles_ny@yahoo.com'),
	('Charles', 'mix_tape_charles@google.com'),
	('Teona', 'miss_teona_99@yahoo.com');

	
SET ROLE guard;

SELECT *
FROM party_guest_name;

SET ROLE postgres;

--процедура создания таблицы черного списка если она не существуеют
CREATE OR REPLACE PROCEDURE create_black_list()
LANGUAGE plpgsql
AS $$
	BEGIN
		CREATE TABLE IF NOT EXISTS black_list(id SERIAL PRIMARY KEY, email VARCHAR(50));
	END;
$$;

--процедура окончания вечерники
CREATE OR REPLACE PROCEDURE party_end ()
	LANGUAGE plpgsql
	AS $$
		BEGIN
			CALL create_black_list();
			
			INSERT INTO black_list(email)
			SELECT email
			FROM party_guest
			WHERE is_coming = false;
			
			--удаление данных таблицы и сброс сиквенса
			TRUNCATE TABLE party_guest;
			PERFORM SETVAL('party_guest_id_seq', 1);
		END;
$$;


-- процедура вставки человека в таблицу party_guest
CREATE OR REPLACE PROCEDURE insert_into_party_list(_name VARCHAR, _email VARCHAR)
LANGUAGE plpgsql
AS $$
	BEGIN
		INSERT INTO party_guest(name, email)
		VALUES(_name, _email);
	END;
$$;


--функция записи на вечеринку
CREATE OR REPLACE FUNCTION register_to_party(_name VARCHAR, _email VARCHAR)
RETURNS BOOL
LANGUAGE plpgsql
AS $$
	DECLARE is_black_list_exist BOOL;
	BEGIN
		--присвоение значения переменной
		SELECT (to_regclass('public.black_list') IS NOT NULL)
		INTO is_black_list_exist;
		
		IF is_black_list_exist = true
			THEN 
				IF EXISTS (
					SELECT email 
					FROM black_list
					WHERE email = _email)
				THEN
					RAISE NOTICE 'Человек с email % есть в черном списке', _email;
					RETURN false;
				ELSE
					RAISE NOTICE 'Человека с email % нет в черном списке', _email;
					CALL insert_into_party_list(_name, _email);
					RETURN true;
				END IF;
		ELSE
			CALL create_black_list();
			CALL insert_into_party_list(_name, _email);
			RETURN true;
		END IF;
	END;
$$;

--Зарегистрировать Petr, korol_party@yandex.ru на вечеринку с помощью функции.
SELECT register_to_party('Petr', 'korol_party@yandex.ru');

-- На вечеринку пришли гости с email - mix_tape_charles@google.com, miss_teona_99@yahoo.com. Поменять статус у них на "пришел"
UPDATE party_guest
SET is_coming = true
WHERE email IN ('mix_tape_charles@google.com', 'miss_teona_99@yahoo.com');

CALL party_end();
