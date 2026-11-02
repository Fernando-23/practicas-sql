/*
2. Implementar una regla de negocio de validación en línea que permita
validar el STOCK al realizarse una venta. Cada venta se debe
descontar sobre el depósito 00. En caso de que se venda un producto
compuesto, el descuento de stock se debe realizar por sus
componentes. Si no hay STOCK para ese artículo, no se deberá
guardar ese articulo, pero si los otros en los cuales hay stock positivo.
Es decir, solamente se deberán guardar aquellos para los cuales si hay
stock, sin guardarse los que no poseen cantidades suficientes.
*/

create or alter trigger tr_validar_stock_en_una_venta
on dbo.Item_factura
instead of insert
as
begin
    select * from inserted
end
go
select top 1 fact_tipo, fact_sucursal, fact_numero from Factura

