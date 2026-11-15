/**
 * categoriesController.js
 * Controlador de categorías de la aplicación E-commerce Flutter (Grupo G1).
 *
 * Caso de uso: cuando el usuario ingresa al home de la aplicación, la app
 * consulta las categorías disponibles (Electrónica, Ropa, Hogar y Deportes)
 * para mostrarlas y poder filtrar los productos.
 *
 * Capa: lógica de negocio (backend Node.js + Express).
 * Base de datos: MySQL (esquema ecommercefluterg1, tabla categories).
 */

const pool = require('../config/db'); // Pool de conexiones hacia MySQL

/* ==========================================================================
   OBTENER TODAS LAS CATEGORÍAS
   Proceso asíncrono: el backend consulta la base de datos y espera respuesta.
   ========================================================================== */
async function obtenerCategorias(req, res) {
  try {
    // Se traen todas las filas de la tabla categories ordenadas
    // alfabéticamente (ascendente) por el nombre de la categoría.
    const [categories] = await pool.query(
      'SELECT * FROM categories ORDER BY name ASC'
    );

    // Se devuelven las categorías al frontend en formato JSON
    return res.status(200).json(categories);

  } catch (error) {
    console.error('Error al obtener las categorías:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
}

// Se exporta la función para que la ruta de categorías pueda utilizarla
module.exports = { obtenerCategorias };
