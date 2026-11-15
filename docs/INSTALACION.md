# Guía de instalación y ejecución

Esta guía describe cómo configurar la base de datos MySQL, el backend (Node.js/Express) y la aplicación Flutter de **App Tienda G1** en un entorno local.

## 1. Requisitos previos

- **Flutter SDK** compatible con el proyecto (`sdk: ^3.10.7` según `pubspec.yaml`) y dependencias de la plataforma destino.
  - Android: Android SDK y un emulador o dispositivo físico con depuración USB.
  - Web (opcional): Google Chrome y soporte web habilitado en Flutter.
- **Node.js** 18 o superior y **npm**.
- **MySQL** 8 o superior (servidor en ejecución).
- **MySQL Workbench** u otro cliente SQL (opcional, para ejecutar scripts).

> Los comandos de esta guía usan sintaxis de **PowerShell**. Ajusta rutas y nombres de servicio según tu instalación.

## 2. Obtener el proyecto

Coloca la carpeta del proyecto en una ruta local de tu equipo (por ejemplo, dentro de tu carpeta de trabajo). En los ejemplos se usará `<RUTA_DEL_PROYECTO>` para referirse a la carpeta raíz `app_tienda`.

```powershell
cd "<RUTA_DEL_PROYECTO>"
```

## 3. Configurar la base de datos (MySQL)

### 3.1 Crear base de datos y datos iniciales

1. Inicia el servicio de MySQL en tu equipo.
2. Abre MySQL Workbench (u otro cliente) y conéctate a tu servidor local.
3. Ejecuta el script SQL del proyecto. Puedes usar, por ejemplo:
   - `backend/database/ecommercefluterg1.sql` (script del backend), o
   - `database/schema.sql` (esquema/datos incluidos en el repositorio).

El script crea la base de datos, las tablas (`users`, `categories`, `products`, `cart_items`) y datos de ejemplo.

> **Nota:** algunos scripts pueden crear una base con un nombre específico (por ejemplo `ecommercefluterg1` o `ecommerceflutter`). Asegúrate de que el valor `DB_NAME` en la configuración del backend coincida con la base de datos que hayas creado/seleccionado.

### 3.2 Actualizar rutas de imágenes de productos (opcional)

Si necesitas normalizar las URLs/rutas de imágenes de productos a los assets locales incluidos en `assets/products/`, el repositorio incluye el script idempotente:

- `backend/database/update_product_images_ecommercefluterg1.sql`

Este script actualiza únicamente el campo de imagen de los productos esperados. Ejecútalo solo si tu base lo requiere y revisa su contenido antes de aplicarlo.

### 3.3 Verificación rápida

```sql
SHOW DATABASES;
USE <NOMBRE_DE_TU_BASE_DE_DATOS>;
SHOW TABLES;
SELECT COUNT(*) FROM products;
```

## 4. Configurar y ejecutar el backend

### 4.1 Variables de entorno

1. Entra a la carpeta del backend:

```powershell
cd "<RUTA_DEL_PROYECTO>\backend"
```

2. Crea tu archivo `.env` a partir de la plantilla:

```powershell
Copy-Item .env.example .env
```

3. Edita `.env` y define valores reales para tu entorno local:

| Variable | Descripción |
|---|---|
| `PORT` | Puerto del servidor (por defecto `3000`) |
| `DB_HOST` | Host de MySQL (normalmente `localhost`) |
| `DB_PORT` | Puerto de MySQL (normalmente `3306`) |
| `DB_USER` | Usuario de MySQL |
| `DB_PASSWORD` | Contraseña del usuario de MySQL |
| `DB_NAME` | Nombre de la base de datos creada |
| `JWT_SECRET` | Clave secreta para firmar tokens JWT (usa un valor propio y privado) |

> **Importante:** el archivo `.env` contiene credenciales y **no debe** compartirse ni incluirse en un repositorio público. La plantilla `.env.example` no debe contener contraseñas reales.

