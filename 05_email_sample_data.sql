-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 05_EMAIL_SAMPLE_DATA.SQL
-- ============================================================================
-- Purpose: Create and load fictional complaint email documents for Cortex Search.
-- Prerequisites: Run 00_setup.sql and 02_sample_data.sql first.
-- Safe to rerun: MERGE updates matching EMAIL_ID rows and inserts new rows.
-- These records are synthetic and linked to existing complaint cases.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA EMAILS;

CREATE TABLE IF NOT EXISTS COMPLAINT_EMAIL (
    EMAIL_ID       VARCHAR(20)   NOT NULL,
    COMPLAINT_ID   VARCHAR(12)   NOT NULL,
    EMAIL_DATE     TIMESTAMP_NTZ NOT NULL,
    SENDER_ROLE    VARCHAR(30)   NOT NULL,
    SUBJECT        VARCHAR(200)  NOT NULL,
    EMAIL_BODY     VARCHAR(10000) NOT NULL,
    CUSTOMER_ID    VARCHAR(10),
    PRODUCT_ID     VARCHAR(10),
    ISSUE_ID       VARCHAR(10),
    EMAIL_CHANNEL  VARCHAR(20)   DEFAULT 'EMAIL',
    CONSTRAINT PK_COMPLAINT_EMAIL PRIMARY KEY (EMAIL_ID)
);

COMMENT ON TABLE COMPLAINT_EMAIL IS
  'Fictional complaint email documents linked to structured complaint cases; EMAIL_BODY is the Cortex Search text column.';

