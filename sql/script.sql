-- Script común para las dos demos (Aurora y RDS for MySQL)
CREATE DATABASE IF NOT EXISTS farmacia;
USE farmacia;
DROP TABLE IF EXISTS producto;
CREATE TABLE producto (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80), stock INT, precio DECIMAL(8,2),
  creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

-- 10 000 filas de prueba
SET SESSION cte_max_recursion_depth = 20000;
INSERT INTO producto (nombre, stock, precio)
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i < 10000)
SELECT CONCAT('Producto ', i), FLOOR(RAND()*500), ROUND(RAND()*100, 2) FROM n;

SELECT COUNT(*), AVG(precio), SUM(stock) FROM producto;
SELECT @@hostname, @@version, @@read_only;
