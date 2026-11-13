-- ================================================================
-- ENTERPRISE CONVERSATIONAL AI - 02_SAMPLE_DATA.SQL
-- ================================================================
-- Purpose: Seed a small, deterministic synthetic dataset using
--          plain INSERT INTO ... VALUES statements.
-- Prerequisites: 00_setup.sql, then 01_physical_layer.sql.
-- WARNING: Intended for EMPTY demo tables. Running twice inserts
--          duplicate IDs (Snowflake standard-table PKs are NOT enforced).
--          Do not run against real customer or production data.
-- Data volumes: CUSTOMER 20, PRODUCT 10, ISSUE 10, COMPLAINT 100.
-- All customers and cases are fictional; no personal data is used.
--
-- Designed question: Why did Product X complaint volume increase
-- in the LAST COMPLETED QUARTER (2026 Q3 vs 2026 Q2)?
-- Quarter    Product X    All other products    Total
-- 2025 Q4          6                12             18
-- 2026 Q1          9                12             21
-- 2026 Q2         12                13             25
-- 2026 Q3         23                13             36
-- The 2026 Q3 Product X cases lean toward fee-related issues.
-- This represents synthetic correlation, NOT established causality.
-- REOPEN_COUNT > 0 does not duplicate COMPLAINT_ID, since one row
-- represents one complaint case (not one complaint event).
-- ================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA STRUCTURED;

-- 1. Customers (20)
INSERT INTO CUSTOMER (
    CUSTOMER_ID, CUSTOMER_NAME, CUSTOMER_SEGMENT, CUSTOMER_STATE, CUSTOMER_SINCE_DATE
) VALUES
    ('C001', 'Alex Morgan', 'RETAIL', 'NSW', '2019-02-02'),
    ('C002', 'Taylor Chen', 'PREMIUM', 'VIC', '2020-03-03'),
    ('C003', 'Jordan Patel', 'BUSINESS', 'QLD', '2021-04-04'),
    ('C004', 'Casey Williams', 'RETAIL', 'WA', '2022-05-05'),
    ('C005', 'Riley Singh', 'PREMIUM', 'SA', '2023-06-06'),
    ('C006', 'Jamie Walker', 'BUSINESS', 'ACT', '2024-07-07'),
    ('C007', 'Sam Nguyen', 'RETAIL', 'NSW', '2018-08-08'),
    ('C008', 'Morgan Wilson', 'PREMIUM', 'VIC', '2019-09-09'),
    ('C009', 'Avery Brown', 'BUSINESS', 'QLD', '2020-10-10'),
    ('C010', 'Charlie Khan', 'RETAIL', 'WA', '2021-11-11'),
    ('C011', 'Harper Lee', 'PREMIUM', 'SA', '2022-12-12'),
    ('C012', 'Dakota Evans', 'BUSINESS', 'ACT', '2023-01-13'),
    ('C013', 'Quinn Davis', 'RETAIL', 'NSW', '2024-02-14'),
    ('C014', 'Finley Ahmed', 'PREMIUM', 'VIC', '2018-03-15'),
    ('C015', 'Parker Thompson', 'BUSINESS', 'QLD', '2019-04-16'),
    ('C016', 'Robin Clarke', 'RETAIL', 'WA', '2020-05-17'),
    ('C017', 'Skyler Martin', 'PREMIUM', 'SA', '2021-06-18'),
    ('C018', 'Drew Jackson', 'BUSINESS', 'ACT', '2022-07-19'),
    ('C019', 'Emerson Ali', 'RETAIL', 'NSW', '2023-08-20'),
    ('C020', 'Blake Robinson', 'PREMIUM', 'VIC', '2024-09-21');

