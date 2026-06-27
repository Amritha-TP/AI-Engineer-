create database sales_management_db_4;

use sales_management_db_4;

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

INSERT INTO ProductLines (productLine, textDescription, htmlDescription, image) VALUES
('Classic Cars', 'Vintage and collectible classic cars', NULL, NULL),
('Motorcycles', 'Replica motorcycle models', NULL, NULL),
('Trucks and Buses', 'Heavy-duty trucks and buses', NULL, NULL),
('Vintage Planes', 'Historical aircraft replicas', NULL, NULL),
('Ships', 'Model ships and boats', NULL, NULL),
('Trains', 'Model trains and rail engines', NULL, NULL),
('Sports Cars', 'High-performance sports cars', NULL, NULL),
('Diecast Models', 'Premium diecast scale models', NULL, NULL),
('Construction Vehicles', 'Bulldozers, cranes, and loaders', NULL, NULL),
('Racing Cars', 'Formula and rally racing cars', NULL, NULL);

INSERT INTO Products VALUES
('P001', 'Classic Cars', '1969 Ford Mustang', '1:18', 'AutoArt', 'Classic muscle car', 120, 75.00, 120.00),
('P002', 'Classic Cars', '1957 Chevy Bel Air', '1:18', 'Minichamps', 'Vintage Chevy model', 80, 65.00, 110.00),
('P003', 'Motorcycles', 'Harley Davidson 1998', '1:10', 'Maisto', 'Harley replica', 150, 55.00, 95.00),
('P004', 'Motorcycles', 'Yamaha R1 2005', '1:12', 'Welly', 'Sport bike model', 200, 40.00, 75.00),
('P005', 'Vintage Planes', 'Fokker Dr.I', '1:32', 'Revell', 'WWI fighter plane', 60, 90.00, 150.00),
('P006', 'Ships', 'Titanic 1912', '1:700', 'Academy', 'Historic ship model', 40, 120.00, 200.00),
('P007', 'Trucks and Buses', 'Volvo FH16 Truck', '1:24', 'Italeri', 'Heavy-duty truck', 70, 85.00, 140.00),
('P008', 'Sports Cars', 'Ferrari F40', '1:18', 'Hot Wheels Elite', 'Supercar model', 90, 95.00, 160.00),
('P009', 'Racing Cars', 'Formula 1 Red Bull RB18', '1:18', 'Spark', 'F1 racing car', 50, 150.00, 250.00),
('P010', 'Diecast Models', 'Jeep Wrangler Rubicon', '1:24', 'Jada Toys', 'Diecast SUV model', 110, 45.00, 80.00);

INSERT INTO offices VALUES
('O01', 'New York', '212-555-1000', '123 Madison Ave', NULL, 'NY', 'USA', '10001', 'NA'),
('O02', 'Los Angeles', '310-555-2000', '456 Sunset Blvd', NULL, 'CA', 'USA', '90001', 'NA'),
('O03', 'Chicago', '312-555-3000', '789 Lake Shore Dr', NULL, 'IL', 'USA', '60007', 'NA'),
('O04', 'Houston', '713-555-4000', '101 Main St', NULL, 'TX', 'USA', '77001', 'NA'),
('O05', 'Miami', '305-555-5000', '202 Ocean Dr', NULL, 'FL', 'USA', '33101', 'NA'),
('O06', 'Toronto', '416-555-6000', '55 King St', NULL, 'ON', 'Canada', 'M5H 1J9', 'NA'),
('O07', 'London', '020-555-7000', '12 Oxford St', NULL, 'London', 'UK', 'W1D 1AB', 'EU'),
('O08', 'Paris', '01-555-8000', '88 Champs Elysees', NULL, 'Paris', 'France', '75008', 'EU'),
('O09', 'Tokyo', '03-555-9000', '5 Shibuya Crossing', NULL, 'Tokyo', 'Japan', '150-0002', 'APAC'),
('O10', 'Sydney', '02-555-1001', '77 Harbour St', NULL, 'NSW', 'Australia', '2000', 'APAC');

