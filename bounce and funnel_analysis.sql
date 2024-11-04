use mavenfuzzyfactory;
SELECT * FROM mavenfuzzyfactory.website_pageviews;
with  req_sess as(
select ws.website_session_id,wp.created_at,wp.pageview_url,wp.website_pageview_id
from website_sessions ws 
join website_pageviews wp
on ws.website_session_id=wp.website_session_id 
where wp.created_at<'2012-08-31' and wp.created_at>'2012-06-01'
and wp.pageview_url in ("/home","/lander-1")
and ws.utm_source="gsearch" and ws.utm_campaign="nonbrand"),
land_page as
(
select min(website_pageview_id) as min_page,website_session_id from req_sess
group by website_session_id)
select count(distinct r.website_session_id) as tot_sess,r.pageview_url,min(date(r.created_at)) as start_week
from req_sess r
join land_page l
on r.website_pageview_id=l.min_page
and r.website_session_id=l.website_session_id
group by r.pageview_url,week(r.created_at);
WITH req_sess AS (
    SELECT ws.website_session_id, ws.created_at, wp.pageview_url, wp.website_pageview_id
    FROM website_sessions ws 
    JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id 
    WHERE ws.created_at < '2012-08-31' AND ws.created_at > '2012-06-01'
      AND wp.pageview_url IN ("/home", "/lander-1")
      AND ws.utm_source = "gsearch" AND ws.utm_campaign = "nonbrand"
),
land_page AS (
    SELECT MIN(website_pageview_id) AS min_page, website_session_id 
    FROM req_sess
    GROUP BY website_session_id
),
land_url AS (
    SELECT r.website_session_id, r.pageview_url
    FROM req_sess r
    left  JOIN land_page l ON r.website_pageview_id = l.min_page and r.website_session_id=l.website_session_id
),
bounce AS (
    SELECT r.website_session_id, COUNT(DISTINCT r.website_pageview_id) AS page_num, r.pageview_url AS num_page 
    FROM req_sess r
    left JOIN land_url l ON r.website_session_id = l.website_session_id
    GROUP BY r.website_session_id, r.pageview_url
    HAVING COUNT(DISTINCT r.website_pageview_id) = 1
)
SELECT r.pageview_url, MIN(DATE(r.created_at)) AS first_date, COUNT(DISTINCT l.website_session_id) AS total,
       COUNT(DISTINCT b.website_session_id) AS bou,
       COUNT(DISTINCT l.website_session_id) / COUNT(DISTINCT b.website_session_id) AS bou_rate
FROM req_sess r
left JOIN land_url l ON r.website_session_id = l.website_session_id
left JOIN bounce b ON r.website_session_id = b.website_session_id
GROUP BY r.pageview_url, WEEK(r.created_at);

-- funnel analysis
with main_table as
(
select ws.website_session_id,wp.website_pageview_id,wp.created_at as pv_created_at,wp.pageview_url,
case when wp.pageview_url in ('/home','/lander-1','/lander-2') then 1 else 0 end as start_click,
case when wp.pageview_url='/products' then 1 else 0 end as product_click,
case when wp.pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mr_fuzzy_click,
case when wp.pageview_url='/cart' then 1 else 0 end as cart_click,
case when wp.pageview_url='/shipping' then 1 else 0 end as ship_click,
case when wp.pageview_url='/billing' then 1 else 0 end as bill_click,
case when wp.pageview_url='/thank-you-for-your-order' then 1 else 0 end as ty_click
from website_sessions ws
left join website_pageviews wp
on ws.website_session_id=wp.website_session_id
where ws.created_at between '2012-08-05' and '2012-09-05'
and wp.pageview_url in('home','/lander-1','/lander-2','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
and ws.utm_source="gsearch"),
funnel as(
select website_session_id,max(product_click) as pc,max(mr_fuzzy_click)as fc,max(cart_click) as cc,
max(ship_click) as shc,max(bill_click) as bc,max(ty_click) as tyc

from main_table
group by website_session_id)
select count(distinct website_session_id) as total_sessions,

sum(pc) as conv_to_pc,
sum(fc) as conv_to_fc,
sum(cc) as conv_to_cc,
sum(shc) as conv_to_shc,
sum(bc) as conv_to_bc,
sum(tyc) as conv_to_tyc from funnel;
