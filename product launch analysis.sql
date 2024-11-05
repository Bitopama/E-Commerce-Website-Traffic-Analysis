-- how product launch affects conversion rates

-- before and after launching product love bear how many are sessions are going to the next page from product page and how many are selecting mr fuzzy and love bear


with product_sessions as(
select count(distinct website_pageview_id),website_session_id


from  website_pageviews
where created_at>'2012-10-06' and created_at<'2013-04-06'
group by website_session_id
having count(distinct website_pageview_id)>2
),
 non_bounced_sessions as(
select count(distinct website_pageview_id),website_session_id

from  website_pageviews
where created_at>'2012-10-06' and created_at<'2013-04-06'
group by website_session_id
having count(distinct website_pageview_id)>1
),
products as
( select website_session_id,pageview_url
 from website_pageviews
 where pageview_url in ("/the-original-mr-fuzzy" ,"/the-forever-love-bear")
 )

select 
case when  ws.created_at<'2013-01-06' then 'pre_product_2' 
 when ws.created_at>='2013-01-06' then 'post_product_2' end as time_period,
count(distinct nbs.website_session_id) as sessions,
 count(distinct ps.website_session_id) as sessions_w_next_pg,
  count(distinct ps.website_session_id)/count(distinct nbs.website_session_id) as pct_w_next_pg,
count(distinct case when p.pageview_url="/the-original-mr-fuzzy" then p.website_session_id end) as to_mrfuzzy,
 count(distinct case when p.pageview_url="/the-forever-love-bear" then p.website_session_id end) as to_lovebear
  from website_sessions ws
  left join non_bounced_sessions nbs
  on nbs.website_session_id=ws.website_session_id
  left join product_sessions ps
  on ps.website_session_id=ws.website_session_id
  left join products p
  on p.website_session_id=ws.website_session_id
  where  ws.created_at>'2012-10-06' and ws.created_at<'2013-04-06'
  group by 1;
  -- funnel analysis of mr fuzzy and love bear products

 -- before and after 3 months of launching love bear product how the funnel conversion rates have changed from actually viewing the product to buying it
 with product_sessions as(
select count(distinct website_pageview_id),website_session_id


from  website_pageviews
where created_at>'2012-10-06' and created_at<'2013-04-06'
group by website_session_id
having count(distinct website_pageview_id)>2
),funnel_1 as(
select website_session_id, created_at,
case when pageview_url='/cart' then 1 else 0 end as to_cart,
case when pageview_url='/shipping' then 1 else 0 end as to_ship,
case when pageview_url in ('/billing','/billing-1','/billing-2') then 1 else 0 end as to_bill,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as to_thanks
from website_pageviews
where website_session_id in (select website_session_id from product_sessions)
and created_at in (select created_at from product_sessions))
select

case when wp.pageview_url='/the-original-mr-fuzzy' then 'mrfuzzy' 
  when wp.pageview_url='/the-forever-love-bear' then 'lovebear' end as product_category,
count(distinct f1.website_session_id) as viewed_the_product,
count(distinct case when f1.to_cart=1 then wp.website_session_id end) as to_cart,
count(distinct case when f1.to_ship=1 then wp.website_session_id end) as to_ship,
count(distinct case when f1.to_bill=1 then wp.website_session_id end) as to_bill,
count(distinct case when f1.to_thanks=1 then wp.website_session_id end) as to_thanks,
count(distinct case when f1.to_thanks=1 then wp.website_session_id end)/count(distinct f1.website_session_id) as buying_to_viewing
from website_pageviews  wp
join funnel_1 f1
on wp.website_session_id=f1.website_session_id 
where wp.created_at>'2012-10-06' and wp.created_at<'2013-04-06'
and pageview_url in('/the-original-mr-fuzzy','/the-forever-love-bear')

group by 1;

-- love bear revenue  and margin analysis before and after 3 months of product launch
select
case when ws.created_at<'2013-01-06' then 'pre_love_bear'
when ws.created_at>='2013-01-06' then 'post_love_bear' end as time_period,
count(distinct o.order_id)/count(distinct ws.website_session_id) as conv_rate,
sum(o.price_usd)/count(distinct o.order_id) as aov,
sum(o.price_usd-o.cogs_usd)/count(distinct o.order_id) as avg_order_margin,

sum(o.price_usd)/count(distinct ws.website_session_id) as rev_per_sess,
sum(o.price_usd-o.cogs_usd)/count(distinct ws.website_session_id) as margin_per_sess 
from website_sessions ws
left join orders o
on ws.website_session_id=o.website_session_id
where ws.created_at between '2012-10-06' and '2013-04-06'
group by 1
;


 

