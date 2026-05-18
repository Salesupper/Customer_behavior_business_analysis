SELECT distinct count(customer_id) as contagem_distinta 
FROM customer;

SELECT 
	distinct count(customer_id) as contagem_distinta,
	count(customer_id) as contagem 
FROM customer;


SELECT 
	customer_id
	,count(customer_id) as contagem
FROM customer
GROUP BY customer_id
HAVING count(customer_id) > 1;

SELECT 
	  category
	, count(1) as contagem
FROM customer
GROUP BY 1
HAVING count(1) = 1;


-- 'Qual é a receita total gerada por clientes masculinos vs. femininos?'
SELECT 
	gender,
	SUM(purchase_amount) AS total_receita
FROM customer
GROUP BY gender;


-- 'Quais clientes usaram desconto, mas ainda gastaram mais do que a média de compra?'
SELECT 
	customer_id,
	purchase_amount,
	purchase_amount
FROM customer
WHERE discount_applied = 'Yes' AND purchase_amount >= (
	SELECT AVG(purchase_amount)
	FROM customer
);


-- 'Quais são os 5 produtos com a maior média de avaliação?'
SELECT
	  item_purchased
	, ROUND(AVG(review_rating)::numeric, 2) AS media_avaliacao
FROM customer
GROUP BY 1
ORDER BY media_avaliacao DESC
LIMIT 5;


-- 'Compare o valor médio de compras entre os tipos de entrega Standard e Express.'
SELECT 
	shipping_type,
	ROUND(AVG(purchase_amount)::numeric, 2) as media_compra
FROM customer
WHERE shipping_type IN ('Standard','Express')
GROUP BY shipping_type
ORDER BY media_compra DESC;


-- 'Clientes assinantes gastam mais? Compare gasto médio e receita total entre assinantes e não assinantes.'
SELECT 
	subscription_status,
	COUNT(customer_id),
	ROUND(AVG(purchase_amount)::numeric, 2) AS media_compra,
	ROUND(SUM(purchase_amount)::numeric, 2) AS receita_total
FROM customer
GROUP BY subscription_status
ORDER BY receita_total DESC;


-- 'Quais 5 produtos possuem a maior porcentagem de compras com desconto aplicado?'
SELECT 
	item_purchased,
	ROUND(100 * SUM(CASE 
		WHEN lower(discount_applied) = 'yes' THEN 1 
			ELSE 0 
		END)/COUNT(*),2) AS taxa_compra_disconto
FROM customer
GROUP BY item_purchased
ORDER BY taxa_compra_disconto DESC
LIMIT 5;


-- 'Segmente os clientes em Novos, Recorrentes e Fiéis com base no total de compras anteriores, e mostre a quantidade de cada grupo.'
WITH custumer_type AS(
SELECT 
	customer_id,previous_purchases,
	CASE 
		WHEN previous_purchases = 1 THEN 'Cliente_novo'
		WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Cliente_regular'
		ELSE 'Cliente_fiel'
		END AS customer_segment
FROM customer
)
SELECT 
	customer_segment,
	COUNT(*) AS numero_clientes
FROM custumer_type
GROUP BY customer_segment
ORDER BY numero_clientes DESC;
	

-- 'Quais são os 3 produtos mais comprados dentro de cada categoria?'
WITH item_counts as (
	SELECT 
	category,
	item_purchased,
	COUNT(customer_id) as total_orders,
	ROW_NUMBER() OVER(
		PARTITION BY category
		ORDER BY COUNT(customer_id)  DESC) AS item_rank
	FROM customer
	GROUP BY category, item_purchased
	)

SELECT
	item_rank,
	category,
	item_purchased,
	total_orders
FROM item_counts
WHERE item_rank <= 3;


-- 'Clientes recorrentes (mais de 5 compras anteriores) também tendem a ser assinantes?'
SELECT 
	subscription_status,
	COUNT(customer_id) AS cliente_recorrente
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- 'Qual é a contribuição de receita de cada faixa etária?'
SELECT 
	age_group,
	COUNT(customer_id) AS total_clientes,
	SUM(purchase_amount) as total_receita
FROM customer
GROUP BY age_group
ORDER BY total_receita DESC;
