use batch

--select * from dn_tef_recibidas
--select * from archivo_procesado
--select * from dn_tef_conciliacion
--select * from dn_tef_a_enviar

--select * from log_procesos_ejecutados

--exec BorrarDatosTesting


--exec Batch.dbo.sp_batch_read_transfer
--exec Batch.dbo.sp_batch_MAC_transfer
exec Batch.dbo.sp_batch_concilia_transfer
exec Batch.dbo.sp_batch_process_conciliacion