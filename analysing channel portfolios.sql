-- channel portfolio analysis
-- which utm content had the most sessions and the most orders
use mavenfuzzyfactory;
select ws.utm_content,count(distinct ws.website_session_id) as sessions ,count(distinct o.website_session_id) as orders,
(count(distinct o.website_session_id))/count(distinct ws.website_session_id) as conversion_rate
from website_sessions ws
left join  orders o 
on ws.website_session_id=o.website_session_id
where ws.created_at between '2014-01-01' and '2014-02-01'
group by ws.utm_content
order by conversion_rate desc;
-- comparing g_search and b_search session volume trends on weekly basis for non brand campaigns
select min(date(created_at)) as start_of_week,
count(distinct case when utm_source="gsearch" then website_session_id end) as gsearch,
count(distinct case when utm_source="bsearch" then website_session_id end) as bsearch
from website_sessions where created_at between '2012-08-22' and '2012-11-29' and utm_campaign="nonbrand"
group by week(created_at);
-- gsearch and  bsearch session volume by  their device type for non brand campaigns
select utm_source,
count(distinct case when device_type="mobile" then website_session_id  end ) as mobile_sessions,
count(distinct case when device_type="desktop" then website_session_id  end ) as desktop_sessions
from website_sessions
where created_at between '2012-08-22' and  '2012-11-30' and utm_campaign="nonbrand"
group by utm_source;
-- gsearch and bsearch and their conversion rates for diff device types
select ws.device_type,ws.utm_source,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.website_session_id)/count(distinct ws.website_session_id) as conversion_rates
from website_sessions ws
left join orders o
on ws.website_session_id=o.website_session_id
where ws.created_at >='2012-08-22' and ws.created_at<'2012-09-18'
and ws.utm_campaign="nonbrand"
group by ws.device_type,ws.utm_source;
-- analyzing direct traffic which is either by direct type in or by organic search to analyse the conversion rates from direct traffic based on month and year
select year(created_at) as yr,month(created_at) as mo,
count(distinct case when utm_campaign="nonbrand" then website_session_id end ) as nonbrand,
count(distinct case when utm_campaign="brand" then website_session_id end ) as brand,
count(distinct case when utm_campaign="brand" then website_session_id end )/count(distinct case when utm_campaign="nonbrand" then website_session_id end )
as brand_pct_of_nonbrand,
count(distinct case when utm_source is null and http_referer is null then website_session_id end ) as direct_type,
count(distinct case when utm_source is null and http_referer is null then website_session_id end )/count(distinct case when utm_campaign="nonbrand" then website_session_id end )
as direct_pct_of_nonbrand,
count(distinct case when utm_source is null and http_referer="https://www.gsearch.com" then website_session_id end ) as organic_g_type,
count(distinct case when utm_source is null and http_referer="https://www.gsearch.com" then website_session_id end )/count(distinct case when utm_campaign="nonbrand" then website_session_id end )
as direct_og_of_nonbrand,
count(distinct case when utm_source is null and http_referer="https://www.bsearch.com" then website_session_id end ) as organic_b_type,
count(distinct case when utm_source is null and http_referer="https://www.bsearch.com" then website_session_id end )/count(distinct case when utm_campaign="nonbrand" then website_session_id end )
as direct_ob_of_nonbrand
from website_sessions
group by 1,2;


