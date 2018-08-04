--DECLARE @str varchar(255)

--exec dbo.sp_pm_getTransferParams @str out

--select @str



--truncate table archivo_procesado





--

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
		@aux varchar(max),
		@id int


	SELECT top 1 @aux = ap_string, @id = ap_id
	FROM archivo_procesado 
	WHERE ap_procesado = 'N'
	AND ap_archivo = 'TRANSFER'
	and SUBSTRING(ap_string,1,1) = '2'
	ORDER BY ap_id asc

	select @aux

INSERT INTO dn_tef_recibidas
			values (
				SUBSTRING(@aux,2,3), --[BCO_DEBITO]
				SUBSTRING(@aux,5,8), --[FEC_SOLICITUD]
				SUBSTRING(@aux,13,7), --[NRO_TRANSFERENCIA]
				SUBSTRING(@aux,20,7), --[COD_ABONADO]
				SUBSTRING(@aux,27,2), --[TIPO_OPERACION]
				SUBSTRING(@aux,29,17), --[IMPORTE]
				SUBSTRING(@aux,46,4), --[SUC_DEBITO]
				SUBSTRING(@aux,50,29), --[NOM_SOLICITANTE]
				SUBSTRING(@aux,79,2), --[TIPO_CTA_DEB_RED]
				SUBSTRING(@aux,91,2), --[NRO_CTA_RED]
				SUBSTRING(@aux,83,17), --[CTA_DEBITO]
				SUBSTRING(@aux,100,6), --[FEC_ENVIO_DEBITO]
				SUBSTRING(@aux,106,4), --[HORA_ENVIO_DEBITO]
				SUBSTRING(@aux,110,2), --[OPERADOR_DB_1]
				SUBSTRING(@aux,112,2), --[OPERADOR_DB_2]
				SUBSTRING(@aux,114,4), --[MOTIVO_RECHAZO_DB]
				SUBSTRING(@aux,118,3), --[BCO_CREDITO]
				SUBSTRING(@aux,121,4), --[SUC_CREDITO]
				SUBSTRING(@aux,125,29), --[NOM_BENEFICIARIO]
				SUBSTRING(@aux,154,2), --[TIPO_CTA_CRED_RED]
				SUBSTRING(@aux,156,17), --[CTA_CREDITO]
				SUBSTRING(@aux,163,6), --[FEC_ENVIO_CREDITO]
				SUBSTRING(@aux,169,4), --[HORA_ENVIO_CREDITO]
				SUBSTRING(@aux,183,2), --[OPERADOR_CR_1]
				SUBSTRING(@aux,185,2), --[OPERADOR_CR_2]
				SUBSTRING(@aux,187,4), --[MOTIVO_RECHAZO_CR]
				SUBSTRING(@aux,191,2), --[OPERADOR_INGRESO]
				SUBSTRING(@aux,193,2), --[AUTORIZANTE_1]
				SUBSTRING(@aux,195,2), --[AUTORIZANTE_2]
				SUBSTRING(@aux,197,2), --[AUTORIZANTE_3]
				SUBSTRING(@aux,199,6), --[FECHA_AUTORIZACION]
				SUBSTRING(@aux,205,4), --[HORA_AUTORIZACION]
				SUBSTRING(@aux,209,2), --[ESTADO]
				SUBSTRING(@aux,211,6), --[FEC_ESTADO]
				SUBSTRING(@aux,217,60), --[OBSERVACION_1]
				SUBSTRING(@aux,277,100), --[OBSERVACION_2]
				SUBSTRING(@aux,377,12), --[CLAVE_MAC_1]
				SUBSTRING(@aux,389,12), --[CLAVE_MAC_2]
				SUBSTRING(@aux,401,7), --[NRO_REFERENCIA]
				SUBSTRING(@aux,408,3), --[NRO_ENVIO]
				SUBSTRING(@aux,411,1), --[DEB_CONSOLIDADO]
				SUBSTRING(@aux,412,1), --[TIPO_TITULAR]
				SUBSTRING(@aux,413,1), --[PAGO_PREACORDADO]
				SUBSTRING(@aux,414,1), --[RIESGO_ABONADO]
				SUBSTRING(@aux,415,1), --[RIESGO_BANCO]
				SUBSTRING(@aux,416,100), --[ESTADOS_ANTERIORES]
				SUBSTRING(@aux,516,1), --[CTA_ESP]
				SUBSTRING(@aux,517,11), --[CUITOR]
				SUBSTRING(@aux,528,11) --[CUITCR]
				)
	



