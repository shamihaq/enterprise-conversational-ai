-- ================================================================
-- ENTERPRISE CONVERSATIONAL AI - 01_PHYSICAL_LAYER.SQL
-- ================================================================
-- LAYER 1: STRUCTURED PHYSICAL DATA LAYER (3NF-oriented)
-- Business domain: Synthetic customer complaints
--

-- Creates four relational tables:
--   CUSTOMER  : customer master
--   PRODUCT   : product variant master
--   ISSUE     : standardised complaint issue master
--   COMPLAINT : one row per unique complaint case
--
-- Prerequisite: Run sql/00_setup.sql first.
-- Safe to rerun: CREATE TABLE IF NOT EXISTS retains existing data.
-- Note: Snowflake standard tables record PK/FK constraints as metadata;
--       they do not enforce key uniqueness or foreign-key integrity.
-- ================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA STRUCTURED;

-- ================================================================
-- CUSTOMER: Customer master data
-- Grain: One row per customer
-- ================================================================
CREATE TABLE IF NOT EXISTS CUSTOMER (
    CUSTOMER_ID          VARCHAR(10)   NOT NULL,
    CUSTOMER_NAME        VARCHAR(100)  NOT NULL,
    CUSTOMER_SEGMENT     VARCHAR(30)   NOT NULL,  -- RETAIL | PREMIUM | BUSINESS
    CUSTOMER_STATE       VARCHAR(10)   NOT NULL,  -- NSW | VIC | QLD | ...
    CUSTOMER_SINCE_DATE  DATE,
    CONSTRAINT PK_CUSTOMER PRIMARY KEY (CUSTOMER_ID)
)
CLUSTER BY (CUSTOMER_ID)
;
COMMENT ON TABLE CUSTOMER IS 'Synthetic customer master for complaint analysis; one row per customer.';

-- ================================================================
-- PRODUCT: Product variants
-- Grain: One row per sellable product variant
-- PRODUCT_NAME is the common product family label (e.g. Product X).
-- ================================================================
CREATE TABLE IF NOT EXISTS PRODUCT (
    PRODUCT_ID       VARCHAR(10)   NOT NULL,
    PRODUCT_NAME     VARCHAR(100)  NOT NULL,  -- Product X | Product Y
    PRODUCT_VARIANT  VARCHAR(50)   NOT NULL,  -- Standard | Premium | Platinum
    PRODUCT_CATEGORY VARCHAR(50)   NOT NULL,  -- CREDIT_CARD | HOME_LOAN | ...
    LAUNCH_DATE      DATE,
    PRODUCT_STATUS   VARCHAR(20)   NOT NULL,  -- ACTIVE | DISCONTINUED
    CONSTRAINT PK_PRODUCT PRIMARY KEY (PRODUCT_ID),
    CONSTRAINT UQ_PRODUCT_VARIANT UNIQUE (PRODUCT_NAME, PRODUCT_VARIANT)
)
CLUSTER BY (PRODUCT_ID)
;
COMMENT ON TABLE PRODUCT IS 'Synthetic product catalogue; distinct row per product family and variant combination.';

-- ================================================================
-- ISSUE: Standardised complaint issue classification
-- Grain: One row per issue type
-- ================================================================
CREATE TABLE IF NOT EXISTS ISSUE (
    ISSUE_ID           VARCHAR(10)   NOT NULL,
    ISSUE_CATEGORY     VARCHAR(50)   NOT NULL,  -- FEES | SERVICE | TRANSACTIONS
    ISSUE_NAME         VARCHAR(100)  NOT NULL,  -- Incorrect Fee | Delayed Refund
    ISSUE_DESCRIPTION  VARCHAR(255),
    CONSTRAINT PK_ISSUE PRIMARY KEY (ISSUE_ID),
    CONSTRAINT UQ_ISSUE_NAME UNIQUE (ISSUE_NAME)
);
COMMENT ON TABLE ISSUE IS 'Standardised complaint issue catalogue used to analyse recurring issues.';

-- ================================================================
-- COMPLAINT: Complaint case records
-- Grain: One row per unique complaint case (including reopened cases)
-- Foreign keys reference CUSTOMER, PRODUCT and ISSUE.
-- REOPEN_COUNT summarises lifecycle events for this simple demo;
-- a fuller model would derive it from a status-event history table.
-- ================================================================
CREATE TABLE IF NOT EXISTS COMPLAINT (
    COMPLAINT_ID           VARCHAR(12)   NOT NULL,
    CUSTOMER_ID            VARCHAR(10)   NOT NULL,
    PRODUCT_ID             VARCHAR(10)   NOT NULL,
    ISSUE_ID               VARCHAR(10)   NOT NULL,
    COMPLAINT_DATE         DATE          NOT NULL,
    COMPLAINT_STATUS       VARCHAR(20)   NOT NULL, -- OPEN | IN_PROGRESS | RESOLVED | CLOSED
    COMPLAINT_CHANNEL      VARCHAR(20)   NOT NULL, -- EMAIL | PHONE | BRANCH | WEB | APP
    RESOLUTION_DATE        DATE,
    REOPEN_COUNT           NUMBER(2,0)   NOT NULL DEFAULT 0,
    COMPLAINT_DESCRIPTION  VARCHAR(500),
    CONSTRAINT PK_COMPLAINT PRIMARY KEY (COMPLAINT_ID),
    CONSTRAINT FK_COMPLAINT_CUSTOMER FOREIGN KEY (CUSTOMER_ID)
        REFERENCES CUSTOMER (CUSTOMER_ID),
    CONSTRAINT FK_COMPLAINT_PRODUCT FOREIGN KEY (PRODUCT_ID)
        REFERENCES PRODUCT (PRODUCT_ID),
    CONSTRAINT FK_COMPLAINT_ISSUE FOREIGN KEY (ISSUE_ID)
        REFERENCES ISSUE (ISSUE_ID)
)
CLUSTER BY (COMPLAINT_ID)
;
COMMENT ON TABLE COMPLAINT IS 'Synthetic complaint cases: one case per COMPLAINT_ID, with a primary product and issue.';

-- ================================================================
-- Verification: list physical-layer tables
-- ================================================================
SHOW TABLES IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED;

-- Next: 02_sample_data.sql (populate <= 100 rows per table)
-- Later: graph physical layer (KG_NODE/KG_EDGE) in GRAPH schema.
