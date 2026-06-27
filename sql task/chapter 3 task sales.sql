create database sales_management;

use sales_management;

create table ProductLines(
productLine varchar(50) primary key,
textDescription varchar(4000) default null,
htmlDescription mediumtext ,
image blob );

create table Products(
productCode varchar(15) primary key,
productLine varchar(50),
productName varchar(70) not null,
productScale varchar(70),
productVendor varchar(70),
productDescription text,
quantityInStock int ,
buyPrice decimal(10,2),
MSRP decimal(10.2),
foreign key(productLine) references ProductLines(ProductLine));

create table offices(
	officeCode VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    addressLine1 VARCHAR(50) NOT NULL,
    addressLine2 VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    postalCode VARCHAR(15) NOT NULL,
    territory VARCHAR(10) NOT NULL);
    
alter table offices modify column state varchar(50) NOT NULL;

CREATE TABLE employees (
    employeeNumber INT PRIMARY KEY,
    lastName VARCHAR(50) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    officeCode VARCHAR(10) NOT NULL,
    reportsTo INT,
    jobTitle VARCHAR(50) NOT NULL,
    FOREIGN KEY (officeCode) REFERENCES offices(officeCode),
    FOREIGN KEY (reportsTo) REFERENCES employees(employeeNumber)
);

CREATE TABLE customers (
    customerNumber INT PRIMARY KEY,
    customerName VARCHAR(50) NOT NULL,
    contactLastName VARCHAR(50) NOT NULL,
    contactFirstName VARCHAR(50) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    addressLine1 VARCHAR(50) NOT NULL,
    addressLine2 VARCHAR(50),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    postalCode VARCHAR(15),
    country VARCHAR(50) NOT NULL,
    salesRepEmployeeNumber INT,
    creditLimit DECIMAL(10,2),
    FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber)
);

CREATE TABLE orders (
    orderNumber INT PRIMARY KEY,
    orderDate DATE NOT NULL,
    requiredDate DATE NOT NULL,
    shippedDate DATE NOT NULL,
    status VARCHAR(15) NOT NULL,
    comments VARCHAR(200),
    customerNumber INT NOT NULL,
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

CREATE TABLE payments (
    customerNumber INT NOT NULL,
    checkNumber VARCHAR(50) NOT NULL,
    paymentDate DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (customerNumber, checkNumber),
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

CREATE TABLE orderdetails (
    orderNumber INT NOT NULL,
    productCode VARCHAR(15) NOT NULL,
    quantityOrdered INT NOT NULL,
    priceEach DECIMAL(10,2) NOT NULL,
    orderLineNumber SMALLINT NOT NULL,
    PRIMARY KEY (orderNumber, productCode),
    FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber),
    FOREIGN KEY (productCode) REFERENCES products(productCode)
);

INSERT INTO ProductLines 
VALUES 
('Classic Cars', 'Vintage and classic model cars', NULL, NULL),
('Motorcycles', 'Racing and sports bikes', NULL, NULL);

INSERT INTO Products 
VALUES 
('S10_1678','Motorcycles', '1969 Harley Davidson',  '1:10','Min Lin Diecast','Classic Harley Davidson bike model', 100, 4800, 6500),
('S12_1099','Classic Cars', '1968 Ford Mustang',  '1:12','Autoart Studio', 'Classic Ford Mustang model', 50, 9500, 12000);

INSERT INTO offices 
VALUES 
('1', 'Chennai', '+91-44-12345678', 'T Nagar', NULL, 'Tamil Nadu', 'India', '600017', 'APAC'),
('2', 'Bangalore', '+91-80-87654321', 'MG Road', NULL, 'Karnataka', 'India', '560001', 'APAC');

INSERT INTO employees 
VALUES
(1002, 'Kumar', 'Arun', 'x101', 'arun.kumar@classic.com', '1', NULL, 'Sales Manager'),
(1056, 'Ravi', 'Suresh', 'x102', 'suresh.ravi@classic.com', '1', 1002, 'Sales Rep'),
(1076, 'Sharma', 'Neha', 'x103', 'neha.sharma@classic.com', '2', 1002, 'Sales Rep');

INSERT INTO customers 
VALUES
(2001, 'ABC Traders', 'Rao', 'Vikram', '+91-9876543210','Anna Nagar', NULL, 'Chennai', 'Tamil Nadu', '600040', 'India', 1056, 150000),
(2002, 'XYZ Electronics', 'Patel', 'Amit', '+91-9123456789', 'Indiranagar', NULL, 'Bangalore', 'Karnataka', '560038', 'India', 1076, 200000);

INSERT INTO orders 
VALUES
(30001, '2026-01-10', '2026-01-15', '2026-01-13', 'Shipped', 'Delivered on time', 2001),
(30002, '2026-01-12', '2026-01-18', '2026-01-15', 'In Process', 'ON THE WAY', 2002);

INSERT INTO payments 
VALUES
(2001, 'CHK1001', '2026-01-16', 13000),
(2002, 'CHK1002', '2026-01-17', 12000);

INSERT INTO orderdetails 
VALUES
(30001, 'S10_1678', 2, 6500, 1),
(30002, 'S12_1099', 1, 12000, 1);

SELECT * FROM ProductLines;
SELECT * FROM Products;
SELECT * FROM customers;
SELECT * FROM orderdetails;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM employees;
SELECT * FROM offices;

-- DQL - Data Query Language is used to select specific data from the table without changing the data.(SELECT)

-- DML - Data Manipulation Language is used to modify/alter and update contents in the table.(INSERT, ALTER,UPDATE,DELETE)

-- Q1: Show only product names and prices from products table where quantity in stock is 50.
SELECT productName,buyPrice FROM Products where quantityInStock=50; -- select retrives a data from table

-- Q2: Add a new product line
INSERT INTO productlines
values ("Aircrafts","Military Aircrafts",NULL,NULL); -- inserts a new row

-- Q3: Change the city of office 1 to coimbatore in offices
UPDATE offices 
SET city = "Coimbatore"
WHERE officeCode = '1'; -- update changes a value in a column based on the given condition.

-- Q4: Remove productline aircrafts from productline table
DELETE FROM productlines 
WHERE ProductLine ='Aircrafts'; -- delete helps you to delete a row from a table.

-- Q5: Add a new column to orders named customer_name
	ALTER TABLE orders
    ADD customer_name varchar(50);

-- Q6: update customer_name in orders table
   UPDATE ORDERS 
   SET customer_name = 'ABC Traders'
   where customerNumber ='2001';
   
   UPDATE ORDERS 
   SET customer_name = 'XYZ Electronics'
   where customerNumber ='2002';
   
-- Q7: Change the size of productName column in products table.
	ALTER TABLE products
    MODIFY productName VARCHAR(100);
    
-- Q8: select the order detail where the price is above 10000.
	SELECT * FROM orderdetails
    WHERE priceEach>10000;

-- Q9: who is the sales manager?
	SELECT firstName, lastName, jobTitle 
    FROM employees 
    WHERE jobTitle='Sales Manager';
    
-- Q10: Give me shipped order details:
	SELECT * FROM orders
    WHERE status ='shipped';