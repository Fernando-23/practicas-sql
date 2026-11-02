/*
2do Recuperatorio 17/07/2026
Ejercicio 1)
Realice una consulta SQL que devuelva, para cada producto con STOCK positivo
(stoc_cantidad), la siguiente información:

a. Nombre del producto.
b. El período (formato AAAAMM) en el que realizó la mayor cantidad de compras
en unidades.
c. La cantidad de productos compuestos distintos que tiene.

La consulta deberá ordenar los resultados en forma descendente según la cantidad de
facturas en las que se encuentra.
Nota: No se permiten sub-select en el from ni CTES.

*/

select p.prod_detalle as nombre_producto,
	(select top 1 format(f2.fact_fecha,'yyyyMM') 
		from Item_Factura as itf2
		join Factura as f2 on f2.fact_numero = itf2.item_numero and f2.fact_sucursal = itf2.item_sucursal
		and f2.fact_tipo = itf2.item_tipo
		where itf2.item_producto = p.prod_codigo
		group by format(f2.fact_fecha,'yyyyMM')
		order by sum(itf2.item_cantidad) desc) as periodo_mayor_compras,
	(select count(c.comp_producto)from Composicion as c
		where c.comp_producto = p.prod_codigo
	)as cantidad_componentes,
	count(f.fact_numero) as cantidad_facturas_encontradas
	
	from Producto as p
	left join Item_Factura as itf 
		on itf.item_producto = p.prod_codigo
	left join Factura as f 
		on f.fact_numero = itf.item_numero and f.fact_sucursal = itf.item_sucursal
		and f.fact_tipo = itf.item_tipo
	
where p.prod_codigo in 
	(select s.stoc_producto from STOCK as s
		where s.stoc_cantidad > 0)

group by p.prod_codigo, p.prod_detalle
order by cantidad_facturas_encontradas desc