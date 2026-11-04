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
on dbo.Item_Factura
instead of insert
as
begin
    -- Una variable por cada columna de Item_Factura
    declare @tipo char(1), @sucursal char(4), @numero char(8),
            @prod char(8), @cant decimal(12,2), @precio decimal(12,2)

    -- Recorre los renglones que se intentaron insertar
    declare cr_items cursor for
        select item_tipo, item_sucursal, item_numero,
               item_producto, item_cantidad, item_precio
        from inserted

    open cr_items
    fetch next from cr_items into @tipo, @sucursal, @numero, @prod, @cant, @precio

    while @@fetch_status = 0
    begin
        print @prod

        fetch next from cr_items into @tipo, @sucursal, @numero, @prod, @cant, @precio
    end

    close cr_items
    deallocate cr_items
end
go

drop trigger tr_validar_stock_en_una_venta