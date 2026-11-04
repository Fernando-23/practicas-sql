/*
2. Se requiere diseñar e implementar los objetos necesarios para gestionar un
sistema de comisiones de vendedores. La lógica debe contemplar los siguientes
aspectos:
	1. Registro de comisiones:
		• Se debe almacenar la comisión correspondiente a cada vendedor por
		cada factura emitida.
		• El porcentaje de comisión se obtiene de la tabla empl_comision, que
		refleja el porcentaje asignado al vendedor en ese momento.

	2. Manejo de cambios en el porcentaje de comisión:
		• El porcentaje de comisión puede variar a lo largo del tiempo.
		• Sin embargo, dentro de un mismo mes, todas las facturas deben
			aplicar el mismo porcentaje de comisión vigente para ese mes(que es
			el último cargado).

	3. Visualización dinámica:
		• La visualización de la información debe ser dinámica y generarse en 
		cualquier momento a partir de las estructuras estáticas de datos.
		• El sistema debe permitir consultar:
			- El porcentaje de comisión y el monto correspondiente factura por factura.
			- El acumulado mensual de las comisiones para cada vendedor, 
			reflejando los valores calculados en base a las reglas establecidas.
*/

alter table Factura add fact_comision decimal(12,2)
go
update f set f.fact_comision = e.empl_comision
	from Factura as f
	join Empleado as e on e.empl_codigo = f.fact_vendedor
go



create trigger tr_guardar_comision on Factura
after insert
as begin
	update f set f.fact_comision = e.empl_comision
	from inserted as i
		join Factura as f on i.fact_tipo = f.fact_tipo
			and i.fact_sucursal = f.fact_sucursal
			and i.fact_numero = f.fact_numero
		join Empleado as e on e.empl_codigo = i.fact_vendedor
end
go


-- para futuros cambios en el mes
create trigger tr_actualizar_comision on Empleado
after update
as
begin
	update f set f.fact_comision = i.empl_comision
	from inserted as i
	join Factura as f on i.empl_codigo = f.fact_vendedor
	where month(f.fact_fecha) = month(getdate()) and year(f.fact_fecha)=year(getdate())
end
go


create view v_factura_con_comision as
	select 
		f.fact_numero as nro_factura,
		f.fact_comision as porc_comision,
		f.fact_total as monto_total
		from Factura as f
go


create view v_acumulado_para_vendedor as
	select f.fact_vendedor,
		sum(f.fact_comision * f.fact_total) as acumulado_mensual,
		month(f.fact_fecha) as mes,
		year(f.fact_fecha) as anio
		from  Factura as f
		group by f.fact_vendedor,month(f.fact_fecha),year(f.fact_fecha)
go