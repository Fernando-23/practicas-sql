/*
2. Suponiendo que se aplican los siguientes cambios en el modelo de datos:

	Cambio 1) create table Provincia (pcia_id int primary key, pcia_nombre char(100));
	Cambio 2) alter table cliente add pcia_id int null;

Crear el/los objetos necesarios para implementar el concepto de foreign
key entre cliente y provincia.

Nota: No se permite agregar una constraint de tipo FOREIGN KEY entre la
tabla y el campo agregado.
*/

create or alter trigger tr_fk_cliente_provincia on Cliente
after insert, update
as
begin
    if exists (select 1 from inserted as i
               where i.pcia_id is not null
                 and not exists (select 1 from Provincia as p
                                 where i.pcia_id = p.pcia_id))
    begin
        rollback;
        -- throw 50001, 'La provincia no existe', 1;
    end
end
go

create or alter trigger tr_delete_provincia on Provincia
after delete, update
as
begin
    if exists(select 1 from deleted as d                    --caso update
        join Cliente as c on c.pcia_id = d.pcia_id  -- che tenes clientes
        where not exists (select 1 from inserted as i   --y ademas sos distinto al insertado
                             where i.pcia_id = d.pcia_id))               
        begin 
            rollback;
            throw 50001,'No se puede cambiar el id de una provincia con clientes',1;

        return
        end
      
    if exists(select 1 from deleted as d                    --caso delete
        join Cliente as c on c.pcia_id = d.pcia_id)
        begin
            rollback;
            throw 50001,'Hay clientes referenciando a la provincia a eliminar',1;
        end 
end
go


/*

delete p from Provincia as p 
    join deleted as d on p.pcia_id = d.pcia_id

*/