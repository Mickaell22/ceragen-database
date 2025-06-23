# DAWA Backend - Documentación Completa

## 📋 Resumen del Sistema

**DAWA Backend** es una API REST desarrollada en Flask para el sistema de evaluación y coevaluación académica.

### Características principales:
- ✅ **API REST** con Flask y Flask-RESTful
- ✅ **Base de datos** PostgreSQL con esquema `ceragen`
- ✅ **Autenticación JWT** con tokens de 120 minutos
- ✅ **Documentación Swagger** en `/ws/secoed/`
- ✅ **Logs detallados** para debugging
- ✅ **CORS habilitado** para frontend

---

## 🗂️ Estructura del Proyecto

```
DAWA_2_BACKEND/
└── ws_ceragen/
├── 📄 .gitignore                     # Archivos ignorados por Git
├── 📄 app.py                         # Punto de entrada Flask
├── 📄 package-lock.json              # Lock de dependencias Node
├── 📄 package.json                   # Configuración Node.js
│
├── 📁 src/                           # Código fuente principal
│   ├── 📁 api/                       # Lógica de la API REST
│   │   ├── 📁 Components/            # Componentes de lógica de negocio
│   │   │   ├── 📁 Admin/             # Gestión administrativa
│   │   │   │   ├── 📄 AdminCicleComponent.py
│   │   │   │   ├── 📄 AdminiesComponent.py
│   │   │   │   ├── 📄 AdminMaritalStatus.py
│   │   │   │   ├── 📄 AdminParameterList.py
│   │   │   │   ├── 📄 AdminPeriodComponent.py
│   │   │   │   ├── 📄 AdminPersonComponent.py
│   │   │   │   ├── 📄 AdminPerson_genre.py
│   │   │   │   ├── 📄 AdminUniversityCareerComponent.py
│   │   │   │   ├── 📄 CareerPeriod_component.py
│   │   │   │   └── 📄 Unit_academy_component.py
│   │   │   ├── 📁 Audit/             # Auditoría del sistema
│   │   │   │   ├── 📄 AuditComponent.py
│   │   │   │   └── 📄 ErrorComponent.py
│   │   │   └── 📁 Security/          # Seguridad y autenticación
│   │   │       ├── 📄 ComponentMenu.py
│   │   │       ├── 📄 GetPersonComponent.py
│   │   │       ├── 📄 LoginComponent.py         # ⭐ Login principal
│   │   │       ├── 📄 loginDataComponent.py
│   │   │       ├── 📄 LogoutComponent.py
│   │   │       ├── 📄 menuComponent.py          # ⭐ Menús
│   │   │       ├── 📄 MenuRolComponent.py
│   │   │       ├── 📄 moduleComponent.py        # ⭐ Módulos
│   │   │       ├── 📄 ModuloComponent.py
│   │   │       ├── 📄 NotificationComponent.py
│   │   │       ├── 📄 rolComponent.py           # ⭐ Roles
│   │   │       ├── 📄 RolSistemComponent.py
│   │   │       ├── 📄 TokenComponent.py         # ⭐ JWT Tokens
│   │   │       ├── 📄 URCPComponent.py
│   │   │       ├── 📄 UserComponent.py          # ⭐ Usuarios
│   │   │       └── 📄 UserRolComponent.py
│   │   ├── 📁 Model/                 # Modelos de datos
│   │   │   ├── 📁 Request/           # Validación de entrada
│   │   │   │   ├── 📄 ValidateDataRequest.py    # ⭐ Validaciones generales
│   │   │   │   ├── 📁 Admin/         # Requests administrativos
│   │   │   │   │   ├── 📄 MaritalStatusRequest.py
│   │   │   │   │   ├── 📄 ParameterListRequest.py
│   │   │   │   │   ├── 📄 PersonGenreRequest.py
│   │   │   │   │   └── 📄 PersonRequest.py
│   │   │   │   └── 📁 Security/      # Requests de seguridad
│   │   │   │       ├── 📄 DeleteService.py
│   │   │   │       ├── 📄 InsertMenu.py
│   │   │   │       ├── 📄 InsertMenuRol.py
│   │   │   │       ├── 📄 InsertModulo.py
│   │   │   │       ├── 📄 InsertRolSistem.py
│   │   │   │       ├── 📄 InsertRolUser.py
│   │   │   │       ├── 📄 Inserturcp.py
│   │   │   │       ├── 📄 InsertUser.py          # ⭐ Crear usuario
│   │   │   │       ├── 📄 LoginRequest.py        # ⭐ Login request
│   │   │   │       ├── 📄 LogoutRequest.py
│   │   │   │       ├── 📄 NotificationIsReadRequest.py
│   │   │   │       ├── 📄 RecoveringPassword.py
│   │   │   │       ├── 📄 SelectFaculty.py
│   │   │   │       ├── 📄 UpdateMenu.py
│   │   │   │       ├── 📄 UpdateMenuRol.py
│   │   │   │       ├── 📄 UpdateModulo.py
│   │   │   │       ├── 📄 UpdateRolSistem.py
│   │   │   │       ├── 📄 UpdateRolUser.py
│   │   │   │       ├── 📄 Updateurcp.py
│   │   │   │       ├── 📄 UpdateUser.py
│   │   │   │       └── 📄 UpdateUserPassword.py
│   │   │   └── 📁 Response/          # Formato de salida
│   │   │       ├── 📁 Audit/         # Responses de auditoría
│   │   │       │   └── 📄 AudtSQLResponse.py
│   │   │       └── 📁 Security/      # Responses de seguridad
│   │   │           ├── 📄 MenuResponse.py
│   │   │           ├── 📄 ModuloResponse.py
│   │   │           ├── 📄 NotificationResponse.py
│   │   │           ├── 📄 PersonResponse.py
│   │   │           ├── 📄 RolSistemResponse.py
│   │   │           ├── 📄 UserResponse.py
│   │   │           └── 📄 UserRolResponse.py
│   │   ├── 📁 Routes/                # Configuración de rutas
│   │   │   └── 📄 api_routes.py                 # ⭐ Todas las rutas
│   │   └── 📁 Services/              # Endpoints REST
│   │       ├── 📁 Admin/             # Servicios administrativos
│   │       │   ├── 📄 AdminMaritalStatusservice.py
│   │       │   ├── 📄 AdminParameterListservice.py
│   │       │   ├── 📄 AdminPersonService.py
│   │       │   └── 📄 AdminPerson_genre_service.py
│   │       ├── 📁 Audit/             # Servicios de auditoría
│   │       │   ├── 📄 AuditService.py
│   │       │   └── 📄 ErrorService.py
│   │       └── 📁 Security/          # Servicios de seguridad
│   │           ├── 📄 GetPersonService.py
│   │           ├── 📄 LoginService.py        # ⭐ Endpoint login
│   │           ├── 📄 LogoutService.py
│   │           ├── 📄 MenuRolServices.py
│   │           ├── 📄 MenuService.py
│   │           ├── 📄 ModuloService.py
│   │           ├── 📄 NotificationService.py
│   │           ├── 📄 RolSistemService.py
│   │           ├── 📄 URCPService.py
│   │           ├── 📄 UserRolService.py
│   │           └── 📄 UserService.py         # ⭐ CRUD usuarios
│   └── 📁 utils/                     # Utilidades del sistema
│       ├── 📄 requirements.txt               # Dependencias Python
│       ├── 📁 database/              # Conexión base de datos
│       │   └── 📄 connection_db.py           # ⭐ Manejo PostgreSQL
│       ├── 📁 general/               # Configuración general
│       │   ├── 📄 config.cfg         # Archivo de configuración
│       │   ├── 📄 config.py          # ⭐ Configuración Python
│       │   ├── 📄 logs.py            # ⭐ Sistema de logs
│       │   ├── 📄 response.py        # ⭐ Formatos respuesta
│       │   └── 📁 LOGS/              # Carpeta de logs
│       │       ├── 📄 ERR_19_06_2025.log
│       │       └── 📄 ERR_20_06_2025.log
│       ├── 📁 middleware/            # Middleware personalizado
│       │   └── 📄 require_api_key.py
│       ├── 📁 pdf/                   # Generación de PDFs
│       │   └── 📄 generate_pdf.py
│       └── 📁 smpt/                  # Email/SMTP
│           ├── 📄 smpt_goolge.py
│           └── 📄 smpt_officeUG.py
└── 📁 static/                        # Archivos estáticos
    ├── 📄 MessagePassword.html               # Template de email
    └── 📄 swagger.json                       # ⭐ Documentación API
```

