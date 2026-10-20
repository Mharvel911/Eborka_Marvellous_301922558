-- MIT 8103 | Marvellous Ewere Eborka | 301922558
-- Portfolio 3: concurrency in MySQL. Open TWO mysql windows (Session A and Session B), both using eborka_bank.
-- Run the steps in the order shown. Screenshot both windows at each key step.
-- MySQL's default isolation level is REPEATABLE READ.

-- ============ DEMO 1: LOST UPDATE (the problem) ============
-- Reset:   UPDATE account SET balance = 100000 WHERE account_id = 3;

-- A: START TRANSACTION;
-- A: SELECT balance FROM account WHERE account_id = 3;          -- reads 100000
-- B: START TRANSACTION;
-- B: SELECT balance FROM account WHERE account_id = 3;          -- also reads 100000
-- A: UPDATE account SET balance = 100000 - 30000 WHERE account_id = 3;   -- app-calculated value
-- A: COMMIT;
-- B: UPDATE account SET balance = 100000 - 30000 WHERE account_id = 3;
-- B: COMMIT;
-- Check:   SELECT balance FROM account WHERE account_id = 3;    -- 70000, but should be 40000 (A's withdrawal was lost)

-- ============ DEMO 2: FIX WITH SELECT ... FOR UPDATE ============
-- Reset:   UPDATE account SET balance = 100000 WHERE account_id = 3;

-- A: START TRANSACTION;
-- A: SELECT balance FROM account WHERE account_id = 3 FOR UPDATE;   -- locks the row
-- B: START TRANSACTION;
-- B: SELECT balance FROM account WHERE account_id = 3 FOR UPDATE;   -- BLOCKS, waiting for A
-- A: UPDATE account SET balance = balance - 30000 WHERE account_id = 3;
-- A: COMMIT;                                                         -- B now unblocks and reads 70000
-- B: UPDATE account SET balance = balance - 30000 WHERE account_id = 3;
-- B: COMMIT;
-- Check:   SELECT balance FROM account WHERE account_id = 3;    -- 40000 (correct)

-- ============ DEMO 3: DEADLOCK ============
-- A: START TRANSACTION;
-- A: UPDATE account SET balance = balance - 100 WHERE account_id = 4;
-- B: START TRANSACTION;
-- B: UPDATE account SET balance = balance - 100 WHERE account_id = 5;
-- A: UPDATE account SET balance = balance + 100 WHERE account_id = 5;   -- waits for B
-- B: UPDATE account SET balance = balance + 100 WHERE account_id = 4;   -- ERROR 1213 Deadlock found; MySQL rolls one session back
-- Then: ROLLBACK; in any session that is still open.
-- Screenshot, then run:  SHOW ENGINE INNODB STATUS\G   (see the section LATEST DETECTED DEADLOCK)
-- Prevention: always lock accounts in the same order (as transfer_funds does).

-- ============ DEMO 4: ISOLATION LEVELS ============
-- Part 1: READ COMMITTED allows a non-repeatable read
-- A: SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- A: START TRANSACTION;
-- A: SELECT balance FROM account WHERE account_id = 6;
-- B: UPDATE account SET balance = balance + 500 WHERE account_id = 6;   (autocommits)
-- A: SELECT balance FROM account WHERE account_id = 6;       -- value CHANGED inside one transaction
-- A: COMMIT;

-- Part 2: REPEATABLE READ (the MySQL default) prevents it
-- A: SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- A: START TRANSACTION;
-- A: SELECT balance FROM account WHERE account_id = 6;
-- B: UPDATE account SET balance = balance + 500 WHERE account_id = 6;
-- A: SELECT balance FROM account WHERE account_id = 6;       -- SAME value as the first read
-- A: COMMIT;
-- A: SELECT balance FROM account WHERE account_id = 6;       -- now shows the new value
-- Check the level any time with:  SELECT @@transaction_isolation;
