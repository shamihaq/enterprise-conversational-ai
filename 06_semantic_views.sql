-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 06_SEMANTIC_VIEWS.SQL
-- ============================================================================
-- Creates two native Snowflake Semantic Views:
--   RELATIONAL_COMPLAINTS_SV: structured customer/product/issue/complaint model
--   GRAPH_COMPLAINTS_SV: graph nodes and edges with typed dimensions
-- Prerequisites: 01_physical_layer.sql, 02_sample_data.sql,
--                03_graph_physical_layer.sql, 04_graph_sample_data.sql.
-- Deploy after reviewing the definitions. Native semantic views are Snowflake
-- objects; the ontology-stack-builder skill normally builds/tests these via
-- the semantic-view skill. No Cortex Search dependency in this file.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
-- Relational semantic model. Foreign keys are on COMPLAINT and point to the
-- customer, product and issue lookup entities.
CREATE OR REPLACE SEMANTIC VIEW STRUCTURED.RELATIONAL_COMPLAINTS_SV
  TABLES (
    complaints AS STRUCTURED.COMPLAINT
      PRIMARY KEY (COMPLAINT_ID)
      WITH SYNONYMS ('complaints', 'cases')
      COMMENT = 'One row per complaint case',
    customers AS STRUCTURED.CUSTOMER
      PRIMARY KEY (CUSTOMER_ID)
      COMMENT = 'Customer associated with complaint cases',
    products AS STRUCTURED.PRODUCT
      PRIMARY KEY (PRODUCT_ID)
      COMMENT = 'Product variant associated with complaint cases',
    issues AS STRUCTURED.ISSUE
      PRIMARY KEY (ISSUE_ID)
      COMMENT = 'Standardized complaint issue classification'
  )
  RELATIONSHIPS (
    complaints_to_customers AS complaints (CUSTOMER_ID) REFERENCES customers,
    complaints_to_products AS complaints (PRODUCT_ID) REFERENCES products,
    complaints_to_issues AS complaints (ISSUE_ID) REFERENCES issues
  )
  FACTS (
    complaints.reopen_count AS REOPEN_COUNT
      COMMENT = 'Number of times the complaint was reopened'
  )
  DIMENSIONS (
    complaints.complaint_id AS COMPLAINT_ID,
    complaints.complaint_date AS COMPLAINT_DATE,
    complaints.complaint_status AS COMPLAINT_STATUS,
    complaints.complaint_channel AS COMPLAINT_CHANNEL,
    complaints.resolution_date AS RESOLUTION_DATE,
    customers.customer_name AS CUSTOMER_NAME,
    customers.customer_segment AS CUSTOMER_SEGMENT,
    customers.customer_state AS CUSTOMER_STATE,
    products.product_name AS PRODUCT_NAME,
    products.product_variant AS PRODUCT_VARIANT,
    products.product_category AS PRODUCT_CATEGORY,
    products.product_status AS PRODUCT_STATUS,
    issues.issue_category AS ISSUE_CATEGORY,
    issues.issue_name AS ISSUE_NAME,
    issues.issue_description AS ISSUE_DESCRIPTION
  )
  METRICS (
    complaints.complaint_count AS COUNT(DISTINCT COMPLAINT_ID)
      COMMENT = 'Number of distinct complaint cases',
    complaints.average_reopens AS AVG(REOPEN_COUNT)
      COMMENT = 'Average reopen count per complaint'
  )
  COMMENT = 'Relational complaint analysis across customers, product variants, and issue classifications.';

-- Graph semantic model. Expose one logical node table and one edge table.
-- NODE_ID and EDGE_ID are globally unique by the ID convention in 03/04.
CREATE OR REPLACE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV
  TABLES (
    nodes AS GRAPH.KG_NODE
      PRIMARY KEY (NODE_ID)
      COMMENT = 'Graph entities; NODE_TYPE identifies CUSTOMER, PRODUCT, ISSUE, or COMPLAINT',
    edges AS GRAPH.KG_EDGE
      PRIMARY KEY (EDGE_ID)
      COMMENT = 'Directed graph relationships; SRC_ID and DST_ID refer to graph nodes'
  )
  RELATIONSHIPS (
    edges_to_source_node AS edges (SRC_ID) REFERENCES nodes (NODE_ID),
    edges_to_target_node AS edges (DST_ID) REFERENCES nodes (NODE_ID)
  )
  FACTS (
    edges.weight AS WEIGHT COMMENT = 'Relationship weight, defaulting to 1.0'
  )
  DIMENSIONS (
    nodes.node_id AS NODE_ID,
    nodes.node_type AS NODE_TYPE,
    nodes.name AS NODE_NAME,
    nodes.props AS NODE_PROPERTIES,
    edges.edge_id AS EDGE_ID,
    edges.edge_type AS EDGE_TYPE,
    edges.effective_start AS EFFECTIVE_START,
    edges.effective_end AS EFFECTIVE_END
  )
  METRICS (
    nodes.node_count AS COUNT(DISTINCT NODE_ID)
      COMMENT = 'Number of distinct graph nodes',
    edges.edge_count AS COUNT(DISTINCT EDGE_ID)
      COMMENT = 'Number of distinct graph edges'
  )
  COMMENT = 'Graph complaint model for node and relationship inventory; graph traversal remains explicit SQL over KG_EDGE.';

-- Describe both deployed semantic views and test a basic semantic query.
DESCRIBE SEMANTIC VIEW STRUCTURED.RELATIONAL_COMPLAINTS_SV;
DESCRIBE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV;

SELECT * FROM SEMANTIC_VIEW(
  STRUCTURED.RELATIONAL_COMPLAINTS_SV
  METRICS complaints.complaint_count
  DIMENSIONS products.product_name, issues.issue_name
);

-- Next: 07_cortex_search.sql.
