-- Crest Tech (simulated fintech): payment collection platform
-- Portfolio 1: relational schema (SQLite dialect)
PRAGMA foreign_keys = ON;

CREATE TABLE banks (
    bank_id    INTEGER PRIMARY KEY,
    bank_name  TEXT NOT NULL UNIQUE,
    bank_code  TEXT NOT NULL UNIQUE,
    is_active  INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1))
);

CREATE TABLE payment_channels (
    channel_id    INTEGER PRIMARY KEY,
    channel_name  TEXT NOT NULL UNIQUE CHECK (channel_name IN ('CARD','BANK_TRANSFER','USSD'))
);

CREATE TABLE businesses (
    business_id          INTEGER PRIMARY KEY,
    business_name        TEXT NOT NULL,
    email                TEXT NOT NULL UNIQUE,
    settlement_bank_id   INTEGER NOT NULL REFERENCES banks(bank_id),
    settlement_account   TEXT NOT NULL,
    status               TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','SUSPENDED')),
    created_at           TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE payers (
    payer_id   INTEGER PRIMARY KEY,
    full_name  TEXT NOT NULL,
    email      TEXT NOT NULL,
    phone      TEXT
);

CREATE TABLE invoices (
    invoice_id    INTEGER PRIMARY KEY,
    business_id   INTEGER NOT NULL REFERENCES businesses(business_id),
    payer_id      INTEGER NOT NULL REFERENCES payers(payer_id),
    invoice_ref   TEXT NOT NULL UNIQUE,
    amount_kobo   INTEGER NOT NULL CHECK (amount_kobo > 0),   -- money in kobo: no decimal rounding errors
    due_date      TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'UNPAID' CHECK (status IN ('UNPAID','PAID','OVERDUE','CANCELLED')),
    created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE settlements (
    settlement_id    INTEGER PRIMARY KEY,
    business_id      INTEGER NOT NULL REFERENCES businesses(business_id),
    settlement_date  TEXT NOT NULL,
    total_kobo       INTEGER NOT NULL CHECK (total_kobo >= 0),
    status           TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','PAID')),
    UNIQUE (business_id, settlement_date)                      -- one payout per business per day
);

CREATE TABLE payments (
    payment_id     INTEGER PRIMARY KEY,
    invoice_id     INTEGER NOT NULL REFERENCES invoices(invoice_id),
    channel_id     INTEGER NOT NULL REFERENCES payment_channels(channel_id),
    bank_id        INTEGER NOT NULL REFERENCES banks(bank_id),
    payment_ref    TEXT NOT NULL UNIQUE,                       -- bank's reference: blocks double-processing
    amount_kobo    INTEGER NOT NULL CHECK (amount_kobo > 0),
    fee_kobo       INTEGER NOT NULL DEFAULT 0 CHECK (fee_kobo >= 0),
    status         TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','SUCCESS','FAILED','REVERSED')),
    settlement_id  INTEGER REFERENCES settlements(settlement_id),  -- NULL until paid out
    created_at     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE audit_log (
    log_id      INTEGER PRIMARY KEY,
    payment_id  INTEGER NOT NULL,
    old_status  TEXT NOT NULL,
    new_status  TEXT NOT NULL,
    changed_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Every payment status change is recorded automatically (regulatory traceability)
CREATE TRIGGER trg_audit_payment_status
AFTER UPDATE OF status ON payments
WHEN OLD.status <> NEW.status
BEGIN
    INSERT INTO audit_log(payment_id, old_status, new_status)
    VALUES (OLD.payment_id, OLD.status, NEW.status);
END;
