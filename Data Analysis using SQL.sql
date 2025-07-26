-- Create table

Use database snowflake_learning_db;

select * from yelp_businesses_tabular;

select * from yelp_reviews_tabular;


--1. Find the number of businesses in each category

-- Method : 1

select trim(a.value) as category , count(*) as num_of_business 
from (SELECT *
FROM yelp_businesses_tabular,                            -- Base table (source of rows)
     LATERAL split_to_table(categories, ',') )a          -- Extra rows per row, using categories
     group by 1
     order by 2 desc; 
     
     -- “Start with each row from yelp_businesses_tabular, and for each row, apply split_to_table to split categories.”


-- 2. Find the Top 10 Users who have reviewed the most business in the "Restaurants" Category


with cte as (SELECT user_id , category ,business_id
FROM (
    SELECT 
        a.business_id AS business_id,
        a.review_count AS review_counts,
        b.user_id AS user_id,
        cat.value AS category
    FROM yelp_businesses_tabular a
    JOIN yelp_reviews_tabular b 
        ON a.business_id = b.business_id
    , LATERAL split_to_table(a.categories, ',') cat
) c )

select user_id, count (distinct business_id) as distinct_reviews from cte
where category ilike ('%Restaurants%') group by 1 order by 2 desc;

   
select user_id, num_of_reviews  
from  cte
WHERE TRIM(LOWER(category)) = 'restaurants'
 order by 2 desc limit 10;


-- Method : 2

select b.user_id, count(distinct b.business_id) as num_of_reviews
from yelp_businesses_tabular a 
join yelp_reviews_tabular b on a.business_id = b.business_id
where a.categories ilike ('%Restaurants%')
group by 1
order by 2 desc limit 10
;


-- 3. Find the most popular category of business based on the number of reviews

select * from yelp_businesses_tabular;

select trim(a.value) as category , sum(review_count)
from (SELECT *
FROM yelp_businesses_tabular,                           
     LATERAL split_to_table(categories, ',') )a          
      group by 1 order by 2 desc;


--4 . Find top 3 most recent review for each business

select * from yelp_reviews_tabular;

with cte as (select a.name, b.review_text,b.review_date, 
row_number() over(partition by b.business_id order by review_date desc) as rn
from yelp_businesses_tabular a
join yelp_reviews_tabular b
on a.business_id = b.business_id)


select * from cte where rn <=3;


-- 5. Find the Month with Highest Number of Reviews

select month(review_date), count(*) as review_per_month
from yelp_reviews_tabular
group by 1
order by 2 desc
limit 1;

-- 6. Find the percentage of 5- Star review for each businesses


select a.business_id, a.name,count(*) as total_review,
sum(case when b.review_stars = 5 then 1 else 0 end) as five_star_review,
(five_star_review / total_review ) * 100 as five_stars_review_per_business
from yelp_businesses_tabular a 
join yelp_reviews_tabular b on a.business_id = b.business_id
group by 1 ,2;

-- 7. Find the top 5 most reviewed businesses in each city

with cte as (select city,name, a.business_id,count(b.user_id) as num_of_reviews, dense_rank() over (partition by city order by num_of_reviews desc ) rn
from yelp_businesses_tabular a join yelp_reviews_tabular b 
on a.business_id = b.business_id group by 1,2,3)

select city, name , num_of_reviews
from cte where rn <=5 ;


-- 8. Find the average rating of businesses that have atleast 100 reviews

select a.business_id ,avg(b.review_stars) as average_rating, count(b.user_id)  from yelp_businesses_tabular a 
join yelp_reviews_tabular b 
on a.business_id = b.business_id
group by 1
having count(b.user_id) >= 100;

-- 9. List the Top 10 users who have written the most reviews, along with the businesses they reviewed

select b.user_id,a.name, count(*) as review_count, 
from yelp_businesses_tabular a join yelp_reviews_tabular b 
on a.business_id = b.business_id
group by 1,2
order by 3 desc;

-- 10. Find top 10 businesses with highest positive reviews

select a.business_id, a.name, count(*) as number_of_reviews from yelp_businesses_tabular a join yelp_reviews_tabular b 
on a.business_id = b.business_id
where sentiments = 'Positive'
group by 1,2
order by 3 desc
limit 10;

-- 11. Sentiment Trends Over Time

select 
    review_date,
    sentiments,
    count(*) as total_reviews
from yelp_reviews_tabular
group by review_date, sentiments
order by review_date;

-- 12. Find the average star rating by category

SELECT 
    TRIM(cat.value) AS category,
    ROUND(AVG(a.review_stars), 2) AS avg_rating
FROM yelp_businesses_tabular b
join yelp_reviews_tabular a 
on a.business_id = b.business_id,
     LATERAL split_to_table(b.categories, ',') cat
GROUP BY TRIM(cat.value)
ORDER BY avg_rating DESC
;


-- 12.Find the top 5 cities with the most negative reviews


select * from yelp_reviews_tabular;

select * from yelp_businesses_tabular;

select a.city , sum(case when sentiments = 'Negative' then 1 else 0 end) as negative_review
from yelp_businesses_tabular a 
join yelp_reviews_tabular b 
on a.business_id = b.business_id
group by 1
order by 2 desc
limit 10;


-- 13. Find businesses that have received only positive reviews


select count(a.business_id) from yelp_businesses_tabular a 
join yelp_reviews_tabular b 
on a.business_id = b.business_id
where b.sentiments = 'Positive';





