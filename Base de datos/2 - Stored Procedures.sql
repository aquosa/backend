Use Batch
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_pm_getTransferParams') IS NOT NULL
    DROP PROCEDURE sp_pm_getTransferParams
GO
CREATE PROCEDURE sp_pm_getTransferParams( @result AS varchar(1000) out	)
AS
BEGIN
	--Variables
	DECLARE 
			@nombre varchar(255),
			@path varchar(255),
			@insertQuery varchar(255),
			@execQuery varchar(255),
			@insertQueryb64 varchar(255),
			@execQueryb64 varchar(255),
			@ebcdic char

			

	--Parametria correspondiente al archivo
	SELECT @path = pe_path_archivo, @nombre = pe_nombre_archivo, @ebcdic = pe_ebcdic
	FROM Batch..parametria_archivos_entrada_interbanking
	WHERE pe_archivo = 'TRANSFER'

	--Query para insertar
	SELECT @insertQueryb64 = qr_query
	FROM Batch..backend_querys
	WHERE qr_archivo = 'TRANSFER'
	and qr_funcion = 'insert'
	
	--Query para procesar
	SELECT @execQueryb64 = qr_query
	FROM Batch..backend_querys
	WHERE qr_archivo = 'TRANSFER'
	and qr_funcion = 'process'

	--Desencripto los querys
	select @insertQuery = Batch.dbo.fn_str_FROM_BASE64(@insertQueryb64);
	select @execQuery = Batch.dbo.fn_str_FROM_BASE64(@execQueryb64);

	--Armado de string para que el batch parsee
	SET @result = @nombre + '|' + @path + '|' + @ebcdic + '|' + @insertQuery + '|' + @execQuery  

	--Vuelvo a encriptar y las recibe el batch
	SET @result = Batch.dbo.fn_str_TO_BASE64(@result);
END
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_batch_read_transfer') IS NOT NULL
    DROP PROCEDURE sp_batch_read_transfer
GO
CREATE PROCEDURE sp_batch_read_transfer
AS
BEGIN
	DECLARE 
		@aux varchar(max),
		@id int

	SELECT top 1 @aux = ap_string, @id = ap_id
	FROM archivo_procesado 
	WHERE ap_procesado = 'N'
	AND ap_archivo = 'TRANSFER'
	and SUBSTRING(ap_string,1,1) = '2' --Aca estoy filtrando los header y footer
	ORDER BY ap_id asc

	WHILE (1=1)
	BEGIN
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

		UPDATE archivo_procesado SET ap_procesado = 'S' WHERE ap_id = @id

		SET @aux = NULL

		--Hay que corregir este break porque me inserta una fila de nulls
		SELECT top 1 @aux = ap_string, @id = ap_id
		FROM archivo_procesado 
		WHERE ap_procesado = 'N'
		AND ap_archivo = 'TRANSFER'
		and SUBSTRING(ap_string,1,1) = '2'
		ORDER BY ap_id asc
		
		IF @@ROWCOUNT = 0 BREAK
	END
END

GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_batch_process') IS NOT NULL
    DROP PROCEDURE sp_batch_process
GO
CREATE PROCEDURE sp_batch_process
--( @proceso varchar(100) ) FALTA GENERALIZAR los procesos
AS
BEGIN
	DECLARE
		@subproceso varchar(20),
		@query nvarchar(255),
		@id int,
		@total int,
		@actual int,
		@result int

	--Inicializacion
	SET @total = 0
	SET @actual = 0

	--Me fijo en la tabla de logeo si ya hice alguno hoy
	SELECT @subproceso = lp_subproceso, @query = lp_query
	FROM log_procesos_ejecutados
	--WHERE lp_proceso = @proceso
	WHERE lp_proceso = 'TRANSFER'
	AND CAST(lp_fecha_ejecucion AS DATE) = CAST(GETDATE() as DATE)

	--Busco el total para escribir menos
	SELECT @total = count(*)
	FROM planificacion_procesos_detalle
	WHERE pp_estado = 'A'
	GROUP BY pp_proceso

	--No procese nada ni se rompio en el medio
	if @subproceso IS NULL
	BEGIN
		WHILE(1=1)
		BEGIN

			--Busco en la tabla de proceso que es lo que tengo que hacer
			SELECT top 1 @id = pp_id, @query = pp_query
			FROM planificacion_procesos_detalle
			WHERE pp_proceso = 'TRANSFER'
			and pp_estado = 'A'
			ORDER BY pp_id asc

			--Corro el query que me traje
			exec sp_executesql @query

			--Aumento una vez que corri
			SET @actual = @actual + 1

			--Logeo la operacion
			INSERT INTO log_procesos_ejecutados 
			--VALUES (@proceso,@subproceso,@query,GETDATE())
			VALUES ('TRANSFER',@subproceso,@query,GETDATE())

			--Me fijo si tengo que cortar
			IF @total = @actual BREAK
		END
	END
	--ELSE -- Hay algo que reprocesar

