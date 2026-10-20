# Normalisation Explanation
Student: Eborka Marvellous | ID: 301922558

## Unnormalised starting design (example)
One table: `bank_records(customer_name, customer_email, account_number, account_type, type_interest_rate, branch_name, branch_city, txn_date, txn_amount)`.

## 1NF
Every column holds one atomic value and each row is uniquely identifiable. Repeating transaction groups per customer are moved to their own rows/table.

## 2NF
No partial dependency on part of a composite key. Customer details depend only on the customer, not on each transaction, so `customer` is separated from `account` and `bank_transaction`.

## 3NF
No transitive dependency. `interest_rate` depends on the account type, not on the account, so it lives in `account_type`. `branch_city` depends on the branch, so it lives in `branch`.

## Result
The eight-table schema (`Eborka_Marvellous_301922558_schema.sql`) separates customer, branch, account-type and transaction information as part of its 3NF-oriented design. `balance` on `account` is a deliberate, controlled denormalisation for performance (it avoids summing the full transaction history). It is kept consistent by doing updates inside transactions (see Portfolio 3).

The explanation describes the intended dependencies in the sample schema. A complete formal proof would require listing the functional dependencies for every relation.
