/*
Ejercicio 1)
Realice una consulta SQL que devuelva, para cada cliente, la siguiente información:

a. Razón social del cliente.
b. El período (formato AAAAMM) en el que realizó la mayor cantidad de compras
(en cantidades).
c. La cantidad de productos distintos adquiridos.
d. El importe total facturado.

La consulta deberá ordenar los resultados en forma descendente según la cantidad de
facturas emitidas para cada cliente.
Nota: No se permiten sub-select en el from ni CTES.
*/

select c.clie_razon_social as razon_social,
	(select top 1 format(f2.fact_fecha,'yyyyMM')
		from Factura as f2
		join Item_Factura as itf 
		on f2.fact_numero = itf.item_numero and f2.fact_sucursal = itf.item_sucursal and f2.fact_tipo = itf.item_tipo
		where f2.fact_cliente = c.clie_codigo
		group by format(f2.fact_fecha,'yyyyMM')
		order by sum(itf.item_cantidad) desc) as periodo,
	
	(select count(distinct itf3.item_producto) from Item_Factura as itf3
		join Factura as f3 on f3.fact_numero = itf3.item_numero and f3.fact_sucursal = itf3.item_sucursal and f3.fact_tipo = itf3.item_tipo
		where f3.fact_cliente = c.clie_codigo) as productos_adquiridos,
		

	(select sum(f4.fact_total)  
		from Factura as f4
		where f4.fact_cliente = c.clie_codigo) as total_facturado,

	count(f.fact_numero) as cantidad_facturas_emitidas

	from Cliente as c
	left join Factura as f on f.fact_cliente = c.clie_codigo

group by c.clie_razon_social,c.clie_codigo
order by cantidad_facturas_emitidas desc
