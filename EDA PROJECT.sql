-- EDA

SELECT *
FROM layoffs_staging2;

-- FINDING OUTLIERS

SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- NOW WE LOOK AT TO SEE HOW BIG THESE LAYOFFS WERE IN PERCENTAGE

SELECT MAX(percentage_laid_off),MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;


-- COMPANY WITH 1% LAID OFF IS BASCIALLY 100% OF COMPANY IS LAID


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = '1';

-- THESE COMPANY ARE MOSTLY STARTUPS AND THEY WERE OUT OF BUSSINESS BECAUSE OF INFLATION

-- WE CAN ORDER BY THEM FUUNDS RAISED TO FIND THE SIZE OF THE COMPANY

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = '1'
ORDER BY funds_raised_millions desc;



-- MOSTLY USING GROUP BY
-- COMPANY WITH BIGGEST SINGLE LAYOFFS

SELECT company,total_laid_off
FROM layoffs_staging2
ORDER BY 2 DESC
LIMIT 1;

-- COMPANY WITH THE MOST TOTAL LAYOFFS

SELECT company, sum(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


-- BY LOCATION

SELECT location , sum(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;



-- THIS IS TOTAL IN THE PAST YEAR IN THE DATASET


SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;


SELECT YEAR(DATE), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(DATE)
ORDER BY 1 ASC;

SELECT industry,SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT stage,SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- NOW LETS RANK THESE COMPANIES BY LAYOFFS


WITH company_year as
(
	SELECT 	company,YEAR(date) AS YEARS ,SUM(total_laid_off) AS total_laid_off
    FROM world_layoffs.layoffs_staging2
    GROUP BY company,YEAR(date)
)
, company_year_rank AS 
(
	SELECT  company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- ROLLING TOTAL LAYOFFS PER MONTH 

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