### 4.2 Instalar dependencias y ejecutar

```powershell
npm install
npm run dev
```

(También puedes usar `npm start` según los scripts definidos en `backend/package.json`).

Si la conexión es correcta, el servidor indicará que está en ejecución (por defecto en el puerto configurado, p. ej. `http://localhost:3000`). Mantén esta terminal abierta mientras uses la app.

### 4.3 Comprobación del API

En otra terminal o navegador:

```powershell
Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3000/api/categories" -UseBasicParsing
```

Deberías recibir respuestas HTTP exitosas (por ejemplo 200) con el mensaje de estado o el listado de categorías.

## 5. Configurar y ejecutar la aplicación Flutter

Abre una **nueva** terminal en la raíz del proyecto:

```powershell
cd "<RUTA_DEL_PROYECTO>"
flutter pub get
```

### 5.1 URL de la API

La app obtiene la URL base de la API mediante la constante de compilación `API_URL` (con un valor por defecto según plataforma cuando no se especifica). Ejemplos:

- **Navegador web / escritorio (misma máquina que el backend):**
  ```powershell
  flutter run -d chrome --dart-define=API_URL=http://localhost:3000/api
  ```
- **Emulador Android (backend en la máquina anfitriona):**
  ```powershell
  flutter run --dart-define=API_URL=http://10.0.2.2:3000/api
  ```
- **Dispositivo físico Android (misma red local que el PC):**
  ```powershell
  flutter run -d <ID_DEL_DISPOSITIVO> --dart-define=API_URL=http://<IP_LOCAL_DE_TU_PC>:3000/api
  ```

Reemplaza `<IP_LOCAL_DE_TU_PC>` por la dirección IPv4 de la interfaz de red de tu PC en la misma red que el dispositivo (puedes consultarla con `ipconfig` en PowerShell). El dispositivo y el PC deben estar en la misma red y el puerto del backend debe ser accesible.

### 5.2 Compilación (opcional)

```powershell
flutter build apk --debug
```

> La compilación Android requiere una configuración compatible de Android SDK, Gradle y JDK en tu entorno.

## 6. Flujo de verificación funcional sugerido

1. Registrar un usuario nuevo e iniciar sesión.
2. Listar categorías y productos; abrir el detalle de un producto.
3. Agregar productos al carrito, modificar cantidades, eliminar ítems y verificar subtotales/total.
4. Cerrar y volver a abrir sesión para comprobar la persistencia del carrito en la base de datos.

## 7. Solución de problemas comunes

| Problema | Posible causa | Acción sugerida |
|---|---|---|
| Error de conexión a MySQL en el backend | Credenciales o `DB_NAME` incorrectos, MySQL detenido | Revisar `backend/.env`, que el servicio MySQL esté activo y que la base exista |
| `ECONNREFUSED` / sin respuesta del API | Backend no iniciado o puerto distinto | Verificar que `npm run dev` esté en ejecución y el `PORT` configurado |
| La app no conecta desde emulador/dispositivo | URL de API incorrecta para la plataforma/red | Usar `--dart-define=API_URL=...` adecuado (emulador vs dispositivo físico) |
| Dispositivo físico no alcanza al backend | Distinta red, firewall o aislamiento de clientes en el router | Confirmar misma red, IP correcta del PC, puerto accesible y reglas de firewall locales |
| Assets/imágenes no corresponden | Rutas de imagen en BD desactualizadas | Revisar y, si aplica, ejecutar el script de actualización de imágenes indicado en 3.2 |

## 8. Notas de seguridad

- No publiques tu archivo `.env` ni expongas `JWT_SECRET`, contraseñas de base de datos u otras credenciales.
- Cambia `JWT_SECRET` por un valor robusto y privado en cualquier entorno compartido.
- Evita incluir direcciones, rutas o datos personales en capturas o documentación pública.