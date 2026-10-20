// MIT 8103 - Advanced Database Systems
// Portfolio 4 - Eborka Trust Bank (simulated retail bank)
// MongoDB document model for digital banking activity/audit events.
//
// Run from a connected MongoDB Shell (mongosh):
//   load("C:/path/to/Eborka_Marvellous_301922558_mongodb_audit_events.js")
// Or from a terminal already connected/configured for MongoDB:
//   mongosh --file Eborka_Marvellous_301922558_mongodb_audit_events.js
//
// IMPORTANT: This is a DEMONSTRATION script. Every run resets ONLY the
// activity_events collection in the MongoDB database eborka_trust_bank.
// Do not run against a production collection with valuable information.

(function () {
  const bankDb = db.getSiblingDB("eborka_trust_bank");
  const events = bankDb.getCollection("activity_events");

  print("=== TEST 01: reset demo collection and insert sample documents ===");
  events.drop();

  events.insertMany([
    {
      customer_id: 1,
      account_number: "0000000001",
      event: "LOGIN",
      device: { type: "mobile", os: "Android", ip: "192.0.2.10" },
      channel: "mobile_app",
      ts: new Date("2026-10-01T08:15:00Z")
    },
    {
      customer_id: 1,
      account_number: "0000000001",
      event: "TRANSFER",
      amount: 5000,
      to_account: "0000000002",
      channel: "mobile_app",
      ts: new Date("2026-10-01T08:20:00Z")
    },
    {
      customer_id: 2,
      account_number: "0000000002",
      event: "FAILED_LOGIN",
      device: { type: "web", browser: "Chrome", ip: "198.51.100.20" },
      attempts: 3,
      ts: new Date("2026-10-02T09:00:00Z")
    },
    {
      customer_id: 3,
      account_number: "0000000003",
      event: "WITHDRAWAL",
      amount: 20000,
      channel: "ATM",
      atm: { id: "ATM-LAG-014", city: "Lagos" },
      ts: new Date("2026-10-03T12:30:00Z")
    },
    {
      customer_id: 1,
      account_number: "0000000001",
      event: "PROFILE_UPDATE",
      changes: ["phone", "notification_preference"],
      channel: "mobile_app",
      ts: new Date("2026-10-04T11:05:00Z")
    },
    {
      customer_id: 2,
      account_number: "0000000002",
      event: "LOGIN",
      device: { type: "web", browser: "Firefox", ip: "198.51.100.21" },
      channel: "web",
      ts: new Date("2026-10-04T12:00:00Z")
    },
    {
      customer_id: 2,
      account_number: "0000000002",
      event: "TRANSFER",
      amount: 3500,
      to_account: "0000000004",
      channel: "web",
      ts: new Date("2026-10-04T12:04:00Z")
    },
    {
      customer_id: 3,
      account_number: "0000000003",
      event: "FAILED_LOGIN",
      device: { type: "mobile", os: "iOS", ip: "203.0.113.15" },
      attempts: 5,
      ts: new Date("2026-10-05T07:30:00Z")
    },
    {
      customer_id: 1,
      account_number: "0000000001",
      event: "LOGOUT",
      channel: "mobile_app",
      ts: new Date("2026-10-05T10:00:00Z")
    },
    {
      customer_id: 4,
      account_number: "0000000004",
      event: "DEPOSIT",
      amount: 12000,
      channel: "branch",
      branch_id: 1,
      ts: new Date("2026-10-06T14:10:00Z")
    }
  ]);

  print("Database: " + bankDb.getName());
  print("Collection: " + events.getName());
  print("Document count: " + events.countDocuments({}));

  print("=== TEST 02: inspect two different document structures ===");
  print("LOGIN event (contains an embedded device document):");
  printjson(events.findOne({ event: "LOGIN" }, { _id: 0 }));
  print("WITHDRAWAL event (contains an embedded ATM document):");
  printjson(events.findOne({ event: "WITHDRAWAL" }, { _id: 0 }));

  print("=== TEST 03: create and verify indexes ===");
  events.createIndex({ customer_id: 1, ts: -1 }, { name: "idx_customer_time" });
  events.createIndex({ event: 1 }, { name: "idx_event_type" });
  printjson(events.getIndexes());

  print("=== TEST 04: customer 1 activity, newest first ===");
  printjson(
    events.find({ customer_id: 1 }, { _id: 0 })
      .sort({ ts: -1 }).toArray()
  );

  print("=== TEST 05: potential security incidents (3+ failed attempts) ===");
  printjson(
    events.find(
      { event: "FAILED_LOGIN", attempts: { $gte: 3 } },
      { _id: 0 }
    ).sort({ ts: -1 }).toArray()
  );

  print("=== TEST 06: aggregation by event type ===");
  printjson(
    events.aggregate([
      { $group: {
        _id: "$event",
        count: { $sum: 1 },
        total_amount: { $sum: { $ifNull: ["$amount", 0] } }
      } },
      { $sort: { count: -1, _id: 1 } }
    ]).toArray()
  );

  print("=== TEST 07: verify count and check sample results ===");
  const allCount = events.countDocuments({});
  const customerOneCount = events.countDocuments({ customer_id: 1 });
  const suspiciousCount = events.countDocuments({
    event: "FAILED_LOGIN", attempts: { $gte: 3 }
  });
  printjson({
    expected_total: 10,
    actual_total: allCount,
    expected_customer_1_events: 4,
    actual_customer_1_events: customerOneCount,
    expected_flagged_failed_logins: 2,
    actual_flagged_failed_logins: suspiciousCount
  });

  if (allCount !== 10 || customerOneCount !== 4 || suspiciousCount !== 2) {
    throw new Error("Validation counts did not match the expected demo results.");
  }
  print("VALIDATION PASSED (sample counts match expectations)");
})();
