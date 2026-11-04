/*

2. Se desea crear una vista denominada v_item_factura que permita visualizar, para
cada ítem de una factura, la identificación de la factura, el nombre del producto, el
precio unitario, la cantidad y el total correspondiente a ese ítem.

Sin embargo, se solicita eliminar físicamente los campos item_precio e item_total de
la tabla item_factura, ya que se considera que dichos valores no deben almacenarse
más en esa tabla. Además, no está permitido agregar nuevos campos
a item_factura.

¿Qué debería implementarse para que la vista v_item_factura pueda mostrar en
todo momento la información requerida, tanto para los datos actuales como para los
futuros?

*/

-- creo la nueva tabla pre migrar
create table dbo.Datos_prod_item_factura(
	datoit_tipo char(1) not null,
	datoit_sucursal char(4) not null,
	datoit_numero char(8) not null,
	datoit_item_producto char(8) not null,
	datoit_precio decimal(12,2),
	datoit_total decimal(12,2),
	
	constraint PK_Datos_prod_item_factura primary key(datoit_tipo,datoit_sucursal,datoit_numero,datoit_item_producto),
	
	constraint FK_Datos_prod_item_factura
		foreign key(datoit_tipo,datoit_sucursal,datoit_numero,datoit_item_producto) 
		references Item_Factura(item_tipo,item_sucursal,item_numero,item_producto)
)
go

-- -------para ir probando-------
-- drop table Datos_prod_item_factura
-- ------------------------------

-- ahora sii migro
insert into Datos_prod_item_factura(datoit_tipo,datoit_sucursal,datoit_numero,datoit_item_producto,datoit_precio,datoit_total)
	select i.item_tipo,i.item_sucursal,i.item_numero,i.item_producto,i.item_precio,(i.item_cantidad*i.item_precio) from Item_Factura as i
go
	
-- hacemo como te hacen a vos (a mi) en el amor con item_precio, "ya no quiero verte nunca mas"
alter table Item_Factura drop column item_precio
go

-- para los nuevos datosss
create or alter trigger tr_guardar_precio_item_factura_precio
on Item_Factura
after insert
as
begin	
	insert into Datos_prod_item_factura(datoit_tipo,datoit_sucursal,datoit_numero,datoit_item_producto,datoit_precio,datoit_total)
	select ins.item_tipo,ins.item_sucursal,ins.item_numero,ins.item_producto,p.prod_precio,(ins.item_cantidad*p.prod_precio) from inserted as ins
		join Producto as p on p.prod_codigo = ins.item_producto
end
go


-- la vista en si
create or alter view v_item_factura as
	select dp.datoit_numero,p.prod_detalle,dp.datoit_precio,i.item_cantidad,dp.datoit_total from Datos_prod_item_factura as dp
		join Item_Factura as i 
			on i.item_numero = dp.datoit_numero and i.item_sucursal = dp.datoit_sucursal 
			and i.item_tipo = dp.datoit_tipo and i.item_producto = dp.datoit_item_producto
		join Producto as p on p.prod_codigo = i.item_producto
go

-- ----pa ver la view
--select * from v_item_factura
