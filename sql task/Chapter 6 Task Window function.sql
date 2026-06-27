CREATE DATABASE employee_window;
USE employee_window;

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary INT,
    hire_date DATE,
    performance_score INT
);

INSERT INTO Employees VALUES
(1, 'Alice', 'HR', 55000, '2020-01-15', 4),
(2, 'Bob', 'HR', 60000, '2019-03-10', 5),
(3, 'Charlie', 'Finance', 75000, '2018-07-22', 3),
(4, 'David', 'Finance', 72000, '2021-02-11', 4),
(5, 'Eva', 'Finance', 80000, '2017-11-05', 5),
(6, 'Frank', 'IT', 90000, '2019-06-18', 4),
(7, 'Grace', 'IT', 95000, '2020-09-25', 5),
(8, 'Helen', 'IT', 88000, '2021-12-01', 3),
(9, 'Ian', 'Marketing', 65000, '2018-04-14', 4),
(10, 'Jane', 'Marketing', 68000, '2020-08-30', 5);

-- Task 1: Frame 5 questions that use window functions.

-- Q1: rank the employees based on performance_score.

select *,
rank() over(order by performance_score) as EmpRank
from Employees;

-- Q 1.2 dense rank employees based on department and performance score wise. 
select *,
dense_rank() over(partition by department order by performance_score) as DeptEmployeeRank
from Employees;

-- Q2 total the salary of employees in department vise.

select *,
sum(salary) over(partition by department ) as Total_dept_salary
from Employees;

-- Q3 average the salary of employees in department vise.

select *,
avg(salary) over(partition by department ) as Avg_dept_salary
from Employees;

-- Q3 count of employees in each department.

select *,
count(emp_name) over(partition by department ) as count_of_emp_dept
from Employees ;

-- Q4 Compare each employee’s salary with the previous employee hired in the same department.

select *,
lag (salary) over(partition by department order by hire_date) as previous_emp_salary
from employees;

-- Q5 Compare each employee’s salary with the next employee hired in the same department.

select *,
lead (salary) over(partition by department order by hire_date) as next_emp_salary
from employees;

-- Task 2 : Stored Procedures

-- Q1: retrive all emp details
delimiter $$

create procedure get_all_emp_details()
begin 
	select*from employees;
end $$
delimiter ;

call  get_all_emp_details;

-- Q2: get employee detail based on performance score

delimiter $$
create procedure performance_emp(in P_score int)
begin
	select *
    from employees 
    where performance_score = P_score;
end $$
delimiter ;

call performance_emp(4);

-- Q3: get employee detail based on department

delimiter $$
create procedure dept_emp(in dpt varcharacter(30))
begin
	select *
    from employees 
    where department = dpt;
end $$
delimiter ;

call dept_emp("IT");