INSERT INTO employees VALUES
(1001, 'Smith', 'John', 'x101', 'john.smith@company.com', 'O01', NULL, 'CEO'),
(1002, 'Brown', 'Linda', 'x102', 'linda.brown@company.com', 'O02', 1001, 'Sales Manager'),
(1003, 'Taylor', 'Robert', 'x103', 'robert.taylor@company.com', 'O03', 1001, 'HR Manager'),
(1004, 'Wilson', 'Emma', 'x104', 'emma.wilson@company.com', 'O04', 1002, 'Sales Rep'),
(1005, 'Davis', 'Olivia', 'x105', 'olivia.davis@company.com', 'O05', 1002, 'Sales Rep'),
(1006, 'Miller', 'James', 'x106', 'james.miller@company.com', 'O06', 1003, 'HR Assistant'),
(1007, 'Moore', 'Sophia', 'x107', 'sophia.moore@company.com', 'O07', 1002, 'Sales Rep'),
(1008, 'Jackson', 'William', 'x108', 'william.jackson@company.com', 'O08', 1002, 'Sales Rep'),
(1009, 'Martin', 'Ava', 'x109', 'ava.martin@company.com', 'O09', 1003, 'HR Assistant'),
(1010, 'Lee', 'Ethan', 'x110', 'ethan.lee@company.com', 'O10', 1002, 'Sales Rep');

INSERT INTO customers VALUES
(2001, 'Tech World', 'Singh', 'Rohan', '9000000001', '12 MG Road', NULL, 'Bangalore', 'KA', '560001', 'India', 1004, 150000),
(2002, 'Auto Hub', 'Khan', 'Aamir', '9000000002', '22 Park St', NULL, 'Kolkata', 'WB', '700016', 'India', 1005, 200000),
(2003, 'Model Masters', 'Patel', 'Neha', '9000000003', '45 Ring Road', NULL, 'Delhi', 'DL', '110001', 'India', 1007, 180000),
(2004, 'Hobby Store', 'Rao', 'Vikram', '9000000004', '78 Anna Nagar', NULL, 'Chennai', 'TN', '600040', 'India', 1008, 120000),
(2005, 'Collectors Den', 'Shah', 'Meera', '9000000005', '9 Carter Road', NULL, 'Mumbai', 'MH', '400050', 'India', 1004, 250000),
(2006, 'Miniature World', 'Das', 'Arjun', '9000000006', '33 Salt Lake', NULL, 'Kolkata', 'WB', '700091', 'India', 1005, 175000),
(2007, 'Scale Models', 'Nair', 'Anu', '9000000007', '88 Marine Drive', NULL, 'Mumbai', 'MH', '400020', 'India', 1007, 160000),
(2008, 'Toy Planet', 'Iyer', 'Kiran', '9000000008', '55 Brigade Road', NULL, 'Bangalore', 'KA', '560025', 'India', 1008, 140000),
(2009, 'Hobby Craft', 'Menon', 'Dev', '9000000009', '101 MG Road', NULL, 'Pune', 'MH', '411001', 'India', 1004, 130000),
(2010, 'Model Zone', 'Roy', 'Isha', '9000000010', '66 Park Street', NULL, 'Kolkata', 'WB', '700017', 'India', 1005, 190000);

INSERT INTO orders VALUES
(30001, '2024-01-10', '2024-01-15', '2024-01-14', 'Shipped', NULL, 2001),
(30002, '2024-01-12', '2024-01-18', '2024-01-17', 'Shipped', NULL, 2002),
(30003, '2024-01-15', '2024-01-20', '2024-01-19', 'Shipped', NULL, 2003),
(30004, '2024-01-18', '2024-01-25', '2024-01-23', 'Shipped', NULL, 2004),
(30005, '2024-01-20', '2024-01-28', '2024-01-26', 'Shipped', NULL, 2005),
(30006, '2024-01-22', '2024-01-30', '2024-01-29', 'Shipped', NULL, 2006),
(30007, '2024-01-25', '2024-02-02', '2024-02-01', 'Shipped', NULL, 2007),
(30008, '2024-01-28', '2024-02-05', '2024-02-04', 'Shipped', NULL, 2008),
(30009, '2024-01-30', '2024-02-07', '2024-02-06', 'Shipped', NULL, 2009),
(30010, '2024-02-01', '2024-02-10', '2024-02-09', 'Shipped', NULL, 2010);

