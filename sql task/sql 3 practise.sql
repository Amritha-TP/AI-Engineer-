create database studentsdb;


use studentsdb;

create table students(
student_id int auto_increment primary key,
firstname varchar(50),
lastname varchar(50),
birth_date date,
gender varchar(10));

create table courses(
course_id int auto_increment primary key,
course_name varchar(50),
credits int);

create table enrollment(
enrollmentid int auto_increment primary key,
student_id int,
course_id int,
enrollmentdate date,
foreign key(student_id) references students(student_id),
foreign key(course_id) references courses(course_id)); 


insert into students(firstname, lastname,birth_date,gender)
values
("John","Doe",'2000-05-15','Male'),
('Jane',"smith",'2002-11-09',"Female"),
('Emily', 'Johnson', '2001-07-22', 'Female'),
('Michael', 'Williams', '2000-12-30', 'Male'),
('Sarah', 'Brown', '1998-10-10', 'Female'),
('David', 'Jones', '2002-03-25', 'Male'),
('Emma', 'Garcia', '2000-11-08', 'Female'),
('James', 'Martinez', '1999-01-01', 'Male'),
('Olivia', 'Hernandez', '2001-08-30', 'Female'),
('William', 'Lopez', '2000-02-14', 'Male');

insert into courses(course_name,credits)
values
("Maths",3),
('Computer Science', 4),
('Biology', 3),
('Chemistry', 4),
('Physics', 3),
('Literature', 2),
('History', 3),
('Economics', 3),
('Engineering', 4),
('Data Science', 4);

insert into enrollment (student_id,course_id,enrollmentdate)
values
(1, 1, '2021-08-20'),
(2, 1, '2021-08-20'),
(1, 2, '2021-08-20'),
(3, 2, '2021-08-20'),
(4, 3, '2021-08-20'),
(2, 4, '2022-01-15'),
(3, 5, '2021-08-20'),
(5, 6, '2022-01-15'),
(6, 7, '2021-08-20'),
(7, 8, '2022-01-15'),
(8, 9, '2021-08-20'),
(9, 10, '2022-01-15');

SELECT * FROM courses;

 