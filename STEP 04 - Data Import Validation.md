<img width="2169" height="725" alt="Logótipo NovaCommerce com Saco Orbitante" src="https://github.com/user-attachments/assets/cec5fbdf-826b-44e5-b07d-57cc16dbc2f9" />







 
 Step 04 — Data Import Validation

 Objective
Verify that all eight tables were imported correctly and that their record counts match the original dataset.

 Validation Method
Used SQL `COUNT(*)` combined with `UNION ALL` to retrieve the total number of records from each table.

 SQL Query

```sql
SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'shipping', COUNT(*) FROM shipping;
```


## Key Findings
- All eight tables were successfully imported.
- Every table matches its expected record count.
- No record count discrepancies were identified.
- The database is ready for the next data quality checks.