-- 2. Products (10)
INSERT INTO PRODUCT (
    PRODUCT_ID, PRODUCT_NAME, PRODUCT_VARIANT, PRODUCT_CATEGORY, LAUNCH_DATE, PRODUCT_STATUS
) VALUES
    ('P001', 'Product X', 'Standard', 'CREDIT_CARD', '2022-02-01', 'ACTIVE'),
    ('P002', 'Product X', 'Premium', 'CREDIT_CARD', '2022-05-01', 'ACTIVE'),
    ('P003', 'Product X', 'Platinum', 'CREDIT_CARD', '2023-01-15', 'ACTIVE'),
    ('P004', 'Product Y', 'Standard', 'CREDIT_CARD', '2021-03-01', 'ACTIVE'),
    ('P005', 'Product Y', 'Premium', 'CREDIT_CARD', '2021-09-01', 'ACTIVE'),
    ('P006', 'Product Z', 'Standard', 'HOME_LOAN', '2020-01-01', 'ACTIVE'),
    ('P007', 'Product Z', 'Variable', 'HOME_LOAN', '2020-02-01', 'ACTIVE'),
    ('P008', 'Product A', 'Everyday', 'TRANSACTION_ACCOUNT', '2022-04-01', 'ACTIVE'),
    ('P009', 'Product B', 'Saver', 'SAVINGS_ACCOUNT', '2023-04-01', 'ACTIVE'),
    ('P010', 'Product C', 'Basic', 'PERSONAL_LOAN', '2021-07-01', 'ACTIVE');

-- 3. Standardised issues (10)
INSERT INTO ISSUE (
    ISSUE_ID, ISSUE_CATEGORY, ISSUE_NAME, ISSUE_DESCRIPTION
) VALUES
    ('I001', 'FEES', 'Incorrect Fee', 'Unexpected or incorrectly calculated product fees.'),
    ('I002', 'FEES', 'Fee Reversal Delay', 'Delay reversing a disputed fee.'),
    ('I003', 'TRANSACTIONS', 'Declined Transaction', 'Valid transactions declined unexpectedly.'),
    ('I004', 'TRANSACTIONS', 'Duplicate Charge', 'Same transaction posted more than once.'),
    ('I005', 'SERVICE', 'Slow Response', 'Delayed response to a customer enquiry or complaint.'),
    ('I006', 'SERVICE', 'Poor Communication', 'Inconsistent or unclear customer updates.'),
    ('I007', 'DIGITAL', 'App Login Failure', 'Unable to access product using the mobile app.'),
    ('I008', 'DIGITAL', 'Incorrect Balance Display', 'Balance shown incorrectly in a digital channel.'),
    ('I009', 'PAYMENTS', 'Delayed Refund', 'Refund not credited within expected time.'),
    ('I010', 'DOCUMENTS', 'Incorrect Statement', 'Statement details missing or incorrect.');

