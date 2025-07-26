-- Create table for yelp_review and yepl_businesses

Use database snowflake_learning_db;

create or replace table yelp_review(review_text variant);


copy into yelp_review
from 's3://yelpjay'
credentials = (AWS_KEY_ID = '*******', AWS_SECRET_KEY = '********') file_format =(type=json);
select * from yelp_review;



create or replace table yelp_businesses(business_text variant);

copy into yelp_businesses
from 's3://yelpjay/yelp_academic_dataset_business.json'
credentials = (AWS_KEY_ID = '********', AWS_SECRET_KEY = '*******') file_format =(type=json);

select * from yelp_businesses;
