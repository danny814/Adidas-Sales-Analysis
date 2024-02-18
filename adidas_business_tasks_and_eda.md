# Adidas Sales Analysis
## EDA and Business Tasks

__Author__: Daniel Perez <br />
__Email__: dannypere11@gmail.com <br />
__LinkedIn__: https://www.linkedin.com/in/danielperez12/ <br />

__1.__ What are the top/bottom selling product categories?

```sql
SELECT product,
ROUND((SUM(prof)),2) AS total_prof,
COUNT(invoicedate) AS sales_ct,
SUM(units) AS total_units
FROM ['adidas$']
GROUP BY product
ORDER BY total_units DESC
```
__Results:__

product|                    total_prof|             sales_ct|    total_units
|--------------------|-----------------------|-----------------|-----|
Men's Street Footwear |         11629045.62  |          1610   |     593320
Men's Athletic Footwear|         7437456.94  |           1610  |      435526
Women's Apparel        |         9685220.56  |           1608  |     433827
Women's Street Footwear |        6494016.81  |           1608  |      392269
Women's Athletic Footwear|       5597822.44  |           1606  |     317236
Men's Apparel            |       6381405.33 |            1606  |      306683

__2.__ What are the profit margins on the top/bottom selling 'products' compared to their min and max?

```sql
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
```

__Results:__

product | avg_margin |    min_marg |     max_marg  |     total_units  | sales | total_prof
|-------|------------|-------------|---------------|------------------|-------|-----------|
Men's Street Footwear|  0.446 |     0.25 |  0.7 |    593320  |   1610  |   11629045.62
Men's Athletic Footwear| 0.403 |    0.15 |  0.65 |   435526  |   1610  |   7437456.94
Women's Apparel|         0.441  |   0.1  |  0.8  |   433827  |   1608  |   9685220.56
Women's Street Footwear  |  0.41 |   0.25 | 0.64 |   392269  |   1608  |   6494016.81
Women's Athletic Footwear|     0.424 |  0.25 |  0.75 | 317236  |  1606 |   5597822.44
Men's Apparel|         0.413 |        0.15  |  0.77  |     306683 |   1606  |   6381405.33