-- 4. Complaint cases (100), inserted in manageable 25-row batches
INSERT INTO COMPLAINT (
    COMPLAINT_ID, CUSTOMER_ID, PRODUCT_ID, ISSUE_ID, COMPLAINT_DATE, COMPLAINT_STATUS, COMPLAINT_CHANNEL, RESOLUTION_DATE, REOPEN_COUNT, COMPLAINT_DESCRIPTION
) VALUES
    ('CMP0001', 'C008', 'P001', 'I001', '2025-10-03', 'RESOLVED', 'PHONE', '2025-10-08', 0, 'Customer reported incorrect fee for Product X Standard.'),
    ('CMP0002', 'C015', 'P002', 'I003', '2025-10-08', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported declined transaction for Product X Premium.'),
    ('CMP0003', 'C002', 'P003', 'I005', '2025-10-13', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported slow response for Product X Platinum.'),
    ('CMP0004', 'C009', 'P001', 'I002', '2025-10-18', 'CLOSED', 'APP', '2025-10-26', 1, 'Customer reported fee reversal delay for Product X Standard.'),
    ('CMP0005', 'C016', 'P002', 'I006', '2025-10-23', 'RESOLVED', 'EMAIL', '2025-11-01', 0, 'Customer reported poor communication for Product X Premium.'),
    ('CMP0006', 'C003', 'P003', 'I009', '2025-10-28', 'OPEN', 'PHONE', NULL, 0, 'Customer reported delayed refund for Product X Platinum.'),
    ('CMP0007', 'C010', 'P004', 'I003', '2025-11-02', 'IN_PROGRESS', 'BRANCH', NULL, 0, 'Customer reported declined transaction for Product Y Standard.'),
    ('CMP0008', 'C017', 'P005', 'I005', '2025-11-07', 'CLOSED', 'WEB', '2025-11-19', 0, 'Customer reported slow response for Product Y Premium.'),
    ('CMP0009', 'C004', 'P006', 'I007', '2025-11-12', 'RESOLVED', 'APP', '2025-11-25', 0, 'Customer reported app login failure for Product Z Standard.'),
    ('CMP0010', 'C011', 'P007', 'I009', '2025-11-18', 'OPEN', 'EMAIL', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0011', 'C018', 'P008', 'I006', '2025-11-23', 'IN_PROGRESS', 'PHONE', NULL, 0, 'Customer reported poor communication for Product A Everyday.'),
    ('CMP0012', 'C005', 'P009', 'I010', '2025-11-28', 'CLOSED', 'BRANCH', '2025-12-14', 0, 'Customer reported incorrect statement for Product B Saver.'),
    ('CMP0013', 'C012', 'P010', 'I004', '2025-12-03', 'RESOLVED', 'WEB', '2025-12-20', 1, 'Customer reported duplicate charge for Product C Basic.'),
    ('CMP0014', 'C019', 'P004', 'I008', '2025-12-08', 'OPEN', 'APP', NULL, 0, 'Customer reported incorrect balance display for Product Y Standard.'),
    ('CMP0015', 'C006', 'P005', 'I002', '2025-12-13', 'IN_PROGRESS', 'EMAIL', NULL, 0, 'Customer reported fee reversal delay for Product Y Premium.'),
    ('CMP0016', 'C013', 'P006', 'I005', '2025-12-18', 'CLOSED', 'PHONE', '2026-01-07', 0, 'Customer reported slow response for Product Z Standard.'),
    ('CMP0017', 'C020', 'P007', 'I009', '2025-12-23', 'RESOLVED', 'BRANCH', '2025-12-27', 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0018', 'C007', 'P008', 'I003', '2025-12-28', 'OPEN', 'WEB', NULL, 0, 'Customer reported declined transaction for Product A Everyday.'),
    ('CMP0019', 'C014', 'P002', 'I001', '2026-01-03', 'CLOSED', 'EMAIL', '2026-01-09', 0, 'Customer reported incorrect fee for Product X Premium.'),
    ('CMP0020', 'C001', 'P003', 'I003', '2026-01-07', 'RESOLVED', 'PHONE', '2026-01-14', 0, 'Customer reported declined transaction for Product X Platinum.'),
    ('CMP0021', 'C008', 'P001', 'I005', '2026-01-11', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported slow response for Product X Standard.'),
    ('CMP0022', 'C015', 'P002', 'I002', '2026-01-15', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported fee reversal delay for Product X Premium.'),
    ('CMP0023', 'C002', 'P003', 'I006', '2026-01-20', 'CLOSED', 'APP', '2026-01-30', 0, 'Customer reported poor communication for Product X Platinum.'),
    ('CMP0024', 'C009', 'P001', 'I009', '2026-01-24', 'RESOLVED', 'EMAIL', '2026-02-04', 0, 'Customer reported delayed refund for Product X Standard.'),
    ('CMP0025', 'C016', 'P002', 'I004', '2026-01-28', 'OPEN', 'PHONE', NULL, 0, 'Customer reported duplicate charge for Product X Premium.');

INSERT INTO COMPLAINT (
    COMPLAINT_ID, CUSTOMER_ID, PRODUCT_ID, ISSUE_ID, COMPLAINT_DATE, COMPLAINT_STATUS, COMPLAINT_CHANNEL, RESOLUTION_DATE, REOPEN_COUNT, COMPLAINT_DESCRIPTION
) VALUES
    ('CMP0026', 'C003', 'P003', 'I001', '2026-02-01', 'IN_PROGRESS', 'BRANCH', NULL, 0, 'Customer reported incorrect fee for Product X Platinum.'),
    ('CMP0027', 'C010', 'P001', 'I007', '2026-02-06', 'CLOSED', 'WEB', '2026-02-20', 1, 'Customer reported app login failure for Product X Standard.'),
    ('CMP0028', 'C017', 'P005', 'I005', '2026-02-10', 'RESOLVED', 'APP', '2026-02-25', 0, 'Customer reported slow response for Product Y Premium.'),
    ('CMP0029', 'C004', 'P006', 'I007', '2026-02-14', 'OPEN', 'EMAIL', NULL, 0, 'Customer reported app login failure for Product Z Standard.'),
    ('CMP0030', 'C011', 'P007', 'I009', '2026-02-18', 'IN_PROGRESS', 'PHONE', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0031', 'C018', 'P008', 'I006', '2026-02-22', 'CLOSED', 'BRANCH', '2026-03-12', 0, 'Customer reported poor communication for Product A Everyday.'),
    ('CMP0032', 'C005', 'P009', 'I010', '2026-02-27', 'RESOLVED', 'WEB', '2026-03-18', 0, 'Customer reported incorrect statement for Product B Saver.'),
    ('CMP0033', 'C012', 'P010', 'I004', '2026-03-03', 'OPEN', 'APP', NULL, 0, 'Customer reported duplicate charge for Product C Basic.'),
    ('CMP0034', 'C019', 'P004', 'I008', '2026-03-07', 'IN_PROGRESS', 'EMAIL', NULL, 0, 'Customer reported incorrect balance display for Product Y Standard.'),
    ('CMP0035', 'C006', 'P005', 'I002', '2026-03-11', 'CLOSED', 'PHONE', '2026-03-16', 0, 'Customer reported fee reversal delay for Product Y Premium.'),
    ('CMP0036', 'C013', 'P006', 'I005', '2026-03-16', 'RESOLVED', 'BRANCH', '2026-03-22', 0, 'Customer reported slow response for Product Z Standard.'),
    ('CMP0037', 'C020', 'P007', 'I009', '2026-03-20', 'OPEN', 'WEB', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0038', 'C007', 'P008', 'I003', '2026-03-24', 'IN_PROGRESS', 'APP', NULL, 0, 'Customer reported declined transaction for Product A Everyday.'),
    ('CMP0039', 'C014', 'P009', 'I007', '2026-03-28', 'CLOSED', 'EMAIL', '2026-04-06', 0, 'Customer reported app login failure for Product B Saver.'),
    ('CMP0040', 'C001', 'P003', 'I001', '2026-04-02', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported incorrect fee for Product X Platinum.'),
    ('CMP0041', 'C008', 'P001', 'I003', '2026-04-06', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported declined transaction for Product X Standard.'),
    ('CMP0042', 'C015', 'P002', 'I005', '2026-04-10', 'CLOSED', 'APP', '2026-04-22', 0, 'Customer reported slow response for Product X Premium.'),
    ('CMP0043', 'C002', 'P003', 'I002', '2026-04-13', 'RESOLVED', 'EMAIL', '2026-04-26', 0, 'Customer reported fee reversal delay for Product X Platinum.'),
    ('CMP0044', 'C009', 'P001', 'I006', '2026-04-17', 'OPEN', 'PHONE', NULL, 1, 'Customer reported poor communication for Product X Standard.'),
    ('CMP0045', 'C016', 'P002', 'I009', '2026-04-20', 'IN_PROGRESS', 'BRANCH', NULL, 0, 'Customer reported delayed refund for Product X Premium.'),
    ('CMP0046', 'C003', 'P003', 'I004', '2026-04-24', 'CLOSED', 'WEB', '2026-05-10', 0, 'Customer reported duplicate charge for Product X Platinum.'),
    ('CMP0047', 'C010', 'P001', 'I001', '2026-04-28', 'RESOLVED', 'APP', '2026-05-15', 0, 'Customer reported incorrect fee for Product X Standard.'),
    ('CMP0048', 'C017', 'P002', 'I007', '2026-05-01', 'OPEN', 'EMAIL', NULL, 0, 'Customer reported app login failure for Product X Premium.'),
    ('CMP0049', 'C004', 'P003', 'I010', '2026-05-05', 'IN_PROGRESS', 'PHONE', NULL, 0, 'Customer reported incorrect statement for Product X Platinum.'),
    ('CMP0050', 'C011', 'P001', 'I005', '2026-05-08', 'CLOSED', 'BRANCH', '2026-05-28', 0, 'Customer reported slow response for Product X Standard.');

INSERT INTO COMPLAINT (
    COMPLAINT_ID, CUSTOMER_ID, PRODUCT_ID, ISSUE_ID, COMPLAINT_DATE, COMPLAINT_STATUS, COMPLAINT_CHANNEL, RESOLUTION_DATE, REOPEN_COUNT, COMPLAINT_DESCRIPTION
) VALUES
    ('CMP0051', 'C018', 'P002', 'I003', '2026-05-12', 'RESOLVED', 'WEB', '2026-05-16', 0, 'Customer reported declined transaction for Product X Premium.'),
    ('CMP0052', 'C005', 'P006', 'I007', '2026-05-16', 'OPEN', 'APP', NULL, 0, 'Customer reported app login failure for Product Z Standard.'),
    ('CMP0053', 'C012', 'P007', 'I009', '2026-05-19', 'IN_PROGRESS', 'EMAIL', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0054', 'C019', 'P008', 'I006', '2026-05-23', 'CLOSED', 'PHONE', '2026-05-30', 0, 'Customer reported poor communication for Product A Everyday.'),
    ('CMP0055', 'C006', 'P009', 'I010', '2026-05-26', 'RESOLVED', 'BRANCH', '2026-06-03', 0, 'Customer reported incorrect statement for Product B Saver.'),
    ('CMP0056', 'C013', 'P010', 'I004', '2026-05-30', 'OPEN', 'WEB', NULL, 0, 'Customer reported duplicate charge for Product C Basic.'),
    ('CMP0057', 'C020', 'P004', 'I008', '2026-06-03', 'IN_PROGRESS', 'APP', NULL, 0, 'Customer reported incorrect balance display for Product Y Standard.'),
    ('CMP0058', 'C007', 'P005', 'I002', '2026-06-06', 'CLOSED', 'EMAIL', '2026-06-17', 0, 'Customer reported fee reversal delay for Product Y Premium.'),
    ('CMP0059', 'C014', 'P006', 'I005', '2026-06-10', 'RESOLVED', 'PHONE', '2026-06-22', 1, 'Customer reported slow response for Product Z Standard.'),
    ('CMP0060', 'C001', 'P007', 'I009', '2026-06-13', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0061', 'C008', 'P008', 'I003', '2026-06-17', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported declined transaction for Product A Everyday.'),
    ('CMP0062', 'C015', 'P009', 'I007', '2026-06-21', 'CLOSED', 'APP', '2026-07-06', 0, 'Customer reported app login failure for Product B Saver.'),
    ('CMP0063', 'C002', 'P010', 'I003', '2026-06-24', 'RESOLVED', 'EMAIL', '2026-07-10', 0, 'Customer reported declined transaction for Product C Basic.'),
    ('CMP0064', 'C009', 'P004', 'I005', '2026-06-28', 'OPEN', 'PHONE', NULL, 0, 'Customer reported slow response for Product Y Standard.'),
    ('CMP0065', 'C016', 'P001', 'I001', '2026-07-02', 'CLOSED', 'WEB', '2026-07-20', 0, 'Customer reported incorrect fee for Standard variant of Product X; fee amount disputed.'),
    ('CMP0066', 'C003', 'P002', 'I001', '2026-07-04', 'RESOLVED', 'APP', '2026-07-23', 0, 'Customer reported incorrect fee for Premium variant of Product X; fee amount disputed.'),
    ('CMP0067', 'C010', 'P003', 'I002', '2026-07-07', 'OPEN', 'EMAIL', NULL, 0, 'Customer reported fee reversal delay for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0068', 'C017', 'P001', 'I001', '2026-07-09', 'IN_PROGRESS', 'PHONE', NULL, 0, 'Customer reported incorrect fee for Standard variant of Product X; fee amount disputed.'),
    ('CMP0069', 'C004', 'P002', 'I005', '2026-07-12', 'CLOSED', 'BRANCH', '2026-07-17', 0, 'Customer reported slow response for Product X Premium.'),
    ('CMP0070', 'C011', 'P003', 'I003', '2026-07-14', 'RESOLVED', 'WEB', '2026-07-20', 0, 'Customer reported declined transaction for Product X Platinum.'),
    ('CMP0071', 'C018', 'P001', 'I001', '2026-07-17', 'OPEN', 'APP', NULL, 0, 'Customer reported incorrect fee for Standard variant of Product X; fee amount disputed.'),
    ('CMP0072', 'C005', 'P002', 'I002', '2026-07-19', 'IN_PROGRESS', 'EMAIL', NULL, 0, 'Customer reported fee reversal delay for Premium variant of Product X; fee amount disputed.'),
    ('CMP0073', 'C012', 'P003', 'I001', '2026-07-22', 'CLOSED', 'PHONE', '2026-07-31', 1, 'Customer reported incorrect fee for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0074', 'C019', 'P001', 'I006', '2026-07-25', 'RESOLVED', 'BRANCH', '2026-08-04', 0, 'Customer reported poor communication for Product X Standard.'),
    ('CMP0075', 'C006', 'P002', 'I001', '2026-07-27', 'OPEN', 'WEB', NULL, 0, 'Customer reported incorrect fee for Premium variant of Product X; fee amount disputed.');

INSERT INTO COMPLAINT (
    COMPLAINT_ID, CUSTOMER_ID, PRODUCT_ID, ISSUE_ID, COMPLAINT_DATE, COMPLAINT_STATUS, COMPLAINT_CHANNEL, RESOLUTION_DATE, REOPEN_COUNT, COMPLAINT_DESCRIPTION
) VALUES
    ('CMP0076', 'C013', 'P003', 'I002', '2026-07-30', 'IN_PROGRESS', 'APP', NULL, 0, 'Customer reported fee reversal delay for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0077', 'C020', 'P001', 'I001', '2026-08-01', 'CLOSED', 'EMAIL', '2026-08-14', 0, 'Customer reported incorrect fee for Standard variant of Product X; fee amount disputed.'),
    ('CMP0078', 'C007', 'P002', 'I005', '2026-08-04', 'RESOLVED', 'PHONE', '2026-08-18', 0, 'Customer reported slow response for Product X Premium.'),
    ('CMP0079', 'C014', 'P003', 'I001', '2026-08-06', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported incorrect fee for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0080', 'C001', 'P001', 'I004', '2026-08-09', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported duplicate charge for Product X Standard.'),
    ('CMP0081', 'C008', 'P002', 'I002', '2026-08-11', 'CLOSED', 'APP', '2026-08-28', 0, 'Customer reported fee reversal delay for Premium variant of Product X; fee amount disputed.'),
    ('CMP0082', 'C015', 'P003', 'I001', '2026-08-14', 'RESOLVED', 'EMAIL', '2026-09-01', 0, 'Customer reported incorrect fee for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0083', 'C002', 'P001', 'I006', '2026-08-16', 'OPEN', 'PHONE', NULL, 0, 'Customer reported poor communication for Product X Standard.'),
    ('CMP0084', 'C009', 'P002', 'I001', '2026-08-19', 'IN_PROGRESS', 'BRANCH', NULL, 1, 'Customer reported incorrect fee for Premium variant of Product X; fee amount disputed.'),
    ('CMP0085', 'C016', 'P003', 'I002', '2026-08-21', 'CLOSED', 'WEB', '2026-08-25', 0, 'Customer reported fee reversal delay for Platinum variant of Product X; fee amount disputed.'),
    ('CMP0086', 'C003', 'P001', 'I001', '2026-08-24', 'RESOLVED', 'APP', '2026-08-29', 0, 'Customer reported incorrect fee for Standard variant of Product X; fee amount disputed.'),
    ('CMP0087', 'C010', 'P002', 'I001', '2026-08-26', 'OPEN', 'EMAIL', NULL, 0, 'Customer reported incorrect fee for Premium variant of Product X; fee amount disputed.'),
    ('CMP0088', 'C017', 'P007', 'I009', '2026-08-29', 'IN_PROGRESS', 'PHONE', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0089', 'C004', 'P008', 'I006', '2026-08-31', 'CLOSED', 'BRANCH', '2026-09-08', 0, 'Customer reported poor communication for Product A Everyday.'),
    ('CMP0090', 'C011', 'P009', 'I010', '2026-09-03', 'RESOLVED', 'WEB', '2026-09-12', 0, 'Customer reported incorrect statement for Product B Saver.'),
    ('CMP0091', 'C018', 'P010', 'I004', '2026-09-05', 'OPEN', 'APP', NULL, 2, 'Customer reported duplicate charge for Product C Basic.'),
    ('CMP0092', 'C005', 'P004', 'I008', '2026-09-08', 'IN_PROGRESS', 'EMAIL', NULL, 0, 'Customer reported incorrect balance display for Product Y Standard.'),
    ('CMP0093', 'C012', 'P005', 'I002', '2026-09-11', 'CLOSED', 'PHONE', '2026-09-23', 0, 'Customer reported fee reversal delay for Product Y Premium.'),
    ('CMP0094', 'C019', 'P006', 'I005', '2026-09-13', 'RESOLVED', 'BRANCH', '2026-09-26', 0, 'Customer reported slow response for Product Z Standard.'),
    ('CMP0095', 'C006', 'P007', 'I009', '2026-09-16', 'OPEN', 'WEB', NULL, 0, 'Customer reported delayed refund for Product Z Variable.'),
    ('CMP0096', 'C013', 'P008', 'I003', '2026-09-18', 'IN_PROGRESS', 'APP', NULL, 1, 'Customer reported declined transaction for Product A Everyday.'),
    ('CMP0097', 'C020', 'P009', 'I007', '2026-09-21', 'CLOSED', 'EMAIL', '2026-10-07', 0, 'Customer reported app login failure for Product B Saver.'),
    ('CMP0098', 'C007', 'P010', 'I003', '2026-09-23', 'RESOLVED', 'PHONE', '2026-10-10', 0, 'Customer reported declined transaction for Product C Basic.'),
    ('CMP0099', 'C014', 'P004', 'I005', '2026-09-26', 'OPEN', 'BRANCH', NULL, 0, 'Customer reported slow response for Product Y Standard.'),
    ('CMP0100', 'C001', 'P005', 'I007', '2026-09-28', 'IN_PROGRESS', 'WEB', NULL, 0, 'Customer reported app login failure for Product Y Premium.');

-- 5. Verification: expected row counts 20 / 10 / 10 / 100
SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM CUSTOMER
UNION ALL SELECT 'PRODUCT', COUNT(*) FROM PRODUCT
UNION ALL SELECT 'ISSUE', COUNT(*) FROM ISSUE
UNION ALL SELECT 'COMPLAINT', COUNT(*) FROM COMPLAINT;

-- 6. Key analysis: Product X quarterly trend
SELECT DATE_TRUNC('QUARTER', c.COMPLAINT_DATE)::DATE AS QUARTER_START,
       COUNT(DISTINCT c.COMPLAINT_ID) AS PRODUCT_X_COMPLAINTS
FROM COMPLAINT c
JOIN PRODUCT p ON c.PRODUCT_ID = p.PRODUCT_ID
WHERE p.PRODUCT_NAME = 'Product X'
GROUP BY 1
ORDER BY 1;

-- 7. Key analysis: recurring Product X issues in 2026 Q3
SELECT i.ISSUE_CATEGORY, i.ISSUE_NAME,
       COUNT(DISTINCT c.COMPLAINT_ID) AS COMPLAINTS
FROM COMPLAINT c
JOIN PRODUCT p ON c.PRODUCT_ID = p.PRODUCT_ID
JOIN ISSUE i ON c.ISSUE_ID = i.ISSUE_ID
WHERE p.PRODUCT_NAME = 'Product X'
  AND c.COMPLAINT_DATE >= DATE '2026-07-01'
  AND c.COMPLAINT_DATE < DATE '2026-10-01'
GROUP BY i.ISSUE_CATEGORY, i.ISSUE_NAME
ORDER BY COMPLAINTS DESC, i.ISSUE_NAME;

-- 8. Basic relationship checks (expect zero orphan records)
SELECT COUNT(*) AS MISSING_CUSTOMERS
FROM COMPLAINT c LEFT JOIN CUSTOMER x ON c.CUSTOMER_ID=x.CUSTOMER_ID
WHERE x.CUSTOMER_ID IS NULL;
SELECT COUNT(*) AS MISSING_PRODUCTS
FROM COMPLAINT c LEFT JOIN PRODUCT p ON c.PRODUCT_ID=p.PRODUCT_ID
WHERE p.PRODUCT_ID IS NULL;
SELECT COUNT(*) AS MISSING_ISSUES
FROM COMPLAINT c LEFT JOIN ISSUE i ON c.ISSUE_ID=i.ISSUE_ID
WHERE i.ISSUE_ID IS NULL;
-- Next: graph nodes and edges, derived using these same stable IDs.
