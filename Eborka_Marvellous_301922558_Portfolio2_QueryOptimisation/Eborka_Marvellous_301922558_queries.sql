-- MIT 8103 | Marvellous Ewere Eborka | 301922558
-- Portfolio 2: queries, execution plans, indexing (MySQL 8.0.18 or newer for EXPLAIN ANALYZE)

-- Q1: Account statement with running balance (window function)
SELECT txn_id, created_at, txn_type, amount,
       SUM(CASE WHEN txn_type IN ('DEPOSIT','TRANSFER_IN','REVERSAL') THEN amount ELSE -amount END)
         OVER (PARTITION BY account_id ORDER BY created_at, txn_id) AS running_total
FROM bank_transaction
WHERE account_id = 42
ORDER BY created_at, txn_id;

-- Q2: Monthly transaction totals per branch
SELECT b.branch_name, DATE_FORMAT(t.created_at, '%Y-%m') AS month_label,
       COUNT(*) AS txn_count, SUM(t.amount) AS total_amount
FROM bank_transaction t
JOIN account a ON a.account_id = t.account_id
JOIN branch  b ON b.branch_id  = a.branch_id
GROUP BY b.branch_name, month_label
ORDER BY month_label, b.branch_name;

-- Q3: Top 10 customers by transaction volume
SELECT c.customer_id, c.full_name, COUNT(*) AS txn_count, SUM(t.amount) AS total_amount
FROM bank_transaction t
JOIN account  a ON a.account_id  = t.account_id
JOIN customer c ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_amount DESC
LIMIT 10;

-- Existing indexes (note: MySQL automatically indexes foreign key columns such as account_id)
SHOW INDEX FROM bank_transaction;

-- ===== DEMO A: full table scan -> index on created_at =====
-- BEFORE: save this output (screenshot). Expect a full table scan.
EXPLAIN ANALYZE
SELECT COUNT(*), SUM(amount) FROM bank_transaction
WHERE created_at >= NOW() - INTERVAL 7 DAY;

CREATE INDEX idx_txn_created_at ON bank_transaction (created_at);
ANALYZE TABLE bank_transaction;

-- AFTER: run the same query again and compare the plan and times.
EXPLAIN ANALYZE
SELECT COUNT(*), SUM(amount) FROM bank_transaction
WHERE created_at >= NOW() - INTERVAL 7 DAY;

-- ===== DEMO B: composite index for the statement query =====
-- BEFORE: uses the automatic account_id foreign key index, then sorts the rows.
EXPLAIN ANALYZE
SELECT * FROM bank_transaction
WHERE account_id = 42 AND created_at >= NOW() - INTERVAL 90 DAY
ORDER BY created_at;

CREATE INDEX idx_txn_account_created ON bank_transaction (account_id, created_at);
ANALYZE TABLE bank_transaction;

-- AFTER: the composite index finds and orders the rows without a separate sort.
EXPLAIN ANALYZE
SELECT * FROM bank_transaction
WHERE account_id = 42 AND created_at >= NOW() - INTERVAL 90 DAY
ORDER BY created_at;
