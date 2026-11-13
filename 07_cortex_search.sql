-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 07_CORTEX_SEARCH.SQL
-- ============================================================================
-- Creates a Cortex Search Service over synthetic complaint email documents.
-- Prerequisites: 05_email_sample_data.sql and a running warehouse.
-- Set the session variable below to a warehouse that exists and that the
-- active role may use. The role also needs Cortex Search service privileges.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA EMAILS;

-- Replace with your available warehouse name before running.
SET CORTEX_SEARCH_WAREHOUSE = 'YOUR_WAREHOUSE_NAME';

CREATE OR REPLACE CORTEX SEARCH SERVICE EMAIL_COMPLAINT_SEARCH
  ON EMAIL_BODY
  PRIMARY KEY (EMAIL_ID)
  ATTRIBUTES COMPLAINT_ID, CUSTOMER_ID, PRODUCT_ID, ISSUE_ID,
             SENDER_ROLE, EMAIL_CHANNEL, EMAIL_DATE
  WAREHOUSE = $CORTEX_SEARCH_WAREHOUSE
  TARGET_LAG = '1 hour'
  COMMENT = 'Search synthetic customer complaint email text; result attributes link back to structured and graph entities.'
AS
  SELECT
      EMAIL_ID,
      COMPLAINT_ID,
      CUSTOMER_ID,
      PRODUCT_ID,
      ISSUE_ID,
      SENDER_ROLE,
      EMAIL_CHANNEL,
      EMAIL_DATE,
      SUBJECT,
      EMAIL_BODY
  FROM EMAILS.COMPLAINT_EMAIL;

-- Verify service creation and indexing state. Indexing can take time after
-- creation; check indexing_state/serving_state before querying the service.
SHOW CORTEX SEARCH SERVICES LIKE 'EMAIL_COMPLAINT_SEARCH' IN SCHEMA EMAILS;
DESCRIBE CORTEX SEARCH SERVICE EMAIL_COMPLAINT_SEARCH;

-- Example Python API usage (run in an application/session with Snowflake
-- Cortex Search access):
-- from snowflake.core import Root
-- svc = root.databases['ENTERPRISE_CONVERSATIONAL_AI'].schemas['EMAILS'] 
--      .cortex_search_services['EMAIL_COMPLAINT_SEARCH']
-- response = svc.search(query='incorrect fee Product X', columns=['EMAIL_ID','COMPLAINT_ID','SUBJECT','EMAIL_BODY'], limit=5)
