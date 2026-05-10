---  1 CREAMOS LAS BASES DE DATOS Y SUS RELACIONES
PRAGMA foreign_keys = ON;

ALTER TABLE Inventario rename TO Inventario_old;
ALTER TABLE Ventas RENAME TO Ventas_old;

CREATE TABLE Inventario (
  ID_Vehiculo INTEGER PRIMARY KEY,
  Marca TEXT NOT NULL,
  Tipo_Combustible TEXT NOT NULL,
  Tipo_transmision TEXT NOT NULL,
  Condicion TEXT NOT NULL,
  Anio INTEGER NOT NULL,
  Color TEXT NOT NULL,
  Estado TEXT NOT NULL,
  Modelos TEXT NOT NULL,
  Precio_entrada REAL NOT NULL,
  Mes_entrada TEXT NOT NULL,
  Kilometraje INTEGER NOT NULL
);

CREATE TABLE Ventas (
ID_Venta             INTEGER PRIMARY KEY,
    ID_Vehiculo          INTEGER NOT NULL, -- Consistencia: nombre igual al de la tabla Inventario
    Metodo_pago          TEXT NOT NULL,
    Descuento_porcentaje REAL NOT NULL,
    Fecha_venta          TEXT NOT NULL,
    Precio_entrada       REAL NOT NULL,    
    Precio_venta         REAL NOT NULL,
    Descuento_dolar      REAL NOT NULL,
    FOREIGN KEY (ID_Vehiculo) REFERENCES Inventario (ID_Vehiculo)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);


--- verificacion de datos repetidos
SELECT ID_Vehiculo, COUNT(*) 
FROM Inventario_old 
GROUP BY ID_Vehiculo 
HAVING COUNT(*) > 1;


--- 2 cambiamos los valores 
INSERT INTO Inventario (
    ID_Vehiculo, Marca, Tipo_Combustible, Tipo_transmision, 
    Condicion, Anio, Color, Estado, Modelos, 
    Precio_entrada, Mes_entrada,Kilometraje
    )
SELECT  ID_Vehiculo, Marca, Tipo_Combustible, Tipo_transmision, 
    Condicion, Anio, Color, Estado, Modelos, 
    Precio_entrada, DATE(Mes_entrada) AS Mes_entrada,
     Kilometraje

FROM Inventario_old;
--- 2 insertamos las ventas
INSERT INTO Ventas( 
ID_Venta, ID_Vehiculo, Metodo_pago, Descuento_porcentaje, Fecha_venta, 
Precio_entrada, Precio_venta, Descuento_dolar
)
SELECT ID_Venta, ID_Vehiculo, Metodo_pago, Descuento_porcentaje, DATE(Fecha_venta) AS Fecha_venta, 
Precio_entrada, Precio_venta, Descuento_dolar

FROM Ventas_old;

-- 3 eliminamos tablas 
DROP TABLE Inventario;
DROP TABLE Ventas;

DROP TABLE  Inventario_old;
DROP TABLE Ventas_old;


