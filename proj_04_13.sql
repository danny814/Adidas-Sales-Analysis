-- pre cleaning

DELETE FROM ['adidas$']
WHERE invoicedate IS NULL

-- sanity check

SELECT *
FROM ['adidas$']

-- we notice that total_sales and profit have an extra decimal place
-- we'll need to fix that before moving on

ALTER TABLE ['adidas$']
	ADD total_amt AS ROUND((priceperunit * units),2),
	prof AS ROUND((margin * ROUND((priceperunit * units),2)),2)

-- sanity check

SELECT *
FROM ['adidas$']

-- dropping old cols

ALTER TABLE ['adidas$']
	DROP COLUMN total_sales, profit

-- column types in order so we move onto dupes
-- since there are no primary keys with regards to a sale entry, we'll consider two rows to be dupes if all columns have the same values

SELECT retailer, retailer_id, invoicedate,
region, [state], city, product, priceperunit, units, margin,
sales_method,
COUNT(*) AS instances
FROM ['adidas$']
GROUP BY retailer, retailer_id, invoicedate,
region, [state], city, product, priceperunit, units, margin,
sales_method
HAVING COUNT(*) > 1

-- basic eda
-- checking nvarchar categoricals for mispellings, dupes, etc

SELECT DISTINCT retailer
FROM ['adidas$']
GROUP BY retailer

-- 6 distinct retailers

SELECT DISTINCT retailer_id
FROM ['adidas$']
GROUP BY retailer_id

-- 4 distinct ids

SELECT DISTINCT retailer,
COUNT(DISTINCT retailer_id) AS ids
FROM ['adidas$']
GROUP BY retailer

-- each retailer has between a count of 1-4 ids

-- min/max invoicedate

SELECT MIN(invoicedate) AS min_timeframe,
MAX(invoicedate) AS max_timeframe
FROM ['adidas$']

-- timeframe begins Jan 01, 2020 and ends Dec 31, 2021
-- two years of data

SELECT DISTINCT region
FROM ['adidas$']
GROUP BY region

-- 5 regions

SELECT DISTINCT [state]
FROM ['adidas$']
GROUP BY [state]
ORDER BY [state]

-- 50 distinct states containing data

SELECT DISTINCT(city)
FROM ['adidas$']
GROUP BY city

-- only 52 cities... might be more useful to group by state if some states have
-- an unfair advantage of 2 or more cities

SELECT DISTINCT(product)
FROM ['adidas$']
GROUP BY product

-- products are actually just product categories... obscures the granularity we were going for
-- but we can still perform an analysis

SELECT MIN(priceperunit) AS minprice,
MAX(priceperunit) AS maxprice,
ROUND((STDEV(priceperunit)),2) AS stdevprice,
ROUND((AVG(priceperunit)),2) AS avgprice
FROM ['adidas$']

-- products priceperunit quartile distribution

SELECT product,
	MIN(priceperunit) AS minimum,
	MAX(CASE WHEN quartile = 1 THEN priceperunit END) AS quartile1,
	MAX(CASE WHEN quartile = 2 THEN priceperunit END) AS median,
	MAX(CASE WHEN quartile = 3 THEN priceperunit END) AS quartile3,
	MAX(priceperunit) AS maximum,
	COUNT(quartile) AS count
FROM (
	SELECT product,
	priceperunit,
	NTILE(4) OVER (PARTITION BY product ORDER BY priceperunit) AS quartile
	FROM ['adidas$']
) vals
GROUP BY product
ORDER BY product

-- products units quartile distribution

SELECT product,
	MIN(units) AS minimum,
	MAX(CASE WHEN quartile = 1 THEN units END) AS quartile1,
	MAX(CASE WHEN quartile = 2 THEN units END) AS median,
	MAX(CASE WHEN quartile = 3 THEN units END) AS quartile3,
	MAX(units) AS maximum,
	COUNT(quartile) AS count
FROM (
	SELECT product,
	units,
	NTILE(4) OVER (PARTITION BY product ORDER BY units) AS quartile
	FROM ['adidas$']
) vals
GROUP BY product
ORDER BY product

-- we see some entries where a total of units were ordered

SELECT *
FROM ['adidas$']
WHERE units = 0

-- definitely strange but valid enough

-- products total_amt quartile distribution

SELECT product,
	MIN(total_amt) AS minimum,
	MAX(CASE WHEN quartile = 1 THEN total_amt END) AS quartile1,
	MAX(CASE WHEN quartile = 2 THEN total_amt END) AS median,
	MAX(CASE WHEN quartile = 3 THEN total_amt END) AS quartile3,
	MAX(total_amt) AS maximum,
	COUNT(quartile) AS count