END

GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_batch_concilia_transfer') IS NOT NULL
    DROP PROCEDURE sp_batch_concilia_transfer
GO
CREATE PROCEDURE sp_batch_concilia_transfer 
AS
BEGIN
	-- Variables
	DECLARE 
	@campos_tef_enviar varchar(255),
	@filler	varchar(365),
	@query varchar(max),
	@reglaCreditos varchar(max),
	@tranCodeCredito varchar(10),
	@reglaReversoCreditos varchar(max),
	@reglaDebitos varchar(max),
	@tranCodeDebito varchar(10),
	@reglaReversoDebitos varchar(max),
	@reglaMonobanco varchar(max),
	@tranCodeMonobanco varchar(10),
	@reglaReversoMonobanco varchar(max),
	@proceso varchar(30),
	@subproceso varchar(20);

	--Inicializacion
	SET @campos_tef_enviar =	'[NRO_TRANSFERENCIA], [FEC_SOLICITUD], [BCO_DEBITO], [BCO_CREDITO],
								 [NRO_REFERENCIA], [CTA_DEBITO], [CTA_CREDITO], [IMPORTE], ''0200'' ';

	SET @proceso = 'TRANSFER';
	SET @subproceso = 'CONCILIA';

	--Tran Code para creditos
	SELECT	@tranCodeCredito = pt_valor
	FROM	parametria_tran_code
	WHERE	pt_tipo = 'TCE' 

	--Tran Code para debitos
	SELECT	@tranCodeDebito = pt_valor
	FROM	parametria_tran_code
	WHERE	pt_tipo = 'TDE' 

	--Tran Code para creditos
	SELECT	@tranCodeMonobanco = pt_valor
	FROM	parametria_tran_code
	WHERE	pt_tipo = 'TDEM' 

	-- Borro todo lo que hay en la tabla de conciliacion
	TRUNCATE TABLE dn_tef_conciliacion

	-- Inserto TEF ONLINE en TEF CONCILIACION
	INSERT INTO dn_tef_conciliacion
	(	[BCO_DEBITO],[FEC_SOLICITUD],[NRO_TRANSFERENCIA],[COD_ABONADO],[TIPO_OPERACION],[IMPORTE],[SUC_DEBITO],[NOM_SOLICITANTE],[TIPO_CTA_DEB_RED],
		[NRO_CTA_RED],[CTA_DEBITO],[FEC_ENVIO_DEBITO],[HORA_ENVIO_DEBITO],[OPERADOR_DB_1],[OPERADOR_DB_2],[MOTIVO_RECHAZO_DB],
		[BCO_CREDITO],[SUC_CREDITO],[NOM_BENEFICIARIO],[TIPO_CTA_CRED_RED],[CTA_CREDITO],[FEC_ENVIO_CREDITO],[HORA_ENVIO_CREDITO],[OPERADOR_CR_1],[OPERADOR_CR_2],[MOTIVO_RECHAZO_CR],
		[OPERADOR_INGRESO],[AUTORIZANTE_1],[AUTORIZANTE_2],[AUTORIZANTE_3],[FECHA_AUTORIZACION],[HORA_AUTORIZACION],[ESTADO_ONLINE],[FEC_ESTADO],
		[OBSERVACION_1],[OBSERVACION_2],[CLAVE_MAC_1],[NRO_REFERENCIA],[NRO_ENVIO],[DEB_CONSOLIDADO],[TIPO_TITULAR],[PAGO_PREACORDADO],
		[RIESGO_ABONADO],[RIESGO_BANCO],[ESTADOS_ANTERIORES],[CTA_ESP],[CUITOR],[CUITCR]
	)
	SELECT 
		[BCO_DEBITO],[FEC_SOLICITUD],[NRO_TRANSFERENCIA],[COD_ABONADO],[TIPO_OPERACION],[IMPORTE],[SUC_DEBITO],[NOM_SOLICITANTE],[TIPO_CTA_DEB_RED],
		[NRO_CTA_RED],[CTA_DEBITO],[FEC_ENVIO_DEBITO],[HORA_ENVIO_DEBITO],[OPERADOR_DB_1],[OPERADOR_DB_2],[MOTIVO_RECHAZO_DB],
		[BCO_CREDITO],[SUC_CREDITO],[NOM_BENEFICIARIO],[TIPO_CTA_CRED_RED],[CTA_CREDITO],[FEC_ENVIO_CREDITO],[HORA_ENVIO_CREDITO],[OPERADOR_CR_1],[OPERADOR_CR_2],[MOTIVO_RECHAZO_CR],
		[OPERADOR_INGRESO],[AUTORIZANTE_1],[AUTORIZANTE_2],[AUTORIZANTE_3],[FECHA_AUTORIZACION],[HORA_AUTORIZACION],[ESTADO],[FEC_ESTADO],
		[OBSERVACION_1],[OBSERVACION_2],[CLAVE_MAC],[NRO_REFERENCIA],[NRO_ENVIO],[DEB_CONSOLIDADO],[TIPO_TITULAR],[PAGO_PREACORDADO],
		[RIESGO_ABONADO],[RIESGO_BANCO],[ESTADOS_ANTERIORES],[CTA_ESP],[CUITOR],[CUITCR]
	FROM dn_tef_online
	
	-- updateo tef conciliacion con el estado de TEF recibidas
	UPDATE dn_tef_conciliacion
	SET ESTADO_BATCH = ESTADO
	FROM dn_tef_conciliacion
	JOIN dn_tef_recibidas
	ON	dn_tef_recibidas.NRO_TRANSFERENCIA = dn_tef_conciliacion.NRO_TRANSFERENCIA
	AND dn_tef_recibidas.FEC_SOLICITUD = dn_tef_conciliacion.FEC_SOLICITUD

	-- inserto las que no esten en online
	INSERT INTO dn_tef_conciliacion
	(	[BCO_DEBITO],[FEC_SOLICITUD],[NRO_TRANSFERENCIA],[COD_ABONADO],[TIPO_OPERACION],[IMPORTE],[SUC_DEBITO],[NOM_SOLICITANTE],[TIPO_CTA_DEB_RED],
		[NRO_CTA_RED],[CTA_DEBITO],[FEC_ENVIO_DEBITO],[HORA_ENVIO_DEBITO],[OPERADOR_DB_1],[OPERADOR_DB_2],[MOTIVO_RECHAZO_DB],
		[BCO_CREDITO],[SUC_CREDITO],[NOM_BENEFICIARIO],[TIPO_CTA_CRED_RED],[CTA_CREDITO],[FEC_ENVIO_CREDITO],[HORA_ENVIO_CREDITO],[OPERADOR_CR_1],[OPERADOR_CR_2],[MOTIVO_RECHAZO_CR],
		[OPERADOR_INGRESO],[AUTORIZANTE_1],[AUTORIZANTE_2],[AUTORIZANTE_3],[FECHA_AUTORIZACION],[HORA_AUTORIZACION],[ESTADO_BATCH],[FEC_ESTADO],
		[OBSERVACION_1],[OBSERVACION_2],[CLAVE_MAC_1],[CLAVE_MAC_2],[NRO_REFERENCIA],[NRO_ENVIO],[DEB_CONSOLIDADO],[TIPO_TITULAR],[PAGO_PREACORDADO],
		[RIESGO_ABONADO],[RIESGO_BANCO],[ESTADOS_ANTERIORES],[CTA_ESP],[CUITOR],[CUITCR]
	)
	SELECT 
		[BCO_DEBITO],[FEC_SOLICITUD],[NRO_TRANSFERENCIA],[COD_ABONADO],[TIPO_OPERACION],[IMPORTE],[SUC_DEBITO],[NOM_SOLICITANTE],[TIPO_CTA_DEB_RED],
		[NRO_CTA_RED],[CTA_DEBITO],[FEC_ENVIO_DEBITO],[HORA_ENVIO_DEBITO],[OPERADOR_DB_1],[OPERADOR_DB_2],[MOTIVO_RECHAZO_DB],
		[BCO_CREDITO],[SUC_CREDITO],[NOM_BENEFICIARIO],[TIPO_CTA_CRED_RED],[CTA_CREDITO],[FEC_ENVIO_CREDITO],[HORA_ENVIO_CREDITO],[OPERADOR_CR_1],[OPERADOR_CR_2],[MOTIVO_RECHAZO_CR],
		[OPERADOR_INGRESO],[AUTORIZANTE_1],[AUTORIZANTE_2],[AUTORIZANTE_3],[FECHA_AUTORIZACION],[HORA_AUTORIZACION],[ESTADO],[FEC_ESTADO],
		[OBSERVACION_1],[OBSERVACION_2],[CLAVE_MAC_1],[CLAVE_MAC_2],[NRO_REFERENCIA],[NRO_ENVIO],[DEB_CONSOLIDADO],[TIPO_TITULAR],[PAGO_PREACORDADO],
		[RIESGO_ABONADO],[RIESGO_BANCO],[ESTADOS_ANTERIORES],[CTA_ESP],[CUITOR],[CUITCR]
	FROM dn_tef_recibidas
	WHERE dn_tef_recibidas.NRO_TRANSFERENCIA not in (
														SELECT NRO_TRANSFERENCIA 
														FROM dn_tef_conciliacion
													)
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
	-- CREDITOS (TCE)
	-- Busco regla para creditos
	SELECT @reglaCreditos = rv_regla
	FROM	parametria_reglas_validacion
	WHERE	rv_tipo = 'TCE'
	AND		rv_proceso = @proceso
	AND		rv_subproceso = @subproceso
	AND		rv_estado = 'A'
	
	-- Seteo el Query que voy a ejecutar
	SET @query = ' 	INSERT INTO dn_tef_a_enviar [NRO_TRANSFERENCIA], [FEC_SOLICITUD], [BCO_DEBITO], [BCO_CREDITO],
												[NRO_REFERENCIA], [CTA_DEBITO], [CTA_CREDITO], [IMPORTE], [TIPO_MOVIMIENTO] , [TRAN_CODE]
					SELECT ' + @campos_tef_enviar + @tranCodeCredito + ' FROM dn_tef_conciliacion 
					WHERE ' + @reglaCreditos

	-- Ejecuto el query
	EXEC sp_executesql @query
					
	--Logeo la operacion
	INSERT INTO log_procesos_ejecutados 
	VALUES (@proceso,@subproceso,@query,GETDATE())

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
	-- REVERSO CREDITOS (TCER)
	-- Busco regla para reverso de creditos
	SELECT @reglaReversoCreditos = rv_regla
	FROM	parametria_reglas_validacion
	WHERE	rv_tipo = 'TCER'
	AND		rv_proceso = @proceso
	AND		rv_subproceso = @subproceso
	AND		rv_estado = 'A'
	
	-- Seteo el Query que voy a ejecutar
	SET @query = ' 	INSERT INTO dn_tef_a_enviar [NRO_TRANSFERENCIA], [FEC_SOLICITUD], [BCO_DEBITO], [BCO_CREDITO],
												[NRO_REFERENCIA], [CTA_DEBITO], [CTA_CREDITO], [IMPORTE], [TIPO_MOVIMIENTO] , [TRAN_CODE]
					SELECT ' + @campos_tef_enviar + @tranCodeCredito + ' FROM dn_tef_conciliacion 
					WHERE ' + @reglaReversoCreditos

	-- Ejecuto el query
	EXEC sp_executesql @query

	--Logeo la operacion
	INSERT INTO log_procesos_ejecutados 
	VALUES (@proceso,@subproceso,@query,GETDATE())

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
	-- DEBITOS (TDE)
	-- Busco regla para creditos
	SELECT @reglaDebitos = rv_regla
	FROM	parametria_reglas_validacion
	WHERE	rv_tipo = 'TDE'
	AND		rv_proceso = @proceso
	AND		rv_subproceso = @subproceso
	AND		rv_estado = 'A'
	
	-- Seteo el Query que voy a ejecutar
	SET @query = ' 	INSERT INTO dn_tef_a_enviar [NRO_TRANSFERENCIA], [FEC_SOLICITUD], [BCO_DEBITO], [BCO_CREDITO],
												[NRO_REFERENCIA], [CTA_DEBITO], [CTA_CREDITO], [IMPORTE], [TIPO_MOVIMIENTO], [TRAN_CODE] 
					SELECT ' + @campos_tef_enviar + @tranCodeCredito + ' FROM dn_tef_conciliacion 
					WHERE ' + @reglaDebitos

	-- Ejecuto el query
	EXEC sp_executesql @query
					
	--Logeo la operacion
	INSERT INTO log_procesos_ejecutados 
	VALUES (@proceso,@subproceso,@query,GETDATE())

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
	-- REVERSO CREDITOS (TDER)
	-- Busco regla para reverso de creditos
	SELECT @reglaReversoDebitos = rv_regla
	FROM	parametria_reglas_validacion
	WHERE	rv_tipo = 'TDER'
	AND		rv_proceso = @proceso
	AND		rv_subproceso = @subproceso
	AND		rv_estado = 'A'
	
	-- Seteo el Query que voy a ejecutar
	SET @query = ' 	INSERT INTO dn_tef_a_enviar [NRO_TRANSFERENCIA], [FEC_SOLICITUD], [BCO_DEBITO], [BCO_CREDITO],
												[NRO_REFERENCIA], [CTA_DEBITO], [CTA_CREDITO], [IMPORTE], [TIPO_MOVIMIENTO] , [TRAN_CODE]
					SELECT ' + @campos_tef_enviar + @tranCodeCredito + ' FROM dn_tef_conciliacion 
					WHERE ' + @reglaReversoDebitos

	-- Ejecuto el query
	EXEC sp_executesql @query
	
	--Logeo la operacion
	INSERT INTO log_procesos_ejecutados 
	VALUES (@proceso,@subproceso,@query,GETDATE())

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

	-- Terminada la conciliacion, largo el proceso para generar los movimientos que se van a enviar al CORE
	-- no deberia estar hardcodeado, deberia estar como otro subproceso
	--EXEC sp_batch_process_conciliacion

