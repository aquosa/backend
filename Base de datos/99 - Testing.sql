
exec batch.dbo.sp_batch_process 'TRANSFER'

DECLARE @query nvarchar(MAX)
SET @query = 'exec batch.dbo.sp_batch_read_transfer'
exec sp_executesql @query


select * from log_procesos_ejecutados
select * from planificacion_procesos_detalle
select * from archivo_procesado
select * from dn_tef_recibidas

truncate table dn_tef_recibidas
truncate table log_procesos_ejecutados

update archivo_procesado set ap_procesado = 'N'

DECLARE 
	@result varchar(max)
exec sp_pm_getConnectorParams @result out
select @result




select *  from planificacion_procesos_detalle