FROM (
	SELECT product,
	total_amt,
	NTILE(4) OVER (PARTITION BY product ORDER BY total_amt) AS quartile
	FROM ['adidas$']
) vals
GROUP BY product
ORDER BY product

-- q1: what are the top/bottom selling 'products'?

SELECT product
ROUND((SUM(prof)),2) AS total_prof,
COUNT(invoicedate) AS sales_ct,
SUM(units) AS total_units
FROM ['adidas$']
GROUP BY product
ORDER BY total_units DESC

-- q2: what are the profit margins on the top/bottom selling 'products' compared to their min and max?

SELECT product,
ROUND((AVG(margin)),3) AS avg_margin,
MIN(margin) AS min_marg,
MAX(margin) AS max_marg,
SUM(units) AS total_units,
COUNT(invoicedate) AS sales,
ROUND((SUM(prof)),2) AS total_prof
FROM ['adidas$']
GROUP BY product
ORDER BY total_units DESC

-- q3: which products have consistently been successful across the timeframe?

WITH totals AS
(
SELECT
product,
MONTH(invoicedate) AS mnth,
SUM(prof) AS monthly_prof
FROM ['adidas$']
GROUP BY product, MONTH(invoicedate)
),

monthly_avgs AS
(
SELECT
product,
mnth,
ROUND(AVG(monthly_prof), 2) AS avg_monthly_prof
FROM totals
GROUP BY product, mnth
),

ranked_products AS
(
SELECT
product,
mnth,
avg_monthly_prof,
RANK() OVER (
	PARTITION BY mnth 
	ORDER BY avg_monthly_prof DESC) AS rnk
FROM monthly_avgs
)

SELECT
product,
mnth,
avg_monthly_prof
FROM ranked_products
WHERE rnk = 1
ORDER BY mnth

-- q4: how have profit margins changed over time?

WITH prof_margins AS
(
SELECT
product,
MONTH(invoicedate) AS mnth,
AVG(margin) AS avg_profit_margin
FROM ['adidas$']
GROUP BY product, MONTH(invoicedate)
),

changeinmargins AS
(
SELECT
product,
mnth,
avg_profit_margin,
LAG(avg_profit_margin) OVER (
						PARTITION BY product 
						ORDER BY mnth) AS prev_margin
FROM prof_margins
)

SELECT
product,
mnth,
ROUND((avg_profit_margin),3) AS avg_profit_margin,
ROUND(CASE WHEN prev_margin IS NOT NULL THEN ((avg_profit_margin - prev_margin) / prev_margin) * 100
     ELSE NULL
     END,3) AS margin_change_percent
FROM changeinmargins
ORDER BY product, mnth

-- q5: is there a noticeable difference in the sales unit volumes by channel? how about over time?

SELECT DISTINCT sales_method,
YEAR(invoicedate) AS yr,
SUM(units) OVER(
	PARTITION BY sales_method
	ORDER BY YEAR(invoicedate)) AS unit_volume
FROM ['adidas$']
ORDER BY yr ASC

-- 5.1 difference between channels over the years

WITH totals AS 
(
SELECT DISTINCT sales_method,
YEAR(invoicedate) AS yr,
SUM(units) OVER(
	PARTITION BY sales_method
	ORDER BY YEAR(invoicedate)) AS unit_volume
FROM ['adidas$']
),

lag_totals AS 
(
SELECT sales_method,
unit_volume,
yr,
LAG(unit_volume) OVER (
	PARTITION BY sales_method
	ORDER BY yr) AS last_years
FROM totals
)

SELECT
sales_method,
yr,
unit_volume,
last_years,
CASE WHEN last_years IS NOT NULL THEN (unit_volume - last_years)
     ELSE NULL
     END AS volume_change,
ROUND(CASE WHEN last_years IS NOT NULL AND last_years != 0 THEN ((unit_volume - last_years) / last_years) * 100
     ELSE NULL
     END,3) AS percentage_change
FROM lag_totals
ORDER BY sales_method, yr


-- q6: what are the average units sold by product on a weekly basis?

WITH totals AS 
(
SELECT product,
DATEPART(wk, invoicedate) AS wek,
YEAR(invoicedate) AS yr,
SUM(units) AS total_units
FROM ['adidas$']
GROUP BY product, DATEPART(wk,invoicedate), YEAR(invoicedate)
)

SELECT product,
yr,
ROUND((AVG(total_units)),2) AS avg_units_per_week
FROM totals
GROUP BY product, yr
ORDER BY yr DESC, avg_units_per_week DESC

-- q7: which states have seen the greatest change in profits? in sales volumes?

WITH totals AS
(
SELECT [state],
YEAR(invoicedate) AS yr,
SUM(prof) AS profit,
SUM(units) AS total_units
FROM ['adidas$']
GROUP BY [state], YEAR(invoicedate)
)

