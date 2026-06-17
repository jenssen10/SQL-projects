-- exploratory data analysis

select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc
;

select min(`date`), max(`date`)
from layoffs_staging2
;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry 
order by 2 desc
;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`) 
order by 1 desc
;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage 
order by 2 desc
;

select substring(`date`,6,2) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
;

with rolling_total AS
(
select substring(`date`,6,2) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)

select `MONTH`, total_off,
sum(total_off) over(order by `MONTH`) as rolling_total
from rolling_total
;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by COMPANY, year(`date`)
order by company asc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by COMPANY, year(`date`)
order by 3 desc ;

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(select *, 
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <= 5
;




SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET `date` = CASE
    WHEN `date` LIKE '%/%' THEN STR_TO_DATE(`date`, '%m/%d/%Y')
    ELSE `date`
END;

SET SQL_SAFE_UPDATES = 1;



ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT YEAR(`date`) FROM layoffs_staging2 LIMIT 10;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 1;


-- Top 5 companies laid off per year
WITH company_year_rank AS (
    SELECT 
        company, 
        YEAR(`date`) AS years, 
        SUM(total_laid_off) AS total_laid_off,
        DENSE_RANK() OVER(
            PARTITION BY YEAR(`date`) 
            ORDER BY SUM(total_laid_off) DESC
        ) AS ranking
    FROM layoffs_staging2
    WHERE YEAR(`date`) IS NOT NULL
    GROUP BY company, YEAR(`date`)
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;















