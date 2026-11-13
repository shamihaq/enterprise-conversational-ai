# Enterprise Conversational AI on Snowflake

This project is a runnable reference implementation for analyzing synthetic customer complaints across relational records, graph relationships, and complaint emails. It combines Snowflake tables, Semantic Views, Cortex Search, Cortex Agents, and Snowflake Business Ontology (BON).

## Architecture

- `STRUCTURED`: customers, products, issues, and complaint records.
- `GRAPH`: graph nodes and relationships derived from the structured data.
- `EMAILS`: synthetic complaint emails indexed by Cortex Search.
- `ONTOLOGY`: Semantic Views and the Cortex Agent. BON is an account-level native Business Ontology domain named `Complaints`; it is not implemented through project `ONT_*` metadata tables.

## Requirements

- A Snowflake account with access to the required Cortex features, including Cortex Agents, Cortex Search, and Business Ontology.
- A role that can create the database, schemas, tables, views, Semantic Views, Cortex Search services, and Cortex Agents, and can query the source objects.
- A warehouse available to that role.
- The BON domain `Complaints` created, populated, and indexed before creating or testing the agent. Use Snowflake's native Business Ontology workflow to create and govern its terms, relationships, and asset representations.

Feature availability and privileges vary by account. Confirm BON and agent support in your account before deployment.

## Run order

Run these scripts in Snowflake in order:

1. `00_setup.sql` — creates the project database and schemas.
2. `01_physical_layer.sql` — creates structured complaint tables.
3. `02_sample_data.sql` — loads synthetic customer, product, issue, and complaint records.
4. `03_graph_physical_layer.sql` — creates `GRAPH.KG_NODE` and `GRAPH.KG_EDGE`.
5. `04_graph_sample_data.sql` — loads graph nodes and edges from the source records.
6. `05_email_sample_data.sql` — creates and loads synthetic complaint email data.
7. `06_semantic_views.sql` — creates the relational complaint Semantic View and an initial graph Semantic View.
8. `06a_concrete_views.sql` — creates typed graph-backed entity and relationship views in `ONTOLOGY`.
9. `06b_sementaic_KG_view.sql` — creates/replaces `GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV` over the concrete views from step 8. Run this after `06_semantic_views.sql` so the typed graph model is the final definition.
10. `07_cortex_search.sql` — creates the email Cortex Search service.
11. `08_cortex_agent.sql` — creates an agent using the relational and graph Semantic Views, email search, and BON search.

The SQL files use `CREATE OR REPLACE` for some objects. Review them before rerunning in an account where those objects may already contain changes.

## Configure placeholders

Before running `07_cortex_search.sql`, replace `YOUR_WAREHOUSE_NAME` with an available warehouse name.

Before running `08_cortex_agent.sql`, replace each `<CORTEX_AGENT_WAREHOUSE>` value in the YAML agent specification with a warehouse available to the active role. The file also assumes the BON domain `Complaints` exists and is indexed. The preview BON search tool is enabled in the agent specification as required by the BON workflow used for this project; check the current feature status for your account.

## Check the deployment

After running the scripts, inspect the Semantic Views and service:

```sql
SHOW SEMANTIC VIEWS IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED;
SHOW SEMANTIC VIEWS IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.GRAPH;
SHOW CORTEX SEARCH SERVICES IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.EMAILS;
SHOW AGENTS IN SCHEMA ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY;
```

Open `COMPLAINTS_AGENT` in Snowsight under **AI & ML → Agents** and test questions that require structured complaint metrics, graph relationships, email retrieval, and BON concept definitions. BON provides governed business concepts; the Semantic Views provide analytical access to complaint data.

## Project files

| File | Purpose |
|---|---|
| `00_setup.sql` | Database and schema setup |
| `01_physical_layer.sql`, `02_sample_data.sql` | Structured complaint tables and sample records |
| `03_graph_physical_layer.sql`, `04_graph_sample_data.sql` | Graph storage and sample nodes/edges |
| `05_email_sample_data.sql`, `07_cortex_search.sql` | Email data and Cortex Search |
| `06_semantic_views.sql`, `06a_concrete_views.sql`, `06b_sementaic_KG_view.sql` | Relational and graph Semantic Views and typed graph views |
| `08_cortex_agent.sql` | Cortex Agent configuration including BON search |

