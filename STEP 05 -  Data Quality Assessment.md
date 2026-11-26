<img width="2169" height="725" alt="Logótipo NovaCommerce com Saco Orbitante" src="https://github.com/user-attachments/assets/cec5fbdf-826b-44e5-b07d-57cc16dbc2f9" />






Step 05 — Data Quality Assessment

 ## Objective

Evaluate the quality and consistency of the NovaCommerce dataset before starting the analytical phase.

The assessment focused on missing values, duplicate primary identifiers, referential integrity, and basic data validation rules.

 1. Missing Values — Shipping

Shipping dates were compared against order statuses.

| Order Status | Total Orders | Shipped Orders | Delivered Orders |
|---|---:|---:|---:|
| Cancelled | 1,022 | 0 | 0 |
| Delivered | 16,814 | 16,814 | 16,814 |
| Processing | 780 | 0 | 0 |
| Shipped | 1,384 | 1,384 | 0 |

**Finding:** The missing shipping and delivery dates were consistent with the order statuses examined. No inconsistency was identified in this specific validation.

## 2. Duplicate Records

Primary identifiers were checked across all eight tables using `GROUP BY` and `HAVING COUNT(*) > 1`.

| Table | Identifier | Duplicate Records |
|---|---|---:|
| customers | customer_id | 0 |
| products | product_id | 0 |
| sellers | seller_id | 0 |
| orders | order_id | 0 |
| order_items | order_item_id | 0 |
| payments | payment_id | 0 |
| reviews | review_id | 0 |
| shipping | shipping_id | 0 |

**Finding:** No duplicate primary identifiers were detected.

## 3. Referential Integrity

Six relationships were validated using LEFT JOIN queries.

| Relationship | Orphan Records |
|---|---:|
| orders → customers | 0 |
| order_items → products | 0 |
| order_items → sellers | 0 |
| payments → orders | 0 |
| reviews → orders | 0 |
| shipping → orders | 0 |

**Finding:** No orphan records were found in the six relationships examined.

## 4. Data Validation

The following business and data constraints were checked:

| Validation | Invalid Records |
|---|---:|
| Product prices and costs <= 0 | 0 |
| Discount rates outside 0–1 | 0 |
| Order item quantities <= 0 | 0 |
| Review scores outside 1–5 or NULL | 0 |

**Finding:** No invalid records were detected in these specific checks.

## 5. Payment Anomalies

The `payments` table was investigated after detecting negative payment amounts.

| Metric | Result |
|---|---:|
| Total payment records | 22,063 |
| NULL payment amounts | 0 |
| Negative payment amounts | 4 |
| Zero payment amounts | 0 |
| Minimum payment amount | -4.07 |
| Maximum payment amount | 3,755.79 |
| Average payment amount | 280.38 |

The four negative transactions were investigated individually.

Three negative transactions had a `Paid` status and were associated with delivered orders. One negative transaction had a `Refunded` status and was associated with a cancelled order.

All four orders had two payment records. This suggests that the negative amounts may represent adjustments or partial refunds, but the available data does not establish their exact meaning.

**Finding:** Four negative payment records were identified as anomalies requiring further investigation. They were not modified or deleted.

## 6. Data Cleaning Decisions

No records were deleted or updated during this assessment.

The original dataset was preserved to avoid losing potentially meaningful financial information.

The four negative payment records should remain flagged for further investigation before any transformation or correction is applied.

## 7. Final Assessment

The NovaCommerce dataset passed the specific checks performed for primary identifier uniqueness, referential integrity, and the selected business validation rules.

Four negative payment amounts were identified as the main outstanding anomaly.

This assessment provides a documented quality baseline before proceeding to the next analytical stage.
