-- Actualización de rutas de imágenes locales (Flutter assets) para productos existentes
-- Base de datos: ecommercefluterg1
-- - Actualiza únicamente image_url de los 10 productos (id 1..10)
-- - No elimina ni recrea tablas
-- - No modifica usuarios, categorías ni registros del carrito
-- - Idempotente: puede ejecutarse más de una vez sin efectos adversos

USE ecommercefluterg1;

UPDATE products SET image_url = 'assets/products/auriculares_bluetooth.jpg' WHERE id = 1;
UPDATE products SET image_url = 'assets/products/smartwatch.jpg'            WHERE id = 2;
UPDATE products SET image_url = 'assets/products/camiseta_basica.jpg'      WHERE id = 3;
UPDATE products SET image_url = 'assets/products/jeans_clasicos.jpg'       WHERE id = 4;
UPDATE products SET image_url = 'assets/products/lampara_led.jpg'          WHERE id = 5;
UPDATE products SET image_url = 'assets/products/set_sabanas.jpg'          WHERE id = 6;
UPDATE products SET image_url = 'assets/products/balon_futbol.png'         WHERE id = 7;
UPDATE products SET image_url = 'assets/products/mancuernas_5kg.jpg'      WHERE id = 8;
UPDATE products SET image_url = 'assets/products/tablet_10.jpg'            WHERE id = 9;
UPDATE products SET image_url = 'assets/products/chaqueta_deportiva.jpg'  WHERE id = 10;

-- Verificación opcional (solo lectura):
-- SELECT id, name, image_url FROM products WHERE id BETWEEN 1 AND 10 ORDER BY id;
