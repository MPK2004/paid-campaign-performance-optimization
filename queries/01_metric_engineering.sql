-- Engineer campaign-level performance metrics for paid traffic

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
)

SELECT *
FROM campaign_metrics
ORDER BY month, roas DESC;