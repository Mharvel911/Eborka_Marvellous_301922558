# Portfolio 5 — Implementation & Evidence Guide

**Project:** Eborka Trust Bank | **Database:** `eborka_trust_bank` | **Platform:** MongoDB Atlas Free (AWS)

This guide records how the **five screenshots (41–45)** were produced in the practical sessions. The test data are fictional.

## Connect safely

1. Open Atlas, confirm the `EborkaTrustBank` cluster and its authorised network address.
2. Connect with `mongosh` using the Atlas-provided connection string and your database username. Use a **password prompt**, not a literal password in terminal history.
3. In the connected shell select `use eborka_trust_bank`.
4. Do not publish passwords, database-user credentials or sensitive connection strings in the repository.

## Screenshot 41 — replica topology

```javascript
db.hello()
```

Save `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_41_mongodb_replica_topology.png`. Check `setName`, `hosts` (three members), `primary`, and `isWritablePrimary`. This is **not** a failover test.

## Screenshot 42 — majority write and retrieval

```javascript
db.cloud_replication_tests.updateOne(
  { test_id: "P5-CLOUD-001" },
  { $set: {
    bank: "Eborka Trust Bank",
    test_type: "Majority Write Concern",
    status: "SUCCESS",
    tested_at: new Date()
  } },
  { upsert: true, writeConcern: { w: "majority", wtimeout: 10000 } }
)

db.cloud_replication_tests.findOne({ test_id: "P5-CLOUD-001" })
```

Save `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_42_mongodb_majority_write.png`. The recorded first execution returned `acknowledged: true` and `upsertedCount: 1`. **A later re-run may return a matched document rather than an upsert.**

## Screenshot 43 — majority read

```javascript
db.runCommand({
  find: "cloud_replication_tests",
  filter: { test_id: "P5-CLOUD-001" },
  readConcern: { level: "majority" },
  limit: 1
})
```

Save `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_43_mongodb_majority_read.png`. The recorded result included the test document and `ok: 1`. This **does not demonstrate reading from a secondary**.

## Screenshot 44 — cloud deployment

Open **MongoDB Atlas → Clusters → EborkaTrustBank**. Capture tier, provider/region, MongoDB version, type **Replica Set — 3 nodes**, and backup status. Save `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_44_atlas_cloud_deployment.png`.

## Screenshot 45 — Atlas Data Explorer

Open **Atlas → Data Explorer → EborkaTrustBank → eborka_trust_bank → cloud_replication_tests**. Confirm `activity_events` and `cloud_replication_tests` are listed and one `P5-CLOUD-001` document appears. Save `Eborka_Marvellous_301922558_screenshot/Eborka_Marvellous_301922558_45_atlas_cloud_collections.png`.

## Optional companion script

The accompanying `Eborka_Marvellous_301922558_atlas_replication_checks.js` re-runs a subset of the manual checks. It was created after the manual screenshot sessions; no screenshot is being represented as proof that this combined file was executed.

```javascript
load("C:/path/to/Eborka_Marvellous_301922558_Portfolio5_DistributedCloud/Eborka_Marvellous_301922558_atlas_replication_checks.js")
```

The companion script updates the timestamp on the **synthetic test record** on each run. It does not drop collections or delete Portfolio 4 documents.

## Important implementation boundaries

- Atlas **Free** has a fixed three-node replica-set configuration; no sharded-cluster deployment is supported.
- No intentional primary failover, node outage, replica-lag measurement or backup restore test was performed.
- Separate backups were **inactive** in the observed Atlas dashboard.
- The existing repository's Docker/MySQL replication starter was not used for these screenshots.
- For further analysis see `Eborka_Marvellous_301922558_README.md` and `Eborka_Marvellous_301922558_sharding_design.md`.