SELECT [state],
yr,
SUM(profit) AS total_profit,
SUM(total_units) AS total_units_sold,
LAG(SUM(profit), 1, 0) OVER (PARTITION BY [state] ORDER BY yr) AS previous_year_profit,
LAG(SUM(total_units), 1, 0) OVER (PARTITION BY [state] ORDER BY yr) AS previous_year_units
INTO #temp
FROM totals
GROUP BY [state], yr;

SELECT [state],
yr,
total_profit,
total_units_sold,
previous_year_profit,
previous_year_units,
ROUND((CASE WHEN previous_year_profit = 0 THEN NULL
     ELSE ((total_profit - previous_year_profit) / previous_year_profit) * 100
     END),2) AS profit_change_percentage,
ROUND((CASE WHEN previous_year_units = 0 THEN NULL
     ELSE ((total_units_sold - previous_year_units) / previous_year_units) * 100
     END),2) AS units_change_percentage
FROM #temp
ORDER BY profit_change_percentage DESC, units_change_percentage DESC


-- getting rid of temp table

DROP TABLE #temp;

-- weird results, we'll check to see

SELECT [state],
COUNT(*) AS instances
FROM ['adidas$']
GROUP BY state
HAVING COUNT(DISTINCT(YEAR(invoicedate))) = 2

-- just as we suspected... only 5 states have two years of data, so of course they would be the top 5 changes for the last question

SELECT [state],
COUNT(DISTINCT MONTH(invoicedate)) AS mnths,
YEAR(invoicedate) AS yr
FROM ['adidas$']
GROUP BY [state], YEAR(invoicedate)
ORDER BY mnths DESC, yr DESC

-- we can still use yearly changes in margins, etc., but probably not at the state level of granularity

-- q8: which retailer has been the most successful? in what region are they primarily located?

-- probably shouldn't do this question simply due to the face that the results will be inaccurate

-- q9: how have online sales performed over the timeframe?

-- see 5.1

-- q10: are there any seasonal or monthly trends in sales?

WITH sns AS
(
SELECT MONTH(invoicedate) AS mnth,
YEAR(invoicedate) AS yr,
CASE WHEN MONTH(invoicedate) IN(3, 4, 5) THEN 'Spring'
WHEN MONTH(invoicedate) IN(6, 7, 8) THEN 'Summer'
WHEN MONTH(invoicedate) IN(9, 10, 11) THEN 'Autumn'
WHEN MONTH(invoicedate) IN(12, 1, 2) THEN 'Winter' END AS season,
COUNT(invoicedate) AS num_sales
FROM ['adidas$']
WHERE YEAR(invoicedate) = 2021 -- this is because hardly any states have data for the year 2020
GROUP BY MONTH(invoicedate), YEAR(invoicedate)
)

SELECT season,
yr,
SUM(num_sales) AS total_sales
FROM sns
GROUP BY yr, season
ORDER BY total_sales DESC

-- some large discrepancies due to the missing data

WITH mons AS
(
SELECT MONTH(invoicedate) AS mnth,
YEAR(invoicedate) AS yr,
COUNT(invoicedate) AS num_sales,
SUM(units) AS total_units
FROM ['adidas$']
WHERE YEAR(invoicedate) = 2021
GROUP BY MONTH(invoicedate), YEAR(invoicedate)
)

SELECT yr,
mnth,
SUM(num_sales) AS total_sales,
SUM(total_units) AS total_units
FROM mons
GROUP BY yr, mnth
ORDER BY total_units DESC

-- seems fairly uniform across the board when examining total_sales,
-- but the total_units change vastly by month

-- q11: what are the peak days of the week and month?

WITH totals AS
(
SELECT DAY(invoicedate) AS day_of_month,
COUNT(invoicedate) AS sales,
SUM(units) AS total_units
FROM ['adidas$']
WHERE YEAR(invoicedate) = 2021
GROUP BY DAY(invoicedate)
)

SELECT AVG(sales) AS avg_sales,
AVG(total_units) AS avg_units,
day_of_month
FROM totals
GROUP BY day_of_month
ORDER BY avg_units DESC

-- 11.1 peak days of week

WITH totals AS
(
SELECT DATENAME(dw, invoicedate) AS day_of_week,
COUNT(invoicedate) AS sales,
SUM(units) AS total_units
FROM ['adidas$']
WHERE YEAR(invoicedate) = 2021
GROUP BY DATENAME(dw,invoicedate)
)

SELECT AVG(sales) AS avg_sales,
AVG(total_units) AS avg_units,
day_of_week
FROM totals
GROUP BY day_of_week
ORDER BY avg_units DESC