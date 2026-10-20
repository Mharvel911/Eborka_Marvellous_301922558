-- MIT 8103 | Marvellous Ewere Eborka | 301922558
-- Portfolio 3: commit, rollback, safe transfers (MySQL 8.0.16 or newer)
-- Note: MySQL autocommit is ON by default. START TRANSACTION switches it off until COMMIT or ROLLBACK.

DROP PROCEDURE IF EXISTS transfer_funds;
DELIMITER $$
CREATE PROCEDURE transfer_funds(
    IN  p_from INT,
    IN  p_to INT,
    IN  p_amount DECIMAL(14,2),
    OUT p_transfer_id BIGINT)
BEGIN
    DECLARE v_from_bal DECIMAL(14,2);
    DECLARE v_to_bal   DECIMAL(14,2);

    -- Any error: undo everything, then pass the error to the caller
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_from = p_to THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot transfer to the same account';
    END IF;

    START TRANSACTION;

    -- Lock both account rows, always the lower account_id first, to avoid deadlocks
    IF p_from < p_to THEN
        SELECT balance INTO v_from_bal FROM account WHERE account_id = p_from FOR UPDATE;
        SELECT balance INTO v_to_bal   FROM account WHERE account_id = p_to   FOR UPDATE;
    ELSE
        SELECT balance INTO v_to_bal   FROM account WHERE account_id = p_to   FOR UPDATE;
        SELECT balance INTO v_from_bal FROM account WHERE account_id = p_from FOR UPDATE;
    END IF;

    IF v_from_bal IS NULL OR v_to_bal IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;
    IF v_from_bal < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    UPDATE account SET balance = balance - p_amount WHERE account_id = p_from;
    UPDATE account SET balance = balance + p_amount WHERE account_id = p_to;

    INSERT INTO transfer (from_account_id, to_account_id, amount, status)
    VALUES (p_from, p_to, p_amount, 'COMPLETED');
    SET p_transfer_id = LAST_INSERT_ID();

    INSERT INTO bank_transaction (account_id, transfer_id, txn_type, amount, balance_after)
    VALUES (p_from, p_transfer_id, 'TRANSFER_OUT', p_amount, v_from_bal - p_amount),
           (p_to,   p_transfer_id, 'TRANSFER_IN',  p_amount, v_to_bal + p_amount);

    COMMIT;
END$$
DELIMITER ;

-- 1) SUCCESSFUL TRANSFER (the procedure COMMITs)
SELECT account_id, balance FROM account WHERE account_id IN (1,2);   -- before
CALL transfer_funds(1, 2, 5000, @tid);
SELECT @tid AS transfer_id;
SELECT account_id, balance FROM account WHERE account_id IN (1,2);   -- after: -5000 / +5000

-- 2) FAILED TRANSFER (insufficient funds -> error -> automatic ROLLBACK)
CALL transfer_funds(1, 2, 99999999, @tid);                           -- expect: Insufficient funds
SELECT account_id, balance FROM account WHERE account_id IN (1,2);   -- unchanged

-- 3) MANUAL COMMIT
START TRANSACTION;
UPDATE account SET balance = balance - 1000 WHERE account_id = 1;
UPDATE account SET balance = balance + 1000 WHERE account_id = 2;
COMMIT;

-- 4) MANUAL ROLLBACK
START TRANSACTION;
UPDATE account SET balance = balance + 1000 WHERE account_id = 1;
SELECT balance FROM account WHERE account_id = 1;   -- shows +1000 inside the transaction
ROLLBACK;
SELECT balance FROM account WHERE account_id = 1;   -- back to the original value

-- 5) CONSTRAINT ERROR INSIDE A TRANSACTION
-- In MySQL only the failed statement is undone; the transaction stays open, so you must ROLLBACK yourself.
START TRANSACTION;
UPDATE account SET balance = balance - 99999999 WHERE account_id = 1;   -- expect: CHECK constraint violated
ROLLBACK;
SELECT balance FROM account WHERE account_id = 1;
