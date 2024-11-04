-- analysing business patterns
select year(ws.created_at) as year,month(ws.created_at) as month,
count(distinct ws.website_session_id) as sessions,
count(distinct o.website_session_id) as orders
from website_sessions ws
left join orders o
on ws.website_session_id=o.website_session_id
where year(ws.created_at)<2013
group by 1,2; 
-- analysing average website sessions for day of the week's hourly basis
with data_table as
(
select weekday(created_at) as wkd,
hour(created_at) as hr,
count(distinct website_session_id) as sessions
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'
group by 1,2)
select hr,
round(avg(case when wkd=0 then sessions end) ,1)as mon,
round(avg(case when wkd=1 then sessions end) ,1)as tue,
round(avg(case when wkd=2 then sessions end) ,1)as wed,
round(avg(case when wkd=3 then sessions end) ,1)as thur,
round(avg(case when wkd=4 then sessions end) ,1)as fri,
round(avg(case when wkd=5 then sessions end) ,1)as sat,
round(avg(case when wkd=6 then sessions end) ,1)as sun
from data_table
group by 1;

