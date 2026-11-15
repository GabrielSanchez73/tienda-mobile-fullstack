-- ============================================================================
-- Esquema de la base de datos del E-commerce Flutter G1 (MySQL 8)
-- Basado en el script compartido en clase. Se puede ejecutar varias veces:
-- las tablas usan IF NOT EXISTS y los datos INSERT IGNORE con ID fijo.
-- ============================================================================
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS ecommercefluterg1
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommercefluterg1;

-- ─── TABLA: users ────────────────────────────────────────────────────────────
-- Usuarios registrados (la contraseña se guarda cifrada con bcrypt)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─── TABLA: categories ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
);

-- ─── TABLA: products ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url VARCHAR(255),
  category_id INT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- ─── TABLA: cart_items ───────────────────────────────────────────────────────
-- Carrito de cada usuario (persistido en la BD, no en el teléfono)
CREATE TABLE IF NOT EXISTS cart_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_product (user_id, product_id)
);

-- ─── DATOS INICIALES: 4 categorías ───────────────────────────────────────────
INSERT IGNORE INTO categories (id, name, description) VALUES
(1, 'Electrónica', 'Dispositivos y gadgets tecnológicos'),
(2, 'Ropa', 'Prendas de vestir para toda ocasión'),
(3, 'Hogar', 'Artículos para el hogar'),
(4, 'Deportes', 'Equipamiento y accesorios deportivos');

-- ─── DATOS INICIALES: 10 productos ───────────────────────────────────────────
INSERT IGNORE INTO products (id, name, description, price, image_url, category_id) VALUES
(1, 'Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido', 49.99, 'assets/products/auriculares_bluetooth.jpg', 1),
(2, 'Smartwatch', 'Reloj inteligente con monitor de actividad', 89.99, 'assets/products/smartwatch.jpg', 1),
(3, 'Camiseta Básica', 'Camiseta de algodón 100% en varios colores', 19.99, 'assets/products/camiseta_basica.jpg', 2),
(4, 'Jeans Clásicos', 'Pantalón jeans corte recto', 39.99, 'assets/products/jeans_clasicos.jpg', 2),
(5, 'Lámpara LED', 'Lámpara de escritorio con luz regulable', 24.99, 'assets/products/lampara_led.jpg', 3),
(6, 'Set de Sábanas', 'Juego de sábanas de algodón tamaño queen', 34.99, 'assets/products/set_sabanas.jpg', 3),
(7, 'Balón de Fútbol', 'Balón oficial tamaño 5', 29.99, 'assets/products/balon_futbol.png', 4),
(8, 'Mancuernas 5kg', 'Par de mancuernas de 5 kg cada una', 44.99, 'assets/products/mancuernas_5kg.jpg', 4),
(9, 'Tablet 10"', 'Tablet con pantalla de 10 pulgadas', 199.99, 'assets/products/tablet_10.jpg', 1),
(10, 'Chaqueta Deportiva', 'Chaqueta ligera para entrenamiento', 54.99, 'assets/products/chaqueta_deportiva.jpg', 2);
