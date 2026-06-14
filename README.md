#📊 Maven Fuzzy Factory – E-Commerce Analytics Project
##🧾 Overview

This project is an end-to-end e-commerce analytics solution built using MySQL and BI dashboarding.
It focuses on analysing user behaviour, marketing performance, product revenue, and conversion funnel efficiency using a structured relational database.

Dataset used is from Maven Analytics – Fuzzy Factory.

The goal of this project is to simulate real-world analytics workflow — from raw data ingestion → SQL transformation → business-ready insights.

##🎯 Project Objectives
Build a clean relational database schema for e-commerce data
Transform raw datasets into analysis-ready format
Analyse traffic sources and marketing performance
Track conversion funnel drop-off points
Identify revenue performance by product
Detect potential revenue leakage (refund impact)
Create executive-level KPI insights for decision making

##🛠️ Tech Stack
MySQL (Data Warehouse & Transformation)
SQL (Data Cleaning, Joins, Aggregations, Views)
Power BI / Dashboard Tool (Visualization Layer)
Excel (Initial data inspection)

##🗂️ Database Design & Pipeline

The project consists of 5 main tables:

website_sessions
website_pageviews
orders
order_items
products
order_item_refunds

##Key Work Done:
Data ingestion using LOAD DATA LOCAL INFILE
Timestamp cleaning & conversion to DATETIME
Schema optimization with indexing
Session-level time dimension creation
Data quality checks (duplicates, consistency validation)

##📈 Analytics Views Created

###1. Marketing Performance View
Tracks:
Sessions by channel (UTM source)
Conversion rate
Revenue per session
Traffic segmentation by device

###2. Funnel Analysis View

Breaks down user journey:

Landing → Product → Cart → Checkout → Purchase
Drop-off analysis at each stage
Session-level behavioural tracking
3. Product Revenue & Loss View

Focuses on:

Gross revenue by product
Net profit estimation
Refund impact analysis
Revenue leakage detection
📊 Dashboard Highlights
📌 Total Traffic: 473K sessions
💰 Total Revenue: $1.94M
📈 Revenue per Session: $4.10
🛒 Conversion Rate: 6.83%

##Key Insights:
Most traffic comes from search (gsearch dominant)
Clear drop-off at product → cart stage
Certain SKUs contribute higher refund risk
Conversion rate improves steadily over time
Revenue growth aligns with traffic expansion

##⚙️ How to Run This Project
Create database:
CREATE DATABASE maven_fuzzy_factory;
Run schema setup script (SQL file provided)
Import CSV files using:
LOAD DATA LOCAL INFILE
Execute analytics views:
vw_marketing_performance
vw_funnel_analysis
vw_product_revenue_loss
Connect to Power BI / Tableau for visualization

##📌 What I Learned
How real e-commerce tracking systems are structured
Building SQL pipelines like a mini data warehouse
Translating raw data into business KPIs
Funnel analysis & conversion optimization thinking
Handling messy timestamp + CSV ingestion issues

👤 Author
Madihah
Exploring Data Analytics & BI
Malaysia 🇲🇾
