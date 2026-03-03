-- Detect unstable segments using volume and volatility signals

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

trend_analysis AS (

  SELECT
    *,

    ROW_NUMBER() OVER (
        PARTITION BY month
        ORDER BY roas DESC
    ) AS roas_rank,

    LAG(roas) OVER (
        PARTITION BY campaign, category
        ORDER BY month
    ) AS prev_month_roas,

    roas - LAG(roas) OVER (
        PARTITION BY campaign, category
        ORDER BY month
    ) AS mom_roas_change

  FROM campaign_metrics
),

stability AS (

  SELECT
    *,

    CASE 
      WHEN purchases < 10 THEN 'Low Volume'
      WHEN purchases BETWEEN 10 AND 30 THEN 'Moderate Volume'
      ELSE 'High Volume'
    END AS volume_confidence,

    STDDEV(roas) OVER (
        PARTITION BY campaign, category
    ) AS roas_volatility,

    CASE 
      WHEN mom_roas_change < -0.5 AND purchases > 20
           THEN 'Structural Decline'

      WHEN mom_roas_change < -0.5 AND purchases < 10
           THEN 'Volatile / Low Data'

      ELSE 'Stable'
    END AS stability_flag

  FROM trend_analysis
)

SELECT *
FROM stability
ORDER BY campaign, category, month;