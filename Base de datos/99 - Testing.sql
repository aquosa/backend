use batch

--select * from dn_tef_recibidas
--select * from archivo_procesado
--select * from dn_tef_conciliacion
--select * from dn_tef_a_enviar

--select * from log_procesos_ejecutados

--exec BorrarDatosTesting


--exec Batch.dbo.sp_batch_read_transfer
--exec Batch.dbo.sp_batch_MAC_transfer
--exec Batch.dbo.sp_batch_concilia_transfer
--exec Batch.dbo.sp_batch_process_conciliacion



select * from log_procesos_ejecutados

select * from archivo_procesado

DECLARE @result varchar(100)
exec sp_pm_getOfferingParams @result out
select @result


select * from dn_offering

delete from dn_offering

borrardatostesting

select * from archivo_procesado

select * from dn_tef_recibidas
select * from dn_offering
select * from dn_abonados_cuentas