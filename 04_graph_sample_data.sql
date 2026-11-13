-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 04_GRAPH_SAMPLE_DATA.SQL
-- ============================================================================
-- Purpose: Populate GRAPH.KG_NODE and GRAPH.KG_EDGE directly from the same
--          structured sample records inserted by 02_sample_data.sql.
--          No graph row limit. No additional fictional business records.
--
-- Run order:
--   00_setup.sql
--   01_physical_layer.sql
--   02_sample_data.sql
--   03_graph_physical_layer.sql
--   04_graph_sample_data.sql  <-- this file
--
-- Expected from the initial synthetic dataset:
--   KG_NODE: 140 = 20 CUSTOMER + 10 PRODUCT + 10 ISSUE + 100 COMPLAINT
--   KG_EDGE: 300 = 100 FILED + 100 ABOUT_PRODUCT + 100 REPORTS_ISSUE
--
-- Node identity: <TYPE>:<STRUCTURED PRIMARY KEY>
--   CUSTOMER:C001, PRODUCT:P001, ISSUE:I001, COMPLAINT:CMP0001
-- Every edge is sourced from an existing COMPLAINT foreign key, rather than
-- inventing unsupported causal or service relationships.
--
-- All inserts avoid re-inserting the same graph ID on repeated execution.
-- Snowflake standard-table primary keys are NOT enforced; validation follows.
-- This is an initial load pattern: changed source attributes will not be
-- refreshed on a rerun, and deleted source records are not removed.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA GRAPH;

-- ============================================================================
-- 1. NODES: CUSTOMER
-- ============================================================================
INSERT INTO KG_NODE (NODE_ID, NODE_TYPE, NAME, PROPS)
SELECT
    'CUSTOMER:' || c.CUSTOMER_ID,
    'CUSTOMER',
    c.CUSTOMER_NAME,
    OBJECT_CONSTRUCT_KEEP_NULL(
        'source_table', 'STRUCTURED.CUSTOMER',
        'source_id', c.CUSTOMER_ID,
        'customer_segment', c.CUSTOMER_SEGMENT,
        'customer_state', c.CUSTOMER_STATE,
        'customer_since_date', c.CUSTOMER_SINCE_DATE
    )
FROM STRUCTURED.CUSTOMER c
WHERE NOT EXISTS (
    SELECT 1 FROM KG_NODE n
    WHERE n.NODE_ID = 'CUSTOMER:' || c.CUSTOMER_ID
);

-- ============================================================================
-- 2. NODES: PRODUCT (one node per product VARIANT)
--    PRODUCT_NAME is the common product family label, e.g. Product X.
-- ============================================================================
INSERT INTO KG_NODE (NODE_ID, NODE_TYPE, NAME, PROPS)
SELECT
    'PRODUCT:' || p.PRODUCT_ID,
    'PRODUCT',
    p.PRODUCT_NAME || ' - ' || p.PRODUCT_VARIANT,
    OBJECT_CONSTRUCT_KEEP_NULL(
        'source_table', 'STRUCTURED.PRODUCT',
        'source_id', p.PRODUCT_ID,
        'product_name', p.PRODUCT_NAME,
        'product_variant', p.PRODUCT_VARIANT,
        'product_category', p.PRODUCT_CATEGORY,
        'launch_date', p.LAUNCH_DATE,
        'product_status', p.PRODUCT_STATUS
    )
FROM STRUCTURED.PRODUCT p
WHERE NOT EXISTS (
    SELECT 1 FROM KG_NODE n
    WHERE n.NODE_ID = 'PRODUCT:' || p.PRODUCT_ID
);

-- ============================================================================
-- 3. NODES: ISSUE
-- ============================================================================
INSERT INTO KG_NODE (NODE_ID, NODE_TYPE, NAME, PROPS)
SELECT
    'ISSUE:' || i.ISSUE_ID,
    'ISSUE',
    i.ISSUE_NAME,
    OBJECT_CONSTRUCT_KEEP_NULL(
        'source_table', 'STRUCTURED.ISSUE',
        'source_id', i.ISSUE_ID,
        'issue_category', i.ISSUE_CATEGORY,
        'issue_description', i.ISSUE_DESCRIPTION
    )
FROM STRUCTURED.ISSUE i
WHERE NOT EXISTS (
    SELECT 1 FROM KG_NODE n
    WHERE n.NODE_ID = 'ISSUE:' || i.ISSUE_ID
);

