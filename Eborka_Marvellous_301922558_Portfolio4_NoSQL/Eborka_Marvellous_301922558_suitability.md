# Portfolio 4 — Why use MongoDB for activity events?

**Case study:** Eborka Trust Bank (simulated retail bank)

## Intended model

The relational MySQL database in Portfolios 1–3 stores account, customer, transfer and bank transaction records. Portfolio 4 explores a different, complementary workload: **digital-banking activity and audit event records**, represented as documents in MongoDB.

## Reason for document modelling

Different events contain different information. A `LOGIN` event can embed a `device` object, a `WITHDRAWAL` event can embed an `atm` object, a `TRANSFER` event can carry an `amount` and `to_account`, and a `PROFILE_UPDATE` event can contain a `changes` array. A document database can store these varied event shapes in one collection without requiring all events to have the same optional fields or creating many separate related tables.

The shared fields `customer_id`, `account_number`, `event` and `ts` allow the bank's staff to retrieve activity by customer and chronological order. The `(customer_id, ts)` compound index supports that access pattern, while the separate `event` index supports filtering by event type. For this tiny demonstration dataset, faster performance has **not** been measured or claimed.

An aggregation pipeline can group events by type, count them, and total any `amount` fields present. A query can also flag `FAILED_LOGIN` records with three or more attempts for potential investigation. These are **illustrative security and reporting queries**, not an operational fraud detection system.

## Why MySQL still matters

MongoDB activity events in this practical are **not the authoritative bank ledger**. They are synthetic examples and are not automatically written by, or reconciled with, Portfolio 3's transaction procedure. The existing MySQL schema is still responsible for funds transfers, account balances, relational constraints, and the atomic debit/credit workflow. The MongoDB collection also does not independently validate its customer/account references against MySQL.

## Limitation and next steps

The practical uses only 10 synthetic activity records, so it demonstrates flexible document structure, queries, aggregation and indexing, not large-scale NoSQL performance or a live dual-database architecture. The sample was executed in MongoDB Atlas through `mongosh` and the accompanying screenshots verify 10 total events, four events for Customer 1, two failed-login records meeting the rule, and the seven-category aggregation. This does not establish production performance or a live banking integration.
