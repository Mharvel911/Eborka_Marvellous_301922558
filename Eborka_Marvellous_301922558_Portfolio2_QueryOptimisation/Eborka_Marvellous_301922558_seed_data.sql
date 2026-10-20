-- MIT 8103 | Marvellous Ewere Eborka | 301922558
-- Portfolio 2: synthetic data for MySQL 8 (5,000 customers/accounts, 500,000 transactions)
-- Run AFTER schema.sql, inside the eborka_bank database.

-- Helper table of numbers 1..500000 (MySQL has no generate_series)
SET SESSION cte_max_recursion_depth = 1000000;
DROP TABLE IF EXISTS seq;
CREATE TABLE seq (n INT PRIMARY KEY);
INSERT INTO seq
WITH RECURSIVE s AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM s WHERE n < 500000)
SELECT n FROM s;

INSERT INTO branch (branch_name, city) VALUES
 ('Lagos Main','Lagos'),('Abuja Central','Abuja'),('Port Harcourt','Port Harcourt'),
 ('Ibadan','Ibadan'),('Benin City','Benin City');

INSERT INTO account_type (type_name, min_balance, interest_rate) VALUES
 ('Savings',0,3.50),('Current',0,0.00),('Fixed Deposit',50000,8.00);

INSERT INTO staff (branch_id, full_name, role, email)
SELECT 1 + (n % 5), CONCAT('Staff Member ', n),
       ELT(1 + (n % 3), 'Teller', 'Manager', 'Auditor'),
       CONCAT('staff', n, '@eborkatrust.example')
FROM seq WHERE n <= 30;

INSERT INTO customer (full_name, email, phone, date_of_birth)
SELECT CONCAT('Customer ', n), CONCAT('customer', n, '@example.com'),
       CONCAT('080', LPAD(n, 8, '0')),
       DATE_ADD('1960-01-01', INTERVAL (n % 15000) DAY)
FROM seq WHERE n <= 5000;

INSERT INTO account (account_number, customer_id, type_id, branch_id, balance)
SELECT LPAD(n, 10, '0'), n, 1 + (n % 3), 1 + (n % 5), 100000
FROM seq WHERE n <= 5000;

-- Synthetic history (does not need to reconcile with account.balance; state this in your report)
INSERT INTO bank_transaction (account_id, txn_type, amount, balance_after, created_at)
SELECT 1 + FLOOR(RAND() * 5000),
       IF(RAND() < 0.5, 'DEPOSIT', 'WITHDRAWAL'),
       ROUND(100 + RAND() * 50000, 2),
       ROUND(RAND() * 500000, 2),
       DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365 * 24 * 3600) SECOND)
FROM seq;

DROP TABLE seq;
ANALYZE TABLE bank_transaction;
SELECT COUNT(*) AS transactions FROM bank_transaction;
