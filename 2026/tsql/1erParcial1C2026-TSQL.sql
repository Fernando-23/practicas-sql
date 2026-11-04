/*

TRANSACT - SQL

Se desea implementar a partir del año 2027, proveedores de productos
de tal modo que pueda ser comprado a más de uno, y un registro de las compras con los envios a los distintos depósitos.

Realizar la implementación en el modelo de datos con su consecuente actualización, 
de tal modo que en una sola transacción se realice la actualización del stock y el llenado de la/s nueva/s tablas.

*/



/*
Se desea implementar a partir del año 2027, proveedores de productos
de tal modo que pueda ser comprado a más de uno, y un registro de las compras con los envios a los distintos depósitos.
*/
create table dbo.Proveedores(
	prv_id char(6) not null,
	constraint PK_Proveedores primary key(prv_id)
)

create table dbo.ProveedoresXProducto(
	provxprod_proveedor char(6) not null,
	provxprod_producto char(8) not null,
	constraint PK_ProveedoresXProducto primary key(provxprod_proveedor,provxprod_producto),
	constraint FK_ProvXProd_proveedor foreign key (provxprod_proveedor) references Proveedores(prv_id),
    constraint FK_ProvXProd_producto foreign key (provxprod_producto) references Producto(prod_codigo)

)

create table dbo.Compra(
	compr_id char(6) not null,
	compr_proveedor char(6) not null,
	compr_fecha smalldatetime not null,

	constraint PK_Compra primary key(compr_id),
	constraint FK_Compra_proveedor foreign key(compr_proveedor) references Proveedores(prv_id),
	
)

create table dbo.Item_Compra(
	itcomp_compra char(6) not null,
	itcomp_producto char(8) not null,
	itcomp_cantidad decimal(12,2),
	
	constraint PK_Item_Compra primary key(itcomp_compra,itcomp_producto),
	constraint FK_Item_Compra_producto foreign key(itcomp_producto) references Producto(prod_codigo),
	constraint FK_Item_Compra_compra foreign key(itcomp_compra) references Compra(compr_id)
)


create table dbo.Envio(
	envio_compra char(6) not null,
	envio_producto char(8) not null,
    envio_deposito char(2) not null,
    envio_cantidad decimal(12,2) not null,
    constraint PK_Envio primary key (envio_compra, envio_producto, envio_deposito),
    constraint FK_Envio_item foreign key (envio_compra, envio_producto)
        references Item_Compra(itcomp_compra, itcomp_producto),
    constraint FK_Envio_deposito foreign key (envio_deposito) references DEPOSITO(depo_codigo)
)
go




/*
Realizar la implementación en el modelo de datos con su consecuente actualización, 
de tal modo que en una sola transacción se realice la actualización del stock y el llenado de la/s nueva/s tablas.
*/
-- compro, que hago?
-- insertar nueva compra
-- insertar item de compra para cada producto comprado
-- ------- de ese item, insertar un nuevo envio asociado al deposito destino
-- ------- de esa cantidad para cada producto, sumarla al stock correspondiente

create or alter procedure sp_registrar_compra
    @compra_id char(6),
    @prov_id   char(6),
    @fecha     smalldatetime,
    @prod_id   char(8),
    @depo_id   char(2),
    @cant      decimal(12,2)
as
begin
    begin try
        begin transaction
            -- 1. Validar que el proveedor vende ese producto
            if not exists (select 1 from ProveedoresXProducto
                           where provxprod_proveedor = @prov_id
                             and provxprod_producto = @prod_id)
                throw 50010, 'El proveedor no vende ese producto', 1;

            -- 2. Insertar la compra si no existe
            if not exists(select 1 from Compra as comp
                           where comp.compr_id = @compra_id)
            insert into Compra(compr_id,compr_proveedor,compr_fecha) values (@compra_id,@prov_id,@fecha) -- la fecha capaz la podria generar
             
            -- 3. Ítem: insertar o sumar cantidad
            if exists(select 1 from Item_Compra as ic
                           where ic.itcomp_compra = @compra_id and ic.itcomp_producto = @prod_id)
                update ic set ic.itcomp_cantidad = ic.itcomp_cantidad + @cant
                from Item_Compra as ic
                where ic.itcomp_compra = @compra_id and ic.itcomp_producto = @prod_id

            else
                insert into Item_Compra(itcomp_compra,itcomp_producto,itcomp_cantidad) values (@compra_id,@prod_id,@cant)

            -- 4. Insertar el envío
            insert into Envio(envio_compra,envio_producto,envio_deposito,envio_cantidad) values (@compra_id,@prod_id,@depo_id,@cant)
            -- 5. Stock: sumar o insertar
            if exists(select 1 from STOCK as s
                    where s.stoc_producto = @prod_id and s.stoc_deposito = @depo_id)
                update s set s.stoc_cantidad = s.stoc_cantidad + @cant
                from STOCK as s
                where s.stoc_producto = @prod_id and s.stoc_deposito = @depo_id
            else insert into STOCK(stoc_cantidad,stoc_producto,stoc_deposito) values (@cant,@prod_id,@depo_id)

        commit transaction
    end try
    begin catch
        rollback transaction;
        throw;
    end catch
end
go