-- ============================================================================
-- 4. NODES: COMPLAINT
-- ============================================================================
INSERT INTO KG_NODE (NODE_ID, NODE_TYPE, NAME, PROPS)
SELECT
    'COMPLAINT:' || c.COMPLAINT_ID,
    'COMPLAINT',
    'Complaint ' || c.COMPLAINT_ID,
    OBJECT_CONSTRUCT_KEEP_NULL(
        'source_table', 'STRUCTURED.COMPLAINT',
        'source_id', c.COMPLAINT_ID,
        'complaint_date', c.COMPLAINT_DATE,
        'complaint_status', c.COMPLAINT_STATUS,
        'complaint_channel', c.COMPLAINT_CHANNEL,
        'resolution_date', c.RESOLUTION_DATE,
        'reopen_count', c.REOPEN_COUNT,
        'complaint_description', c.COMPLAINT_DESCRIPTION
    )
FROM STRUCTURED.COMPLAINT c
WHERE NOT EXISTS (
    SELECT 1 FROM KG_NODE n
    WHERE n.NODE_ID = 'COMPLAINT:' || c.COMPLAINT_ID
);

-- ============================================================================
-- 5. EDGES: CUSTOMER -> COMPLAINT (FILED)
-- ============================================================================
INSERT INTO KG_EDGE (
    EDGE_ID, SRC_ID, DST_ID, EDGE_TYPE, WEIGHT, PROPS,
    EFFECTIVE_START, EFFECTIVE_END
)
SELECT
    'FILED:' || c.COMPLAINT_ID,
    'CUSTOMER:' || c.CUSTOMER_ID,
    'COMPLAINT:' || c.COMPLAINT_ID,
    'FILED',
    1.0,
    OBJECT_CONSTRUCT(
        'source_table', 'STRUCTURED.COMPLAINT',
        'source_id', c.COMPLAINT_ID,
        'source_fk', 'CUSTOMER_ID'
    ),
    c.COMPLAINT_DATE,
    NULL
FROM STRUCTURED.COMPLAINT c
WHERE NOT EXISTS (
    SELECT 1 FROM KG_EDGE e
    WHERE e.EDGE_ID = 'FILED:' || c.COMPLAINT_ID
);

-- ============================================================================
-- 6. EDGES: COMPLAINT -> PRODUCT (ABOUT_PRODUCT)
-- ============================================================================
INSERT INTO KG_EDGE (
    EDGE_ID, SRC_ID, DST_ID, EDGE_TYPE, WEIGHT, PROPS,
    EFFECTIVE_START, EFFECTIVE_END
)
SELECT
    'ABOUT_PRODUCT:' || c.COMPLAINT_ID,
    'COMPLAINT:' || c.COMPLAINT_ID,
    'PRODUCT:' || c.PRODUCT_ID,
    'ABOUT_PRODUCT',
    1.0,
    OBJECT_CONSTRUCT(
        'source_table', 'STRUCTURED.COMPLAINT',
        'source_id', c.COMPLAINT_ID,
        'source_fk', 'PRODUCT_ID'
    ),
    c.COMPLAINT_DATE,
    NULL
FROM STRUCTURED.COMPLAINT c
WHERE NOT EXISTS (
    SELECT 1 FROM KG_EDGE e
    WHERE e.EDGE_ID = 'ABOUT_PRODUCT:' || c.COMPLAINT_ID
);

-- ============================================================================
-- 7. EDGES: COMPLAINT -> ISSUE (REPORTS_ISSUE)
-- ============================================================================
INSERT INTO KG_EDGE (
    EDGE_ID, SRC_ID, DST_ID, EDGE_TYPE, WEIGHT, PROPS,
    EFFECTIVE_START, EFFECTIVE_END
)
SELECT
    'REPORTS_ISSUE:' || c.COMPLAINT_ID,
    'COMPLAINT:' || c.COMPLAINT_ID,
    'ISSUE:' || c.ISSUE_ID,
    'REPORTS_ISSUE',
    1.0,
    OBJECT_CONSTRUCT(
        'source_table', 'STRUCTURED.COMPLAINT',
        'source_id', c.COMPLAINT_ID,
        'source_fk', 'ISSUE_ID'
    ),
    c.COMPLAINT_DATE,
    NULL
