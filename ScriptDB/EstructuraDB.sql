-- Implementacion Base de Datos en SQL
-- Implementacion base de datos dbreservaII
-- verificar que la se base de datos no este creada
IF DB_ID('DBRESERVAII') IS NOT NULL
BEGIN
	USE MASTER
	DROP DATABASE DBRESERVAII
END
-- CREAR LA BASE DE DATOS
CREATE DATABASE DBRESERVAII
ON PRIMARY (
	NAME='DBRESERVAII_MDF', -- ALT + 39
	FILENAME='C:\DBSQLServer\dbreservaII\DBRESERVAII.MDF', -- ALT + 92
	SIZE=15MB,
	MAXSIZE=250MB,
	FILEGROWTH=10MB
),(
	NAME='DBRESERVAII_NDF', -- ALT + 39
	FILENAME='C:\DBSQLServer\dbreservaII\DBRESERVAII.NDF', -- ALT + 92
	SIZE=15MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=10MB
)
LOG ON (
	NAME='DBRESERVAII_LDF', -- ALT + 39
	FILENAME='C:\DBSQLServer\dbreservaII\DBRESERVAII.LDF', -- ALT + 92
	SIZE=15MB,
	MAXSIZE=500MB,
	FILEGROWTH=10%
)
GO

-- ACTIVAR LA BASE DE DATOS
USE DBRESERVAII
go

-- IMPLEMENTAR TABLAS DE LA BASE DE DATOS

-- TABLA PAIS
CREATE TABLE PAIS(
	idpais char(4) not null primary key,
	nombre varchar(30) not null unique
)
go
-- TABLA PASAJERO
CREATE TABLE PASAJERO(
	idpasajero char(8) not null primary key,
	nombre varchar(20) not null,
	apaterno varchar(20) not null,
	amaterno varchar(20) not null,
	tipo_documento varchar(30) not null,
	num_documento varchar(12) not null,
	fecha_nacimiento date not null,
	idpais char(4) not null,
	telefono varchar(15) null,
	email varchar(50) not null unique,
	clave varchar(20) not null
)
go

-- TABLA AEROPUERTO
CREATE TABLE AEROPUERTO(
	idaeropuerto char(5) not null,
	nombre varchar(50) not null,
	idpais char(4) not null,
)
go

-- MODIFICAR TABLA AEROPUERTO
ALTER TABLE AEROPUERTO
ADD CONSTRAINT PK_AEROPUERTO_PAIS
PRIMARY KEY NONCLUSTERED(idaeropuerto) -- NONCLUSTERED indica que es un indice no agrupado
go


-- MODIFICAR TABLA AEROPUERTO
ALTER TABLE AEROPUERTO
ADD CONSTRAINT UQ_AEROPUERTO_NOMBRE
UNIQUE(nombre) -- CAMPO UNICO
go

-- TABLA AEROLINEA
CREATE TABLE AEROLINEA(
	idaerolinea int not null primary key,
	cuit char(11) not null,
	nombre varchar(40) not null
)
go

-- TALBA AVIÓN
CREATE TABLE AVION(
	idavion char(5) not null primary key,
	idaerolinea int not null,
	fabricante varchar(40) null,
	tipo varchar(3) not null,
	capacidad varchar(10) null
)
go

-- ELIMINAR CAMPO CAPACIDAD 
ALTER TABLE AVION
DROP COLUMN capacidad 
go

-- AGREGAR EL CAMPO
ALTER TABLE AVION
ADD capacidad int not null
go

-- MODIFICANDO EL CAMPO TIPO
ALTER TABLE AVION
ALTER COLUMN tipo varchar(30) not null
go

-- TABLA ASIENTO
CREATE TABLE ASIENTO(
	idasiento int not null primary key,
	letra char(2) not null,
	fila int not null
)
go

-- TABLA TARIFA 
CREATE TABLE TARIFA(
	idtarifa int not null primary key,
	clase varchar(20) not null unique,
	precio money not null,
	impuesto money not null
)
go

-- TABLA RESERVA
CREATE TABLE RESERVA(
	idreserva int not null primary key,
	costo money not null,
	fecha date null,
	observacion varchar(200) null
)
go

