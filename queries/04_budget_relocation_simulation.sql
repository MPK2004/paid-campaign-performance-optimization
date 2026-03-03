-- Simulate 20% budget shift from lowest ROAS segment
-- to highest ROAS segment in Month 12

WITH campaign_metrics AS (

  SELECT
    traffic_source.source,
    traffic_source.name AS campaign,
    device.category,
    EXTRACT(MONTH FROM PARSE_DATE('%Y%m%d', event_date)) AS month,

    COUNTIF(event_name = 'session_start') AS sessions,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(ecommerce.purchase_revenue_in_usd) AS revenue,

    -- Simulated Spend (Assuming CPC = $0.5)
    COUNTIF(event_name = 'session_start') * 0.5 AS spend,

    SAFE_DIVIDE(
        COUNTIF(event_name = 'purchase'),
        COUNTIF(event_name = 'session_start')
    ) AS conversion_rate,

    SAFE_DIVIDE(
        COUNTIF(event_name = 'session_start') * 0.5,
        COUNTIF(event_name = 'purchase')
    ) AS cpa,

    SAFE_DIVIDE(
        SUM(ecommerce.purchase_revenue_in_usd),
        COUNTIF(event_name = 'session_start') * 0.5
    ) AS roas

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE traffic_source.medium = 'cpc'
  GROUP BY source, campaign, category, month
),

base AS (
    SELECT *,
           MIN(roas) OVER (PARTITION BY month) AS min_roas,
           MAX(roas) OVER (PARTITION BY month) AS max_roas
    FROM campaign_metrics
),

budget_shift AS (
    SELECT *,
           CASE 
             WHEN month = 12 AND roas = min_roas 
             THEN spend * 0.2
             ELSE 0
           END AS freed_budget
    FROM base
),

final_allocation AS (
    SELECT *,
           CASE 
             WHEN month = 12 AND roas = min_roas 
             THEN spend * 0.8

             WHEN month = 12 AND roas = max_roas
             THEN spend + SUM(freed_budget) OVER (PARTITION BY month)

             ELSE spend
           END AS adjusted_spend,

           CASE
             WHEN month = 12
             THEN adjusted_spend * roas
             ELSE revenue
           END AS projected_revenue

    FROM budget_shift
)

SELECT *
FROM final_allocation
ORDER BY month, adjusted_spend DESC;