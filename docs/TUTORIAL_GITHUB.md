# Tutorial: preparación local para una futura publicación manual en GitHub

> **Alcance y advertencias**
> - Este documento es **solo un tutorial local**. No inicializa repositorios, no crea commits, no configura remotos y no publica ni sincroniza contenido con GitHub.
> - No se incluyen ni solicitan credenciales de GitHub (tokens, contraseñas, llaves). La autenticación, si la realizas en el futuro, debe hacerse por tu cuenta siguiendo los mecanismos oficiales de GitHub.
> - Todos los comandos se muestran en **PowerShell** y deben ejecutarse únicamente cuando decidas hacerlo manualmente.

## 1. Objetivo

Dejar el proyecto en un estado limpio y seguro para que, más adelante, puedas crear un repositorio y subirlo a GitHub por tu cuenta, minimizando el riesgo de exponer información sensible.

## 2. Verificación previa (antes de cualquier acción Git)

### 2.1 Revisar archivos sensibles

Confirma que **no** se incluirán en una publicación:

- `backend/.env` (credenciales reales, secretos).
- Archivos con contraseñas, tokens, claves privadas, certificados o keystores (`*.keystore`, `*.jks`, `key.properties`).
- Bases de datos locales, volcados con datos reales o respaldos personales.

La plantilla `backend/.env.example` sí puede versionarse, siempre que contenga solo valores de ejemplo.

Comprobación rápida (solo lectura):

```powershell
cd "<RUTA_DEL_PROYECTO>"
if (Test-Path "backend\.env") { Write-Output "Existe backend/.env (no debe publicarse)" } else { Write-Output "No existe backend/.env" }
Get-Content "backend\.env.example"
```

### 2.2 Revisar `.gitignore`

Verifica que `.gitignore` excluya dependencias, compilaciones, archivos temporales y secretos (por ejemplo `.env`, `node_modules/`, `build/`, `.dart_tool/`, artefactos de IDE). Ajusta reglas solo si detectas archivos privados que no deban publicarse.

```powershell
Get-Content ".gitignore"
```

### 2.3 Revisar documentación y datos incluidos

- Asegúrate de que README y documentos en `docs/` no contengan rutas personales, nombres de usuario del sistema, direcciones IP privadas, correos personales no deseados ni credenciales.
- Revisa scripts SQL y datos de ejemplo: deben ser datos de prueba, no información real de usuarios.

Búsquedas orientativas (solo lectura):

```powershell
Select-String -Path ".\README.md","docs\*.md" -Pattern "Users\\<usuario>","/Users/","/home/" -SimpleMatch
Select-String -Path ".\README.md","docs\*.md" -Pattern "<IP_LOCAL>|IP privada literal" -SimpleMatch
```

Si aparece alguna coincidencia en documentación que vayas a publicar, reemplázala por un marcador genérico (por ejemplo `<RUTA_DEL_PROYECTO>` o `<IP_LOCAL_DE_TU_PC>`).

### 2.4 Limpieza local (opcional, sin Git)

Puedes eliminar artefactos regenerables para reducir tamaño antes de empaquetar/copiar el proyecto (no borres código fuente ni evidencias académicas necesarias):

```powershell
# Opcional: limpiar compilaciones Flutter (regenerables)
# flutter clean

# Opcional: eliminar dependencias de Node si deseas reinstalarlas después (regenerable)
# Remove-Item -Recurse -Force "backend\node_modules"
```

> Los comandos anteriores están comentados como referencia; ejecútalos solo si comprendes su efecto.

## 3. Comandos Git de referencia (ejecución manual futura)

Los siguientes bloques son **referenciales** para cuando decidas publicar el proyecto manualmente. **No los ejecutes ahora** como parte de este tutorial automatizado.

### 3.1 Inicializar un repositorio local (cuando corresponda)

```powershell
cd "<RUTA_DEL_PROYECTO>"
git init
git status
```

- `git init`: crea un repositorio Git local en la carpeta actual.
- `git status`: muestra el estado de los archivos (sin seguimiento, modificados, etc.).

### 3.2 Revisar qué se incluiría y crear un commit

```powershell
git add .
git status
git commit -m "Versión inicial del proyecto"
```

- `git add .`: prepara los archivos (respetando `.gitignore`) para el commit.
- `git status`: permite verificar que no se hayan agregado archivos sensibles.
- `git commit -m "..."`: registra una instantánea local con el mensaje indicado.

> Antes de confirmar, revisa cuidadosamente la salida de `git status`. Si ves `.env`, `node_modules/`, `build/` u otros archivos privados, **no** continúes: corrige `.gitignore` y quita esos archivos del área de preparación.

### 3.3 Conectar con un repositorio remoto en GitHub (creado previamente en tu cuenta)

```powershell
git branch -M main
git remote add origin https://github.com/<TU_USUARIO>/<TU_REPOSITORIO>.git
git push -u origin main
```

- `git branch -M main`: establece el nombre de la rama principal.
- `git remote add origin ...`: asocia el repositorio local con un remoto (debes crear el repositorio vacío en GitHub desde tu cuenta).
- `git push -u origin main`: envía la rama al remoto y configura el seguimiento.

> La URL y el método de autenticación dependen de tu configuración personal de GitHub. No compartas credenciales ni tokens en archivos del proyecto.

### 3.4 Actualizaciones posteriores (referencia)

```powershell
git add .
git commit -m "Describe brevemente el cambio"
git push
```

## 4. Lista de verificación final

- [ ] `backend/.env` no está incluido ni preparado para publicarse.
- [ ] `.gitignore` cubre secretos, dependencias y artefactos de compilación.
- [ ] `README.md` y `docs/` no exponen rutas personales, IP privadas ni credenciales.
- [ ] Los scripts SQL incluidos contienen únicamente datos de ejemplo apropiados.
- [ ] Has revisado `git status` (cuando decidas usar Git) antes de cualquier commit/push.

## 5. Soporte

Para problemas de instalación o ejecución del proyecto, consulta [INSTALACION.md](INSTALACION.md). Para la política y herramientas oficiales de GitHub, utiliza la documentación oficial de GitHub en su sitio web.