// Rutas de categorías -> prefijo /api/categories (públicas)
const express = require('express');
const { obtenerCategorias } = require('../controllers/categoriesController');

const router = express.Router();

router.get('/', obtenerCategorias); // GET /api/categories

module.exports = router;
