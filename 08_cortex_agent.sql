-- ============================================================================
-- ENTERPRISE CONVERSATIONAL AI - 08_CORTEX_AGENT.SQL
-- ============================================================================
-- Creates a Cortex Agent over the structured and graph semantic views,
-- complaint email Cortex Search, and native Snowflake Business Ontology (BON).
--
-- Prerequisites:
--   06_semantic_views.sql
--   07_cortex_search.sql (service indexed and serving)
--   BON domain 'Complaints' populated and indexed in the Snowflake account
--   An active warehouse and a role with CREATE AGENT, semantic-view, table,
--   and Cortex Search privileges.
-- Replace both warehouse placeholders below before running.
-- ============================================================================

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;
USE SCHEMA ONTOLOGY;

CREATE OR REPLACE AGENT ONTOLOGY.COMPLAINTS_AGENT
  COMMENT = 'Conversational assistant for customer complaints across relational, graph, ontology, and email data.'
  PROFILE = '{"display_name": "Complaints Data Assistant"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  instructions:
    response: "Answer clearly and concisely. Use the configured data tools for questions about this project. Distinguish facts found in complaint emails from structured complaint records. Ground business concept definitions and relationships in the Complaints Business Ontology domain. Start every ontology search query with the domain name Complaints. Do not invent graph paths or relationships that are not returned by the tools."
    orchestration: "Use Structured_Complaints_Analyst for complaint, customer, product, issue, status, and metric questions over relational tables. Use Graph_Complaints_Analyst for graph node and edge inventory questions. Use Business_Ontology for business concept definitions, governed relationships, and ontology context; prefix its query with Complaints. Use Complaint_Email_Search for email text and correspondence. Combine tools when comparing structured complaint data with email evidence."
    sample_questions:
      - question: "How many complaints are open by product?"
      - question: "Find emails about delayed refunds and summarize the customer concerns."
      - question: "Complaints: What does a complaint mean and how is it related to a customer?"

  experimental:
    EnableSnowscopeBusinessOntologySearch: true

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "Structured_Complaints_Analyst"
        description: "Answers structured complaint, customer, product, and issue questions using the relational semantic view."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "Graph_Complaints_Analyst"
        description: "Answers questions about graph nodes, edge types, and graph inventory using the graph semantic view."
    - tool_spec:
        type: "cortex_search"
        name: "Complaint_Email_Search"
        description: "Finds relevant complaint email content and returns the associated complaint identifiers and email attributes."
    - tool_spec:
        type: "snowscope_search"
        name: "Business_Ontology"
        description: "Searches the native Snowflake Business Ontology for governed business concept definitions and relationships in the Complaints domain."

  tool_resources:
    Structured_Complaints_Analyst:
      semantic_view: "ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED.RELATIONAL_COMPLAINTS_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "<CORTEX_AGENT_WAREHOUSE>"
    Graph_Complaints_Analyst:
      semantic_view: "ENTERPRISE_CONVERSATIONAL_AI.GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "<CORTEX_AGENT_WAREHOUSE>"
    Complaint_Email_Search:
      search_service: "ENTERPRISE_CONVERSATIONAL_AI.EMAILS.EMAIL_COMPLAINT_SEARCH"
      max_results: "5"
    Business_Ontology:
      corpus: "businessOntology"
  $$;

-- Before running, replace <CORTEX_AGENT_WAREHOUSE> in both
-- tool_resources blocks with a warehouse name available to the active role.
-- Snowflake agent specifications are YAML text and do not interpolate SQL
-- variables.

DESCRIBE AGENT ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY.COMPLAINTS_AGENT;
SHOW AGENTS LIKE 'COMPLAINTS_AGENT' IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY;

-- After creation, open COMPLAINTS_AGENT in Snowsight > AI & ML > Agents and
-- test the sample questions. The app can also invoke this object with the
-- Cortex Agents Run API using the agent object reference.
