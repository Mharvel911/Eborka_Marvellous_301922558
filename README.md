# MIT 8103 — Advanced Database Systems Practical Portfolio

**Student:** Eborka Marvellous  
**Student ID:** 301922558  
**Student email:** m.eborka2558@miva.edu.ng  
**Repository:** https://github.com/eborkamarvelous-jpg/advanced-database-portfolio

**Academic session:** 2026/2027 (First Semester)  
**Assessment:** Individual Practical Database Portfolio, Miva Open University  
**Case study:** Eborka Trust Bank — a fictional retail banking system  
**Tools:** MySQL 8.0 / MySQL Workbench; MongoDB Atlas / MongoDB Shell (mongosh)

## Project overview

Eborka Trust Bank is a simulated retail bank supporting customers, accounts, branches, staff, payments, transfers and audit activities. The MySQL prototype covers structured operational banking data, transaction handling and query optimisation. A separate MongoDB Atlas prototype models flexible activity/audit documents and illustrates managed cloud database capabilities. **These two prototypes are not synchronised, and no production bank data is used.**

## Portfolio navigation

| Component | Contents | Supporting evidence |
|---|---|---|
| [Portfolio 1 — Database Design](Eborka_Marvellous_301922558_Portfolio1_DatabaseDesign/Eborka_Marvellous_301922558_README.md) | Eight-table relational schema, ER diagram, keys, constraints and 3NF discussion | `Eborka_Marvellous_301922558_schema.sql`, `.mwb` model, screenshots `01`–`04` |
| [Portfolio 2 — Query Optimisation](Eborka_Marvellous_301922558_Portfolio2_QueryOptimisation/Eborka_Marvellous_301922558_README.md) | SQL reporting, execution plans, single-column and composite indexing | `Eborka_Marvellous_301922558_queries.sql`, `Eborka_Marvellous_301922558_seed_data.sql`, screenshots `05`–`13` |
| [Portfolio 3 — Transactions and Concurrency](Eborka_Marvellous_301922558_Portfolio3_TransactionsConcurrency/Eborka_Marvellous_301922558_README.md) | Stored procedure, commit/rollback, lost update, locking, isolation | `Eborka_Marvellous_301922558_transactions.sql`, `Eborka_Marvellous_301922558_concurrency_demo.sql`, screenshots `14`–`30` |
| [Portfolio 4 — NoSQL](Eborka_Marvellous_301922558_Portfolio4_NoSQL/Eborka_Marvellous_301922558_README.md) | MongoDB activity documents, indexes, conditional queries, aggregation and validation | `Eborka_Marvellous_301922558_mongodb_audit_events.js`, screenshots `31`–`37` |
| [Portfolio 5 — Distributed and Cloud](Eborka_Marvellous_301922558_Portfolio5_DistributedCloud/Eborka_Marvellous_301922558_README.md) | MongoDB Atlas deployment, replica-set observation, majority write/read concern, conceptual sharding | `Eborka_Marvellous_301922558_atlas_replication_checks.js`, screenshots `41`–`45` |

## Important implementation and evidence notes

- **Portfolio 2:** Measured execution times are snapshots from the observed MySQL runs, not performance guarantees.
- **Portfolio 3:** Session B's first `SELECT ... FOR UPDATE` attempt waited and timed out; a **later retry** succeeded. The original timed-out query did not resume automatically.
- **Portfolio 4:** The 10 banking activity documents are simulated and not live bank transactions.
- **Portfolio 5:** The Atlas Free cluster uses a **three-node replica set, not three shards**. The hashed-sharding architecture is a **proposal, not a deployed feature**; backups were inactive. The unused Docker/MySQL replication starter exercise has been excluded from this submission copy; the demonstrated exercise uses MongoDB Atlas.

## How to review

Open each linked portfolio README. All referenced SQL/JavaScript scripts and diagrams are stored in their corresponding portfolio folders. Screenshots are grouped in each portfolio’s `Eborka_Marvellous_301922558_screenshot` subfolder. The evidence screenshots were captured in MySQL Workbench, MongoDB Shell or MongoDB Atlas, as applicable. Do not run reset/reseed scripts against databases containing important records.

## Academic integrity and AI declaration

Claude and OpenAI ChatGPT assisted with database concepts, examples of SQL/JavaScript code, troubleshooting, explanations and drafting documentation, as disclosed in the individual portfolio READMEs and the LMS summary. Reported measurements and outputs are tied to saved screenshots rather than claimed AI executions. This is an educational prototype, not a production banking service.

## Assessment submission

The separate **2–3 page LMS portfolio summary** references this GitHub repository and its evidence. This repository should remain private but must be accessible to the assessor before submission. Progressive commit history and access permissions must be confirmed in GitHub directly; they cannot be established from a downloaded ZIP archive.


