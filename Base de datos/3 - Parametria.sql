use Batch

DECLARE @path varchar(255)
SET @path = 'E:\\AQUOSA\\backend\\Backend\\Debug'

TRUNCATE TABLE [dbo].[parametria_archivos_entrada_interbanking]
TRUNCATE TABLE [dbo].[planificacion_procesos_detalle]

INSERT INTO [dbo].[parametria_archivos_entrada_interbanking]
VALUES ('PTRANSF147.dat',@path, 'Parametria para archivo de transferencias de Interbanking','TRANSFER','N')

INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('INSERT INTO Batch..archivo_procesado (ap_archivo,ap_string,ap_fecha_ult_modificacion) values (''TRANSFER'',?,GETDATE())'),'Insercion de TRANSFER recibido',GETDATE(),'TRANSFER','insert')
INSERT INTO [dbo].[backend_querys] VALUES (Batch.dbo.fn_str_TO_BASE64('exec sp_batch_process_transfer'),'Procesamiento de TRANSFER recibido',GETDATE(),'TRANSFER','process')

INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','LECTURA','exec Batch.dbo.sp_batch_read_transfer',GETDATE(),'Generacion de tabla de transferencias recibidas','A')
--INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','CHECKMAC','exec Batch.dbo.sp_batch_MAC_transfer',GETDATE(),'Chequeo de MAC del archivo transfer')
INSERT INTO [dbo].[planificacion_procesos_detalle] VALUES ('TRANSFER','CONCILIA','exec Batch.dbo.sp_batch_concilia_transfer',GETDATE(),'Conciliacion de transferencias recibidas batch contra las transferencias recibidas online','A')

