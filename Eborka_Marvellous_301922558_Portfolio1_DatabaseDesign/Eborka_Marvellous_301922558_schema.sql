-- MIT 8103 | Marvellous Ewere Eborka | 301922558
-- Portfolio 1: Eborka Trust Bank schema (MySQL 8.0.42)
-- Run inside the database:  CREATE DATABASE eborka_bank; USE eborka_bank;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS audit_log, bank_transaction, transfer, account, account_type, customer, staff, branch;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE branch (
    branch_id   INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(60)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE staff (
    staff_id  INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role      VARCHAR(20)  NOT NULL,
    email     VARCHAR(120) NOT NULL UNIQUE,
    CONSTRAINT fk_staff_branch FOREIGN KEY (branch_id) REFERENCES branch(branch_id),
    CONSTRAINT chk_staff_role CHECK (role IN ('Teller','Manager','Auditor'))
) ENGINE=InnoDB;

CREATE TABLE customer (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    date_of_birth DATE NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_dob CHECK (date_of_birth > '1900-01-01')
) ENGINE=InnoDB;

CREATE TABLE account_type (
    type_id       INT AUTO_INCREMENT PRIMARY KEY,
    type_name     VARCHAR(30) NOT NULL UNIQUE,
    min_balance   DECIMAL(12,2) NOT NULL DEFAULT 0,
    interest_rate DECIMAL(5,2)  NOT NULL DEFAULT 0,
    CONSTRAINT chk_type_min CHECK (min_balance >= 0),
    CONSTRAINT chk_type_rate CHECK (interest_rate >= 0)
) ENGINE=InnoDB;

CREATE TABLE account (
    account_id     INT AUTO_INCREMENT PRIMARY KEY,
    account_number CHAR(10) NOT NULL UNIQUE,
    customer_id    INT NOT NULL,
    type_id        INT NOT NULL,
    branch_id      INT NOT NULL,
    balance        DECIMAL(14,2) NOT NULL DEFAULT 0,
    status         VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    opened_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_account_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_account_type     FOREIGN KEY (type_id)     REFERENCES account_type(type_id),
    CONSTRAINT fk_account_branch   FOREIGN KEY (branch_id)   REFERENCES branch(branch_id),
    CONSTRAINT chk_account_balance CHECK (balance >= 0),
    CONSTRAINT chk_account_status  CHECK (status IN ('ACTIVE','FROZEN','CLOSED'))
) ENGINE=InnoDB;

CREATE TABLE transfer (
    transfer_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_account_id INT NOT NULL,
    to_account_id   INT NOT NULL,
    amount          DECIMAL(14,2) NOT NULL,
    status          VARCHAR(10) NOT NULL DEFAULT 'PENDING',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transfer_from FOREIGN KEY (from_account_id) REFERENCES account(account_id),
    CONSTRAINT fk_transfer_to   FOREIGN KEY (to_account_id)   REFERENCES account(account_id),
    CONSTRAINT chk_transfer_amount CHECK (amount > 0),
    CONSTRAINT chk_transfer_status CHECK (status IN ('PENDING','COMPLETED','FAILED','REVERSED')),
    CONSTRAINT chk_transfer_diff   CHECK (from_account_id <> to_account_id)
) ENGINE=InnoDB;

CREATE TABLE bank_transaction (
    txn_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id    INT NOT NULL,
    transfer_id   BIGINT NULL,
    txn_type      VARCHAR(15) NOT NULL,
    amount        DECIMAL(14,2) NOT NULL,
    balance_after DECIMAL(14,2) NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_account  FOREIGN KEY (account_id)  REFERENCES account(account_id),
    CONSTRAINT fk_txn_transfer FOREIGN KEY (transfer_id) REFERENCES transfer(transfer_id),
    CONSTRAINT chk_txn_type CHECK (txn_type IN ('DEPOSIT','WITHDRAWAL','TRANSFER_OUT','TRANSFER_IN','REVERSAL')),
    CONSTRAINT chk_txn_amount CHECK (amount > 0),
    CONSTRAINT chk_txn_balance CHECK (balance_after >= 0)
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    audit_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    staff_id   INT NULL,
    action     VARCHAR(50) NOT NULL,
    details    TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;
