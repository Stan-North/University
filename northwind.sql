--3.1. Посчитать количество заказов за все время. 
SELECT COUNT(*) AS order_count
FROM orders;

--3.2. Посчитать сумму денег по всем заказам за все время (учитывая скидки).  
--Смотри таблицу order_details. Вывод: id заказа, итоговый чек (сумма стоимостей всех  продуктов со скидкой)
--сколько в каждом заказе итоговый чек
--SUM(quantity * (unit_price - (unit_price * discount)))
SELECT order_id, SUM((quantity * unit_price) - ((quantity * unit_price)* discount)) AS total_price
FROM order_details
GROUP BY order_id
ORDER BY order_id;


--3.3. Показать сколько сотрудников работает в каждом городе. 
--Смотри таблицу employee. Вывод: наименование города и количество сотрудников
SELECT city, COUNT(*) AS employees_quantity
FROM employees
GROUP by city;

--3.4. Показать фио сотрудника (одна колонка) и сумму всех его заказов 
SELECT first_name || ' ' || last_name AS full_name, 
		SUM(total_price) AS total_orders_price
FROM (
	SELECT orders.order_id, 
		employee_id, 
		SUM((quantity * unit_price) - ((quantity * unit_price)* discount)) AS total_price
	FROM orders JOIN order_details ON orders.order_id = order_details.order_id
	GROUP BY orders.order_id
	ORDER BY orders.order_id
) AS t1 
JOIN employees ON t1.employee_id = employees.employee_id
GROUP BY full_name
ORDER BY total_orders_price;

--3.5. Показать перечень товаров от самых продаваемых до самых непродаваемых (в штуках). 
-- Вывести наименование продукта и количество проданных штук.
SELECT product_name, total_sold
FROM
	(SELECT product_id, SUM(quantity) AS total_sold
	FROM order_details
	GROUP BY product_id) AS t1
JOIN products ON t1.product_id = products.product_id
ORDER BY total_sold DESC