-- CREATE SOME INDEXES FOR TESTING
USE employees;

-- Create index_1
DROP INDEX index_1 ON employees;
CREATE INDEX index_1 ON employees (last_name, first_name, birth_date);

-- Create index_2
DROP INDEX index_2 ON employees;
CREATE INDEX index_2 ON employees (birth_date, last_name, first_name);

----------------------------------------------------------------------
-- Example 1: Match full value
---- Get last row
SELECT * FROM employees.employees ORDER BY emp_no DESC LIMIT 1;
'499999', '1958-05-01', 'Sachin', 'Tsukuda', 'M', '1997-11-30'
---- Select the last row and analyze
EXPLAIN SELECT * FROM employees.employees WHERE last_name = 'Tsukuda' AND first_name = 'Sachin' AND birth_date = '1958-05-01';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '10.00', 'Using where'
---- Create index_1 and check again
DROP INDEX index_1 ON employees;
CREATE INDEX index_1 ON employees (last_name, first_name, birth_date);
EXPLAIN SELECT * FROM employees.employees WHERE last_name = 'Tsukuda' AND first_name = 'Sachin' AND birth_date = '1958-05-01';
'1', 'SIMPLE', 'employees', NULL, 'ref', 'index_1', 'index_1', '37', 'const,const,const', '1', '100.00', NULL


-- Example 2: Match leftmost prefix
---- Get last row
SELECT * FROM employees.employees ORDER BY emp_no DESC LIMIT 1;
'499999', '1958-05-01', 'Sachin', 'Tsukuda', 'M', '1997-11-30'
---- Select the last row and analyze
EXPLAIN SELECT * FROM employees.employees WHERE last_name = 'Tsukuda';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '10.00', 'Using where'
---- Create index_1 and check again
DROP INDEX index_1 ON employees;
CREATE INDEX index_1 ON employees (last_name, first_name, birth_date);
EXPLAIN SELECT * FROM employees.employees WHERE last_name = 'Tsukuda';
'1', 'SIMPLE', 'employees', NULL, 'ref', 'index_1', 'index_1', '18', 'const', '185', '100.00', NULL

-- Example 3: Match a column prefix
---- Get last row
SELECT * FROM employees.employees ORDER BY emp_no DESC LIMIT 1;
'499999', '1958-05-01', 'Sachin', 'Tsukuda', 'M', '1997-11-30'
---- Select the last row and analyze
EXPLAIN SELECT * FROM employees.employees WHERE last_name = 'Tsukuda';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '10.00', 'Using where'
---- Create index_1
DROP INDEX index_1 ON employees;
CREATE INDEX index_1 ON employees (last_name, first_name, birth_date);
---- Select with prefix condition (worked)
EXPLAIN SELECT * FROM employees.employees WHERE last_name LIKE 'Tsukud%';
'1', 'SIMPLE', 'employees', NULL, 'ref', 'index_1', 'index_1', '18', 'const', '185', '100.00', NULL
---- Select with subfix condition (not worked)
EXPLAIN SELECT * FROM employees.employees WHERE last_name LIKE '%sukuda';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '11.11', 'Using where'
---- Select with prefix condition not for the leftmost column (not worked)
EXPLAIN SELECT * FROM employees.employees WHERE first_name LIKE 'Sachi%';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '11.11', 'Using where'

-- Example 4: Match a range of values
---- Get 2 rows
SELECT * FROM employees.employees where emp_no = '255161';
'255161', '1963-10-01', 'Mitsuyuki', 'Bernatsky', 'F', '1989-05-01'
SELECT * FROM employees.employees where emp_no = '499999';
'499999', '1958-05-01', 'Sachin', 'Tsukuda', 'M', '1997-11-30'
---- Select for a range date without index
EXPLAIN SELECT * FROM employees.employees WHERE birth_date BETWEEN '1963-10-01' AND '1963-11-29';
'1', 'SIMPLE', 'employees', NULL, 'ALL', NULL, NULL, NULL, NULL, '299246', '11.11', 'Using where'
---- Create index_2
DROP INDEX index_2 ON employees;
CREATE INDEX index_2 ON employees (birth_date, last_name, first_name);
---- Select date range on the leftmost column
EXPLAIN SELECT * FROM employees.employees WHERE last_name LIKE 'Tsukud%';
'1', 'SIMPLE', 'employees', NULL, 'range', 'index_2', 'index_2', '3', NULL, '3767', '100.00', 'Using index condition'
