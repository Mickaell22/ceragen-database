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
ws_ceragen/
├── src/
│   ├── api/
│   │   ├── Components/          # Lógica de negocio
│   │   │   ├── Security/        # Autenticación y usuarios
│   │   │   ├── Admin/           # Administración
│   │   │   └── Audit/           # Auditoría
│   │   ├── Services/            # Endpoints REST
│   │   │   ├── Security/        # /security/*
│   │   │   └── Admin/           # /admin/*
│   │   ├── Model/               # Modelos de datos
│   │   │   ├── Request/         # Validación de entrada
│   │   │   └── Response/        # Formato de salida
│   │   └── Routes/
│   │       └── api_routes.py    # Configuración de rutas
│   └── utils/
│       ├── database/            # Conexión PostgreSQL
│       ├── general/             # Configuración y logs
│       └── smpt/               # Email
├── static/
│   └── swagger.json            # Documentación API
├── app.py                      # Punto de entrada
└── requirements.txt            # Dependencias
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

---

## 🚀 Próximos Pasos - Frontend

### Tecnologías Recomendadas:
- **React** con TypeScript
- **Axios** para peticiones HTTP
- **React Router** para navegación
- **Material-UI** o **Tailwind** para estilos

### Configuración Inicial:
```javascript
// Configurar base URL
const API_BASE_URL = 'http://127.0.0.1:5000';

// Configurar interceptors para token
axios.defaults.headers.common['tokenapp'] = localStorage.getItem('token');
```

### Estructura Frontend:
```
frontend/
├── src/
│   ├── components/       # Componentes reutilizables
│   ├── pages/           # Páginas principales  
│   ├── services/        # Llamadas a API
│   ├── hooks/           # Custom hooks
│   └── utils/           # Utilidades
```

---

## ✅ Backend Completamente Funcional

**Estado**: ✅ **OPERATIVO**

- ✅ Autenticación funcionando
- ✅ Base de datos conectada  
- ✅ Todos los esquemas corregidos
- ✅ Swagger documentado
- ✅ Logs implementados
- ✅ CORS configurado
- ✅ Listo para integrar con frontend

**¡Éxito total!** 🎉