-- ============================================================
-- 01_Data_Validation.sql
-- ShopEasy Consumer Intelligence Project
-- Purpose: Audit all 3 tables before cleaning
-- ============================================================

USE ShopEasy;

-- ============================================================
-- SECTION 1: ROW COUNTS (baseline check)
-- ============================================================
-- First thing any analyst does — confirm how many rows exist

SELECT 'customer_journey' AS table_name, COUNT(*) AS total_rows 
FROM customer_journey
UNION ALL
SELECT 'customer_reviews', COUNT(*) 
FROM customer_reviews
UNION ALL
SELECT 'engagement_data',  COUNT(*) 
FROM engagement_data;


-- ============================================================
-- SECTION 2: DUPLICATE DETECTION (customer_journey)
-- ============================================================
-- JourneyID is a Primary Key so it can't have technical duplicates
-- BUT a customer could have the same visit recorded twice (logical duplicate)
-- We use ROW_NUMBER() to find these

-- What is ROW_NUMBER()? 
-- It numbers each row within a group. If two rows are identical 
-- in CustomerID + ProductID + VisitDate + Stage + Action,
-- the second one gets number 2 — that's a duplicate!

SELECT 
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COUNT(*) AS duplicate_count
FROM customer_journey
GROUP BY CustomerID, ProductID, VisitDate, Stage, Action
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Now count exactly how many duplicate rows exist using ROW_NUMBER()
WITH duplicates AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
            ORDER BY JourneyID
        ) AS row_num
    FROM customer_journey
)
SELECT COUNT(*) AS duplicate_rows_to_remove
FROM duplicates
WHERE row_num > 1;


-- ============================================================
-- SECTION 3: NULL VALUE CHECK
-- ============================================================
-- Check which columns have missing values and how many

-- customer_journey nulls
SELECT
    SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS null_customerid,
    SUM(CASE WHEN ProductID   IS NULL THEN 1 ELSE 0 END) AS null_productid,
    SUM(CASE WHEN VisitDate   IS NULL THEN 1 ELSE 0 END) AS null_visitdate,
    SUM(CASE WHEN Stage       IS NULL THEN 1 ELSE 0 END) AS null_stage,
    SUM(CASE WHEN Action      IS NULL THEN 1 ELSE 0 END) AS null_action,
    SUM(CASE WHEN Duration    IS NULL THEN 1 ELSE 0 END) AS null_duration
FROM customer_journey;

-- customer_reviews nulls
SELECT
    SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS null_customerid,
    SUM(CASE WHEN ProductID   IS NULL THEN 1 ELSE 0 END) AS null_productid,
    SUM(CASE WHEN Rating      IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN ReviewText  IS NULL THEN 1 ELSE 0 END) AS null_reviewtext
FROM customer_reviews;

-- engagement_data nulls
SELECT
    SUM(CASE WHEN ContentType          IS NULL THEN 1 ELSE 0 END) AS null_contenttype,
    SUM(CASE WHEN ViewsClicksCombined  IS NULL THEN 1 ELSE 0 END) AS null_combined,
    SUM(CASE WHEN Likes                IS NULL THEN 1 ELSE 0 END) AS null_likes
FROM engagement_data;


-- ============================================================
-- SECTION 4: CASING ISSUES (the sneaky problem)
-- ============================================================
-- "View" and "view" look the same to humans but SQL treats them differently
-- COLLATE Latin1_General_CS_AS makes SQL case-SENSITIVE so we can catch this

-- Check Stage column in customer_journey
SELECT DISTINCT Stage
FROM customer_journey
ORDER BY Stage;

-- Now use COLLATE to find hidden case variants
SELECT 
    Stage,
    COUNT(*) AS occurrences
FROM customer_journey
GROUP BY Stage
ORDER BY Stage COLLATE Latin1_General_CS_AS;

-- Check ContentType in engagement_data
SELECT 
    ContentType,
    COUNT(*) AS occurrences
FROM engagement_data
GROUP BY ContentType
ORDER BY ContentType COLLATE Latin1_General_CS_AS;


-- ============================================================
-- SECTION 5: WHITESPACE CHECK (customer_reviews)
-- ============================================================
-- Extra spaces before/after text cause silent matching failures
-- LTRIM/RTRIM removes them — but first let's find if they exist

SELECT COUNT(*) AS reviews_with_whitespace
FROM customer_reviews
WHERE ReviewText != LTRIM(RTRIM(ReviewText));


-- ============================================================
-- SECTION 6: COMBINED COLUMN CHECK (engagement_data)
-- ============================================================
-- ViewsClicksCombined stores "1500-300" — views and clicks smashed together
-- We need to verify the format before splitting it

SELECT TOP 10
    ViewsClicksCombined,
    -- Extract the part BEFORE the dash = Views
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS views_extracted,
    -- Extract the part AFTER the dash = Clicks
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS clicks_extracted
FROM engagement_data;


-- ============================================================
-- SECTION 7: RATING RANGE CHECK (customer_reviews)
-- ============================================================
-- Ratings should only be 1 to 5 — catch anything outside that range

SELECT 
    Rating,
    COUNT(*) AS count
FROM customer_reviews
GROUP BY Rating
ORDER BY Rating;

-- Any invalid ratings?
SELECT COUNT(*) AS invalid_ratings
FROM customer_reviews
WHERE Rating < 1 OR Rating > 5;


-- ============================================================
-- VALIDATION SUMMARY
-- ============================================================
SELECT 'Run complete - review each result set above' AS status;