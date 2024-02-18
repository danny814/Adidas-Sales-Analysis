# Adidas Sales Analysis

## Analysis-Based Recommendations

### 1. Sales Performance Analysis

__1.0 Reallocate resources to popular product categories.__ <br />
The top three selling product categories are as follows:

product|                    total_prof|             sales_ct|    total_units
|--------------------|-----------------------|-----------------|-----|
Men's Street Footwear |         11629045.62  |          1610   |     593320
Men's Athletic Footwear|         7437456.94  |           1610  |      435526
Women's Apparel        |         9685220.56  |           1608  |     433827

Resources should be reevaluated to cater to these three categories; the company should invest more into the development and marketing of successful product lines within these three categories to maximize potential.

__1.1 Profit Margin Reevaluation__ <br />
The top three earning categories also sell the most units.

product | avg_margin |    min_marg |     max_marg  |     total_units  | sales | total_prof
|-------|------------|-------------|---------------|------------------|-------|-----------|
Men's Street Footwear|  0.446 |     0.25 |  0.7 |    593320  |   1610  |   11629045.62
Men's Athletic Footwear| 0.403 |    0.15 |  0.65 |   435526  |   1610  |   7437456.94
Women's Apparel|         0.441  |   0.1  |  0.8  |   433827  |   1608  |   9685220.56

The average margins on these categories leaves much to be desired. We should consider marketing products with higher margins within these categories, or experiment with raising the prices of products with lower margins within these categories in the next quarter to maximize profits and minimize costs. Consistently successful products within these categories should see margin increases with new releases.

### 2. Inventory Optimization

__2.0 Demand Forecasting__ <br />

Predictive analytics should be implemented in the near future to anticipate demand and minimize waste. A simple regressional model can serve as the basis for each region/state, with a more refined/complex model being implemented as more data and features are collected. Different models should be tested for each region. The shelf life of products should be assessed both before and after implementing such a model to quantify its impact and reassess the model's performance as necessary.

__2.1 Planning for the online shift__ <br />
From the data available, sales through online retailers have seen an explosion in the last year alone (978% increase).

sales_method|yr|unit_volume|last_years|volume_change|percentage_change
|------------|---|------|------|--------|----------|
In-store|2020|156575|NULL|NULL|NULL
In-store|2021|689990|156575|533415|340.677
Online|2020|87085|NULL|NULL|NULL
Online|2021|939093|87085|852008|978.364
Outlet|2020|218689|NULL|NULL|NULL
Outlet|2021|849778|218689|631089|288.578

Budgets towards marketing by channel should be reflective of these changes. Online behaviors of customers both on the retailers' sites and through email should be collected and assessed. By focusing our efforts on the online experience of customers, we can capitalize on the increase in online sales. Consider making online-only promotions, email-exclusive coupons, and early access to sales for those subscribed to the email list.

### 3. Geographic Performance

__3.0 Improving the quality of geographic data.__

The lack of data across regions and states shows room for improvement. This missing data is preventing us from finding region-specific trends, region-specific seasonal trends, and a more refined marketing strategy. We are also unable to find which state/city saw the most change in profits/volumes over a given timeframe, and therefore cannot examine which states are performing the best or are most affected by the shift to online sales. We strongly recommend fixing this to improve our future analyses as soon as possible. <br />

Once we have a more granular regional analysis, we can begin to:
* Tailor marketing strategies to be region/state specific
* Prioritizing top-selling distributors/retailers for exclusives, promotions
* Customize product assortments based on regional preference
* Explore partnerships with region-specific organizations to enhance brand visibility and create more identity-based product lines

### 4. Seasonal Trends

__4.0 Seasonal fluctuations__ <br />

Inventory levels should incorporate both predictive analytics as well as a seasonal compenent to align with seasonal fluctuations in demand (i.e. winter holiday shopping, back to school shopping, season-specific sports equipment and athleisure). We should collaborate with marketing teams to create seasonal-based ad campaigns and related promotions centered around these periods.<br />

Peak days of the week/month should also be capitalized on, with seasonal promotions beginning around these days to promote the most sales.