MERGE INTO COMPLAINT_EMAIL AS target
USING (
    SELECT column1::VARCHAR AS EMAIL_ID,
           column2::VARCHAR AS COMPLAINT_ID,
           column3::TIMESTAMP_NTZ AS EMAIL_DATE,
           column4::VARCHAR AS SENDER_ROLE,
           column5::VARCHAR AS SUBJECT,
           column6::VARCHAR AS EMAIL_BODY
    FROM VALUES
      ('EML0001', 'CMP0065', '2026-07-03 09:14:00', 'CUSTOMER',
       'Disputed annual fee on Product X Standard',
       'Hello Support, I noticed an annual fee on my Product X Standard card that does not match the fee information I was given. Please explain the charge and let me know whether it can be reversed. I have attached the statement date and can provide more details if needed.'),
      ('EML0002', 'CMP0065', '2026-07-05 14:32:00', 'SUPPORT',
       'Re: Disputed annual fee on Product X Standard',
       'Hi Alex, we have opened a review of the annual fee on your Product X Standard account. The case is linked to complaint CMP0065. We will compare the billed amount with the applicable product terms and update you when the review is complete.'),
      ('EML0003', 'CMP0071', '2026-07-17 10:06:00', 'CUSTOMER',
       'Fee charged after product change',
       'Dear Complaints Team, I changed my Product X Standard card recently and believe I was charged a fee after the change. Could you check the timing and confirm whether the fee should have applied? I am concerned because the amount appeared on my latest statement.'),
      ('EML0004', 'CMP0073', '2026-07-22 16:48:00', 'CUSTOMER',
       'Refund still missing for disputed fee',
       'Hello, I was told that the disputed fee would be reviewed, but I cannot see a reversal yet. Please confirm whether the fee review is still in progress and when I should expect an update. This is about my Product X Platinum account.'),
      ('EML0005', 'CMP0084', '2026-08-19 08:55:00', 'CUSTOMER',
       'Incorrect fee on Product X Premium',
       'I am writing about an incorrect fee on my Product X Premium account. The statement shows a charge I do not recognise. Please check the fee calculation and tell me what information you need to investigate it.'),
      ('EML0006', 'CMP0085', '2026-08-22 11:20:00', 'SUPPORT',
       'Update on fee reversal request',
       'Hello, your request about the fee reversal delay has been assigned for review under complaint CMP0085. We are checking the original fee and reversal processing dates. We will send another message once we have confirmed the outcome.'),
      ('EML0007', 'CMP0086', '2026-08-24 13:02:00', 'CUSTOMER',
       'Annual fee amount does not look right',
       'The annual fee for my Product X Standard card seems higher than expected. Could someone confirm which fee schedule applies to my account and whether a correction is required? I would appreciate a written explanation.'),
      ('EML0008', 'CMP0087', '2026-08-27 09:41:00', 'CUSTOMER',
       'Please review Product X Premium fee',
       'I have an incorrect fee concern for Product X Premium. I checked the product information but cannot reconcile it with the amount charged. Please investigate the transaction and advise whether it can be reversed.'),
      ('EML0009', 'CMP0078', '2026-08-05 15:12:00', 'CUSTOMER',
       'No response to my earlier enquiry',
       'I am following up because I have not received a clear response to my earlier enquiry about Product X Premium. Please let me know who is handling the matter and when I can expect an update.'),
      ('EML0010', 'CMP0097', '2026-09-22 17:27:00', 'CUSTOMER',
       'Unable to sign in to mobile app',
       'I cannot sign in to the mobile app to check my Product B Saver balance. The app returns me to the login screen after I enter my details. Please advise how to restore access.'),
      ('EML0011', 'CMP0098', '2026-09-24 12:03:00', 'CUSTOMER',
       'Valid payment declined',
       'A payment using my Product C Basic account was declined even though I believe sufficient funds were available. Please check why it was declined and confirm whether any restriction has been placed on the account.'),
      ('EML0012', 'CMP0100', '2026-09-29 10:18:00', 'CUSTOMER',
       'App login problem with Product Y Premium',
       'I am unable to log into the app to manage my Product Y Premium account. I have tried restarting the app and resetting my password. Please help restore access and let me know if there is a known service issue.')
) AS source (EMAIL_ID, COMPLAINT_ID, EMAIL_DATE, SENDER_ROLE, SUBJECT, EMAIL_BODY)
ON target.EMAIL_ID = source.EMAIL_ID
WHEN MATCHED THEN UPDATE SET
    COMPLAINT_ID = source.COMPLAINT_ID,
    EMAIL_DATE = source.EMAIL_DATE,
    SENDER_ROLE = source.SENDER_ROLE,
    SUBJECT = source.SUBJECT,
    EMAIL_BODY = source.EMAIL_BODY
WHEN NOT MATCHED THEN INSERT
    (EMAIL_ID, COMPLAINT_ID, EMAIL_DATE, SENDER_ROLE, SUBJECT, EMAIL_BODY)
VALUES
    (source.EMAIL_ID, source.COMPLAINT_ID, source.EMAIL_DATE, source.SENDER_ROLE, source.SUBJECT, source.EMAIL_BODY);

-- Enrich email rows with structured identifiers through the complaint link.
UPDATE EMAILS.COMPLAINT_EMAIL AS e
SET CUSTOMER_ID = c.CUSTOMER_ID,
    PRODUCT_ID = c.PRODUCT_ID,
    ISSUE_ID = c.ISSUE_ID
FROM STRUCTURED.COMPLAINT AS c
WHERE e.COMPLAINT_ID = c.COMPLAINT_ID;

-- Verification: expected 12 distinct synthetic email records.
SELECT COUNT(*) AS EMAIL_COUNT,
       COUNT(DISTINCT EMAIL_ID) AS DISTINCT_EMAIL_COUNT,
       COUNT_IF(c.COMPLAINT_ID IS NULL) AS ORPHAN_EMAILS
FROM EMAILS.COMPLAINT_EMAIL e
LEFT JOIN STRUCTURED.COMPLAINT c ON e.COMPLAINT_ID = c.COMPLAINT_ID;

-- Next: 06_semantic_views.sql, then 07_cortex_search.sql.
