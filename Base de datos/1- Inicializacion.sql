use Batch
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_batch')
DROP TABLE parametria_batch
CREATE TABLE parametria_batch (
pb_id int IDENTITY(1,1) PRIMARY KEY,
pb_input_path_cierre varchar(255),
pb_input_path_inicio varchar(255),
pb_output_path_inicio varchar(255)
);
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_archivos_entrada_interbanking')
DROP TABLE parametria_archivos_entrada_interbanking
CREATE TABLE parametria_archivos_entrada_interbanking(
pe_id int IDENTITY(1,1) PRIMARY KEY,
pe_nombre_archivo varchar(100),
pe_path_archivo varchar(255),
pe_descripcion varchar(255),
pe_archivo varchar(100),
pe_ebcdic char
);
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_conector_core')
DROP TABLE parametria_conector_core
CREATE TABLE parametria_conector_core(
pc_id int IDENTITY(1,1) PRIMARY KEY,
pc_tipo_conector varchar(100),
pc_proceso varchar(100),
pc_descripcion varchar(255)
);
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_spec_conector_core')
		   DROP TABLE parametria_spec_conector_core
CREATE TABLE parametria_spec_conector_core(
ps_id int IDENTITY(1,1) PRIMARY KEY,
ps_string varchar(100),
ps_proceso  varchar(100),
ps_descripcion varchar(255)
);
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'backend_querys')
DROP TABLE backend_querys
CREATE TABLE backend_querys (
qr_id int IDENTITY(1,1) PRIMARY KEY,
qr_query varchar(MAX),
qr_descripcion varchar(255),
qr_fecha_ult_modificacion datetime,
qr_archivo varchar(100),
qr_funcion varchar(100)
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'interfaces')
DROP TABLE interfaces
CREATE TABLE interfaces  (
if_id int,
if_interfaz varchar(10),
if_descripcion varchar(255),
if_header varchar(255),
if_footer varchar(255),
if_fecha_ult_modificacion datetime,
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'movimientos_generados')
DROP TABLE movimientos_generados
CREATE TABLE movimientos_generados (
mg_id int,
mg_string varchar(MAX),
mg_fecha_ult_modificacion datetime
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'movimientos_generados_his')
DROP TABLE movimientos_generados_his
CREATE TABLE movimientos_generados_his (
mg_id int,
mg_string varchar(MAX),
mg_fecha_ult_modificacion datetime,
mg_fecha_generacion datetime
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'envio_core_generado')
DROP TABLE envio_core_generado
CREATE TABLE envio_core_generado (
ec_id int,
ec_string varchar(MAX),
ec_fecha_ult_modificacion datetime,
ec_fecha_generacion datetime,
ec_estado char
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'envio_core_respuesta')
DROP TABLE envio_core_respuesta
CREATE TABLE envio_core_respuesta (
er_id int,
er_string varchar(MAX),
er_fecha_ult_modificacion datetime,
er_proceso varchar(100)
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'archivo_procesado')
DROP TABLE archivo_procesado
CREATE TABLE archivo_procesado (
ap_id int IDENTITY(1,1) PRIMARY KEY,
ap_archivo varchar(100),
ap_string varchar(MAX),
ap_fecha_ult_modificacion datetime,
ap_procesado char default 'N'
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'dn_tef_recibidas')
DROP TABLE dn_tef_recibidas
CREATE TABLE [dbo].[dn_tef_recibidas](
	[BCO_DEBITO] [char](3) NULL,
	[FEC_SOLICITUD] [char](8) NULL,
	[NRO_TRANSFERENCIA] [char](7) NOT NULL,
	[COD_ABONADO] [char](7) NULL,
	[TIPO_OPERACION] [char](2) NULL,
	[IMPORTE] [char](17) NULL,
	[SUC_DEBITO] [char](4) NULL,
	[NOM_SOLICITANTE] [char](29) NULL,
	[TIPO_CTA_DEB_RED] [char](2) NULL,
	[NRO_CTA_RED] [char](2) NULL,
	[CTA_DEBITO] [char](17) NULL,
	[FEC_ENVIO_DEBITO] [char](6) NULL,
	[HORA_ENVIO_DEBITO] [char](4) NULL,
	[OPERADOR_DB_1] [char](2) NULL,
	[OPERADOR_DB_2] [char](2) NULL,
	[MOTIVO_RECHAZO_DB] [char](4) NULL,
	[BCO_CREDITO] [char](3) NULL,
	[SUC_CREDITO] [char](4) NULL,
	[NOM_BENEFICIARIO] [char](29) NULL,
	[TIPO_CTA_CRED_RED] [char](2) NULL,
	[CTA_CREDITO] [char](17) NULL,
	[FEC_ENVIO_CREDITO] [char](6) NULL,
	[HORA_ENVIO_CREDITO] [char](4) NULL,
	[OPERADOR_CR_1] [char](2) NULL,
	[OPERADOR_CR_2] [char](2) NULL,
	[MOTIVO_RECHAZO_CR] [char](4) NULL,
	[OPERADOR_INGRESO] [char](2) NULL,
	[AUTORIZANTE_1] [char](2) NULL,
	[AUTORIZANTE_2] [char](2) NULL,
	[AUTORIZANTE_3] [char](2) NULL,
	[FECHA_AUTORIZACION] [char](6) NULL,
	[HORA_AUTORIZACION] [char](4) NULL,
	[ESTADO] [char](2) NULL,
	[FEC_ESTADO] [char](6) NULL,
	[OBSERVACION_1] [char](60) NULL,
	[OBSERVACION_2] [char](100) NULL,
	[CLAVE_MAC_1] [char](12) NULL,
	[CLAVE_MAC_2] [char](12) NULL,
	[NRO_REFERENCIA] [char](7) NULL,
	[NRO_ENVIO] [char](3) NULL,
	[DEB_CONSOLIDADO] [char](1) NULL,
	[TIPO_TITULAR] [char](1) NULL,
	[PAGO_PREACORDADO] [char](1) NULL,
	[RIESGO_ABONADO] [char](1) NULL,
	[RIESGO_BANCO] [char](1) NULL,
	[ESTADOS_ANTERIORES] [char](140) NULL,
	[CTA_ESP] [char] (1) NULL,
	[CUITOR] [char] (11) NULL,
	[CUITCR] [char] (11) NULL
	)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'planificacion_procesos_detalle')
