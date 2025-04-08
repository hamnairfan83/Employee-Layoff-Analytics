-- Select all companies with 100% layoffs and sort them by funds raised
SELECT *
FROM layoff_backup2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions;

-- Total layoffs by company, sorted by company name in descending order
SELECT company, SUM(total_laid_off)
FROM layoff_backup2
GROUP BY company
ORDER BY 1 DESC;

-- Total layoffs by industry, sorted by industry name in descending order
SELECT industry, SUM(total_laid_off)
FROM layoff_backup2
GROUP BY industry
ORDER BY 1 DESC;

-- Total layoffs per year based on the `date` column
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_backup2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;  -- Sort by total laid off, descending

-- Total layoffs by month (MM format from date), excluding NULL values
SELECT SUBSTRING(`date`, 6, 2) AS Month, SUM(total_laid_off)
FROM layoff_backup2
WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL
GROUP BY Month
ORDER BY 2 DESC;

-- PRACTICE: Try calculating rolling total of layoffs per month
WITH rolling_total AS (
	SELECT SUBSTRING(`date`, 6, 2) AS `Month`, SUM(total_laid_off)
	FROM layoff_backup2
	WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL
	GROUP BY `Month`
)
-- Attempting to calculate a cumulative (rolling) sum of layoffs over months
SELECT `Month`, total_laid_off,
	SUM(total_laid_off) OVER (ORDER BY CAST(`Month` AS UNSIGNED)) AS rolling_total 
FROM rolling_total
ORDER BY 1 DESC;

-- IMPROVED VERSION: Rolling total per month with correct aggregation
WITH rolling_total AS (
    SELECT 
        SUBSTRING(`date`, 6, 2) AS `Month`, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoff_backup2
    WHERE `date` IS NOT NULL
    GROUP BY `Month`
)
-- Display monthly layoffs and their rolling (cumulative) total
SELECT 
    `Month`, 
    total_laid_off,
    SUM(total_laid_off) OVER (ORDER BY CAST(`Month` AS UNSIGNED)) AS rolling_total
FROM rolling_total
ORDER BY CAST(`Month` AS UNSIGNED) ASC;

-- Create a temporary table of company-year layoffs with correct grouping
WITH company_year AS (
    SELECT 
        company, 
        YEAR(`date`) AS year,  -- Extract year from the date
        SUM(total_laid_off) AS total_laid_off  -- Sum layoffs for each company-year
    FROM layoff_backup2
    WHERE `date` IS NOT NULL  -- Ensuring there are no NULL dates
    GROUP BY company, YEAR(`date`)  -- Grouping by both company and year
)
-- View the company-year layoffs table
SELECT *
FROM company_year;

-- PRACTICE TEST: Identify top companies by layoffs per year with rankings
WITH company_year AS (
    SELECT 
        company, YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_laid_off 
    FROM layoff_backup2
    WHERE `date` IS NOT NULL
    GROUP BY company, YEAR(`date`)
)
-- Rank companies per year by total_laid_off in descending order
SELECT *,
	DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS Ranking 
FROM company_year
WHERE year IS NOT NULL  -- Ensuring no NULL years
ORDER BY Ranking ASC;

-- FINAL VERSION: Same as above, with clearer aliases and correct aggregation
WITH company_year AS (
    SELECT 
        company, 
        YEAR(`date`) AS year,  -- Extract year from the date
        SUM(total_laid_off) AS total_laid_off  -- Aggregating total_laid_off
    FROM layoff_backup2
    WHERE `date` IS NOT NULL  -- Ensuring no NULL dates
    GROUP BY company, YEAR(`date`)  -- Grouping by both company and year
)
-- Get ranking of companies by layoffs within each year
SELECT *,
       DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS Ranking 
FROM company_year
WHERE year IS NOT NULL  -- Fixed column name
ORDER BY Ranking ASC;
