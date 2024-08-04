CREATE DATABASE TIENDA_UNY;

USE TIENDA_UNY;

CREATE TABLE Productos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL
);

CREATE TABLE Pedidos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    FechaPedido DATETIME NOT NULL
);

CREATE TABLE DetallesPedido (
    PedidoID INT,
    ProductoID INT,
    Cantidad INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (PedidoID, ProductoID),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID)
);

INSERT INTO Productos (Nombre, Precio, Stock) VALUES
('Laptop', 1200.99, 10),
('Smartphone', 699.99, 25),
('Tablet', 299.99, 15),
('Monitor', 199.99, 20),
('Teclado', 49.99, 50);

START TRANSACTION;

-- Variables de entrada
SET @cliente_id = 1; -- ID del cliente
SET @producto1_id = 1; -- ID del primer producto
SET @producto1_cantidad = 11; -- Cantidad del primer producto
SET @producto2_id = 2; -- ID del segundo producto
SET @producto2_cantidad = 3; -- Cantidad del segundo producto

-- Verificar el stock del primer producto
SELECT Stock INTO @stock1 FROM Productos WHERE ID = @producto1_id;

DELIMITER //
CREATE PROCEDURE CheckStock1AndRollback()
BEGIN
    DECLARE mensaje VARCHAR(255);

    IF @stock1 < @producto1_cantidad THEN
        ROLLBACK;
        SET mensaje = 'No hay suficiente stock para el primer producto.';
    ELSE
        SET mensaje = 'Suficiente stock disponible.';
    END IF;

    SELECT mensaje AS mensaje;
END //
DELIMITER ;

CALL CheckStock1AndRollback();

-- Verificar el stock del segundo producto
SELECT Stock INTO @stock2 FROM Productos WHERE ID = @producto2_id;

DELIMITER //
CREATE PROCEDURE CheckStock2AndRollback()
BEGIN
    DECLARE mensaje VARCHAR(255);

    IF @stock2 < @producto2_cantidad THEN
        ROLLBACK;
        SET mensaje = 'No hay suficiente stock para el segundo producto.';
    ELSE
        SET mensaje = 'Suficiente stock disponible.';
    END IF;

    SELECT mensaje AS mensaje;
END //
DELIMITER ;

CALL CheckStock2AndRollback();

-- Insertar el pedido
INSERT INTO Pedidos (ClienteID, FechaPedido) VALUES (@cliente_id, NOW());
SET @pedido_id = LAST_INSERT_ID();

-- Insertar los detalles del pedido
INSERT INTO DetallesPedido (PedidoID, ProductoID, Cantidad, Precio)
VALUES (@pedido_id, @producto1_id, @producto1_cantidad, (SELECT Precio FROM Productos WHERE ID = @producto1_id));

INSERT INTO DetallesPedido (PedidoID, ProductoID, Cantidad, Precio)
VALUES (@pedido_id, @producto2_id, @producto2_cantidad, (SELECT Precio FROM Productos WHERE ID = @producto2_id));

-- Actualizar el stock del primer producto
UPDATE Productos SET Stock = Stock - @producto1_cantidad WHERE ID = @producto1_id;

-- Actualizar el stock del segundo producto
UPDATE Productos SET Stock = Stock - @producto2_cantidad WHERE ID = @producto2_id;

COMMIT;
SELECT 'Compra realizada exitosamente.' AS mensaje;