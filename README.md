# App Tienda G1 — Prototipo funcional de e-commerce

Aplicación móvil de comercio electrónico desarrollada con **Flutter** (frontend), **Node.js + Express** (API REST) y **MySQL** (persistencia). Permite registro e inicio de sesión, exploración de catálogo por categorías, detalle de producto y carrito de compras persistente por usuario.

## Características

- Autenticación de usuarios (registro e inicio de sesión) con JWT.
- Contraseñas almacenadas con hash seguro en base de datos (`bcrypt`).
- Catálogo de categorías y productos consumido desde la API.
- Filtrado por categoría, búsqueda y detalle de producto.
- Carrito persistente en MySQL (agregar, actualizar cantidad, eliminar) protegido con token.
- Interfaz Material 3 con estados de carga, error y vacío.

## Arquitectura

| Capa | Tecnología | Responsabilidad |
|---|---|---|
| App móvil | Flutter / Dart + Provider | UI, estado, consumo de API |
| Backend | Node.js + Express | API REST, validación, autenticación |
| Base de datos | MySQL | Usuarios, categorías, productos y carrito |

Estructura principal del repositorio:

```text
app_tienda/
├─ android/ ios/ web/ linux/ macos/ windows/   # Plataformas Flutter
├─ assets/products/                             # Imágenes locales de productos
├─ backend/                                     # API Node.js + Express
│  ├─ config/ controllers/ middlewares/ routes/
│  ├─ database/                                 # Scripts SQL del backend
│  ├─ .env.example                              # Plantilla de variables de entorno
│  └─ index.js
├─ database/                                    # Scripts SQL (esquema/datos)
├─ docs/                                        # Documentación e instalación
├─ lib/                                         # Código fuente Flutter
│  ├─ core/ models/ providers/ services/ screens/ widgets/
│  └─ main.dart
├─ test/                                        # Pruebas Flutter
├─ pubspec.yaml
└─ README.md
```

> Nota: pueden existir carpetas/archivos auxiliares o de respaldo generados durante el desarrollo (por ejemplo respaldos de plataforma o artefactos locales). La documentación indica cuáles deben excluirse de un repositorio público.

## Requisitos previos

- Flutter SDK compatible con Dart `^3.10.7` y herramientas de plataforma (Android SDK para compilar en Android).
- Node.js 18+ y npm.
- MySQL 8+ (servidor y, opcionalmente, MySQL Workbench).
- Dispositivo/emulador o navegador según la plataforma objetivo.

## Instalación y ejecución

La guía completa (MySQL, variables de entorno, backend, app y solución de problemas) está en:

- **[docs/INSTALACION.md](docs/INSTALACION.md)** — configuración paso a paso.
- **[docs/TUTORIAL_GITHUB.md](docs/TUTORIAL_GITHUB.md)** — preparación local y comandos para una publicación manual futura en GitHub (tutorial; no ejecuta acciones Git automáticamente).

Resumen rápido:

1. Crear la base de datos ejecutando el script SQL incluido (ver [docs/INSTALACION.md](docs/INSTALACION.md)).
2. Configurar `backend/.env` a partir de `backend/.env.example` y ejecutar el backend (`npm install`, luego `npm run dev` o `npm start`).
3. Obtener dependencias Flutter (`flutter pub get`) y ejecutar la app apuntando a la URL de la API (por ejemplo con `--dart-define=API_URL=http://<IP_DE_TU_PC>:3000/api` en dispositivo físico).

## API (endpoints principales)

| Método | Ruta | Autenticación | Descripción |
|---|---|---|---|
| POST | `/api/auth/register` | No | Registro de usuario |
| POST | `/api/auth/login` | No | Inicio de sesión |
| GET | `/api/categories` | No | Listado de categorías |
| GET | `/api/products` | No | Listado de productos |
| GET | `/api/products/:id` | No | Detalle de producto |
| GET | `/api/products/category/:id` | No | Productos por categoría |
| GET | `/api/cart` | JWT | Obtener carrito |
| POST | `/api/cart` | JWT | Agregar al carrito |
| PUT | `/api/cart/:id` | JWT | Actualizar cantidad |
| DELETE | `/api/cart/:id` | JWT | Eliminar del carrito |

## Documentación del proyecto

| Documento | Propósito |
|---|---|
| [docs/INSTALACION.md](docs/INSTALACION.md) | Instalación y ejecución (MySQL, backend, Flutter) |
| [docs/TUTORIAL_GITHUB.md](docs/TUTORIAL_GITHUB.md) | Tutorial local para publicación manual futura en GitHub |
| [docs/GUIA_EJECUCION_LEGADO.md](docs/GUIA_EJECUCION_LEGADO.md) | Guía de ejecución paso a paso (material de apoyo) |
| [docs/TUTORIAL_CONSTRUCCION_LEGADO.md](docs/TUTORIAL_CONSTRUCCION_LEGADO.md) | Tutorial de construcción por clases (material de apoyo) |
| [docs/ANALOGIA_BACKEND.md](docs/ANALOGIA_BACKEND.md) | Analogía explicativa del backend (material de apoyo) |
| [docs/ESPECIFICACION_PROYECTO.md](docs/ESPECIFICACION_PROYECTO.md) | Especificación/alcance del proyecto |

## Seguridad y buenas prácticas

- No versionar archivos `.env` ni credenciales reales; usar `backend/.env.example` como plantilla.
- No incluir claves privadas, tokens, keystores ni datos sensibles en el repositorio.
- Las contraseñas de usuarios se almacenan con hash (`bcrypt`) y la API no expone hashes en las respuestas de autenticación.

## Licencia y uso académico

Proyecto desarrollado con fines académicos. Ajustar la licencia según los lineamientos del curso o de la institución antes de una publicación pública.