FROM STRUCTURED.COMPLAINT c
WHERE NOT EXISTS (
    SELECT 1 FROM KG_EDGE e
    WHERE e.EDGE_ID = 'REPORTS_ISSUE:' || c.COMPLAINT_ID
);

-- ============================================================================
-- 8. VALIDATION
-- ============================================================================

-- 8a. Node totals by type (expected: 20 / 10 / 10 / 100)
SELECT NODE_TYPE, COUNT(*) AS NODE_COUNT
FROM KG_NODE
GROUP BY NODE_TYPE
ORDER BY NODE_TYPE;

-- 8b. Edge totals by type (expected: 100 each)
SELECT EDGE_TYPE, COUNT(*) AS EDGE_COUNT
FROM KG_EDGE
GROUP BY EDGE_TYPE
ORDER BY EDGE_TYPE;

-- 8c. Compare structured and graph totals (expected: 140 / 300)
SELECT
    (SELECT COUNT(*) FROM KG_NODE) AS GRAPH_NODES,
    (SELECT COUNT(*) FROM KG_EDGE) AS GRAPH_EDGES,
    (SELECT COUNT(*) FROM STRUCTURED.CUSTOMER)
      + (SELECT COUNT(*) FROM STRUCTURED.PRODUCT)
      + (SELECT COUNT(*) FROM STRUCTURED.ISSUE)
      + (SELECT COUNT(*) FROM STRUCTURED.COMPLAINT) AS STRUCTURED_ROWS,
    (SELECT COUNT(*) FROM STRUCTURED.COMPLAINT) * 3 AS EXPECTED_EDGES;

-- 8d. Duplicate IDs (expected: 0 rows for each query)
SELECT NODE_ID, COUNT(*) AS OCCURRENCES
FROM KG_NODE GROUP BY NODE_ID HAVING COUNT(*) > 1;

SELECT EDGE_ID, COUNT(*) AS OCCURRENCES
FROM KG_EDGE GROUP BY EDGE_ID HAVING COUNT(*) > 1;

-- 8e. Orphan edges (expected: 0)
SELECT e.EDGE_ID, e.SRC_ID, e.DST_ID
FROM KG_EDGE e
LEFT JOIN KG_NODE src ON src.NODE_ID = e.SRC_ID
LEFT JOIN KG_NODE dst ON dst.NODE_ID = e.DST_ID
WHERE src.NODE_ID IS NULL OR dst.NODE_ID IS NULL;

-- 8f. Example: Product X linked complaints and recurring issues, 2026 Q3
-- Traversal: PRODUCT <-ABOUT_PRODUCT- COMPLAINT -REPORTS_ISSUE-> ISSUE
SELECT
    p.PROPS:product_name::VARCHAR AS PRODUCT_FAMILY,
    i.NAME AS ISSUE_NAME,
    COUNT(DISTINCT c.NODE_ID) AS COMPLAINTS
FROM KG_NODE p
JOIN KG_EDGE about_e
  ON about_e.DST_ID = p.NODE_ID AND about_e.EDGE_TYPE = 'ABOUT_PRODUCT'
JOIN KG_NODE c
  ON c.NODE_ID = about_e.SRC_ID AND c.NODE_TYPE = 'COMPLAINT'
JOIN KG_EDGE issue_e
  ON issue_e.SRC_ID = c.NODE_ID AND issue_e.EDGE_TYPE = 'REPORTS_ISSUE'
JOIN KG_NODE i
  ON i.NODE_ID = issue_e.DST_ID AND i.NODE_TYPE = 'ISSUE'
WHERE p.NODE_TYPE = 'PRODUCT'
  AND p.PROPS:product_name::VARCHAR = 'Product X'
  AND c.PROPS:complaint_date::DATE >= DATE '2026-07-01'
  AND c.PROPS:complaint_date::DATE < DATE '2026-10-01'
GROUP BY 1, 2
ORDER BY COMPLAINTS DESC, ISSUE_NAME;

-- 8g. Example: complaint neighbors, demonstrating shared source identifiers
SELECT e.EDGE_TYPE, e.SRC_ID, e.DST_ID
FROM KG_EDGE e
WHERE e.SRC_ID = 'COMPLAINT:CMP0071'
   OR e.DST_ID = 'COMPLAINT:CMP0071'
ORDER BY e.EDGE_TYPE;

-- Next stage: define shared ontology concepts and add separately sourced
-- business relationships only when supported by explicit sample evidence.
-- Do not infer a system change or supplier root cause solely from this graph.