-- RESTRICCIONES CHECK, DEFAULT
-- RESTRICCION DEFAULT
ALTER TABLE RESERVA
ADD CONSTRAINT DFL_RESERVA_FECHA
DEFAULT GETDATE() FOR fecha
go

-- TABLA VUELO
CREATE TABLE VUELO(
	idasiento int not null,
	idaeropuerto char(5) not null,
	idreserva int not null,
	idavion char(5) not null,
	idtarifa int not null
)
go

-- IMPLEMENTAR LAS LLAVES PRIMARIAS DE LA TABLA VUELO
ALTER TABLE VUELO
ADD PRIMARY KEY (idasiento, idaeropuerto, idreserva, idavion)
go

-- TABLA PAGO
CREATE TABLE PAGO(
	idpago int not null primary key identity,
	idreserva int not null,
	fecha date default getdate(),
	idpasajero char(8) not null,
	monto money not null,
	tipo_comprobante varchar(20) not null,
	num_comprobante varchar(15) not null,
	impuesto decimal(5,2) not null
)
go

-- AGREGAR RESTRICCION CHECK, CONTROLAR QUE NO SE INGRESEN
-- FECHAS MAYORES A LA FECHA
ALTER TABLE PAGO
ADD CONSTRAINT CHK_PAGO_FECHA
CHECK (fecha<=getdate())
go

-- IMPLEMENTAR LAS RELACIONES ENTRE TABLA DE LA MISMA BASE DE DATOS
-- RELACION ENTRE TABLA PAIS Y PASAJERO
ALTER TABLE PASAJERO
ADD CONSTRAINT FK_PASAJERO_PAIS
FOREIGN KEY (idpais) REFERENCES PAIS(idpais)
go

-- RELACION ENTRE TABLA AEROPUERTO Y PAIS
ALTER TABLE AEROPUERTO
ADD CONSTRAINT FK_AEROPUERTO_PAIS
FOREIGN KEY (idpais) REFERENCES PAIS(idpais)
go

-- RELACION ENTRE TABLA PAGO Y PASAJERO
ALTER TABLE PAGO
ADD CONSTRAINT FK_PAGO_PASAJERO
FOREIGN KEY (idpasajero) REFERENCES PASAJERO (idpasajero)
go

-- RELACION ENTRE PAGO Y RESERVA
ALTER TABLE PAGO
ADD CONSTRAINT FK_PAGO_RESERVA
FOREIGN KEY (idreserva) REFERENCES RESERVA(idreserva)
go

-- RELACION AVION Y AEROLINEA
ALTER TABLE AVION
ADD CONSTRAINT FK_AVION_AEROLINEA
FOREIGN KEY (idaerolinea) REFERENCES AEROLINEA(idaerolinea)
go

-- ELIMINAR RELACION 
-- ALTER TABLE AVION
-- DROP CONSTRAINT FK_AVION_AEROLINEA

-- RELACION ENTRE LA TABLA VUELO Y ASIENTO
ALTER TABLE VUELO
ADD CONSTRAINT FK_VUELO_ASIENTO
FOREIGN KEY (idasiento) REFERENCES ASIENTO (idasiento)
go

-- RELACION ENTRE TABLA VUELO Y AVION
ALTER TABLE VUELO
ADD CONSTRAINT FK_VUELO_AVION
FOREIGN KEY (idavion) REFERENCES AVION (idavion)
go

-- RELACION ENTRE LA TABLA VUELO Y RESERVA
ALTER TABLE VUELO
ADD CONSTRAINT FK_VUELO_RESERVA
FOREIGN KEY (idreserva) REFERENCES RESERVA (idreserva)
go

-- RELACION ENTRE LA TABLA VUELO Y TARIFA 
ALTER TABLE VUELO
ADD CONSTRAINT FK_VUELO_TARIFA
FOREIGN KEY (idtarifa) REFERENCES TARIFA (idtarifa)
go

-- RELACION ENTRE TABLA VUELO Y AEROPUERTO
ALTER TABLE VUELO
ADD CONSTRAINT FK_VUELO_AEROPUERTO
FOREIGN KEY (idaeropuerto) REFERENCES AEROPUERTO (idaeropuerto)
go