---

## ⚙️ Configuración

### 📁 config.cfg
```ini
[AMBIENTE]
env = DESARROLLO
connect_email = SMTP_UG

[DESARROLLO]
db_user = postgres
db_pass = 1234
db_host = localhost
db_name = DAWA
db_port = 5432
secret_jwt = JkDawa*+19**
api_moodle_url = https://5.161.135.79

[PRODUCCION]
db_user = secoed
db_pass = secoed2021
db_host = 5.161.135.79
db_name = secoedV3_db
db_port = 5434
secret_jwt = JkDawa*+19**//65454
api_moodle_url = https://5.161.135.79
```

### 🗄️ Base de Datos
- **Motor**: PostgreSQL 17
- **Esquema**: `ceragen`
- **Conexión**: localhost:5432
- **Tablas principales**: 
  - `segu_user` - Usuarios
  - `segu_rol` - Roles
  - `segu_menu` - Menús
  - `admin_person` - Personas

---

## 🚀 Instalación y Ejecución

### 1. Instalar dependencias:
```bash
pip install -r requirements.txt
```

### 2. Configurar base de datos:
- Crear base `DAWA` en PostgreSQL
- Ejecutar scripts de creación de tablas
- Configurar esquema `ceragen`

### 3. Ejecutar servidor:
```bash
python app.py
```

