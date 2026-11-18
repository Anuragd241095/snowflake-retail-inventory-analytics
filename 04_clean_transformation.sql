
-- =====================================================
-- Project: Retail Sales & Inventory Intelligence
-- Step 4: Data Cleaning and Transformation
-- =====================================================

-- Create CLEAN schema if it does not exist
CREATE SCHEMA IF NOT EXISTS RETAIL_DB.CLEAN;

-- Create cleaned inventory table
CREATE TABLE IF NOT EXISTS
RETAIL_DB.CLEAN.RETAIL_INVENTORY_CLEAN AS

SELECT
    DATE,
    STORE_ID,
    PRODUCT_ID,
    CATEGORY,
    REGION,
    INVENTORY_LEVEL,
    UNITS_SOLD,
    UNITS_ORDERED,

    -- Preserve original demand forecast
    DEMAND_FORECAST AS ORIGINAL_DEMAND_FORECAST,

    -- Convert negative forecasts to zero
    GREATEST(DEMAND_FORECAST, 0) AS DEMAND_FORECAST,

    PRICE,
    DISCOUNT,
    WEATHER_CONDITION,
    HOLIDAY_PROMOTION,
    COMPETITOR_PRICING,
    SEASONALITY

FROM RETAIL_DB.RAW.RETAIL_INVENTORY;


-- =====================================================
-- Validate the cleaned dataset
-- =====================================================

SELECT
    COUNT(*) AS TOTAL_RECORDS,

    COUNT_IF(DEMAND_FORECAST < 0)
        AS NEGATIVE_FORECASTS,

    COUNT_IF(ORIGINAL_DEMAND_FORECAST < 0)
        AS ADJUSTED_RECORDS

FROM RETAIL_DB.CLEAN.RETAIL_INVENTORY_CLEAN;
