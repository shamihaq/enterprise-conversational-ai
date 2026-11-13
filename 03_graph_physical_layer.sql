-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 03_GRAPH_PHYSICAL_LAYER.SQL
-- ============================================================================
-- Layer: Knowledge graph physical storage (Snowflake-native node / edge tables)
-- Design inspired by Snowflake-Labs/ontology-on-snowflake/sql/01_physical_layer.sql
-- https://github.com/Snowflake-Labs/ontology-on-snowflake/tree/main/sql
--
-- Prerequisites:
--   00_setup.sql             database and GRAPH schema
--   01_physical_layer.sql    structured source tables
--   02_sample_data.sql      synthetic structured records
--
-- This file creates ONLY graph storage. It does not load nodes or edges.
-- Follow-on script will derive node/edge rows from STRUCTURED tables and
-- add a small set of graph-only entities (e.g. SERVICE and SYSTEM_CHANGE).
--
-- Identity strategy:
--   NODE_ID = '<NODE_TYPE>:<SOURCE_PRIMARY_KEY>'
--   e.g. CUSTOMER:C001, PRODUCT:P001, ISSUE:I001, COMPLAINT:CMP001.
--   Keep the original source PK in PROPS:source_id and its source table in
--   PROPS:source_table. Prefixing prevents cross-table PK collisions.
--
-- Initial node types: CUSTOMER, PRODUCT, ISSUE, COMPLAINT
-- Initial relationship types (direction: SRC_ID -> DST_ID):
--   FILED             CUSTOMER -> COMPLAINT
--   ABOUT_PRODUCT     COMPLAINT -> PRODUCT
--   REPORTS_ISSUE     COMPLAINT -> ISSUE
-- Future graph-only extensions:
--   PRODUCT -> SERVICE (USES_SERVICE)
--   SERVICE -> SYSTEM_CHANGE (AFFECTED_BY)
--   SYSTEM_CHANGE -> ISSUE (POTENTIALLY_ASSOCIATED_WITH)
--
-- Snowflake standard table PKs/FKs are informational (not enforced).
-- Keep graph IDs unique and edge endpoints valid through load validation.
-- This small demo does not require CLUSTER BY or a graph database service.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA GRAPH;

-- ============================================================================
-- KG_NODE: Universal business-entity store
-- Grain: one row per graph node (distinct NODE_ID)
-- ============================================================================
CREATE TABLE IF NOT EXISTS KG_NODE (
    NODE_ID       VARCHAR(100)  NOT NULL,        -- globally unique graph identity
    NODE_TYPE     VARCHAR(50)   NOT NULL,        -- CUSTOMER | PRODUCT | ISSUE | COMPLAINT | ...
    NAME          VARCHAR(255),                  -- display name / label
    PROPS         VARIANT,                       -- original source ID and domain properties
    TS_INGESTED   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_KG_NODE PRIMARY KEY (NODE_ID)
);

COMMENT ON TABLE KG_NODE IS
    'Universal node store for complaint-domain entities. Stable prefixed IDs link nodes to structured source records.';

-- ============================================================================
-- KG_EDGE: Directed relationship store
-- Grain: one row per distinct relationship instance (EDGE_ID)
-- ============================================================================
CREATE TABLE IF NOT EXISTS KG_EDGE (
    EDGE_ID          VARCHAR(200) NOT NULL,       -- stable relationship ID
    SRC_ID           VARCHAR(100) NOT NULL,       -- references KG_NODE.NODE_ID logically
    DST_ID           VARCHAR(100) NOT NULL,       -- references KG_NODE.NODE_ID logically
    EDGE_TYPE        VARCHAR(80)  NOT NULL,       -- relationship predicate
    WEIGHT           FLOAT        DEFAULT 1.0,   -- reserved for graph algorithms
    PROPS            VARIANT,                     -- relationship attributes / provenance
    EFFECTIVE_START  DATE,                        -- start of relationship validity
    EFFECTIVE_END    DATE,                        -- NULL = no known end
    TS_INGESTED      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_KG_EDGE PRIMARY KEY (EDGE_ID)
);

COMMENT ON TABLE KG_EDGE IS
    'Directed relationships between KG_NODE entities, with optional temporal validity and source provenance.';

-- ============================================================================
-- Object verification (safe before graph data is loaded)
-- ============================================================================
SHOW TABLES IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.GRAPH;

-- The following should both return zero after first creation.
SELECT 'KG_NODE' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM KG_NODE
UNION ALL
SELECT 'KG_EDGE' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM KG_EDGE;

-- ============================================================================
-- Future loading/validation conventions (no INSERTs in this file)
-- ============================================================================
-- Typical graph links from existing COMPLAINT rows:
--   CUSTOMER:<customer_id>   --FILED---------> COMPLAINT:<complaint_id>
--   COMPLAINT:<complaint_id> --ABOUT_PRODUCT-> PRODUCT:<product_id>
--   COMPLAINT:<complaint_id> --REPORTS_ISSUE-> ISSUE:<issue_id>
--
-- When loading data, validate:
--   (1) duplicate NODE_ID / EDGE_ID (Snowflake standard PK not enforced)
--   (2) every SRC_ID and DST_ID exists in KG_NODE
--   (3) valid NODE_TYPE and EDGE_TYPE domain values
--   (4) EFFECTIVE_END >= EFFECTIVE_START where both are non-NULL
--
-- Earlier demo limit: <=100 records per table. The structured source has
-- 140 records in total, so loading all sources as graph nodes would exceed
-- the limit. In the NEXT script, select a coherent subset (e.g. 20 customers,
-- 10 products, 10 issues, and 60 complaints = 100 KG_NODE records), then
-- generate edges only between included nodes. Alternatively, relax the graph
-- table cap explicitly before loading the complete source graph.
-- ============================================================================
