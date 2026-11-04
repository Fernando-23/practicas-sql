/*
Realizar una consulta SQL que devuelva todos los clientes que durante
2 años consecutivos compraron al menos 5 productos distintos.
De esos clientes mostrar:

	1. El codigo de cliente
	2. El monto total comprado
	3. La cantidad de unidades de productos compradas en el 2012

El resultado debe ser ordenado primero por aquellos clientes que compraron
solo productos compuestos en algun momento, luego el resto
*/

select c.clie_codigo,
	(sum(i.item_precio * i.item_cantidad)) as monto_total_comprado,
	(select sum(i2.item_cantidad) from Item_Factura as i2
		join Factura as f2 on f2.fact_numero = i2.item_numero and i2.item_sucursal = f2.fact_sucursal and i2.item_tipo = f2.fact_tipo
		where f2.fact_cliente = c.clie_codigo and year(f2.fact_fecha) = 2012
	)as cant_unidades_prod_compr_en_2012
	
	from Cliente as c
	join Factura as f 
		on f.fact_cliente = c.clie_codigo
	join Item_Factura as i on i.item_numero = f.fact_numero and i.item_sucursal = f.fact_sucursal and i.item_tipo = f.fact_tipo
	
	where exists(select 1 from Factura as f2
				join Item_Factura as i2 on i2.item_numero = f2.fact_numero and i2.item_sucursal = f2.fact_sucursal and i2.item_tipo = f2.fact_tipo
				where f2.fact_cliente = c.clie_codigo --and datediff(year,f.fact_fecha,f2.fact_fecha) = 1
				group by year(f2.fact_fecha)
				having count(distinct i2.item_producto) >= 5)
	group by c.clie_codigo
	
-- El resultado debe ser ordenado primero por aquellos clientes que compraron
-- solo productos compuestos en algun momento, luego el resto
	order by case when exists(select 1 from Factura as f3
        where f3.fact_cliente = c.clie_codigo and not exists(select 1 from Item_Factura as i2
		where i2.item_numero = f3.fact_numero and i2.item_sucursal = f3.fact_sucursal and i2.item_tipo = f3.fact_tipo
                            and i2.item_producto not in (select comp_producto from Composicion))) then 0 else 1 end desc