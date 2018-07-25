CREATE TABLE parametria_batch (
pb_id int,
pb_input_path_cierre varchar(255),
pb_input_path_inicio varchar(255),
pb_output_path_inicio varchar(255),

);

CREATE TABLE querys (
qr_id int,
qr_query varchar(MAX),
qr_descripcion varchar(255),
qr_fecha_ult_modificacion datetime
)

CREATE TABLE interfaces  (
if_id int,
if_interfaz varchar(10),
if_descripcion varchar(255),
if_fecha_ult_modificacion datetime,
)


