# Portfolio 4 — Practical execution and evidence checklist

**Course:** MIT 8103 Advanced Database Systems  
**Case study:** Eborka Trust Bank (simulated)  
**Objective:** demonstrate a MongoDB document model for digital banking activity/audit events, linked conceptually to the MySQL core bank schema.

## 1. Data model and design

- **MySQL remains authoritative** for `customer`, `account`, `transfer`, `bank_transaction`, and balances.
- **MongoDB collection:** `eborka_trust_bank.activity_events`. Each document records a *simulated* banking activity event.
- **Common fields:** `customer_id`, `account_number` (string, preserving leading zeros), `event`, and `ts`.
- **Optional/different fields:** `device` document for LOGIN/FAILED_LOGIN, `atm` document for an ATM withdrawal, `changes` array for profile updates, `amount` and `to_account` for transfers, `branch_id` for deposits.
- **Indexes:** `(customer_id, ts descending)` for customer timelines, and `event` for type-based filtering. With only 10 documents, performance advantages are not proven; the indexes mainly demonstrate data-access design.
- **Scope:** these events are illustrative, not a live integration with MySQL; MongoDB does not automatically enforce the MySQL account foreign keys.

## 2. Software needed

You need access to MongoDB through **either**:

1. Locally installed MongoDB Community Server **and** `mongosh`; or
2. A MongoDB Atlas cluster **and** `mongosh` connected to it.

MongoDB Compass may be used to inspect the collection, but this project script is designed for the **MongoDB Shell (`mongosh`)**. Do not paste or share Atlas passwords, access tokens, or connection strings containing credentials.

## 3. Running the script

1. Put `Eborka_Marvellous_301922558_mongodb_audit_events.js` in your `Eborka_Marvellous_301922558_Portfolio4_NoSQL` repository folder.
2. Connect to a **test** MongoDB deployment with `mongosh`.
3. Inside `mongosh`, load the saved script using its absolute path, for example on Windows:

```javascript
load("C:/Users/YOUR_USER/Documents/advanced-database-portfolio/Eborka_Marvellous_301922558_Portfolio4_NoSQL/Eborka_Marvellous_301922558_mongodb_audit_events.js")
```

Alternatively, open a terminal in the script's directory and execute:

```powershell
mongosh --file Eborka_Marvellous_301922558_mongodb_audit_events.js
```

If your deployment is hosted on Atlas, first connect `mongosh` with your Atlas connection details, **then** call `load()`.

**Caution:** each execution resets only the **demo** collection `eborka_trust_bank.activity_events`. Do not run it if you already have important data in that MongoDB collection. It does not modify MySQL `eborka_bank`.

## 4. Expected output (must be verified in your own run)

| Script section | What to look for | Suggested screenshot |
|---|---|---|
| TEST 01 | Database name; collection `activity_events`; 10 inserted documents | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_31_mongodb_collection.png` |
| TEST 02 | Different shapes of `LOGIN` (device) and `WITHDRAWAL` (ATM) documents | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_32_mongodb_document_models.png` |
| TEST 03 | `_id_`, `idx_customer_time`, and `idx_event_type` in `getIndexes()` | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_33_mongodb_indexes.png` |
| TEST 04 | Four events for customer 1, newest first | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_34_mongodb_customer_activity.png` |
| TEST 05 | Two `FAILED_LOGIN` entries with at least three attempts | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_35_mongodb_failed_logins.png` |
| TEST 06 | Aggregation counts grouped by event type and illustrative event amounts | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_36_mongodb_aggregation.png` |
| TEST 07 | Expected and actual counts align; `VALIDATION PASSED` | `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_37_mongodb_validation.png` |

The expected results have now been checked against actual `mongosh` screenshots `31`–`37`, supplied with this submission. The screenshots are direct implementation evidence; the script is reproducible independently.

### Optional manual verification commands

Use the same connected shell; the following commands do not modify records:

```javascript
const p4db = db.getSiblingDB("eborka_trust_bank");
p4db.activity_events.countDocuments({});
p4db.activity_events.find({ customer_id: 1 }, { _id: 0 }).sort({ ts: -1 });
p4db.activity_events.getIndexes();
```

## 5. Evidence and GitHub README workflow

- Keep `Eborka_Marvellous_301922558_mongodb_audit_events.js` in `Eborka_Marvellous_301922558_Portfolio4_NoSQL`.
- Save the real screenshots under the **suggested exact filenames** (or tell ChatGPT the filenames you used).
- Share the screenshots and any error messages here.
- The completed `Eborka_Marvellous_301922558_README.md` includes the verified results and embeds all seven evidence screenshots, following the documentation style of Portfolios 1–3.
- Record your actual software version and any issues you solved for your own technical reflection.
- Add an accurate AI-use declaration to the final README, as the assignment requires.

**Learning goal:** be able to explain *why the flexible MongoDB event structure is useful alongside MySQL*, what the queries return, how indexing supports customer timelines, and why event logs must not replace the transactional account ledger.
