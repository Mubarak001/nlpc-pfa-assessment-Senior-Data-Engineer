-- Task 2: SCD Type 2 – Asset Register Data Ingestion
-- Source: stg_assets (staging) | Target: dim_assets (dimension)
-- Handles: new inserts, change detection, effective dating, IsCurrent flag

BEGIN TRANSACTION;

-- STEP 1: Expire changed records 
UPDATE dim_assets
SET 
    EffectiveTo = CAST(GETDATE() AS DATE),
    IsCurrent   = 0
FROM dim_assets d
INNER JOIN stg_assets s ON d.AssetID = s.AssetID
WHERE d.IsCurrent = 1
  AND (
        d.AssetName      <> s.AssetName      OR
        d.AssetCategory  <> s.AssetCategory  OR
        d.Location       <> s.Location       OR
        d.AssignedTo     <> s.AssignedTo     OR
        d.AssetValue     <> s.AssetValue
      );

-- STEP 2: Insert new versions for changed records and net-new assets
INSERT INTO dim_assets (
    AssetID, AssetName, AssetCategory,
    Location, AssignedTo, AssetValue,
    EffectiveFrom, EffectiveTo, IsCurrent
)
SELECT
    s.AssetID,
    s.AssetName,
    s.AssetCategory,
    s.Location,
    s.AssignedTo,
    s.AssetValue,
    CAST(GETDATE() AS DATE) AS EffectiveFrom,
    '2100-12-31'            AS EffectiveTo,
    1                       AS IsCurrent
FROM stg_assets s
WHERE NOT EXISTS (
    SELECT 1 FROM dim_assets d
    WHERE d.AssetID    = s.AssetID
      AND d.IsCurrent    = 1
      AND d.AssetName      = s.AssetName
      AND d.AssetCategory  = s.AssetCategory
      AND d.Location       = s.Location
      AND d.AssignedTo     = s.AssignedTo
      AND d.AssetValue     = s.AssetValue
);

COMMIT TRANSACTION;