drop table planificacion_procesos_detalle
CREATE TABLE planificacion_procesos_detalle(
pp_id  int IDENTITY(1,1) PRIMARY KEY,
pp_proceso varchar(255),
pp_subproceso varchar(255),
pp_query varchar(255),
pp_fecha_ult_modificacion datetime,
pp_descripcion varchar(255),
pp_estado char default 'B'
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'log_procesos_ejecutados')
DROP TABLE log_procesos_ejecutados
CREATE TABLE log_procesos_ejecutados(
lp_id  int IDENTITY(1,1) PRIMARY KEY,
lp_proceso varchar(255),
lp_subproceso varchar(255),
lp_query varchar(255),
lp_fecha_ejecucion datetime
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'planificacion_procesos_definicion')
DROP TABLE planificacion_procesos_definicion
CREATE TABLE planificacion_procesos_definicion(
pd_id  int IDENTITY(1,1) PRIMARY KEY,
pd_proceso varchar(255),
pd_descripcion varchar(255)
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_reglas_validacion')
DROP TABLE parametria_reglas_validacion
CREATE TABLE parametria_reglas_validacion(
rv_id  int IDENTITY(1,1) PRIMARY KEY,
rv_proceso varchar(255),
rv_subproceso varchar(255),
rv_tipo varchar(4),
rv_regla varchar(100),
rv_fecha_ult_modificacion varchar(100),
rv_estado char
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'dn_tef_conciliacion')
DROP TABLE dn_tef_conciliacion
CREATE TABLE dn_tef_conciliacion(
	[BCO_DEBITO] [char](3) NULL,
	[FEC_SOLICITUD] [char](8) NULL,
	[NRO_TRANSFERENCIA] [char](7) NOT NULL,
	[COD_ABONADO] [char](7) NULL,
	[TIPO_OPERACION] [char](2) NULL,
	[IMPORTE] [char](17) NULL,
	[SUC_DEBITO] [char](4) NULL,
	[NOM_SOLICITANTE] [char](29) NULL,
	[TIPO_CTA_DEB_RED] [char](2) NULL,
	[NRO_CTA_RED] [char](2) NULL,
	[CTA_DEBITO] [char](17) NULL,
	[FEC_ENVIO_DEBITO] [char](6) NULL,
	[HORA_ENVIO_DEBITO] [char](4) NULL,
	[OPERADOR_DB_1] [char](2) NULL,
	[OPERADOR_DB_2] [char](2) NULL,
	[MOTIVO_RECHAZO_DB] [char](4) NULL,
	[BCO_CREDITO] [char](3) NULL,
	[SUC_CREDITO] [char](4) NULL,
	[NOM_BENEFICIARIO] [char](29) NULL,
	[TIPO_CTA_CRED_RED] [char](2) NULL,
	[CTA_CREDITO] [char](17) NULL,
	[FEC_ENVIO_CREDITO] [char](6) NULL,
	[HORA_ENVIO_CREDITO] [char](4) NULL,
	[OPERADOR_CR_1] [char](2) NULL,
	[OPERADOR_CR_2] [char](2) NULL,
	[MOTIVO_RECHAZO_CR] [char](4) NULL,
	[OPERADOR_INGRESO] [char](2) NULL,
	[AUTORIZANTE_1] [char](2) NULL,
	[AUTORIZANTE_2] [char](2) NULL,
	[AUTORIZANTE_3] [char](2) NULL,
	[FECHA_AUTORIZACION] [char](6) NULL,
	[HORA_AUTORIZACION] [char](4) NULL,
	[ESTADO_ONLINE] [char](2) NULL,
	[ESTADO_BATCH] [char](2) NULL,
	[FEC_ESTADO] [char](6) NULL,
	[OBSERVACION_1] [char](60) NULL,
	[OBSERVACION_2] [char](100) NULL,
	[CLAVE_MAC_1] [char](12) NULL,
	[CLAVE_MAC_2] [char](12) NULL,
	[NRO_REFERENCIA] [char](7) NULL,
	[NRO_ENVIO] [char](3) NULL,
	[DEB_CONSOLIDADO] [char](1) NULL,
	[TIPO_TITULAR] [char](1) NULL,
	[PAGO_PREACORDADO] [char](1) NULL,
	[RIESGO_ABONADO] [char](1) NULL,
	[RIESGO_BANCO] [char](1) NULL,
	[ESTADOS_ANTERIORES] [char](140) NULL,
	[CTA_ESP] [char] (1) NULL,
	[CUITOR] [char] (11) NULL,
	[CUITCR] [char] (11) NULL,
	[ESTADO_PROCESAMIENTO] char(1) NULL default 'P'
	)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'dn_tef_online')
