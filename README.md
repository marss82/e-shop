# e-shop executive summary

## Project Background

This project analyses revenue growth across all product categories for a fictional e-shop over a two-year period (2024–2025), with the goal of identifying high-level trends to support business decision-making.

Insights and recommendations are provided on the following areas:

- Which product categories and markets drove the strongest revenue growth
- How marketing channels shifted in 2025 and what that means for customer acquisition
- Where refund risk is concentrated and what anomalies require further investigation
- How discounts and coupons affect net revenue and customer behavior

SQL cleaning queries can be found [there](https://github.com/marss82/e-shop/blob/main/data_cleaning.sql)

SQL explortion queries can be found [there](https://github.com/marss82/e-shop/blob/main/exploration.sql)

## Data Structure & Initial Checks

We have ~29 000 order records for 2 years period

1. cleaning and transforming data with SQL
2. exploration with SQL

## Executive summary

#### Overview of Findings

The e-shop grew strongly in 2025, with net revenue up 24% to €52M and orders up 18%. Customer retention is a clear strength — 89% of customers returned for a second purchase. All five categories and four markets grew, with Sports leading at +29% revenue growth. The following sections explore channel shifts, discount effectiveness, and a notable electronics refund spike that warrants further investigation.

#### Orders and Revenue

|                           | 2024      | 2025          |
| ---                       | ---       | ---           |
| net revenue               | ~41.8M    | ~52M (+24%)   |
| orders                    | ~13 300   | ~15 700 (+18%)|
| average revenue per order | ~3 100    | ~3 300 (+5%)  |
| new customers             | ~4 800    | ~5 500 (+14%) |
| refunds                   | ~3.4%     | ~3.9% (+0.5%) |

- 89% of customers placed 2 or more orders. The average number of orders per customer over 2 years is 3.5, with an average of 1.5 units per order.
- We serve customers across 4 countries: Czech Republic (62%), Slovakia (18%), Germany (13%), and Austria (7%). Growth is consistent across all markets.
- November and December show 1.5–2x spikes in orders, new customers, and revenue, with even larger peaks in 2025. This is followed by a slowdown in January and February, with a similarly quiet summer period.
- Most orders are placed on mobile devices, a trend that strengthened significantly in 2025.
- The highest revenue growth by category is Sports (+29%), the lowest is Home (+19%).

|               | Revenue growth YoY     | Refund rate |
| ---           | ---                    | ---         |
| Sports        | +29%                   | 3.2%        |
| Beauty        | +27%                   | 3.7%        |
| Fashion       | +25%                   | 3.3%        |
| Electronics   | +24%                   | 5.1%        |
| Home          | +19%                   | 3.3%        |


#### Refunds

- Refund activity peaks in November and December alongside order volume, but — unlike general orders — there is also elevated activity in January and May.
- Electronics saw a more significant spike: 3x more returned orders in November 2025, with the average refund value nearly doubling to €6,176.
- The range of refund values suggests it was not a single product but likely a broader campaign that brought in customers who were not the right fit for the items they purchased.


#### Marketing channels 

|               | 2024 revenue channels | 2025 revenue channels | orders % in 2025 |
| ---           | ---                   | ---                   | ---              |
| organic       | 28%                   | 26%                   | 25%              |
| paid search   | 13.5%                 | 23.5%                 | 23%              |
| direct        | 19.5%                 | 17%                   | 17%              |
| email         | 12%                   | 11%                   | 12%              |
| affiliate     | 9.3%                  | 9%                    | 9%               |
| paid social   | 9%                    | 13.5%                 | 14.6%            |


- Organic, paid search, and direct remain the leading channels by both orders and revenue.
- Email applies the highest average discount (10%), which reduces net revenue from those orders.
- Paid social grew its share notably in 2025, generating 1.5–2x more monthly orders throughout the year with peaks in January, February, and November. However, orders in January, March, and October came with a lower average order value.
- Paid social also increased its share of new customer acquisition by 5.5 percentage points.

#### Discounts and Coupons

- Discounted orders come primarily from organic and paid search, both of which have a healthy refund rate of 3.6%.
- The affiliate channel has the highest refund rate at 5%, despite having the fewest orders overall.
- Orders with larger discounts (20%+) have a lower refund rate (2%) compared to lightly discounted orders (3–4%). The 1–10% discount tier has both the highest order volume and the highest refund rate.
- Coupon users receive an average 18% discount versus 5% for non-coupon orders, resulting in 15% lower net revenue per order.
- All coupons are used relatively evenly throughout the year but peak in November and December — which does not align with their seasonal names such as "Spring" or "BF2025", suggesting customers apply available codes opportunistically rather than in response to campaign timing.

## Recommendations

- **Audit mobile checkout.** Mobile grew significantly in 2025 across all customer segments. Review page speed and checkout UX to ensure the growth is not being limited by friction.
- **Investigate the electronics refund spike.** November 2025 saw 3x more returns at nearly double the value. 
If a campaign was involved, investigate what went wrong.
- **Evaluate paid social quality before increasing spend.** Volume grew strongly but average order value varies significantly by month. Switch channel reporting to revenue per order, not order count.
- **Restructure coupon strategy.** Only 9.3% of orders use coupons, and seasonal codes are applied year-round regardless of intent. Run A/B tests on timing and targeting before the next campaign cycle.
- **Address the summer gap.** Demand drops notably from June to August, deepening in 2025. A targeted summer campaign — likely Sports or outdoor-focused — would reduce over-reliance on the November–December peaks.
- **Invest in Sports, review Home.** Sports combines the fastest growth (+29%) with the lowest refund rate (3.2%) — a clear priority for increased marketing budget. Home at +19% is the only category worth a strategic review.