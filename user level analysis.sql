-- for each repeat session how many users are there
CREATE TEMPORARY TABLE sessions_w_repeats AS
SELECT ns.user_id,
       ns.website_session_id AS new_session_id,
       ns.created_at as new_session_created_at,
       ws.created_at as repeated_session_created_at,
       ws.website_session_id AS repeat_sessions
FROM (
    SELECT user_id,
           website_session_id,created_at 
    FROM website_sessions
    WHERE created_at < '2014-11-01'
      AND created_at >= '2014-01-01'
      AND is_repeat_session = 0
) AS ns
LEFT JOIN website_sessions ws
ON ws.website_session_id > ns.website_session_id
   AND ws.user_id = ns.user_id
   AND ws.is_repeat_session = 1

and ws.created_at<'2014-11-01' and ws.created_at>='2014-01-01' ;
drop temporary table sessions_w_repeats;
select * from sessions_w_repeats;
select repeat_sessions,
count(distinct user_id) as users
from
( select user_id,
count(distinct repeat_sessions) as repeat_sessions
from sessions_w_repeats
group by 1
order by 2 desc) as user_level
group by 1;
select * from  sessions_w_repeats
where user_id=152837;
-- finding min, max and average time between first and second session of the same user for repeated users
with first_t as(
select user_id,new_session_created_at,repeated_session_created_at 
from sessions_w_repeats
where repeat_sessions is not null),
data_t as(
select user_id,datediff(min(repeated_session_created_at),min(new_session_created_at)) as  diff_time
from first_t
group by 1)
select avg(diff_time),min(diff_time),max(diff_time) from data_t;
-- based on paid and non paid channels we want to know number of new and repeated sessions

select 
case when utm_source is null and http_referer in ("https://www.gsearch.com","https://www.bsearch.com") then "organic search" 
when  utm_source is null and http_referer is null then "direct type in"
when utm_campaign = "nonbrand" then "paid nonbrand"
when utm_campaign = "brand" then "paid brand"
when utm_source = "socialbook" then "paid social"
end as channel_group,
count( distinct case when is_repeat_session=0 then website_session_id end) as new_sessions,
count(distinct case when is_repeat_session=1 then website_session_id end) as repeat_sessions
from website_sessions
group by 1;