END
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_pm_getConnectorParams') IS NOT NULL
    DROP PROCEDURE sp_pm_getConnectorParams
GO
CREATE PROCEDURE sp_pm_getConnectorParams( @result AS varchar(8000) out )
AS
BEGIN
	--Variables
	DECLARE 
			@tipo_conector varchar(255),
			@selectquery varchar(255),
			@insertQuery varchar(255),
			@execQuery varchar(255),
			@insertQueryb64 varchar(255),
			@execQueryb64 varchar(255),
			@selectQueryb64 varchar(255)			

	--Parametria correspondiente al tipo de conector a usar por el batch
	SELECT @tipo_conector = pc_tipo_conector
	FROM Batch..parametria_conector_core
	WHERE pc_proceso = 'BATCH'

	--Query para insertar
	SELECT @insertQueryb64 = qr_query
	FROM Batch..backend_querys
	WHERE qr_archivo = 'ENVIO_CORE'
	and qr_funcion = 'insert'
	
	--Query para procesar
	SELECT @execQueryb64 = qr_query
	FROM Batch..backend_querys
	WHERE qr_archivo = 'ENVIO_CORE'
	and qr_funcion = 'process'

	--Query para seleccionar
	SELECT @selectQueryb64 = qr_query
	FROM Batch..backend_querys
	WHERE qr_archivo = 'ENVIO_CORE'
	and qr_funcion = 'select'

	--Desencripto los querys
	select @insertQuery = Batch.dbo.fn_str_FROM_BASE64(@insertQueryb64);
	select @execQuery = Batch.dbo.fn_str_FROM_BASE64(@execQueryb64);
	select @selectQuery = Batch.dbo.fn_str_FROM_BASE64(@selectQueryb64);

	--Armado de string para que el batch parsee
	SET @result = @tipo_conector + '|' + @selectquery + '|' + @insertQuery + '|' + @execQuery  

	--Vuelvo a encriptar y las recibe el batch
	SET @result = Batch.dbo.fn_str_TO_BASE64(@result);
