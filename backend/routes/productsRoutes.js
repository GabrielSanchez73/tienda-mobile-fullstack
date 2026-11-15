// Rutas de productos -> prefijo /api/products (públicas)
const express = require('express');
const {
  getProducts,
  getProductById,
  getProductsByCategory,
} = require('../controllers/productsController');

const router = express.Router();

router.get('/', getProducts);                              // GET /api/products
router.get('/category/:categoryId', getProductsByCategory); // GET /api/products/category/:categoryId
router.get('/:id', getProductById);                        // GET /api/products/:id

module.exports = router;
