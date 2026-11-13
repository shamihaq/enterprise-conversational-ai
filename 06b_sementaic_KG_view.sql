-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 06B_SEMENTAIC_KG_VIEW.SQL
-- ============================================================================
-- Purpose: Define a Snowflake Semantic View over the concrete typed entity and
-- relationship views created by ontology_stack/02_concrete_views.sql.
--
-- Run order:
--   00_setup.sql
--   01_physical_layer.sql
--   02_sample_data.sql
--   03_graph_physical_layer.sql  <-- creates GRAPH.KG_NODE and GRAPH.KG_EDGE
--   04_graph_sample_data.sql     <-- populates those graph objects
--   06a_concrete_views.sql          <-- creates V_{CLASS}/V_{REL} views
--   06b_sementaic_KG_view.sql    <-- creates this semantic view
--
-- This file does not create physical or concrete views. Run the prerequisites
-- above first. BON carries governed definitions; this semantic view supports
-- analytical queries against the concrete graph-backed views.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;

-- Confirm the physical graph objects exist before defining the semantic layer.
SHOW TABLES IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.GRAPH;

-- Model each entity and relationship type explicitly, preserving typed
-- attributes and endpoint meanings for Cortex Analyst.
CREATE OR REPLACE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV
  TABLES (
    customers AS ONTOLOGY.V_CUSTOMER
      PRIMARY KEY (NODE_ID)
      COMMENT = 'One graph-backed customer entity',
    products AS ONTOLOGY.V_PRODUCT
      PRIMARY KEY (NODE_ID)
      COMMENT = 'One graph-backed product variant entity',
    issues AS ONTOLOGY.V_ISSUE
      PRIMARY KEY (NODE_ID)
      COMMENT = 'One graph-backed complaint issue entity',
    complaints AS ONTOLOGY.V_COMPLAINT
      PRIMARY KEY (NODE_ID)
      COMMENT = 'One graph-backed complaint entity',
    filed AS ONTOLOGY.V_FILED
      PRIMARY KEY (SRC_ID, DST_ID)
      COMMENT = 'Customer-to-complaint FILED relationship',
    about_product AS ONTOLOGY.V_ABOUT_PRODUCT
      PRIMARY KEY (SRC_ID, DST_ID)
      COMMENT = 'Complaint-to-product ABOUT_PRODUCT relationship',
    reports_issue AS ONTOLOGY.V_REPORTS_ISSUE
      PRIMARY KEY (SRC_ID, DST_ID)
      COMMENT = 'Complaint-to-issue REPORTS_ISSUE relationship'
  )
  RELATIONSHIPS (
    filed_customer AS filed (SRC_ID) REFERENCES customers (NODE_ID),
    filed_complaint AS filed (DST_ID) REFERENCES complaints (NODE_ID),
    product_complaint AS about_product (SRC_ID) REFERENCES complaints (NODE_ID),
    product_entity AS about_product (DST_ID) REFERENCES products (NODE_ID),
    issue_complaint AS reports_issue (SRC_ID) REFERENCES complaints (NODE_ID),
    issue_entity AS reports_issue (DST_ID) REFERENCES issues (NODE_ID)
  )
  FACTS (
    filed.weight AS WEIGHT,
    about_product.weight AS WEIGHT,
    reports_issue.weight AS WEIGHT,
    complaints.reopen_count AS REOPEN_COUNT
  )
  DIMENSIONS (
    customers.name AS CUSTOMER_NAME,
    customers.customer_segment AS CUSTOMER_SEGMENT,
    customers.customer_state AS CUSTOMER_STATE,
    customers.customer_since_date AS CUSTOMER_SINCE_DATE,
    products.name AS PRODUCT_LABEL,
    products.product_name AS PRODUCT_NAME,
    products.product_variant AS PRODUCT_VARIANT,
    products.product_category AS PRODUCT_CATEGORY,
    products.product_status AS PRODUCT_STATUS,
    products.launch_date AS PRODUCT_LAUNCH_DATE,
    issues.name AS ISSUE_NAME,
    issues.issue_category AS ISSUE_CATEGORY,
    issues.issue_description AS ISSUE_DESCRIPTION,
    complaints.name AS COMPLAINT_NAME,
    complaints.complaint_date AS COMPLAINT_DATE,
    complaints.complaint_status AS COMPLAINT_STATUS,
    complaints.complaint_channel AS COMPLAINT_CHANNEL,
    complaints.resolution_date AS RESOLUTION_DATE,
    complaints.complaint_description AS COMPLAINT_DESCRIPTION,
    filed.src_id AS FILED_CUSTOMER_ID,
    filed.dst_id AS FILED_COMPLAINT_ID,
    filed.effective_start AS FILED_EFFECTIVE_START,
    filed.effective_end AS FILED_EFFECTIVE_END,
    about_product.src_id AS PRODUCT_COMPLAINT_ID,
    about_product.dst_id AS RELATED_PRODUCT_ID,
    reports_issue.src_id AS ISSUE_COMPLAINT_ID,
    reports_issue.dst_id AS RELATED_ISSUE_ID
  )
  METRICS (
    customers.customer_count AS COUNT(DISTINCT customers.NODE_ID),
    products.product_count AS COUNT(DISTINCT products.NODE_ID),
    issues.issue_count AS COUNT(DISTINCT issues.NODE_ID),
    complaints.complaint_count AS COUNT(DISTINCT complaints.NODE_ID),
    filed.filed_count AS COUNT(DISTINCT filed.SRC_ID || '|' || filed.DST_ID),
    about_product.about_product_count AS COUNT(DISTINCT about_product.SRC_ID || '|' || about_product.DST_ID),
    reports_issue.reports_issue_count AS COUNT(DISTINCT reports_issue.SRC_ID || '|' || reports_issue.DST_ID)
  )
  COMMENT = 'Typed customer complaint graph model over concrete entity and relationship views. Use for complaint-to-customer, product, and issue analytics.';

DESCRIBE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV;
