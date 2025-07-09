use pizza_database;
select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;

#IDENTIFIED Total number of order place
select count(distinct order_id) from order_details;

#Calculate the total revenue generated from pizza sales
select sum(pizzas.price * order_details.quantity) as revenue_collection from pizzas 
join order_details on pizzas.pizza_id = order_details.pizza_id;

#Identify the highest-priced pizza.
select pizza_types.name, pizzas.price from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc
limit 1;

#Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_id) as no_of_count from pizzas join 
order_details on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size
order by no_of_count desc
limit 1;

#List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) from 
pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by sum(order_details.quantity) desc
limit 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) from pizza_types 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(order_details.quantity) desc;

#Determine the distribution of orders by hour of the day.
select hour(time), count(distinct order_id) from orders
group by hour(time)
order by count(distinct order_id) desc;

#Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category
order by count(name) desc;

#Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from (select orders.date, sum(order_details.quantity) as quantity from orders join 
order_details on orders.order_id = order_details.order_id
group by orders.date) as order_quantity;

#Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, round(sum(order_details.quantity * pizzas.price),0) as revenue from order_details join pizzas 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by revenue desc 
limit 3;

#Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, 
 round(sum(order_details.quantity * pizzas.price) / (select sum(pizzas.price * order_details.quantity) as revenue_collection from pizzas 
join order_details on pizzas.pizza_id = order_details.pizza_id)* 100,2)
   as revenue from order_details join pizzas 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by revenue desc;

#Analyze the cumulative revenue generated over time.
select date, sum(revenue) over (order by date) as cumulative_revenue
from
(select orders.date, round(sum(order_details.quantity * pizzas.price),2) as revenue from pizzas join order_details 
on order_details.pizza_id = pizzas.pizza_id join 
orders on order_details.order_id = orders.order_id
group by orders.date) as rev_coll;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue_collection from 
(select name, category, revenue_collection, rank() 
over(partition by category order by revenue_collection desc) as rn
from 
(select pizza_types.name, pizza_types.category, round(sum(pizzas.price * order_details.quantity), 2) as revenue_collection from pizzas 
join order_details on pizzas.pizza_id = order_details.pizza_id join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name, pizza_types.category) as aaa) as b
where rn < 4;



