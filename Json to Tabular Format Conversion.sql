-- Sentiment Analysis UDF 

create or replace function analyze_sentiment (text string)
returns string
language PYTHON
runtime_version ='3.9'
packages =('textblob')
handler = 'sentiment_analyzer'
as $$
from textblob import TextBlob

def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;



-- Json to Tabular Format Conversion

Use database snowflake_learning_db;


-- Yelp_Review

-- Extracting onyl relevant attributes needed for analysis


select  review_text:business_id::string         as business_id ,
        review_text:date::date                  as review_date ,
        review_text:user_id::string             as user_id,
        review_text:stars::number               as review_stars,
        review_text:text::string                as review_text,
        
        from yelp_review ;

-- Storing extracted data into tabular format table


create or replace table yelp_reviews_tabular as 
select          review_text:business_id::string         as business_id ,
                review_text:date::date                  as review_date ,
                review_text:user_id::string             as user_id,
                review_text:stars::number               as review_stars,
                review_text:text::string                as review_text,
                analyze_sentiment(review_text)          as sentiments

                from yelp_review ;

select * from yelp_reviews_tabular;


-- Yelp_Businesses



-- Extracting onyl relevant attributes needed for analysis

select  
        business_text:address :: string     as address,
        business_text:business_id:: string  as business_id,
        business_text:categories:: string   as categories,
        business_text:city::string          as city,
        business_text:hours::string         as hours,
        business_text:is_open::number       as is_open,
        business_text:name::string          as name,
        business_text:postal_code::string   as postal_code,
        business_text:review_count::number  as review_count,
        business_text:stars::number         as stars,
        business_text:state::string         as state   
        
        from yelp_businesses;

-- Storing extracted data into tabular format table

create or replace table yelp_businesses_tabular as
select  
        business_text:address :: string     as address,
        business_text:business_id:: string  as business_id,
        business_text:categories:: string   as categories,
        business_text:city::string          as city,
        business_text:hours::string         as hours,
        business_text:is_open::number       as is_open,
        business_text:name::string          as name,
        business_text:postal_code::string   as postal_code,
        business_text:review_count::number  as review_count,
        business_text:stars::number         as stars,
        business_text:state::string         as state   
        
        from yelp_businesses;

select * from yelp_businesses_tabular;