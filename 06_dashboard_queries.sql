
-- =====================================================
-- PROJECT: Retail Sales & Inventory Intelligence
-- STEP 6: Dashboard Charts and KPI Queries
-- PLATFORM: Snowflake
-- =====================================================


-- =====================================================
-- CHART 1: MONTHLY SALES PERFORMANCE
-- Excludes months without complete calendar-date coverage
-- =====================================================

WITH MONTHLY_SALES AS (
    SELECT
        DATE_TRUNC('MONTH', DATE) AS SALES_MONTH,
        ROUND(SUM(ESTIMATED_NET_SALES), 2)
            AS MONTHLY_SALES,
        COUNT(DISTINCT DATE) AS DAYS_AVAILABLE
    FROM RETAIL_DB.ANALYTICS.DAILY_SALES
    GROUP BY DATE_TRUNC('MONTH', DATE)
)
SELECT
    SALES_MONTH,
    MONTHLY_SALES
FROM MONTHLY_SALES
WHERE DAYS_AVAILABLE = DAY(LAST_DAY(SALES_MONTH))
ORDER BY SALES_MONTH;


-- =====================================================
-- CHART 2: TOP 10 BEST-SELLING PRODUCTS
-- =====================================================

SELECT
    PRODUCT_ID,
    TOTAL_UNITS_SOLD
FROM RETAIL_DB.ANALYTICS.PRODUCT_PERFORMANCE
ORDER BY TOTAL_UNITS_SOLD DESC
LIMIT 10;


-- =====================================================
-- CHART 3: INVENTORY STOCK STATUS DISTRIBUTION
-- =====================================================

SELECT
    STOCK_STATUS,
    COUNT(*) AS TOTAL_PRODUCTS
FROM RETAIL_DB.ANALYTICS.LATEST_INVENTORY
GROUP BY STOCK_STATUS
ORDER BY TOTAL_PRODUCTS DESC;


-- =====================================================
-- CHART 4: STORE-WISE SALES PERFORMANCE
-- =====================================================

SELECT
    STORE_ID,
    ROUND(SUM(ESTIMATED_NET_SALES), 2)
        AS TOTAL_SALES
FROM RETAIL_DB.ANALYTICS.DAILY_SALES
GROUP BY STORE_ID
ORDER BY TOTAL_SALES DESC;


-- =====================================================
-- CHART 5: INVENTORY VALUE BY PRODUCT CATEGORY
-- =====================================================

SELECT
    CATEGORY,
    ROUND(SUM(ESTIMATED_INVENTORY_VALUE), 2)
        AS INVENTORY_VALUE
FROM RETAIL_DB.ANALYTICS.LATEST_INVENTORY
GROUP BY CATEGORY
ORDER BY INVENTORY_VALUE DESC;


-- =====================================================
-- KPI 1: TOTAL ESTIMATED SALES
-- =====================================================

SELECT
    ROUND(SUM(ESTIMATED_NET_SALES), 2)
        AS TOTAL_ESTIMATED_SALES
FROM RETAIL_DB.ANALYTICS.DAILY_SALES;


-- =====================================================
-- KPI 2: INVENTORY DAYS OF SUPPLY
-- Based on the last 30 calendar days of sales
-- =====================================================

WITH SNAPSHOT AS (
    SELECT
        MAX(DATE) AS SNAPSHOT_DATE,
        SUM(INVENTORY_LEVEL) AS STOCK_UNITS
    FROM RETAIL_DB.ANALYTICS.LATEST_INVENTORY
),
SALES_30_DAYS AS (
    SELECT
        SUM(C.UNITS_SOLD) / 30.0 AS AVG_DAILY_SALES
    FROM RETAIL_DB.CLEAN.RETAIL_INVENTORY_CLEAN C
    CROSS JOIN SNAPSHOT S
    WHERE C.DATE > DATEADD(DAY, -30, S.SNAPSHOT_DATE)
      AND C.DATE <= S.SNAPSHOT_DATE
)
SELECT
    ROUND(
        S.STOCK_UNITS /
        NULLIF(A.AVG_DAILY_SALES, 0), 1
    ) AS INVENTORY_DAYS_OF_SUPPLY
FROM SNAPSHOT S
CROSS JOIN SALES_30_DAYS A;


-- =====================================================
-- KPI 3: AVAILABLE STOCK UNITS
-- =====================================================

SELECT
    SUM(INVENTORY_LEVEL) AS AVAILABLE_STOCK_UNITS
FROM RETAIL_DB.ANALYTICS.LATEST_INVENTORY;


-- =====================================================
-- KPI 4: AVERAGE DAILY UNITS SOLD
-- =====================================================

SELECT
    ROUND(
        SUM(UNITS_SOLD) /
        NULLIF(COUNT(DISTINCT DATE), 0), 0
    ) AS AVG_DAILY_UNITS_SOLD
FROM RETAIL_DB.CLEAN.RETAIL_INVENTORY_CLEAN;