DROP TABLE dn_tef_online
CREATE TABLE dn_tef_online(
	[BCO_DEBITO] [char](3) NULL,
	[FEC_SOLICITUD] [char](8) NULL,
	[NRO_TRANSFERENCIA] [char](7) NOT NULL,
	[COD_ABONADO] [char](7) NULL,
	[TIPO_OPERACION] [char](2) NULL,
	[IMPORTE] [char](17) NULL,
	[SUC_DEBITO] [char](4) NULL,
	[NOM_SOLICITANTE] [char](29) NULL,
	[TIPO_CTA_DEB_RED] [char](2) NULL,
	[NRO_CTA_RED] [char](2) NULL,
	[CTA_DEBITO] [char](17) NULL,
	[FEC_ENVIO_DEBITO] [char](6) NULL,
	[HORA_ENVIO_DEBITO] [char](4) NULL,
	[OPERADOR_DB_1] [char](2) NULL,
	[OPERADOR_DB_2] [char](2) NULL,
	[MOTIVO_RECHAZO_DB] [char](4) NULL,
	[BCO_CREDITO] [char](3) NULL,
	[SUC_CREDITO] [char](4) NULL,
	[NOM_BENEFICIARIO] [char](29) NULL,
	[TIPO_CTA_CRED_RED] [char](2) NULL,
	[CTA_CREDITO] [char](17) NULL,
	[FEC_ENVIO_CREDITO] [char](6) NULL,
	[HORA_ENVIO_CREDITO] [char](4) NULL,
	[OPERADOR_CR_1] [char](2) NULL,
	[OPERADOR_CR_2] [char](2) NULL,
	[MOTIVO_RECHAZO_CR] [char](4) NULL,
	[OPERADOR_INGRESO] [char](2) NULL,
	[AUTORIZANTE_1] [char](2) NULL,
	[AUTORIZANTE_2] [char](2) NULL,
	[AUTORIZANTE_3] [char](2) NULL,
	[FECHA_AUTORIZACION] [char](6) NULL,
	[HORA_AUTORIZACION] [char](4) NULL,
	[ESTADO] [char](2) NULL,
	[FEC_ESTADO] [char](6) NULL,
	[OBSERVACION_1] [char](60) NULL,
	[OBSERVACION_2] [char](100) NULL,
	[CLAVE_MAC] [char](12) NULL,
	[NRO_REFERENCIA] [char](7) NULL,
	[NRO_ENVIO] [char](3) NULL,
	[DEB_CONSOLIDADO] [char](1) NULL,
	[TIPO_TITULAR] [char](1) NULL,
	[PAGO_PREACORDADO] [char](1) NULL,
	[RIESGO_ABONADO] [char](1) NULL,
	[RIESGO_BANCO] [char](1) NULL,
	[ESTADOS_ANTERIORES] [char](140) NULL,
	[CTA_ESP] [char] (1) NULL,
	[CUITOR] [char] (11) NULL,
	[CUITCR] [char] (11) NULL
	)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'dn_tef_a_enviar')
DROP TABLE dn_tef_a_enviar
CREATE TABLE dn_tef_a_enviar(
	[NRO_TRANSFERENCIA] [char](7) NOT NULL,
	[FEC_SOLICITUD] [char](8) NULL,
	[BCO_DEBITO] [char](3) NULL,
	[BCO_CREDITO] [char](3) NULL,
	[TIPO_MOVIMIENTO] [char](4) NULL,
	[NRO_REFERENCIA] [char](7) NOT NULL,
	[TRAN_CODE] [char](6) NOT NULL,
	[CTA_DEBITO] [char](17) NULL,
	[CTA_CREDITO] [char](17) NULL,
	[IMPORTE] [char](17) NULL,
	[FILLER] [char] (365) NULL
)
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'parametria_tran_code')
DROP TABLE parametria_tran_code
CREATE TABLE parametria_tran_code(
	pt_id  int IDENTITY(1,1) PRIMARY KEY,
	pt_tipo varchar(4),
	pt_valor varchar(10),
	pt_estado char default 'A',
	pt_descripcion varchar(100)
)