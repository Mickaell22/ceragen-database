# 📋 Documentación del Sistema de Gestión - Centro Médico CERAGEN

## 🔐 Módulo de Seguridad - Frontend React

**Proyecto:** DAWA (Desarrollo de Aplicaciones Web Avanzadas)  
**Sistema:** Centro Médico de Terapia Física CERAGEN  
**Tecnología:** React + Material-UI + Flask Backend  
**Fecha:** Junio 2025  

---

## 📖 Índice

1. [Gestión de Usuarios](#-gestión-de-usuarios)
2. [Gestión de Roles](#-gestión-de-roles)
3. [Configuración Técnica](#-configuración-técnica)
4. [Solución de Problemas](#-solución-de-problemas)

---

## 👥 Gestión de Usuarios

### **Archivo:** `UserManagement.js`
**Ruta:** `src/views/security/UserManagement.js`

### 🎯 Funcionalidades Implementadas

#### ✅ **Funcionalidades Operativas:**
- **Crear usuarios** - Totalmente funcional
- **Listar usuarios** - Con búsqueda y filtros
- **Ver detalles de usuarios** - Modo solo lectura
- **Eliminar usuarios** - Soft delete (marcar como inactivo)

#### ❌ **Funcionalidades Limitadas:**
- **Editar usuarios** - Deshabilitado por limitaciones del backend

### 📊 Características Principales

#### **1. Dashboard de Usuarios**
```javascript
// Estadísticas en tiempo real
- Usuarios Activos: {users.filter(u => u.user_state !== false).length}
- Roles Disponibles: {roles.length}
- Personas Registradas: {persons.length}
```

#### **2. Tabla Interactiva**
- 🔍 **Búsqueda en tiempo real** por nombre de usuario o email
- 👁️ **Vista detallada** de cada usuario
- 🗑️ **Eliminación con confirmación** y advertencias
- 🎨 **Estados visuales** con chips de colores

#### **3. Formulario de Creación**
```javascript
// Campos requeridos
- Persona (selección desde admin_person)
- Cédula (auto-llenado desde persona)
- Email (auto-llenado desde persona)
- Contraseña (mínimo 6 caracteres)
- Rol (selección desde segu_rol)
```

### 🔧 Endpoints Utilizados

| Acción | Método | Endpoint | Estado |
|--------|---------|----------|---------|
| **Listar usuarios** | `GET` | `/user/list` | ✅ Funcional |
| **Crear usuario** | `POST` | `/user/insert` | ✅ Funcional |
| **Eliminar usuario** | `PATCH` | `/user/delete` | ✅ Funcional |
| **Actualizar usuario** | `PATCH` | `/user/update` | ❌ Limitado |
| **Listar roles** | `GET` | `/RolSistem/list` | ✅ Funcional |
| **Listar personas** | `GET` | `/admin/persons/list` | ✅ Funcional |

### 📝 Formato de Datos

#### **Request - Crear Usuario:**
```json
{
  "person_ci": "1234567890",
  "person_mail": "usuario@email.com",
  "person_password": "password123",
  "rol_id": 1,
  "person_id": 5,
  "id_career_period": 1
}
```

#### **Request - Eliminar Usuario:**
```json
{
  "del_id": 123
}
```

### 🚨 Limitaciones Conocidas

#### **1. Edición de Usuarios**
```javascript
// El backend actual (/user/update) solo permite:
- Cambiar estado de bloqueo (locked/unlocked)
- NO permite cambiar: email, contraseña, rol, datos personales

// Solución implementada:
const openEditDialog = (user) => {
  showSnackbar(
    'La edición de usuarios no está disponible. El backend actual solo permite bloquear/desbloquear usuarios.', 
    'warning'
  );
  openViewDialog(user); // Abrir en modo solo lectura
};
```

#### **2. Dependencias**
- **Requiere personas registradas** en `admin_person` para crear usuarios
- **Requiere roles activos** en `segu_rol`
- **Token JWT válido** para todas las operaciones

### 🔍 Validaciones Implementadas

```javascript
const validateForm = () => {
  const newErrors = {};
  
  // Validaciones críticas
  if (!formData.person_id) newErrors.person_id = 'Debe seleccionar una persona';
  if (!formData.person_ci.trim()) newErrors.person_ci = 'La cédula es requerida';
  if (formData.person_ci.length < 8) newErrors.person_ci = 'Mínimo 8 caracteres';
  if (dialogMode === 'create' && !formData.person_password.trim()) {
    newErrors.person_password = 'Contraseña requerida para usuarios nuevos';
  }
  if (formData.person_mail && !/\S+@\S+\.\S+/.test(formData.person_mail)) {
    newErrors.person_mail = 'Formato de email inválido';
  }
  if (!formData.rol_id) newErrors.rol_id = 'El rol es requerido';
  
  return Object.keys(newErrors).length === 0;
};
```

---

## 🛡️ Gestión de Roles

### **Archivo:** `RoleManagement.js`
**Ruta:** `src/views/security/RoleManagement.js`

### 🎯 Funcionalidades Implementadas

#### ✅ **Funcionalidades Operativas:**
- **Crear roles** - Totalmente funcional
- **Listar roles** - Con estadísticas
- **Editar roles** - Nombre y descripción
- **Eliminar roles** - Soft delete

### 📊 Características Principales

#### **1. Dashboard de Roles**
```javascript
// Estadísticas mostradas
- Total de Roles: {roles.length}
- Roles Activos: {roles.length} (todos activos por defecto)
```

#### **2. Tabla de Roles**
- 📋 **Información completa:** ID, Nombre, Descripción, Estado, Fecha
- ✏️ **Edición inline** con diálogo modal
- 🗑️ **Eliminación con confirmación**
- 🎨 **Estados visuales** con chips

#### **3. Formulario de Roles**
```javascript
// Campos del formulario
- rol_name: String (requerido)
- rol_description: String (opcional)
```

### 🔧 Endpoints Utilizados

| Acción | Método | Endpoint | Estado |
|--------|---------|----------|---------|
| **Listar roles** | `GET` | `/RolSistem/list` | ✅ Funcional |
| **Crear rol** | `POST` | `/RolSistem/insert` | ✅ Funcional |
| **Actualizar rol** | `PATCH` | `/RolSistem/update` | ✅ Funcional |
| **Eliminar rol** | `PATCH` | `/RolSistem/delete` | ✅ Funcional |

### 📝 Formato de Datos

#### **Request - Crear Rol:**
```json
{
  "rol_name": "Terapista",
  "rol_description": "Profesional encargado de realizar terapias físicas"
}
```

#### **Request - Actualizar Rol:**
```json
{
  "rol_id": 5,
  "rol_name": "Terapista Senior",
  "rol_description": "Terapista con más de 5 años de experiencia"
}
```

#### **Request - Eliminar Rol:**
```json
{
  "del_id": 5
}
```

### 🔧 Configuración de Headers

```javascript
const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    'tokenapp': token || '',
    'Authorization': `Bearer ${token || ''}`
  };
};
```

### 🎨 Funciones Principales

#### **1. Crear/Editar Rol**
```javascript
const handleSave = async () => {
  const url = dialogMode === 'create' 
    ? 'http://127.0.0.1:5000/RolSistem/insert'
    : 'http://127.0.0.1:5000/RolSistem/update';

  const response = await fetch(url, {
    method: dialogMode === 'create' ? 'POST' : 'PATCH',
    headers: getAuthHeaders(),
    body: JSON.stringify(formData)
  });
};
```

#### **2. Eliminar Rol**
```javascript
const handleDelete = async (role) => {
  const response = await fetch('http://127.0.0.1:5000/RolSistem/delete', {
    method: 'PATCH',  // ⚠️ PATCH, no DELETE
    headers: getAuthHeaders(),
    body: JSON.stringify({
      del_id: role.rol_id  // ⚠️ del_id, no rol_id
    })
  });
};
```

---

## ⚙️ Configuración Técnica

### 🔗 Integración Backend-Frontend

#### **1. Autenticación**
```javascript
// Token almacenado en localStorage
const token = localStorage.getItem('token');

// Headers requeridos para todas las peticiones
headers: {
  'Content-Type': 'application/json',
  'tokenapp': token
}
```

#### **2. URLs Base**
```javascript
const API_BASE_URL = 'http://127.0.0.1:5000';

// Endpoints principales
const ENDPOINTS = {
  users: {
    list: '/user/list',
    insert: '/user/insert',
    delete: '/user/delete',
    update: '/user/update'  // ⚠️ Limitado
  },
  roles: {
    list: '/RolSistem/list',
    insert: '/RolSistem/insert',
    update: '/RolSistem/update',
    delete: '/RolSistem/delete'
  },
  persons: {
    list: '/admin/persons/list'
  }
};
```

#### **3. Manejo de Errores**
```javascript
// Patrón estándar para manejo de errores
try {
  const response = await fetch(url, config);
  
  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`HTTP ${response.status}: ${errorText}`);
  }
  
  const data = await response.json();
  
  if (!data.result) {
    throw new Error(data.message || 'Error del servidor');
  }
  
  // Proceso exitoso
  handleSuccess(data.data);
  
} catch (error) {
  console.error('Error:', error);
  showSnackbar(`Error: ${error.message}`, 'error');
}
```

### 🎨 Componentes UI Utilizados

#### **Material-UI Components:**
```javascript
import {
  Typography, Box, Table, TableBody, TableCell, TableHead, TableRow,
  Avatar, Chip, Paper, TableContainer, Stack, Button, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, Grid, Alert,
  Snackbar, TextField, CircularProgress, Tooltip, FormControl,
  InputLabel, Select, MenuItem, DialogContentText, Slide, LinearProgress
} from '@mui/material';
```

#### **Iconos Tabler:**
```javascript
import {
  IconPlus, IconEdit, IconTrash, IconEye, IconSearch, IconRefresh,
  IconShield, IconUsers, IconAlertTriangle, IconCheck, IconExclamationMark
} from '@tabler/icons';
```

#### **Componentes Personalizados:**
```javascript
import Breadcrumb from '../../layouts/full/shared/breadcrumb/Breadcrumb';
import PageContainer from '../../components/container/PageContainer';
import CustomTextField from '../../components/forms/theme-elements/CustomTextField';
import CustomOutlinedButton from '../../components/forms/theme-elements/CustomOutlinedButton';
import CustomFormLabel from '../../components/forms/theme-elements/CustomFormLabel';
```

---

## 🚨 Solución de Problemas

### **Error 401 - No Autorizado**
```bash
# Síntoma
HTTP 401: Unauthorized

# Causa
Token JWT inválido, expirado o no encontrado

# Solución
1. Verificar que existe token en localStorage
2. Verificar que el token no ha expirado (120 minutos)
3. Realizar nuevo login si es necesario
```

### **Error 405 - Método No Permitido**
```bash
# Síntoma
HTTP 405: Method Not Allowed

# Causa Común
Usar DELETE en lugar de PATCH para eliminaciones

# Solución
// ❌ Incorrecto
method: 'DELETE'

// ✅ Correcto
method: 'PATCH'
```

### **Error de Validación de Request**
```bash
# Síntoma
"Error al Validar el Request -> {'campo': ['Unknown field.']}"

# Causa
Enviar campos que el backend no reconoce

# Solución
Verificar el schema de validación en el backend y ajustar el request
```

### **Error de Conexión**
```bash
# Síntoma
TypeError: Failed to fetch

# Causa
Backend no disponible o CORS no configurado

# Solución
1. Verificar que Flask esté ejecutándose en puerto 5000
2. Verificar configuración CORS en backend
3. Verificar URL de conexión
```

### **Personas no se cargan**
```bash
# Síntoma
"No hay personas disponibles"

# Causa
Error en endpoint /admin/persons/list

# Solución
1. Verificar token válido
2. Verificar que existan registros en admin_person
3. Verificar permisos del usuario
```

---

## 📊 Estado del Sistema

### ✅ **Funcionalidades Completamente Operativas:**
- Gestión completa de roles (CRUD)
- Creación de usuarios
- Visualización de usuarios
- Eliminación de usuarios
- Autenticación JWT
- Manejo de errores
- Validaciones de formularios
- Interfaz responsive

### ⚠️ **Limitaciones Conocidas:**
- Edición de usuarios limitada por backend
- Dependencia de datos maestros (personas, roles)
- Tokens con expiración de 120 minutos

### 🚀 **Próximas Mejoras:**
- Implementar edición completa de usuarios
- Agregar filtros avanzados
- Implementar paginación
- Agregar exportación de datos
- Implementar auditoría de cambios

---

## 📝 Notas de Desarrollo

### **Estructura de Archivos:**
```
src/views/security/
├── UserManagement.js     # Gestión de usuarios
├── RoleManagement.js     # Gestión de roles
├── MenuManagement.js     # Gestión de menús (futuro)
└── SecurityDashboard.js  # Dashboard principal
```

### **Patrón de Código:**
1. **Estados React** para manejo de datos
2. **Async/Await** para peticiones HTTP
3. **Try/Catch** para manejo de errores
4. **Material-UI** para componentes visuales
5. **Snackbar** para notificaciones
6. **Validaciones** antes de envío

### **Convenciones:**
- Nombres de funciones en camelCase
- Constantes en UPPER_SNAKE_CASE
- Componentes en PascalCase
- Variables de estado descriptivas
- Comentarios con emojis para organización

---

## 🎯 Ejemplos de Uso

### **Crear un Usuario Paso a Paso:**

1. **Verificar Prerrequisitos:**
   - Backend ejecutándose en puerto 5000
   - Token JWT válido en localStorage
   - Al menos una persona registrada en admin_person
   - Al menos un rol activo en segu_rol

2. **Proceso de Creación:**
   ```javascript
   // 1. Click en "Nuevo Usuario"
   // 2. Seleccionar persona de la lista
   // 3. Campos se auto-llenan (cédula, email)
   // 4. Ingresar contraseña (mínimo 6 caracteres)
   // 5. Seleccionar rol
   // 6. Click en "Crear Usuario"
   ```

3. **Validaciones Automáticas:**
   - Persona seleccionada
   - Cédula válida (auto-llenada)
   - Contraseña con mínimo 6 caracteres
   - Email en formato válido (si se proporciona)
   - Rol seleccionado

### **Eliminar un Usuario:**

1. **Proceso:**
   ```javascript
   // 1. Click en icono de basura en la tabla
   // 2. Confirmar en el diálogo de advertencia
   // 3. Usuario marcado como inactivo (soft delete)
   ```

2. **Advertencias Mostradas:**
   - El usuario no podrá iniciar sesión
   - Los datos se conservan en el sistema
   - La acción es reversible desde la base de datos

### **Gestionar Roles:**

1. **Crear Rol:**
   ```javascript
   // 1. Click en "Nuevo Rol"
   // 2. Ingresar nombre (requerido)
   // 3. Ingresar descripción (opcional)
   // 4. Click en "Crear"
   ```

2. **Editar Rol:**
   ```javascript
   // 1. Click en icono de edición
   // 2. Modificar nombre o descripción
   // 3. Click en "Actualizar"
   ```

3. **Eliminar Rol:**
   ```javascript
   // 1. Click en icono de basura
   // 2. Confirmar eliminación
   // 3. Rol marcado como inactivo
   ```

---

## 📋 Checklist de Verificación

### **Antes de Usar el Sistema:**
- [ ] Backend Flask ejecutándose en http://127.0.0.1:5000
- [ ] Base de datos PostgreSQL conectada
- [ ] Token JWT válido en localStorage
- [ ] Al menos una persona en admin_person
- [ ] Al menos un rol en segu_rol

### **Verificación de Funcionalidades:**
- [ ] Login funcional
- [ ] Lista de usuarios se carga
- [ ] Lista de roles se carga
- [ ] Creación de usuarios funciona
- [ ] Eliminación de usuarios funciona
- [ ] CRUD completo de roles funciona
- [ ] Mensajes de error se muestran claramente
- [ ] Validaciones de formulario funcionan

### **Configuración del Entorno:**
- [ ] React Dev Server en puerto 3000
- [ ] Flask Backend en puerto 5000
- [ ] CORS habilitado en backend
- [ ] Variables de entorno configuradas
- [ ] Dependencias de npm instaladas

---

**Documento generado:** Junio 2025  
**Autor:** Equipo DAWA  
**Estado:** Sistema operativo con limitaciones documentadas  
**Última actualización:** Implementación de gestión de usuarios y roles  
**Versión:** 1.0.0