--To import data from csv file to Postgresql
create table content (content_id VARCHAR ( 50 ) ,
	user_id VARCHAR ( 50 ),type VARCHAR ( 50 ),
	category VARCHAR ( 50 ),url VARCHAR ( 255 ))
	
create table reactions (content_id VARCHAR ( 50 ) ,
	user_id VARCHAR ( 50 ),type VARCHAR ( 50 ),
	date_time TIMESTAMP)
	
create table reactionTypes ( 
 type VARCHAR ( 50 ),sentiment VARCHAR ( 50 ), score int )
 
 select * from reactions --24573 number of records after cleanup
 select * from content -- 1001
 select *  from reactiontypes --16
  
-- Data cleaning  
--Rename column type to reaction_type
alter table reactiontypes rename type to reaction_type
 
-- Since we dont need url column for our analysis  
alter table content drop url;

--Some values in category are with " " to replace category with plain category 
select regexp_replace(category,'[^a-zA-Z0-9]','') from content

-- To make sure category has all values without "" 
select distinct category from content

-- Rename column type to content_type 
alter table content rename type to content_type

--Since we are calculating best performing categories we dont need column user_id
alter table content drop column user_id 
alter table reactions drop column user_id  

-- Some values in reactions table are null to delete rows where type =null
delete from reactions where type is null

-- Rename column type to reaction_type
alter table reactions rename type to reaction_type

-- SQL query to find out Top 5 performimg categories 
select ranked.category, total_score from (
select total_score, category, rank() over(order by total_score desc) as rnk 
from (select sum(score) as total_score, lower(category) as category 
		from reactions react
		join reactiontypes retype on react.reaction_type = retype.reaction_type 
		left join content cnt on react.content_id = cnt.content_id
		group by category) agg
) ranked		
where rnk <=5
 