INSERT INTO payments VALUES
(2001, 'CHK001', '2024-01-14', 50000),
(2002, 'CHK002', '2024-01-17', 75000),
(2003, 'CHK003', '2024-01-19', 60000),
(2004, 'CHK004', '2024-01-23', 45000),
(2005, 'CHK005', '2024-01-26', 90000),
(2006, 'CHK006', '2024-01-29', 70000),
(2007, 'CHK007', '2024-02-01', 55000),
(2008, 'CHK008', '2024-02-04', 65000),
(2009, 'CHK009', '2024-02-06', 48000),
(2010, 'CHK010', '2024-02-09', 82000);

INSERT INTO orderdetails VALUES
(30001, 'P001', 5, 120.00, 1),
(30002, 'P003', 3, 95.00, 1),
(30003, 'P005', 2, 150.00, 1),
(30004, 'P008', 1, 160.00, 1),
(30005, 'P002', 4, 110.00, 1),
(30006, 'P004', 6, 75.00, 1),
(30007, 'P006', 1, 200.00, 1),
(30008, 'P007', 2, 140.00, 1),
(30009, 'P009', 1, 250.00, 1),
(30010, 'P010', 3, 80.00, 1);

-- Task 1 - Aggregate Functions.
    -- 1. Frame 3 problem statements using aggregate functions.
    -- 2. Use functions such as COUNT, SUM, AVG, MIN, or MAX.
    
-- Q1: count the number of orders received from customers.
	   select count(*) as numberOforders
       from orders;
       
-- Q2: Find the total and average amount received in payments
	   select 
       sum(amount) as Total_Amount_recieved,
	   avg(amount) as Average_Amount_recieved
       from payments;
    
-- Q3: Find the max and min products from products table
	   select
       min(buyprice) as minimum_price,
       max(buyPrice) as maximum_price
       from products;
       
-- Task 2 - Aggregate Functions with WHERE.
    -- 3. Frame 3 problem statements using aggregate functions with WHERE conditions.
    
-- Q1: Find the total payment amount received from customers whose payment amount is greater than 50,000.
	   select sum(amount) as highValuePay
       from payments where amount>50000;
       
-- Q2: Count how many orders were shipped in January 2024.
	   select count(*) as totalOrdersInJan
       from orders where shippedDate between '2024-01-01' and '2024-01-31';
       
-- Q3: Find the average, minimum, and maximum buy price of products belonging to the 'Classic Cars' product line.
       select avg(buyPrice) as avgBuyprice,
			  min(buyPrice) as minBuyprice,
              max(buyPrice) as maxBuyprice
	   from products 
       where productLine = 'Classic Cars';
       
-- Task 3 - Aggregate Functions with GROUP BY.
    -- 4. Frame 3 problem statements using aggregate functions along with GROUP BY.

-- Q1: Find the total number of employees on each job title.
	  select jobTitle,count(*) as count
	  from employees group by jobTitle;

-- Q2: Count how many office in each country.
	   select country, count(*) as numberOfOffices 
       from offices 
       group by country;
       
-- Q3: List product codes that appear in more than 3 quantity of orders.
	   select productCode, sum(quantityOrdered) 
       from orderdetails 
       where quantityOrdered > 3 
       group by productCode;	
       
-- Task 4 - Subqueries .
    -- 5. Frame 1 problem statement using a subquery.
    
-- Q1: Find the product details of all products 
       -- whose buy price is higher than the average buy price of all products
       
       select * from products where buyPrice > (select avg(buyPrice) from products);
       
-- Q2: Retrieve the details of customers who have placed at least one order.

	   select * from customers where customerNumber in (select customerNumber from orders);

	
-- Find the average, minimum, and maximum payment amount made by each customer.