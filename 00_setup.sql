-- ================================================================
-- ENTERPRISE CONVERSATIONAL AI - 00_SETUP.SQL
-- ================================================================
-- Purpose:
--   Initialise the Snowflake database and logical schemas for the
--   Enterprise Conversational AI reference implementation.
--
-- Architecture:
--   STRUCTURED : Customer complaints 3NF relational tables
--   GRAPH      : Knowledge graph nodes, edges and relationship views
--   EMAILS     : Synthetic complaint emails and search assets
--   ONTOLOGY   : Business concepts, relationship definitions and mappings
--
-- Prerequisites:
--   Run with a role that can CREATE DATABASE and CREATE SCHEMA.
--   Use an existing warehouse for subsequent data loads and queries.
--
-- Safe to re-run: IF NOT EXISTS preserves existing objects and data.
-- ================================================================

-- 1. Create the project database.
CREATE DATABASE IF NOT EXISTS ENTERPRISE_CONVERSATIONAL_AI
  COMMENT = 'Synthetic customer complaints reference implementation for structured, graph and email-based conversational AI';

USE DATABASE ENTERPRISE_CONVERSATIONAL_AI;

-- 2. Create schemas aligned to the three data sources and ontology.
CREATE SCHEMA IF NOT EXISTS STRUCTURED
  COMMENT = '3NF customer, product, issue and complaint relational tables';

CREATE SCHEMA IF NOT EXISTS GRAPH
  COMMENT = 'Knowledge graph node, edge and relationship objects';

CREATE SCHEMA IF NOT EXISTS EMAILS
  COMMENT = 'Synthetic complaint email content and Cortex Search supporting objects';

CREATE SCHEMA IF NOT EXISTS ONTOLOGY
  COMMENT = 'Shared business concepts, relationship definitions and source mappings';

-- 3. Set the default context for the next script (structured tables).
USE SCHEMA STRUCTURED;

-- 4. Verify the active context and available schemas.
SELECT CURRENT_DATABASE() AS DATABASE_NAME,
       CURRENT_SCHEMA() AS SCHEMA_NAME,
       CURRENT_ROLE() AS ACTIVE_ROLE,
       CURRENT_WAREHOUSE() AS ACTIVE_WAREHOUSE;

SHOW SCHEMAS IN DATABASE ENTERPRISE_CONVERSATIONAL_AI;

-- Next: sql/01_physical_layer.sql
-- Creates CUSTOMER, PRODUCT, ISSUE and COMPLAINT in STRUCTURED.
