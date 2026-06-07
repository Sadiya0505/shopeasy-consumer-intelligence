-- ============================================================
-- 02_cleaning_transformation.sql
-- ShopEasy Consumer Intelligence Project
-- Purpose: Clean and transform all 3 tables into final form
-- ============================================================

USE ShopEasy;

-- ============================================================
-- SECTION 1: CLEAN customer_journey
-- ============================================================
-- What we're doing:
-- 1. Remove any logical duplicates (even though we found 0,
--    this is best practice — always build the safety net)
-- 2. Standardise Stage casing with UPPER() just in case
-- 3. Preserve NULL Duration — do NOT fill it in
--    (NULLs here are intentional: they mean the customer
--     dropped off and no time was recorded)

-- Drop the cleaned table if it already exists (so we can re-run safely)
IF OBJECT_ID('customer_journey_cleaned', 'U') IS NOT NULL
    DROP TABLE customer_journey_cleaned;

-- Create the cleaned table using a CTE with ROW_NUMBER()
-- ROW_NUMBER() numbers each row within a group of duplicates
-- We keep only row_num = 1 (the first occurrence), discard the rest
WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
            ORDER BY JourneyID
        ) AS row_num
    FROM customer_journey
)
SELECT
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    -- UPPER() makes sure all Stage values are consistently capitalised
    UPPER(LEFT(Stage,1)) + LOWER(SUBSTRING(Stage,2,LEN(Stage))) AS Stage,
    Action,
    Duration   -- NULLs are kept exactly as-is on purpose
INTO customer_journey_cleaned
FROM deduped
WHERE row_num = 1;  -- only keep the first of any duplicate group

-- Verify
SELECT COUNT(*) AS cleaned_journey_rows FROM customer_journey_cleaned;


-- ============================================================
-- SECTION 2: CLEAN customer_reviews
-- ============================================================
-- What we're doing:
-- 1. TRIM whitespace from ReviewText (leading/trailing spaces)
-- 2. Standardise any spacing inside the text
-- 3. Keep all 1363 rows — no duplicates to remove here

IF OBJECT_ID('customer_reviews_cleaned', 'U') IS NOT NULL
    DROP TABLE customer_reviews_cleaned;

SELECT
    ReviewID,
    CustomerID,
    ProductID,
    ReviewDate,
    Rating,
    -- LTRIM removes spaces from the LEFT side of the text
    -- RTRIM removes spaces from the RIGHT side
    -- REPLACE removes any double-spaces inside the text
    LTRIM(RTRIM(REPLACE(ReviewText, '  ', ' '))) AS ReviewText
INTO customer_reviews_cleaned
FROM customer_reviews;

-- Verify
SELECT COUNT(*) AS cleaned_reviews_rows FROM customer_reviews_cleaned;


-- ============================================================
-- SECTION 3: CLEAN engagement_data
-- ============================================================
-- This is the most important transformation:
-- We split "2023-155" into two separate integer columns
-- Views = everything BEFORE the dash
-- Clicks = everything AFTER the dash
-- This is called "column splitting" — a very common analyst task

IF OBJECT_ID('engagement_data_cleaned', 'U') IS NOT NULL
    DROP TABLE engagement_data_cleaned;

SELECT
    EngagementID,
    ContentID,
    -- Standardise ContentType casing just in case
    UPPER(LEFT(ContentType,1)) + LOWER(SUBSTRING(ContentType,2,LEN(ContentType))) 
        AS ContentType,
    -- Extract Views: everything to the LEFT of the dash character
    CAST(
        LEFT(ViewsClicksCombined, 
             CHARINDEX('-', ViewsClicksCombined) - 1) 
    AS INT) AS Views,
    -- Extract Clicks: everything to the RIGHT of the dash character
    CAST(
        RIGHT(ViewsClicksCombined,
              LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined))
    AS INT) AS Clicks,
    Likes,
    EngagementDate
INTO engagement_data_cleaned
FROM engagement_data;

-- Verify
SELECT COUNT(*) AS cleaned_engagement_rows FROM engagement_data_cleaned;


-- ============================================================
-- SECTION 4: VERIFY ALL CLEANED TABLES
-- ============================================================

-- Final row count summary
SELECT 'customer_journey_cleaned'  AS table_name, COUNT(*) AS rows FROM customer_journey_cleaned
UNION ALL
SELECT 'customer_reviews_cleaned',                COUNT(*)         FROM customer_reviews_cleaned
UNION ALL
SELECT 'engagement_data_cleaned',                 COUNT(*)         FROM engagement_data_cleaned;

-- Preview the split columns — confirm Views and Clicks are now separate integers
SELECT TOP 5
    EngagementID,
    ContentType,
    Views,
    Clicks,
    Likes,
    EngagementDate
FROM engagement_data_cleaned;

-- Preview journey cleaned table
SELECT TOP 5 * FROM customer_journey_cleaned;

-- Preview reviews cleaned table
SELECT TOP 5 * FROM customer_reviews_cleaned;

SELECT 'Cleaning complete! 3 cleaned tables are ready.' AS status;