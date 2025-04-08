-- View the original data from the `data cleaning` table
SELECT *
FROM `data cleaning`;

-- Create a backup table with the same structure as `data cleaning`
CREATE TABLE analyst_project.layoff_backup
LIKE `data cleaning`;

-- Verify the structure of the backup table
SELECT *
FROM analyst_project.layoff_backup;

-- Copy all data from the original to the backup table
INSERT INTO analyst_project.layoff_backup
SELECT *
FROM `data cleaning`;

-- Confirm data was successfully copied to backup
SELECT *
FROM analyst_project.layoff_backup;

-- Identify duplicate rows based on specific columns using ROW_NUMBER
WITH CTE_cleaning AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
		) AS row_no
	FROM layoff_backup
)
SELECT *
FROM CTE_cleaning
WHERE row_no > 1;  -- These are duplicates

-- Attempt to delete duplicates (note: this query won't work in some SQL environments like MySQL)
-- Alternative method shown below using a temp table
WITH CTE_cleaning AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
		) AS row_no
	FROM layoff_backup
)
DELETE
FROM layoff_backup
WHERE EXISTS (
    SELECT 1
    FROM CTE_cleaning
    WHERE layoff_backup.id = CTE_cleaning.id
    AND CTE_cleaning.row_no > 1
);

-- Create another backup table with an additional row_no column
CREATE TABLE `layoff_backup2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_no` INT   
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- View structure of new backup table
SELECT *
FROM analyst_project.layoff_backup2;

-- Insert data with row_no to identify duplicates again
INSERT INTO analyst_project.layoff_backup2
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
	) AS row_no
FROM layoff_backup;

-- View contents of updated table
SELECT *
FROM analyst_project.layoff_backup2;

-- Find duplicates using row_no
SELECT *
FROM analyst_project.layoff_backup2
WHERE row_no > 1;

-- Disable safe updates for delete
SET SQL_SAFE_UPDATES = 0;

-- Re-enable safe updates after deletion
SET SQL_SAFE_UPDATES = 1;

-- Remove duplicate records
DELETE
FROM analyst_project.layoff_backup2
WHERE row_no > 1;

-- View company names
SELECT company
FROM analyst_project.layoff_backup2;

-- Trim whitespace from company names
UPDATE analyst_project.layoff_backup2
SET company = TRIM(company);

-- Remove non-alphanumeric characters from company names
UPDATE analyst_project.layoff_backup2
SET company = REGEXP_REPLACE(company, '[^a-zA-Z0-9]', '');

-- Explore unique locations
SELECT DISTINCT location
FROM analyst_project.layoff_backup2
ORDER BY location ASC;

-- (This insert seems like a mistake, it's re-inserting just locations)
-- Fixing to just update instead of re-insert locations
-- INSERT INTO analyst_project.layoff_backup2 (location)
-- SELECT location FROM analyst_project.layoff_backup; -- Removed

-- Check updated locations
SELECT DISTINCT location
FROM analyst_project.layoff_backup2
ORDER BY location ASC;

-- Invalid DELETE syntax - should be corrected or replaced
-- DELETE location FROM analyst_project.layoff_backup2; -- Removed

-- Truncate the table (removes all rows, resets auto_increment)
TRUNCATE TABLE analyst_project.layoff_backup2;

-- Remove special characters from locations
UPDATE analyst_project.layoff_backup2
SET location = REGEXP_REPLACE(COALESCE(location, ''), '[^a-zA-Z0-9 ]', '');

-- Remove odd character (possibly due to encoding issue)
UPDATE analyst_project.layoff_backup2
SET location = REPLACE(location, '¼', '');

-- Check industry values
SELECT DISTINCT industry
FROM analyst_project.layoff_backup2
ORDER BY 1;

-- Find rows with "Crypto"-related industries
SELECT *
FROM analyst_project.layoff_backup2
WHERE industry LIKE 'Crypto%';

-- Normalize all crypto industries under one label
UPDATE analyst_project.layoff_backup2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check updated industries
SELECT DISTINCT industry
FROM analyst_project.layoff_backup2;

-- Clean country column
SELECT DISTINCT country
FROM analyst_project.layoff_backup2
ORDER BY 1;

UPDATE analyst_project.layoff_backup2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Explore stage values
SELECT DISTINCT stage
FROM analyst_project.layoff_backup2
ORDER BY 1;

-- View unique total layoffs
SELECT DISTINCT total_laid_off
FROM analyst_project.layoff_backup2
ORDER BY 1;

-- View unique percentage layoffs
SELECT DISTINCT percentage_laid_off
FROM analyst_project.layoff_backup2
ORDER BY 1;

-- Change percentage_laid_off column to integer format
ALTER TABLE analyst_project.layoff_backup2
MODIFY COLUMN percentage_laid_off INT;

-- Check date values
SELECT DISTINCT date
FROM analyst_project.layoff_backup2
ORDER BY 1;

-- Convert date format for inspection
SELECT `date`,
	STR_TO_DATE(`date`, '%m/%d/%y') AS Date
FROM analyst_project.layoff_backup2;

-- Update date format in the table
UPDATE analyst_project.layoff_backup2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change date column type to DATE
ALTER TABLE analyst_project.layoff_backup2
MODIFY COLUMN `date` DATE;

-- Final check of cleaned data
SELECT *
FROM analyst_project.layoff_backup2;

-- Check for missing industry values
SELECT *
FROM layoff_backup2 
WHERE industry IS NULL OR industry = '';

-- Attempt to find matching companies with valid industry info
SELECT *
FROM layoff_backup2 t1
JOIN layoff_backup2 t2
	ON t1.company = t2.company
	AND t1.industry = t1.industry
WHERE t1.industry IS NULL OR t1.industry = ''
	AND t2.industry IS NOT NULL;

-- Set blank industry to NULL
UPDATE layoff_backup2
SET industry = NULL
WHERE industry = '';

-- Fill in missing industry data based on other records of the same company
UPDATE layoff_backup2 t1
JOIN layoff_backup2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Check specific company data
SELECT *
FROM layoff_backup2
WHERE company = 'airbnb';

-- Remove rows where both percentage and total layoffs are NULL
DELETE 
FROM layoff_backup2
WHERE percentage_laid_off IS NULL
	AND total_laid_off IS NULL;

-- Drop the row_no column after de-duplication is complete
ALTER TABLE layoff_backup2
DROP COLUMN row_no;

-- Final view of cleaned dataset
SELECT *
FROM layoff_backup2;