END
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_pm_getConnectorSpecParams') IS NOT NULL
    DROP PROCEDURE sp_pm_getConnectorSpecParams
GO
CREATE PROCEDURE sp_pm_getConnectorSpecParams( @result AS varchar(8000) out )
AS
BEGIN
	--Parametria correspondiente al tipo de conector a usar por el batch
	SELECT @result = ps_string
	FROM Batch..parametria_spec_conector_core
	WHERE ps_proceso = 'BATCH'

	--Vuelvo a encriptar y las recibe el batch
	SET @result = Batch.dbo.fn_str_TO_BASE64(@result);
END
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_batch_process_core_respuesta') IS NOT NULL
    DROP PROCEDURE sp_batch_process_core_respuesta
GO
CREATE PROCEDURE sp_batch_process_core_respuesta (@result as varchar(8000) out)
AS 
BEGIN

SELECT 1 from parametria_tran_code
	
END
GO
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF object_id('sp_batch_process_conciliacion') IS NOT NULL
    DROP PROCEDURE sp_batch_process_conciliacion
GO
CREATE PROCEDURE sp_batch_process_conciliacion (@result as varchar(8000) out)
AS
BEGIN

	-- Antes que nada, completo el filler
	--"N" FIJO + CUITDB[11] + CUITCR[11] + Concepto[3]+Comprobante asociado al pago[22]+Descripción adicional del motivo del pago[60]
	UPDATE dn_tef_a_enviar
	SET FILLER = CONCAT('N',
						CUITOR,
						CUITCR,
						RIGHT('000'+ISNULL(TIPO_OPERACION,''),3),
						RIGHT('                      '+ISNULL(dbo.dn_tef_conciliacion.NRO_REFERENCIA,''),22),
						RIGHT('                                                            '+ISNULL(OBSERVACION_2,''),60))
	FROM dn_tef_a_enviar
	JOIN dn_tef_conciliacion
	ON dn_tef_conciliacion.NRO_TRANSFERENCIA = dn_tef_a_enviar.NRO_TRANSFERENCIA
	AND dn_tef_conciliacion.FEC_SOLICITUD = dn_tef_a_enviar.FEC_SOLICITUD

	-- Ahora que tengo todos los campos completos, armo un string gigante y lo meto en la tabla correspondiente
	INSERT INTO envio_core_generado (ec_fecha_generacion, ec_fecha_ult_modificacion, ec_estado, ec_string)
	SELECT GETDATE(), GETDATE(), 'P', CONCAT(		
												'000000',														--	chBLOCK_INI_TLF	0	000000
												'HOST24',														--	PREFIX1	6	HOST24
												'99',															--	PREFIX2	2	99
												CONVERT(varchar,GETDATE(),112),									--	DAT_TIM	19	YYYYMMDD  
												'01',															--	REC_TYP	2	01
												'H24',															--	AUTH_PPD	4	H24
												'DPS',															--	TERM_LN	4	DPS 
												BCO_DEBITO,														--	TERM_FIID	4	XXX
												'0000000000000000',												--  TERM_ID	16	0000000000000000
												'0000',															--	CARD_LN	4	0000
												BCO_CREDITO,													--	CARD_FIID	4	XXX
												'0000000000000000000000000000',									--  CARD_PAN	28	0000000000000000000000000000
												'000',															--	CARD_MBR_NUM	3	000
												'0000',															--	BRCH_ID	4	0000
												'0000',															--	REGN_ID	4	0000
												'00',															--	USER_FLD1X	2	00
												'31',															--	TYP_CDE	2	31
												TIPO_MOVIMIENTO,												--	TYP	4	XXXX
												'00',															--	RTE_STAT	2	00
												'5',															--	ORIGINATOR	1	5
												'5',															--	RESPONDER	1	5
												CONVERT(varchar,GETDATE(),112),									--	ENTRY_TIM	19	YYYYMMDD 
												'0000000000000000000',											--	EXIT_TIM	19	0000000000000000000
												'0000000000000000000',											--	RE_ENTRY_TIM	19	0000000000000000000
												CONVERT(varchar,GETDATE(),112),									--	TRAN_DAT	6	YYMMDD 
												'000000',														--	TRAN_TIM	8	000000
												CONVERT(varchar,GETDATE(),112),									--	POST_DAT	6	YYMMDD
												'000000',														--	ACQ_ICHG_SETL_DAT	6	000000
												'000000',														--	ISS_ICHG_SETL_DAT	6	000000
												RIGHT('000000000000'+ISNULL(NRO_TRANSFERENCIA,''),12),			--	SEQ_NUM	12	000000000000
												'00',															--	TERM_TYP	2	00
												'00000',														--	TIM_OFST	5	00000
												RIGHT('00000000000'+ISNULL(NRO_REFERENCIA,''),11),				--	ACQ_INST_ID_NUM	11	XXXXXXXX
												'00000000000',													--	RCV_INST_ID_NUM	11	00000000000
												RIGHT('000000'+ISNULL(TRAN_CODE,''),6),							--	TRAN_CDE	6	XXDDFF
												RIGHT('0000000000000000000000000000'+ISNULL(CTA_DEBITO,''),28),	--	FROM_ACCT	28	XXXXXXXXXXXX
												'0',															--	TIPO_DEP	1	0
												RIGHT('0000000000000000000000000000'+ISNULL(CTA_CREDITO,''),28),--	TO_ACCT	28	XXXXXXXXXXXX
												'N',															--	ULT_ACCT	1	N
												RIGHT('0000000000000000000'+ISNULL(IMPORTE,''),19),				--	AMT_1	19	IMPORTE MOVIMIENTO
												'0000000000000000000',											--	AMT_2	19	0000000000000000000
												'0000000000000000000',											--	AMT_3	19	0000000000000000000
												'0000000000',													--	FILLER1	10	0000000000
												'0',															--	DEP_TYP	1	0
												'000',															--	RESP_CDE	3	COD RESPUESTA TRX = 000 (OK)
												'0000000000000000000000000',									--	TERM_NAME_LOC	25	0000000000000000000000000
												'0000000000000000000000',										--	TERM_OWNER_NAME	22	0000000000000000000000
												'0000000000000',												--	TERM_CITY	13	0000000000000
												'000',															--	TERM_ST_X	3	000
												'00',															--	TERM_CNTRY_X	2	00
												'000000000000',													--	OSEQ_NUM	12	000000000000
												'0000',															--	OTRAN_DAT	4	0000
												'00000000',														--	OTRAN_TIM	8	00000000
												'0000',															--	B24_POST_DAY	4	0000
												'000',															--	ORIG_CRNCY_CDE	3	000
												'0000000000000000000000',										--	DATA	22	0000000000000000000000
												'00000000',														--	TIP_EXCHA_VEND	8	00000000
												'00000000000',													--	FILLER3	11	00000000000
												'00',															--	RVSL_RSN	2	00
												'0000000000000000',												--	PIN_OFST	16	0000000000000000
												'0',															--	SHRG_GRP	1	0
												FILLER)															--	FILLER4	365	N + XXXX + XXX
					FROM dn_tef_a_enviar
END
GO
