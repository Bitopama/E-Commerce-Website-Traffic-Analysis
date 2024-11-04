-- cross sell product analysis and click through rates from cart page
-- fetching the data
create temporary table sessions_seeing_cart
select
case when created_at<'2013-09-25' then 'A.Pre_Cross_Sell' 
when created_at>='2013-01-06' then 'B.Post_Cross_Sell'
end as time_period,
website_session_id as cart_session_id,
website_pageview_id as cart_pageview_id
from website_pageviews 
where created_at between '2013-08-25' and '2013-10-25'
and pageview_url='/cart';
select * from sessions_seeing_cart;
-- sessions which moved to the next page
create temporary table cart_sessions_seeing_another_page
select ssc.time_period,
ssc.cart_session_id,
min(wp.website_pageview_id)
from sessions_seeing_cart ssc
left join website_pageviews wp
on ssc.cart_session_id =wp.website_session_id
and ssc.cart_pageview_id<wp.website_pageview_id
group by 1,2
having min(wp.website_pageview_id) is not null;
select * from cart_sessions_seeing_another_page;
-- cart sessions with orders
create temporary table cart_sessions_with_orders
select ssc.time_period,ssc.cart_session_id,o.order_id,o.items_purchased,o.price_usd
from sessions_seeing_cart ssc
join orders o
on ssc.cart_session_id=o.website_session_id;
select ssc.time_period,ssc.cart_session_id,
case when cssap.cart_session_id is not null then 1 else 0 end as sess_clc_next,
case when cswo.cart_session_id is not null then 1 else 0 end as sess_ordered,
cswo.items_purchased ,cswo.order_id,cswo.price_usd
from sessions_seeing_cart ssc
left join cart_sessions_seeing_another_page cssap
on ssc.cart_session_id=cssap.cart_session_id
left join cart_sessions_with_orders cswo
on ssc.cart_session_id=cssap.cart_session_id
order by ssc.cart_session_id;