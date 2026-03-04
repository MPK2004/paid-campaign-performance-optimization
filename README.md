# Paid Campaign Performance Optimization using GA4 and BigQuery

## Overview

This project analyzes paid campaign performance using the Google Analytics 4 public ecommerce dataset available in BigQuery. The objective is to evaluate marketing efficiency across campaign and device segments, detect unstable performance patterns, and simulate budget reallocation strategies to improve revenue efficiency.

The analysis demonstrates how SQL can be used not only for reporting but also for structured decision-making in marketing analytics.

---

## Dataset

Source: Google BigQuery Public Dataset  
Table: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

Scope of analysis:

- Traffic source: Paid traffic only (`traffic_source.medium = 'cpc'`)
- Dimensions analyzed:
  - Campaign
  - Traffic source
  - Device category
  - Month

---

## Objectives

The project focuses on the following analytical questions:

1. How efficiently are paid campaigns converting traffic into revenue?
2. Which campaign-device segments generate the highest return on ad spend?
3. Are there unstable or statistically unreliable segments?
4. How does performance evolve month-over-month?
5. Can revenue improve through budget reallocation between segments?

---

## Methodology

### Metric Engineering

Campaign-level performance metrics were computed using aggregated event data:

- Sessions
- Purchases
- Revenue
- Simulated advertising spend (assumed CPC = $0.5)
- Conversion Rate
- Cost per Acquisition (CPA)
- Return on Ad Spend (ROAS)

SQL aggregation and conditional counting were used to generate these metrics.

---

### Segment Ranking

Device segments were ranked monthly using window functions:

- `ROW_NUMBER()` was used to rank segments by ROAS within each month.

This allowed identification of top-performing and underperforming segments.

---

### Trend Analysis

Month-over-month performance trends were evaluated using:

- `LAG()` window functions to measure ROAS changes over time.

This helped identify improving segments as well as declining performance.

---

### Stability and Confidence Analysis

To avoid misleading conclusions from small samples:

- Volume thresholds were introduced to classify segments as low, moderate, or high confidence.
- ROAS volatility was measured using standard deviation across months.
- Stability flags were created to identify structural decline versus statistical noise.

---

### Budget Reallocation Simulation

A simple optimization scenario was modeled:

- The lowest ROAS segment in Month 12 had its spend reduced by 20%.
- The freed budget was reallocated to the highest ROAS segment.
- Projected revenue impact was estimated under the assumption of constant ROAS.

This demonstrates how SQL can be used for scenario modeling in marketing optimization.

---

## Key Findings

- Desktop traffic showed consistent improvement in ROAS over time.
- Mobile performance demonstrated volatility, with a significant ROAS drop in Month 12.
- Tablet segments initially showed high ROAS but were based on very small purchase volumes.
- Budget reallocation simulation suggested potential revenue improvements if funds were shifted toward more efficient segments.

---

## Limitations

Several simplifying assumptions were made:

- Advertising spend was simulated using a fixed CPC assumption.
- ROAS was assumed constant when scaling spend.
- Statistical significance testing was not performed.
- Seasonality effects were not explicitly modeled.

These assumptions reflect common early-stage analysis scenarios but would require further validation in production environments.

---

## Skills Demonstrated

- Advanced SQL querying in BigQuery
- Window functions (ROW_NUMBER, LAG, STDDEV)
- Marketing performance analysis
- Trend detection and volatility analysis
- Budget optimization modeling
- Analytical decision framework design

---

## Repository Structure
```markdown
paid-campaign-performance-optimization/
│
├── README.md
│
├── queries/
│ ├── 01_metric_engineering.sql
│ ├── 02_ranking_and_trend_analysis.sql
│ ├── 03_stability_analysis.sql
│ └── 04_budget_reallocation_simulation.sql
│
├── results/
│ ├── monthly_segment_performance_sample.csv
│ └── budget_simulation_sample.csv
│
└── images/
└── sample_query_output.png
```

---

## Tools Used

- Google BigQuery
- SQL
- GA4 Public Dataset