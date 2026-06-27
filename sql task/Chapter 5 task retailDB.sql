create database retailstoreDB;

use retailstoreDB;

create table customers (
customer_id int primary key,
customer_name varchar(50),
city varchar(50));

create table products(
product_id int primary key,
product_name varchar(50),
price decimal(10,2));

create table orders(
order_id int auto_increment primary key,
customer_id int,
product_id int,
qauntity int,
foreign key(customer_id) references customers(customer_id),
foreign key(product_id) references products(product_id)
);

INSERT INTO customers (customer_id, customer_name, city) VALUES
(1, 'Asha', 'Theni'),
(2, 'Rahul', 'Karur'),
(3, 'Meera', 'Idukki'),
(4, 'Vikram', 'Chennai'),
(5,'Amri','Coimbatore');

INSERT INTO products (product_id, product_name, price) VALUES
(101, 'Laptop', 900),
(102, 'Headphones', 50),
(103, 'Keyboard', 30),
(104, 'Smartwatch', 120);

INSERT INTO products (product_id, product_name, price) VALUES
(105,'iphone',100000);

alter table orders 
add price decimal(10,2);

INSERT INTO orders (customer_id, product_id, qauntity,price) VALUES
(1, 101, 1,900),
(1, 102, 2, 100),
(2, 102, 1,50),
(3, 103, 3,90);

INSERT INTO orders (customer_id, product_id, qauntity,price) VALUES(5,105,1,100000);

-- Inner join - return the rows that have matching values in both tables.

-- Q1: find the customer name of the orders
		select c.customer_name, o.qauntity,o.price
        from customers c
        join orders o on c.customer_id = o.customer_id;
        
-- LEFT JOIN - Returns every rows from the left table and the only matched rows from the right table.

-- Q2: show all customers even if no orders.
	select c.customer_name,p.product_name, o.qauntity,o.price
	from customers c
	left join orders o on c.customer_id = o.customer_id
    left join products p on p.product_id =  o.product_id;

-- RIGHT JOIN - Returns all rows from the right table and the matched rows from the left table.
-- Q3: list all the products along with the customer name and order details
	select c.customer_name,p.product_name, o.qauntity,o.price
	from customers c
	right join orders o on c.customer_id = o.customer_id
    right join products p on p.product_id =  o.product_id;
    
-- FULL OUTER JOIN - Returns all rows from both tables. Fills with NULL where data does not match.
					-- we use union as fullouter join is not supported
	select c.customer_name,p.product_name, o.qauntity,o.price
	from customers c
	left join orders o on c.customer_id = o.customer_id
    left join products p on p.product_id =  o.product_id
    
    union all
    
    select c.customer_name,p.product_name, o.qauntity,o.price
	from customers c
	right join orders o on c.customer_id = o.customer_id
    right join products p on p.product_id =  o.product_id;
    
    -- cross join - Returns the Cartesian product of every possible combination of rows between both tables.
	
    select c.customer_name, p.product_name
	from customers c
	cross join products p;
    
    






