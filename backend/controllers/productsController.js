/**
 * productsController.js
 * Controlador de productos de la aplicación E-commerce Flutter (Grupo G1).
 *
 * Casos de uso:
 *   1. getProducts            -> todos los productos del catálogo.
 *   2. getProductById         -> el detalle de un producto.
 *   3. getProductsByCategory  -> los productos de una categoría.
 *
 * La tabla products solo guarda category_id, por eso se hace un JOIN con
 * categories para devolver también el nombre de la categoría.
 */
const pool = require('../config/db');

// Consulta base reutilizada por las tres funciones
const BASE_QUERY = `
  SELECT p.id, p.name, p.description, p.price, p.image_url, p.category_id,
         c.name AS category_name
  FROM products p
  JOIN categories c ON p.category_id = c.id
`;

// ─── OBTENER TODOS LOS PRODUCTOS ─────────────────────────────────────────────
async function getProducts(req, res) {
  try {
    const [products] = await pool.query(`${BASE_QUERY} ORDER BY p.id`);
    return res.status(200).json(products);
  } catch (error) {
    console.error('Error al obtener los productos:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

// ─── OBTENER PRODUCTO POR ID ─────────────────────────────────────────────────
async function getProductById(req, res) {
  try {
    const { id } = req.params; // parámetro dinámico de la ruta /:id

    const [products] = await pool.query(`${BASE_QUERY} WHERE p.id = ?`, [id]);

    if (products.length === 0) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    // El query devuelve un arreglo: el producto está en la posición 0
    return res.status(200).json(products[0]);
  } catch (error) {
    console.error('Error al obtener el producto:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

// ─── OBTENER PRODUCTOS POR CATEGORÍA ─────────────────────────────────────────
async function getProductsByCategory(req, res) {
  try {
    const { categoryId } = req.params;

    const [products] = await pool.query(
      `${BASE_QUERY} WHERE p.category_id = ? ORDER BY p.name ASC`,
      [categoryId]
    );

    // Una categoría sin productos no es un error: se devuelve []
    return res.status(200).json(products);
  } catch (error) {
    console.error('Error al obtener los productos por categoría:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

module.exports = { getProducts, getProductById, getProductsByCategory };
