# Required: Create the Complaints Business Ontology

**Do this before running `08_cortex_agent.sql`.** The SQL scripts in this repository do not create Snowflake Business Ontology domains, terms, relationships, or representations. The Cortex Agent expects a native BON domain named **`Complaints`** to exist and be indexed.

## 1. Check account and role access

Use the Snowflake **`business-ontology` skill/workflow** in an account where Business Ontology is enabled. It is a private-preview feature and may not be enabled for every account. The active role needs the required ontology-domain privileges; creating a domain requires `CREATE ONTOLOGY DOMAIN`.

If the skill or feature is unavailable, stop here and ask the Snowflake account administrator to enable Business Ontology and grant access. Do not substitute the removed project `ONT_*` tables: those are a different, custom implementation.

## 2. Create or select the domain

In the native Business Ontology workflow, check for an existing **`Complaints`** domain first. Reuse it if it is the intended domain and you have the necessary rights. Otherwise create a domain named `Complaints`.

Describe its scope as the customer complaint lifecycle: customer-submitted complaints, the products involved, the reported issue types, and the related complaint communications. Keep the domain focused on business concepts; do not create a term for every column.

## 3. Create the business terms

Create and review these terms, using the descriptions below as a starting point:

| Term | Suggested meaning |
|---|---|
| `Customer` | A person or organization that holds products and may submit complaints. |
| `Product` | A product variant that may be the subject of a complaint. |
| `Issue` | A standardized category or type of problem reported in a complaint. |
| `Complaint` | A recorded customer complaint case, with a date, status, channel, and resolution details. |

Use Snowflake’s native term editor or import workflow to create them. Review descriptions and names before activating/publishing terms. Add synonyms only when they reflect language users actually use (for example, “case” for Complaint).

## 4. Define the relationships

Create directed relationships between the terms:

| Source | Relationship | Target | Intended meaning |
|---|---|---|---|
| `Customer` | `FILES` | `Complaint` | A customer files a complaint; one customer can file multiple complaints. |
| `Complaint` | `IS_ABOUT` | `Product` | A complaint concerns a product variant. |
| `Complaint` | `REPORTS` | `Issue` | A complaint reports a standardized issue. |

Check direction and cardinality against the actual business rules. The sample relational schema has one customer, one product, and one issue per complaint; real data may allow multiple products or issues, so adjust the ontology if needed.

## 5. Link terms to Snowflake assets

Add BON representations/asset associations so the definitions are grounded in this project’s data. Prefer source objects for operational records and the graph Semantic View for graph relationships:

| BON term | Suggested Snowflake representation |
|---|---|
| `Customer` | `ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED.CUSTOMER`; optionally `ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY.V_CUSTOMER` |
| `Product` | `ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED.PRODUCT`; optionally `ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY.V_PRODUCT` |
| `Issue` | `ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED.ISSUE`; optionally `ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY.V_ISSUE` |
| `Complaint` | `ENTERPRISE_CONVERSATIONAL_AI.STRUCTURED.COMPLAINT`; optionally `ENTERPRISE_CONVERSATIONAL_AI.ONTOLOGY.V_COMPLAINT` |
| `FILES`, `IS_ABOUT`, `REPORTS` relationships | Relevant relationship views `V_FILED`, `V_ABOUT_PRODUCT`, `V_REPORTS_ISSUE` and/or `ENTERPRISE_CONVERSATIONAL_AI.GRAPH.RELATIONAL_GRAPH_COMPLAINTS_SV` |

The concrete views are created by `06a_concrete_views.sql`. Run `06a` and `06b` before binding those views. If the native workflow offers semantic-view or object import, use it to discover and associate the assets; confirm the resulting bindings in the ontology UI or with the skill’s read-back command.

The email Cortex Search service (`ENTERPRISE_CONVERSATIONAL_AI.EMAILS.EMAIL_COMPLAINT_SEARCH`) is a search tool for complaint correspondence. Associate it with `Complaint` only if the ontology workflow supports that representation type and the association is accurate; do not treat the service as a replacement for the complaint record table.

## 6. Validate the domain before agent creation

In the native workflow, read the domain back and confirm:

- Domain `Complaints` exists and is available to the agent’s role.
- All four terms are active/approved with useful definitions.
- All three relationships exist with the intended direction.
- Each term is associated with the expected Snowflake asset(s), and each representation resolves.
- The BON search/index can retrieve a definition and relationship for a domain-prefixed query such as `Complaints Complaint`.

Allow time for BON indexing after changes. Do not treat a successful write response alone as proof that the terms and representations are queryable; verify them through read-back/search.

## 7. Create and test the Cortex Agent

Only after validation, configure the warehouse placeholders and run `08_cortex_agent.sql`. Its `Business_Ontology` tool searches the native `businessOntology` corpus and is instructed to prefix ontology requests with `Complaints`.

Test at least:

1. **Definition:** “Complaints: What is a complaint?”
2. **Relationship:** “Complaints: How is a customer related to a complaint?”
3. **Cross-tool:** “How many complaints are open, and find emails about those complaints.”

Confirm the first two answers are grounded in BON and the analytical/email parts use their respective data tools. The agent SQL enables the preview BON-search flag; if the account reports the corpus is disabled, stop and ask the administrator to enable the feature.

## Script order at a glance

1. Run `00_setup.sql` through `05_email_sample_data.sql` to create and load the data.
2. Run `06_semantic_views.sql`.
3. Run `06a_concrete_views.sql`.
4. Run `06b_sementaic_KG_view.sql`.
5. Run `07_cortex_search.sql` and wait for its service to become indexed/serving.
6. **Complete this guide’s native BON setup and validation.**
7. Run `08_cortex_agent.sql` and test the agent.