**Servidor disponible en**: http://127.0.0.1:5000

---

## 🔐 Autenticación

### Login
**Endpoint**: `POST /security/login`

**Request**:
```json
{
  "login_user": "admin",
  "login_password": "admin",
  "host_name": "localhost"
}
```

**Response exitosa**:
```json
{
  "result": true,
  "message": "Operación exitosa",
  "data": {
    "Token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "Datos": {
      "user": {...},
      "rols": [...]
    },
    "LogId": 123
  }
}
```

### Uso del Token
Incluir en headers de todas las peticiones:
```
tokenapp: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 📚 Endpoints Principales

### 🔒 Security
- `POST /security/login` - Iniciar sesión
- `POST /security/logout` - Cerrar sesión  
- `POST /user/insert` - Crear usuario
- `GET /user/list` - Listar usuarios
- `PATCH /user/update` - Actualizar usuario
- `PATCH /user/delete` - Eliminar usuario

### 👤 Admin
- `GET /admin/persons/list` - Listar personas
- `POST /admin/persons/add` - Crear persona
- `PATCH /admin/persons/update` - Actualizar persona
- `DELETE /admin/persons/delete/<id>/<user>` - Eliminar persona

### 📋 Evaluación
- `GET /Questionary/List` - Listar cuestionarios (requiere token)

---

## 🔧 Componentes Clave

### LoginComponent
```python
# Maneja autenticación con hash MD5
resultado = LoginComponent.Login(user, password)
```

### TokenComponent  
```python
# Genera tokens JWT con expiración de 120 min
token = TokenComponent.Token_Generate(username)
valido = TokenComponent.Token_Validate(token)
```

### DataBaseHandle
```python
# Maneja conexiones PostgreSQL con RealDictCursor
resultado = DataBaseHandle.getRecords(sql, tamanio, parametros)
```

---

## 🐛 Solución de Problemas

### Error "cursor not defined"
- **Causa**: Fallo en conexión DB antes de crear cursor
- **Solución**: Inicializar `conn = None, cursor = None`

### Error "secoed not found" 
- **Causa**: Referencias al esquema antiguo
- **Solución**: Cambiar `secoed.` por `ceragen.` en SQL

### Error "no tiene permisos"
- **Causa**: Usuario bloqueado por intentos fallidos
- **Solución**: 
```sql
UPDATE ceragen.segu_user 
SET login_attempts = 0, user_locked = false 
WHERE user_login_id = 'usuario';
```

### Error "ip_address unknown field"
- **Causa**: Campo no esperado en LoginRequest
- **Solución**: Quitar `ip_address` del JSON

---

## 📖 Swagger Documentation

**URL**: http://127.0.0.1:5000/ws/secoed/

La documentación interactiva incluye:
- ✅ Todos los endpoints disponibles
- ✅ Esquemas de request/response  
- ✅ Ejemplos de uso
- ✅ Códigos de estado HTTP
- ✅ Herramienta de pruebas integrada

---

## 🔄 Estados de Respuesta

### Exitosa (200)
```json
{
  "result": true,
  "message": "Operación exitosa", 
  "data": {...}
}
```

### Error (500)
```json
{
  "result": false,
  "message": "Descripción del error",
  "data": {},
  "status_code": 500
}
```

### No autorizado (401)
```json
{
  "result": false,
  "message": "Token inválido o expirado"
}
```

---

## 📝 Logs

### Ubicación
Los logs se escriben mediante `HandleLogs`:
- **Info**: Operaciones normales
- **Error**: Excepciones y errores
- **Debug**: Información detallada para desarrollo

### Ejemplo de logs exitosos:
```
15:46:12 - INF - post - Ingreso a Validar el Login
15:46:12 - INF - Login - Usuario encontrado, ID: 1  
15:46:12 - INF - Login - Login Exitoso para usuario: admin
```

###🛡️ Archivos de Seguridad (No en repo):
src/utils/general/config.cfg   # Contraseñas y secretos
.env                          # Variables de entorno
logs/                         # Archivos de log


###⭐ Archivos Principales Corregidos:

LoginComponent.py - Hash MD5 + logs debug
connection_db.py - Fix cursor error
rolComponent.py - Esquema ceragen + campos correctos
moduleComponent.py - Esquema ceragen
menuComponent.py - Esquema ceragen
UserComponent.py - Esquema ceragen (todos los métodos)



## ✅ Backend Completamente Funcional

**Estado**: ✅ **OPERATIVO**


