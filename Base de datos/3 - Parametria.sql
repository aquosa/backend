use Batch

DECLARE @path varchar(255)
SET @path = 'E:\\AQUOSA\\backend\\Backend\\Debug'
--SET @path  = 'C:\\Banksys\\Batch\\input'

--Borro datos de las tablas si ya existen
TRUNCATE TABLE [dbo].[parametria_archivos_entrada_interbanking]
TRUNCATE TABLE [dbo].[planificacion_procesos_detalle]
TRUNCATE TABLE [dbo].[parametria_conector_core] 
TRUNCATE TABLE [dbo].[parametria_spec_conector_core]
TRUNCATE TABLE [dbo].[parametria_tran_code]
TRUNCATE TABLE [dbo].[parametria_reglas_validacion]

--Parametria para los archivos de input del cierre del dia de interbanking (TRANSFER, OFFERING, CUENTAS)
INSERT INTO [dbo].[parametria_archivos_entrada_interbanking] VALUES ('PTRANSF147.dat',@path, 'Parametria para archivo de transferencias de Interbanking','TRANSFER','N')
INSERT INTO [dbo].[parametria_archivos_entrada_interbanking] VALUES ('QABCO285S.QOFFERI285',@path, 'Parametria para archivo de Offering de Interbanking','OFFERING','N')
INSERT INTO [dbo].[parametria_archivos_entrada_interbanking] VALUES ('QABCO285S.QCUENTA285',@path, 'Parametria para archivo de Abonados-Cuentas de Interbanking','ACCOUNT','N')


--Parametria para los querys que tiene que ejecutar el backend para cada etapa del proceso
--Transfer
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('INSERT INTO Batch..archivo_procesado (ap_archivo,ap_string,ap_fecha_ult_modificacion) values (''TRANSFER'',?,GETDATE())'),'Insercion de TRANSFER recibido',GETDATE(),'TRANSFER','insert')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('exec sp_batch_process'),'Procesamiento de TRANSFER recibido',GETDATE(),'TRANSFER','process')

--Offering
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('INSERT INTO Batch..archivo_procesado (ap_archivo,ap_string,ap_fecha_ult_modificacion) values (''OFFERING'',?,GETDATE())'),'Insercion de OFFERING recibido',GETDATE(),'OFFERING','insert')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('exec sp_batch_process_offering'),'Procesamiento de OFFERING recibido',GETDATE(),'OFFERING','process')

--Account
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('INSERT INTO Batch..archivo_procesado (ap_archivo,ap_string,ap_fecha_ult_modificacion) values (''ACCOUNT'',?,GETDATE())'),'Insercion de ACCOUNT recibido',GETDATE(),'ACCOUNT','insert')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('exec sp_batch_process_account'),'Procesamiento de ACCOUNT recibido',GETDATE(),'ACCOUNT','process')

--Conector TCP
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('SELECT ec_string FROM Batch..envio_core_generado'),'Seleccion de transferencias resultantes de la conciliacion',GETDATE(),'ENVIO_CORE','select')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('INSERT INTO envio_core_respuesta (er_proceso,er_fecha_ult_modificacion,er_string) values (''BATCH'',GETDATE(),?)'),'Insercion de respuestas del envio de las transferencias conciliadas al CORE',GETDATE(),'ENVIO_CORE','insert')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('exec sp_batch_process_core_respuesta'),'Procesamiento de respuestas del CORE de transferencias resultantes de la conciliacion',GETDATE(),'ENVIO_CORE','process')

--Parametria para planificador de procesos
--Transfer
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','LECTURA','exec Batch.dbo.sp_batch_read_transfer',GETDATE(),'Generacion de tabla de transferencias recibidas','A')
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','CHECKMAC','exec Batch.dbo.sp_batch_MAC_transfer',GETDATE(),'Chequeo de MAC del archivo transfer','A')
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','CONCILIA1','exec Batch.dbo.sp_batch_concilia_transfer',GETDATE(),'Conciliacion de transferencias recibidas batch contra las transferencias recibidas online','A')
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','CONCILIA2','exec Batch.dbo.sp_batch_process_conciliacion',GETDATE(),'Generacion de movimientos a enviar al core despues de la conciliacion','A')

--Offering
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('OFFERING','LECTURA','exec Batch.dbo.sp_batch_read_offering',GETDATE(),'Generacion de tabla de offering recibidos','A')

--Account
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('ACCOUNT','LECTURA','exec Batch.dbo.sp_batch_read_account',GETDATE(),'Generacion de tabla de cuentas recibidas','A')

--Parametria TRAN  CODE
INSERT INTO [dbo].[parametria_tran_code] VALUES ('TCE','29','A','Codigo de transaccion para credito')
INSERT INTO [dbo].[parametria_tran_code] VALUES ('TDE','19','A','Codigo de transaccion para debito')
INSERT INTO [dbo].[parametria_tran_code] VALUES ('TDEM','40','A','Codigo de transaccion para monobanco')

--Parametria de reglas de validacion
INSERT INTO [dbo].[parametria_reglas_validacion] VALUES ('TRANSFER','CONCILIA','TCE','BCO_DEBITO NOT IN (147) AND BCO_CREDITO IN (147) AND ESTADO_BATCH in (60,40,50)', GETDATE(), 'A')
INSERT INTO [dbo].[parametria_reglas_validacion] VALUES ('TRANSFER','CONCILIA','TCER','',GETDATE(),'A')
INSERT INTO [dbo].[parametria_reglas_validacion] VALUES ('TRANSFER','CONCILIA','TDE','',GETDATE(),'A')
INSERT INTO [dbo].[parametria_reglas_validacion] VALUES ('TRANSFER','CONCILIA','TDER','',GETDATE(),'A')
INSERT INTO [dbo].[parametria_reglas_validacion] VALUES ('TRANSFER','CONCILIA','TDEM','',GETDATE(),'A')

--Parametria para el CORE
--Conector y sus querys
INSERT INTO [dbo].[parametria_conector_core] VALUES ('TCP','BATCH','Conector Cliente TCP')

--Parametria especifica de cada conector
--TCP -> PUERTO|SERVER|ES CLIENTE? S N
INSERT INTO [dbo].[parametria_spec_conector_core] VALUES ('27015|127.0.0.1|S','BATCH','Parametria especifica del conector TCP Cliente')


