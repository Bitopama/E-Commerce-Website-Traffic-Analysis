-- cross selling products for each product type
select o.primary_product_id,
count( distinct oi.order_item_id) as order_counts,
count(distinct case when oi.product_id=1 then oi.order_item_id end) as cross_sell_prod_1,
count(distinct case when oi.product_id=2 then oi.order_item_id end) as cross_sell_prod_2,
count(distinct case when oi.product_id=3 then oi.order_item_id end) as cross_sell_prod_3
from orders o
left join order_items oi
on o.order_id=oi.order_id 
where   o.order_id between 10000 and 11000
group by 1;
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
min(wp.website_pageview_id) as pv_id_after_cart
from sessions_seeing_cart ssc
left join website_pageviews wp
on ssc.cart_session_id =wp.website_session_id
and ssc.cart_pageview_id<wp.website_pageview_id
group by 1,2;
-- having min(wp.website_pageview_id) is not null;
select * from cart_sessions_seeing_another_page;
drop temporary table cart_sessions_seeing_another_page;
-- cart sessions with orders
create temporary table cart_sessions_with_orders
select time_period,cart_session_id,order_id,items_purchased,price_usd
from sessions_seeing_cart ssc
left join orders o
on ssc.cart_session_id=o.website_session_id;
select * from cart_sessions_with_orders;
drop temporary table cart_sessions_with_orders;
--
-- after launching a new product birthday sugar panda which was lanched after introducing the multi cart option lets analyse how it affects revenue
-- 3 months before and after launching it
select
case when ws.created_at<'2013-12-12' then 'pre_birthday_sugar_panda'
when ws.created_at>='2013-12-12' then 'post_birthday_sugar_panda' end as time_period,
count(distinct o.order_id)/count(distinct ws.website_session_id) as conv_rate,
sum(o.price_usd)/count(distinct o.order_id) as aov,
sum(o.items_purchased)/count(distinct o.order_id) as products_per_order,
sum(o.price_usd)/count(distinct ws.website_session_id) as rev_per_sess
from website_sessions ws
left join orders o
on ws.website_session_id=o.website_session_id
where ws.created_at between '2013-12-09' and '2014-12-03'
group by 1
;