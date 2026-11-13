-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 06B_SEMENTAIC_KG_VIEW.SQL
-- ============================================================================
-- Purpose: Define a Snowflake Semantic View over the graph storage objects.
--
-- Run order:
--   00_setup.sql
--   01_physical_layer.sql
--   02_sample_data.sql
--   03_graph_physical_layer.sql  <-- creates GRAPH.KG_NODE and GRAPH.KG_EDGE
--   04_graph_sample_data.sql     <-- populates those graph objects
--   06b_sementaic_KG_view.sql    <-- creates this semantic view
--
-- This file defines logical tables over the physical graph objects. It does
-- not duplicate their DDL; if either table is missing, run 03 first. The
-- properties below map to the keys populated by 04_graph_sample_data.sql.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;

-- Confirm the physical graph objects exist before defining the semantic layer.
SHOW TABLES IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.GRAPH;

-- Graph semantic model. NODE_ID and EDGE_ID are the declared logical keys.
CREATE OR REPLACE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV
  TABLES (
    nodes AS GRAPH.KG_NODE
      PRIMARY KEY (NODE_ID)
      WITH SYNONYMS ('graph nodes', 'entities')
      COMMENT = 'One row per graph entity; NODE_TYPE identifies its domain type',
    edges AS GRAPH.KG_EDGE
      PRIMARY KEY (EDGE_ID)
      WITH SYNONYMS ('graph edges', 'relationships')
      COMMENT = 'One row per directed graph relationship between two nodes'
  )
  RELATIONSHIPS (
    edges_to_source_node AS edges (SRC_ID) REFERENCES nodes,
    edges_to_target_node AS edges (DST_ID) REFERENCES nodes
  )
  FACTS (
    edges.weight AS WEIGHT
      COMMENT = 'Numeric relationship weight, defaulting to 1.0'
  )
  DIMENSIONS (
    nodes.node_id AS NODE_ID,
    nodes.node_type AS NODE_TYPE,
    nodes.name AS NODE_NAME,
    nodes.source_table AS PROPS:source_table::VARCHAR
      COMMENT = 'Structured source table for this node, when applicable',
    nodes.source_id AS PROPS:source_id::VARCHAR
      COMMENT = 'Original structured primary key for this node, when applicable',

    -- Customer properties; NULL for other node types.
    nodes.customer_segment AS PROPS:customer_segment::VARCHAR,
    nodes.customer_state AS PROPS:customer_state::VARCHAR,
    nodes.customer_since_date AS PROPS:customer_since_date::DATE,

    -- Product properties; PRODUCT nodes represent product variants.
    nodes.product_name AS PROPS:product_name::VARCHAR
      COMMENT = 'Product family name, for PRODUCT nodes',
    nodes.product_variant AS PROPS:product_variant::VARCHAR,
    nodes.product_category AS PROPS:product_category::VARCHAR,
    nodes.product_status AS PROPS:product_status::VARCHAR,
    nodes.product_launch_date AS PROPS:launch_date::DATE,

    -- Issue properties.
    nodes.issue_category AS PROPS:issue_category::VARCHAR,
    nodes.issue_description AS PROPS:issue_description::VARCHAR,

    -- Complaint properties.
    nodes.complaint_date AS PROPS:complaint_date::DATE,
    nodes.complaint_status AS PROPS:complaint_status::VARCHAR,
    nodes.complaint_channel AS PROPS:complaint_channel::VARCHAR,
    nodes.resolution_date AS PROPS:resolution_date::DATE,
    nodes.reopen_count AS PROPS:reopen_count::NUMBER,
    nodes.complaint_description AS PROPS:complaint_description::VARCHAR,

    edges.edge_id AS EDGE_ID,
    edges.src_id AS SRC_ID,
    edges.dst_id AS DST_ID,
    edges.edge_type AS EDGE_TYPE,
    edges.effective_start AS EFFECTIVE_START,
    edges.effective_end AS EFFECTIVE_END,
    edges.source_table AS PROPS:source_table::VARCHAR,
    edges.source_id AS PROPS:source_id::VARCHAR,
    edges.source_fk AS PROPS:source_fk::VARCHAR
  )
  METRICS (
    nodes.node_count AS COUNT(DISTINCT nodes.NODE_ID)
      COMMENT = 'Number of distinct graph nodes',
    edges.edge_count AS COUNT(DISTINCT edges.EDGE_ID)
      COMMENT = 'Number of distinct graph edges; use edge-specific dimensions',
    edges.edge_count_from_source_node
      USING (edges_to_source_node)
      AS COUNT(DISTINCT edges.EDGE_ID)
      COMMENT = 'Distinct outgoing edges grouped by source-node dimensions',
    edges.edge_count_to_target_node
      USING (edges_to_target_node)
      AS COUNT(DISTINCT edges.EDGE_ID)
      COMMENT = 'Distinct incoming edges grouped by target-node dimensions'
  )
  COMMENT = 'Graph inventory and typed source properties over KG_NODE and KG_EDGE. Source and target edge metrics select their respective node relationship; graph traversal remains explicit SQL over KG_EDGE.';

DESCRIBE SEMANTIC VIEW GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV;
