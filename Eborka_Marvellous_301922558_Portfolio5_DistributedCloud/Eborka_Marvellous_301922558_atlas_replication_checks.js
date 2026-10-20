// MIT 8103 — Portfolio 5 | Eborka Trust Bank (fictional test data)
// Run in an authenticated Atlas mongosh session using: load("C:/path/to/Eborka_Marvellous_301922558_atlas_replication_checks.js")
// This is a companion reproducibility script derived from tests done interactively.
// It does not drop collections or touch Portfolio 4's activity_events collection.
// Re-running updates the synthetic test document's tested_at timestamp.

(() => {
const p5Bank = db.getSiblingDB("eborka_trust_bank");
const p5Tests = p5Bank.getCollection("cloud_replication_tests");

print("=== TEST 41: Replica-set topology ===");
const p5Topology = p5Bank.runCommand({ hello: 1 });
printjson({
  ok: p5Topology.ok,
  setName: p5Topology.setName,
  hosts: p5Topology.hosts,
  primary: p5Topology.primary,
  isWritablePrimary: p5Topology.isWritablePrimary,
  secondary: p5Topology.secondary
});

print("=== TEST 42: Majority-acknowledged synthetic write ===");
const p5Write = p5Tests.updateOne(
  { test_id: "P5-CLOUD-001" },
  { $set: {
    bank: "Eborka Trust Bank",
    test_type: "Majority Write Concern",
    status: "SUCCESS",
    tested_at: new Date()
  } },
  { upsert: true, writeConcern: { w: "majority", wtimeout: 10000 } }
);
printjson(p5Write);

print("=== TEST 43: Majority-committed read ===");
const p5Read = p5Bank.runCommand({
  find: "cloud_replication_tests",
  filter: { test_id: "P5-CLOUD-001" },
  readConcern: { level: "majority" },
  limit: 1
});
printjson(p5Read);

print("=== TEST 45: Verify record and collections ===");
printjson({
  database: p5Bank.getName(),
  collections: p5Bank.getCollectionNames().filter(x => ["activity_events", "cloud_replication_tests"].includes(x)),
  testRecord: p5Tests.findOne({ test_id: "P5-CLOUD-001" })
});

const p5Succeeded = p5Topology.ok === 1 && p5Write.acknowledged === true &&
  p5Read.ok === 1 && p5Read.cursor && p5Read.cursor.firstBatch &&
  p5Read.cursor.firstBatch.some(x => x.test_id === "P5-CLOUD-001");
print(p5Succeeded ? "P5 COMPANION CHECK PASSED" : "P5 COMPANION CHECK NEEDS REVIEW");
})();
