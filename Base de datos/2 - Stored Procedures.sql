Use Batch
--DROP PROCEDURE sp_pm_getTransferParams
CREATE PROCEDURE sp_pm_getTransferParams(
										@result AS varchar(1000) out
										)
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

--DROP PROCEDURE sp_batch_read_transfer
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
	and SUBSTRING(ap_string,1,1) = '2'
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

		SELECT top 1 @aux = ap_string, @id = ap_id
		FROM archivo_procesado 
		WHERE ap_procesado = 'N'
		AND ap_archivo = 'TRANSFER'
		and SUBSTRING(ap_string,1,1) = '2'
		ORDER BY ap_id asc
		
		IF @aux IS NULL BREAK
	END
END

--DROP PROCEDURE sp_batch_process
CREATE PROCEDURE sp_batch_process( @proceso varchar(100) )
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
	WHERE lp_proceso = @proceso
	AND CAST(lp_fecha_ejecucion AS DATE) = CAST(GETDATE() as DATE)

	--No procese nada ni se rompio en el medio
	if @subproceso IS NULL
	BEGIN
		WHILE(1=1)
		BEGIN
			--Busco el total para escribir menos
			SELECT @total = count(*)
			FROM planificacion_procesos_detalle
			WHERE pp_estado = 'A'
			GROUP BY pp_proceso

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
			VALUES (@proceso,@subproceso,@query,GETDATE())

			--Me fijo si tengo que cortar
			IF @total = @actual BREAK
		END
	END
	
END

--DROP PROCEDURE sp_batch_concilia_transfer
CREATE PROCEDURE sp_batch_concilia_transfer 
AS
BEGIN
	
END