__3.__ Which products have been consistently successful across the timeframe? (We'll use a month-by-month basis for this task.)

```sql
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
```

__Results:__

product     |               mnth   |     avg_monthly_prof
|----------------------|-----------|-----------------------|
Men's Street Footwear  |       1  |         905043.03
Men's Street Footwear  |       2  |         804081.63
Men's Street Footwear  |      3   |        771472.02
Men's Street Footwear  |       4  |         983480.65
Men's Street Footwear  |       5  |         1054512.28
Women's Apparel        |       6  |         923832.24
Men's Street Footwear  |       7  |         1201012.78
Men's Street Footwear  |       8  |         1191331.76
Men's Street Footwear  |       9  |         1014833.24
Women's Apparel        |      10  |        863433.05
Men's Street Footwear  |      11  |        820139.44
Men's Street Footwear  |      12  |        1170832.49

__4.__ How have profit margins changed over time?

```sql
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
```

__Results:__

product|mnth|avg_profit_margin|margin_change_percent
|-------|---|-----------------|-----------------------|
Men's Apparel|1|0.457|NULL
Men's Apparel|2|0.437|-4.438
Men's Apparel|3|0.432|-1.101
Men's Apparel|4|0.432|-0.04
Men's Apparel|5|0.435|0.698
Men's Apparel|6|0.391|-10.03
Men's Apparel|7|0.389|-0.458
Men's Apparel|8|0.391|0.286
Men's Apparel|9|0.404|3.437
Men's Apparel|10|0.395|-2.28
Men's Apparel|11|0.392|-0.768
Men's Apparel|12|0.399|1.732
Men's Athletic Footwear|1|0.375|NULL
Men's Athletic Footwear|2|0.382|1.792
Men's Athletic Footwear|3|0.391|2.443
Men's Athletic Footwear|4|0.407|3.939
Men's Athletic Footwear|5|0.399|-1.904
Men's Athletic Footwear|6|0.404|1.209
Men's Athletic Footwear|7|0.406|0.6
Men's Athletic Footwear|8|0.417|2.503
Men's Athletic Footwear|9|0.43|3.288
Men's Athletic Footwear|10|0.42|-2.393
Men's Athletic Footwear|11|0.397|-5.426
Men's Athletic Footwear|12|0.404|1.686
Men's Street Footwear|1|0.447|NULL
Men's Street Footwear|2|0.442|-1.08
Men's Street Footwear|3|0.442|0.01
Men's Street Footwear|4|0.458|3.706
Men's Street Footwear|5|0.449|-2.155
Men's Street Footwear|6|0.435|-3.03
Men's Street Footwear|7|0.432|-0.618
Men's Street Footwear|8|0.441|2.016
Men's Street Footwear|9|0.455|3.153
Men's Street Footwear|10|0.448|-1.468
Men's Street Footwear|11|0.449|0.114
Men's Street Footwear|12|0.454|1.208
Women's Apparel|1|0.384|NULL
Women's Apparel|2|0.393|2.37
Women's Apparel|3|0.41|4.413
Women's Apparel|4|0.429|4.597
Women's Apparel|5|0.43|0.092
Women's Apparel|6|0.449|4.585
Women's Apparel|7|0.456|1.531
Women's Apparel|8|0.492|7.872
Women's Apparel|9|0.503|2.3
Women's Apparel|10|0.485|-3.632
Women's Apparel|11|0.431|-11.179
Women's Apparel|12|0.43|-0.288
Women's Athletic Footwear|1|0.408|NULL
Women's Athletic Footwear|2|0.408|-0.1
Women's Athletic Footwear|3|0.417|2.25
Women's Athletic Footwear|4|0.432|3.707
Women's Athletic Footwear|5|0.427|-1.289
Women's Athletic Footwear|6|0.417|-2.286
Women's Athletic Footwear|7|0.423|1.518
Women's Athletic Footwear|8|0.442|4.478
Women's Athletic Footwear|9|0.455|2.743
Women's Athletic Footwear|10|0.435|-4.209
Women's Athletic Footwear|11|0.41|-5.754
Women's Athletic Footwear|12|0.413|0.707
Women's Street Footwear|1|0.412|NULL
Women's Street Footwear|2|0.406|-1.474
Women's Street Footwear|3|0.411|1.271
Women's Street Footwear|4|0.424|3.039
Women's Street Footwear|5|0.415|-2.163
Women's Street Footwear|6|0.396|-4.461
Women's Street Footwear|7|0.396|-0.122
Women's Street Footwear|8|0.406|2.574
Women's Street Footwear|9|0.417|2.802
Women's Street Footwear|10|0.415|-0.547
Women's Street Footwear|11|0.41|-1.267
Women's Street Footwear|12|0.41|0.096

__5.__  Is there a noticeable difference in the sales unit volumes by channel? How about over time?

```sql
SELECT DISTINCT sales_method,
YEAR(invoicedate) AS yr,
SUM(units) OVER(
	PARTITION BY sales_method
	ORDER BY YEAR(invoicedate)) AS unit_volume
FROM ['adidas$']
ORDER BY yr ASC
```

__Results:__

sales_method|yr|unit_volume
|-----------|---|---------|
Online|2020|87085
In-store|2020|156575
Outlet|2020|218689
Outlet|2021|849778
Online|2021|939093
In-store|2021|689990

__5.1__ Difference between channels over the years.

```sql
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
```

__Results:__

sales_method|yr|unit_volume|last_years|volume_change|percentage_change
|------------|---|------|------|--------|----------|
In-store|2020|156575|NULL|NULL|NULL
In-store|2021|689990|156575|533415|340.677
Online|2020|87085|NULL|NULL|NULL
Online|2021|939093|87085|852008|978.364
Outlet|2020|218689|NULL|NULL|NULL
Outlet|2021|849778|218689|631089|288.578

__6.__ What are the average units sold by product on a weekly basis?

```sql
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
```

__Results:__

product|yr|avg_units_per_week
|----|----|------------|
Men's Street Footwear|2021|9502.58
Men's Athletic Footwear|2021|6674.83
Women's Apparel|2021|6672.06
Women's Street Footwear|2021|5971.28
Women's Athletic Footwear|2021|4866.52
Men's Apparel|2021|4631.25
Men's Street Footwear|2020|1871.43
Men's Athletic Footwear|2020|1572.31
Women's Apparel|2020|1542.46
Women's Street Footwear|2020|1457.52
Women's Athletic Footwear|2020|1234.17
Men's Apparel|2020|1200.53

__7.__ Which states have seen the greatest change in profits? in sales volumes?

```sql
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
```

__Results:__

state|yr|total_profit|total_units_sold|previous_year_profit|previous_year_units|profit_change_percentage|units_change_percentage
|----|--|----------|-------------|------|--------|-------|----|
Pennsylvania|2021|580654.35|24605|49446.15|3057|1074.32|704.87
California|2021|2543052.94|140061|417098.71|23223|509.7|503.11
Texas|2021|1337738.29|69178|1494772.31|90322|-10.51|-23.41
Florida|2021|1342206.56|60295|1579387.86|73135|-15.02|-17.56
New York|2021|1220894.66|57186|2114664.41|111954|-42.27|-48.92
North Carolina|2021|1263674.12|62936|0|0|NULL|NULL
North Dakota|2021|352558.47|22781|0|0|NULL|NULL
Ohio|2021|973251.34|47781|0|0|NULL|NULL
Oklahoma|2021|620730.89|40459|0|0|NULL|NULL
Oregon|2021|1158113.75|50536|0|0|NULL|NULL
Pennsylvania|2020|49446.15|3057|0|0|NULL|NULL
Rhode Island|2021|463312.26|27473|0|0|NULL|NULL
South Carolina|2021|1469157.64|72610|0|0|NULL|NULL
South Dakota|2021|383144.46|22973|0|0|NULL|NULL
Tennessee|2021|1269585.06|66077|0|0|NULL|NULL
Texas|2020|1494772.31|90322|0|0|NULL|NULL
Colorado|2020|1000512.08|41378|0|0|NULL|NULL
Connecticut|2021|632060.79|34696|0|0|NULL|NULL
Delaware|2021|588323.81|30275|0|0|NULL|NULL
Florida|2020|1579387.86|73135|0|0|NULL|NULL
Alabama|2021|1368206.39|63327|0|0|NULL|NULL
Alaska|2021|592154.61|30815|0|0|NULL|NULL
Arizona|2021|819408.33|46919|0|0|NULL|NULL
Arkansas|2021|746290.41|48468|0|0|NULL|NULL
California|2020|417098.71|23223|0|0|NULL|NULL
Georgia|2021|1049533.36|56391|0|0|NULL|NULL
Hawaii|2021|779756.57|40375|0|0|NULL|NULL
Idaho|2021|1222558.85|63827|0|0|NULL|NULL
Illinois|2021|508648.61|25407|0|0|NULL|NULL
Indiana|2021|439574.75|26332|0|0|NULL|NULL
Iowa|2021|345626.12|23446|0|0|NULL|NULL
Kansas|2021|460373.54|29463|0|0|NULL|NULL
Kentucky|2021|514300.23|28664|0|0|NULL|NULL
Louisiana|2021|1424389.74|57615|0|0|NULL|NULL
Maine|2021|417746.87|22410|0|0|NULL|NULL
Maryland|2021|359490.87|20818|0|0|NULL|NULL
Massachusetts|2021|517402.12|32895|0|0|NULL|NULL
Michigan|2021|1050351.52|50095|0|0|NULL|NULL
Minnesota|2020|347262.26|20838|0|0|NULL|NULL
Mississippi|2021|959892.23|56814|0|0|NULL|NULL
Missouri|2021|506446.86|36404|0|0|NULL|NULL
Montana|2021|810775.05|42713|0|0|NULL|NULL
Nebraska|2021|316805.91|19154|0|0|NULL|NULL
Nevada|2020|1084651.92|51831|0|0|NULL|NULL
New Hampshire|2021|881847.679999999|40812|0|0|NULL|NULL
New Jersey|2021|476907.22|26540|0|0|NULL|NULL
New Mexico|2021|1027672.91|52633|0|0|NULL|NULL
New York|2020|2114664.41|111954|0|0|NULL|NULL
Utah|2021|588845.35|48548|0|0|NULL|NULL
Vermont|2021|875093.99|38685|0|0|NULL|NULL
Virginia|2021|1174799.43|52969|0|0|NULL|NULL
Washington|2020|927709.38|46611|0|0|NULL|NULL
West Virginia|2021|554928.72|29873|0|0|NULL|NULL
Wisconsin|2021|365126.34|23950|0|0|NULL|NULL
Wyoming|2021|856048.65|50228|0|0|NULL|NULL

For illustrative purposes, we did not limit the query to only return the top 5 from the temp table. From these results, we see that geographical analyses will prove inaccurate due to the fact that only 5 of the 50 states have more than 1 year of data. For more details, see the full TSQL log.

__8.__ Are there any seasonal or monthly trends in sales data?

```sql
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
```

__Results:__

season|yr|total_sales
|-----|---|----------|
Autumn|2021|2146
Spring|2021|2107
Summer|2021|2053
Winter|2021|2040

```sql
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
```

__Results:__

yr|mnth|total_sales|total_units
|---|---|--------|-------------|
2021|8|714|195414
2021|9|728|182425
2021|7|670|180481
2021|1|711|179299
2021|5|725|178900
2021|12|667|171246
2021|6|669|164745
2021|4|711|161717
2021|2|662|156113
2021|10|728|152834
2021|11|690|149350
2021|3|671|143988

__9.__ What are the peak days of the week and month?

```sql
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
```

__Results:__

avg_sales|avg_units|day_of_month
|------|--------|----------|
651|159038|17
569|143178|10
349|99179|16
387|97153|11
402|93904|12
330|93111|9
291|87955|5
375|87562|6
408|86974|13
358|82911|18
366|82395|24
352|81747|23
346|75897|19
261|66403|8
239|63621|4
292|62630|20
294|60340|21
264|59338|3
256|57071|14
277|54680|22
212|54287|15
222|53093|7
150|48837|2
180|43896|26
180|39641|25
90|22913|27
54|13424|1
52|13300|30
54|12958|28
52|12408|29
33|6668|31

__9.1__ Peak days of the week.

```sql
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
```

__Results:__

avg_sales|avg_units|day_of_week
|------|---------|------------|
1163|308971|Thursday
1303|308529|Tuesday
1223|305587|Friday
1156|282792|Wednesday
1230|279766|Saturday
1200|277096|Sunday
1071|253771|Monday