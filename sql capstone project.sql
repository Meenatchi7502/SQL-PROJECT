-- 1. 1. Data Wrangling:---
create database amazon;  
use amazon;
-- Creating Table
CREATE TABLE amazon_sales (
    invoice_id VARCHAR(30) NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10),
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4),
    total DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    time TIMESTAMP NOT NULL,
    payment_method DECIMAL(10, 2) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(10, 2) NOT NULL,
    rating FLOAT(2, 1),
    PRIMARY KEY (invoice_id)
);
select * from amazon;

-- 2.Feature Engineering: ---
ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);
ALTER TABLE sales_data
ADD COLUMN dayname VARCHAR(10);
SET SQL_SAFE_UPDATES = 0;
UPDATE amazon
SET dayname = CASE DAYOFWEEK(date)
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    ELSE 'Saturday'
END;
ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10);

UPDATE amazon
SET timeofday = CASE
    WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
END;
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

UPDATE amazon
SET monthname = CASE MONTH(date)
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    ELSE 'Dec'
END;
select * from amazon;

--- Business Questions To Answer:-----

--- 1.What is the count of distinct cities in the dataset?--
SELECT COUNT(DISTINCT city) AS distinct_cities_count
FROM amazon;  -- 3 cities in the dataset

-- 2.For each branch, what is the corresponding city?
SELECT branch, city
FROM amazon
GROUP BY branch, city;   -- 3 cities and 3 branch

-- 3.What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT `product line`) AS distinct_product_line
FROM amazon;  -- 6 different products are there in the dataset

-- 4.Which payment method occurs most frequently?---
SELECT Payment, COUNT(*) AS frequency
FROM amazon
GROUP BY Payment
ORDER BY frequency DESC
LIMIT 3;  -- 3 type of payments and Ewallet occurs most frequent

-- 5.Which product line has the highest sales?
SELECT `Product line`, SUM(total) AS TOTAL_SALES
FROM amazon
GROUP BY `Product line`
ORDER BY TOTAL_SALES DESC;  -- Food and beverages has the highest sales


-- 6.How much revenue is generated each month?
SELECT monthname, SUM(total) AS revenue
FROM amazon
GROUP BY monthname; -- revenue generated in each month


-- 7.In which month did the cost of goods sold reach its peak?
SELECT monthname, MAX(cogs) AS max_cogs
FROM amazon
GROUP BY monthname
ORDER BY max_cogs DESC
LIMIT 3;     --- IN feb month cost of goods reach its peak

-- 8.Which product line generated the highest revenue?
SELECT `product line`, SUM(total) AS revenue
FROM amazon
GROUP BY `product line`
ORDER BY revenue DESC
LIMIT 3;   --- food and beverages generated highest revenue

-- 9.In which city was the highest revenue recorded?---
SELECT city, SUM(total) AS revenue
FROM amazon
GROUP BY city
ORDER BY revenue DESC
LIMIT 3;   ---- Naypyitaw city has highest revenue record.

-- 10.Which product line incurred the highest Value Added Tax?
SELECT `product line`, SUM(`Tax 5%`) AS total_VAT
FROM `amazon`
GROUP BY `product line`
ORDER BY total_VAT DESC;  -- Food and beverages in the product has high value tax

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- Sales classification for each product line ("Good" or "Bad"):
SELECT DISTINCT`product line`,
    CASE
        WHEN total > (SELECT AVG(total) FROM amazon) THEN 'Good'
        ELSE 'Bad'
    END AS sales_classification
FROM amazon; -- classied product based on sales by defining good and bad

-- 12.Identify the branch that exceeded the average number of products sold. --
select distinct Branch from amazon
where Quantity>(select avg(Quantity) from amazon); -- branch A exceded the average no of products sold

-- 13.Which product line is most frequently associated with each gender?
SELECT gender, `product line`, COUNT(*) AS frequency
FROM amazon
GROUP BY gender, `product line`
ORDER BY gender, frequency DESC;  -- female and fashon accesories 96 frequency

-- 14.Calculate the average rating for each product line.
SELECT`product line`, AVG(rating) AS avg_rating
FROM amazon
GROUP BY `product line`; -- Average rating of the Product

-- 15.Count the sales occurrences for each time of day on every weekday.
SELECT 
    timeofday,
    dayname,
    COUNT(*) AS sales_occurrences
FROM amazon
GROUP BY timeofday, dayname
ORDER BY dayname, timeofday;  -- here Afternoon time at Friday most no of sales occurs

-- 16.Identify the customer type contributing the highest revenue.
SELECT `customer type`, SUM(total) AS total_revenue
FROM amazon
GROUP BY `customer type`
ORDER BY total_revenue DESC
LIMIT 3;  -- 2 type of customer member and Normal here member has high revenue

-- 17.Determine the city with the highest VAT percentage.
SELECT city, AVG(`Tax 5%` / total) * 100 AS avg_VAT_percentage
FROM amazon
GROUP BY city
ORDER BY avg_VAT_percentage DESC
LIMIT 3;   --- Yangon city has high vat pecrecentage

-- 18.Identify the customer type with the highest VAT payments.
SELECT `customer type`, SUM(`Tax 5%`) AS total_VAT_payments
FROM amazon
GROUP BY `customer type`
ORDER BY total_VAT_payments DESC
LIMIT 3; -- member has high vat payments

-- 19.What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT `customer type`) AS distinct_customer_types_count
FROM amazon;  -- 2 type of customers member and normal

-- 20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT `payment`) AS distinct_payment_methods_count
FROM amazon;  ----- E-wallet, cash and Credit Card----

-- 21.Which customer type occurs most frequently?---
SELECT `customer type`, COUNT(*) AS frequency
FROM amazon
GROUP BY `customer type`
ORDER BY frequency DESC
LIMIT 3;  -- member type occurs most frequent 501

-- 22.Identify the customer type with the highest purchase frequency.--
SELECT `customer type`, Sum(Quantity) AS purchase_frequency
FROM amazon
GROUP BY `customer type`
ORDER BY purchase_frequency DESC
LIMIT 3;    --- member type has high purchase frequency 2785

-- 23.Determine the predominant gender among customer
SELECT gender, COUNT(*) AS gender_count
FROM amazon
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 3;      -- female gender is predominant than male

-- 24.Examine the distribution of genders within each branch.
SELECT branch, gender, COUNT(*) AS gender_count
FROM amazon
GROUP BY branch, gender
ORDER BY branch, gender;  -- gender count in each branch

-- 25.Identify the time of day when customers provide the most ratings.
SELECT timeofday, COUNT(*) AS rating_count
FROM amazon
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 3;  -- aftrenoon time most no of ratings came

-- 26.Determine the time of day with the highest customer ratings for each branch.
SELECT branch, timeofday, COUNT(*) AS rating_count
FROM amazon
GROUP BY branch, timeofday
ORDER BY branch, rating_count DESC; -- branch A has highest rating

-- 27.Identify the day of the week with the highest average ratings.
SELECT dayname, AVG(rating) AS avg_rating
FROM amazon
GROUP BY dayname
ORDER BY avg_rating DESC
LIMIT 3;  -- Monday has high average rating

-- 28.Determine the day of the week with the highest average ratings for each branch.
SELECT 
    branch,
    dayname,
    AVG(rating) AS avg_rating
FROM amazon
GROUP BY branch, dayname
ORDER BY branch, avg_rating DESC; -- Branch A fridays has high ratings



















select * from amazon;



