/*
1. Realizar una consulta SQL que permita saber los clientes que
compraron por encima del promedio de compras (fact_total) de todos
los clientes del 2012.

De estos clientes mostrar para el 2012:
	1. El código del cliente
	2. La razón social del cliente
	3. Código de producto que en cantidades más compro.
	4. El nombre del producto del punto 3.
	5. Cantidad de productos distintos comprados por el cliente.
	6. Cantidad de productos con composición comprados por el cliente.

El resultado deberá ser ordenado poniendo primero aquellos clientes
que compraron más de entre 5 y 10 productos distintos en el 2012.

Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,
*/

SELECT	c.clie_codigo as codigo,
		c.clie_razon_social as razon_social,
		(select top 1 p2.prod_codigo from Producto as p2
		join Item_Factura as itf2 on itf2.item_producto = p2.prod_codigo
		join Factura as f3 on f3.fact_numero = itf2.item_numero
		where f3.fact_cliente = c.clie_codigo and year(f3.fact_fecha) = 2012
		order by itf2.item_cantidad desc)
		as cod_prod_con_mas_cant_compradas,
		(select top 1 p3.prod_detalle from Producto as p3
		join Item_Factura as itf3 on itf3.item_producto = p3.prod_codigo
		join Factura as f4 on f4.fact_numero = itf3.item_numero
		where f4.fact_cliente = c.clie_codigo and year(f4.fact_fecha) = 2012
		order by itf3.item_cantidad desc)
		as prod_con_mas_cant_compradas,
		count(distinct p.prod_codigo) as cant_prod_comprados
		


	from Cliente as c
	JOIN Factura as f on f.fact_cliente = c.clie_codigo
	JOIN Item_Factura as itf on 
		itf.item_numero = f.fact_numero and itf.item_sucursal = f.fact_sucursal and itf.item_tipo = f.fact_tipo
	JOIN Producto as p on p.prod_codigo = itf.item_producto
	
	where year(f.fact_fecha) = 2012
	group by c.clie_codigo, c.clie_razon_social
	having sum(itf.item_cantidad * itf.item_precio) > (
		select avg(f2.fact_total) 
			from Factura as f2
		where year(f2.fact_fecha) = 2012)

	--order by
