                                                                Layoff Data Analysis Project
Project Overview
This project involves cleaning, analyzing, and processing corporate layoff data. The objective is to identify trends, patterns, and insights related to workforce reductions across various industries and companies. The project also includes de-duplication, data normalization, and transforming raw data into a more structured and useful format for analysis.

Project Overview
Data Cleaning Steps
SQL Queries
Results


Data Cleaning Steps
Backup and Duplicate Detection:
The raw data from the data cleaning table is backed up into a new table (layoff_backup).
Duplicate rows are identified and removed using ROW_NUMBER to ensure that only unique records are kept.

Data Normalization:
Text columns such as company, location, and industry are cleaned by trimming whitespace, removing special characters, and handling missing values.
Specific values like 'Crypto' are standardized across records.

Handling Missing Values:
Null or empty values in columns like industry, location, and percentage_laid_off are handled by filling in missing data where applicable.

Data Transformation:
The percentage_laid_off column is converted to an integer.
The date column is converted into a standard DATE format.

Removing Irrelevant Columns:
The row_no column is dropped after the cleaning process to maintain a clean and meaningful dataset.

SQL Queries
This project utilizes the following SQL queries:
Create Tables: Backup and create the necessary tables for data storage and transformation.
Data Cleaning: Remove duplicates, standardize values, and update columns.
Data Transformation: Convert data formats (e.g., string to integer or date) and handle missing values.
Aggregation & Analysis: Perform analysis such as grouping by company, industry, or year and calculating sums of layoffs.

Results
The output of this project includes:
Cleaned and normalized data with no duplicates.
Aggregated results for layoffs by company, industry, and year.
Standardized data for easy analysis and reporting.

