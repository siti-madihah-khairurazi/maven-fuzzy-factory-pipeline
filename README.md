
# 📊 Maven Fuzzy Factory: End-to-End E-Commerce Analytics Pipeline

## 📝 Project Overview
This project delivers a production-grade business intelligence and analytics pipeline for **Maven Fuzzy Factory**, a fast-growing e-commerce retailer. Using an extensive transactional dataset, this pipeline bridges raw database ingestion, relational data modeling, and optimized view layers in SQL to serve clean, aggregated data models directly into Power BI dashboards. 

The project focuses on extracting critical performance indicators (KPIs), diagnosing conversion funnels, optimizing marketing spend efficiency, and solving complex business challenges such as revenue leakage and product sales velocity.

* **Dataset Credit:** [Maven Analytics](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database)

---

## 🛠️ Tech Stack & Architecture
* **Database Engine:** MySQL Server (Optimized using MySQL Workbench)
* **Data Pipeline Layer:** SQL Views (Decoupled abstraction layer for business logic)
* **Visualization Tool:** Power BI Desktop
* **Data Engineering Techniques:** Bulk data ingestion (`LOAD DATA LOCAL INFILE`), schema extensions, conditional aggregations, division-by-zero mitigation (`NULLIF`).

### 📐 Pipeline Flow
```text
Raw CSV Files ──> MySQL Ingestion ──> Schema Extension (Date Dimensions) ──> Analytical Views Layer ──> Power BI Engine
