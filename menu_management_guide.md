# 🎭 Guía Completa: Sistema de Menús Dinámicos Multi-Rol

## 📋 **PROMPT PARA FUTURAS CONVERSACIONES**

```
CONTEXTO DEL SISTEMA:
- Aplicación React con Material-UI y sistema multi-rol
- Backend Flask con PostgreSQL
- Menús dinámicos según permisos de rol
- Estructura: Módulos → Menús → Submenús
- Roles: Administrador (acceso completo), Terapeuta, Enfermera/Enfermero

ESTRUCTURA DE BASE DE DATOS:
- ceragen.segu_module: Módulos (Dashboard, Médico, Seguridad, etc.)
- ceragen.segu_menu: Menús con jerarquía padre-hijo  
- ceragen.segu_menu_rol: Relación menú-rol (permisos)
- ceragen.segu_rol: Roles del sistema
- ceragen.segu_user_rol: Usuarios con múltiples roles

FRONTEND:
- DynamicSidebar.js: Renderiza menús dinámicos
- UserProfile.js: Cambio temporal de roles
- Iconos Tabler para menús
- Evento 'roleChanged' para actualizar sidebar

PROBLEMA FRECUENTE: 
- Caché del navegador al cambiar roles
- Solución: Hard refresh o cache-busting

NECESITO AYUDA PARA: [describir la tarea específica]
```

---

## 🏗️ **ESTRUCTURA TÉCNICA DEL SISTEMA**

### **1. Jerarquía de Datos:**
```
MÓDULO (ej: Médico)
├── MENÚ PADRE (ej: Pacientes)
│   ├── SUBMENÚ 1 (ej: Gestión de Pacientes)
│   ├── SUBMENÚ 2 (ej: Historial Médico)
│   └── SUBMENÚ 3 (ej: Valoración Médica)
└── MENÚ SIMPLE (ej: Personal Médico)
```

### **2. Mapeo Base de Datos ↔ Frontend:**

| Base de Datos | Frontend | Descripción |
|---------------|----------|-------------|
| `segu_module.mod_name` | NavGroup subheader | Título del módulo |
| `segu_menu.menu_name` | NavItem/NavCollapse title | Nombre del menú |
| `segu_menu.menu_icon_name` | getIconComponent() | Ícono Tabler |
| `segu_menu.menu_href` | href | Ruta React Router |
| `segu_menu.menu_parent_id` | children array | Jerarquía de submenús |

---

## 🔧 **SCRIPTS SQL PARA GESTIÓN DE MENÚS**

### **A. Agregar Nuevo Menú Simple:**
```sql
-- 1. Insertar menú
INSERT INTO ceragen.segu_menu (
    menu_name, menu_order, menu_module_id, menu_parent_id, 
    menu_icon_name, menu_href, menu_url, menu_key, 
    menu_state, user_created, date_created
) VALUES (
    'Nombre del Menú',                 -- Título visible
    [ORDEN],                          -- Posición en el módulo
    [MODULE_ID],                      -- ID del módulo padre
    NULL,                             -- NULL = menú principal
    '[ICON_NAME]',                    -- Ver tabla de iconos abajo
    '/ruta/del/menu',                 -- Ruta React
    '/ruta/del/menu',                 -- URL (igual que href)
    'menu_key_unique',                -- Identificador único
    true, 'admin', NOW()
);

-- 2. Asignar a roles
INSERT INTO ceragen.segu_menu_rol (mr_menu_id, mr_rol_id, user_created, date_created, mr_state)
SELECT m.menu_id, r.rol_id, 'admin', NOW(), true
FROM ceragen.segu_menu m, ceragen.segu_rol r
WHERE m.menu_name = 'Nombre del Menú' 
    AND r.rol_name IN ('Administrador', 'Terapeuta');
```

### **B. Agregar Submenú a Menú Existente:**
```sql
-- 1. Obtener ID del menú padre
SELECT menu_id, menu_name FROM ceragen.segu_menu 
WHERE menu_name = 'Menú Padre' AND menu_parent_id IS NULL;

-- 2. Insertar submenú
INSERT INTO ceragen.segu_menu (
    menu_name, menu_order, menu_module_id, menu_parent_id,
    menu_icon_name, menu_href, menu_url, menu_key,
    menu_state, user_created, date_created
) VALUES (
    'Submenú Nuevo',
    [ORDEN_HIJO],                     -- Posición dentro del padre
    [MODULE_ID],                      -- Mismo módulo que el padre
    [PARENT_MENU_ID],                 -- ID del menú padre
    '[ICON_NAME]',
    '/ruta/submenu',
    '/ruta/submenu', 
    'submenu_key_unique',
    true, 'admin', NOW()
);

-- 3. Heredar permisos del padre
INSERT INTO ceragen.segu_menu_rol (mr_menu_id, mr_rol_id, user_created, date_created, mr_state)
SELECT new_menu.menu_id, existing_perm.mr_rol_id, 'admin', NOW(), true
FROM ceragen.segu_menu new_menu
CROSS JOIN ceragen.segu_menu_rol existing_perm
INNER JOIN ceragen.segu_menu parent_menu ON existing_perm.mr_menu_id = parent_menu.menu_id
WHERE new_menu.menu_name = 'Submenú Nuevo'
    AND parent_menu.menu_name = 'Menú Padre'
    AND existing_perm.mr_state = true;
```

### **C. Scripts de Verificación:**
```sql
-- Ver estructura completa de un módulo
SELECT 
    mod.mod_name as modulo,
    CASE WHEN m.menu_parent_id IS NULL THEN '📁 ' ELSE '  └── ' END || m.menu_name as menu_jerarquia,
    m.menu_href as ruta,
    m.menu_order as orden,
    STRING_AGG(r.rol_name, ', ') as roles_asignados
FROM ceragen.segu_menu m
INNER JOIN ceragen.segu_module mod ON m.menu_module_id = mod.mod_id
LEFT JOIN ceragen.segu_menu_rol mr ON m.menu_id = mr.mr_menu_id AND mr.mr_state = true
LEFT JOIN ceragen.segu_rol r ON mr.mr_rol_id = r.rol_id AND r.rol_state = true
WHERE mod.mod_name = 'Médico' AND m.menu_state = true
GROUP BY mod.mod_name, m.menu_parent_id, m.menu_name, m.menu_href, m.menu_order
ORDER BY m.menu_parent_id NULLS FIRST, m.menu_order;

-- Contar menús por rol
SELECT 
    r.rol_name,
    COUNT(mr.mr_id) as total_menus
FROM ceragen.segu_rol r
LEFT JOIN ceragen.segu_menu_rol mr ON r.rol_id = mr.mr_rol_id AND mr.mr_state = true
LEFT JOIN ceragen.segu_menu m ON mr.mr_menu_id = m.menu_id AND m.menu_state = true
WHERE r.rol_state = true
GROUP BY r.rol_name
ORDER BY total_menus DESC;
```

---

## 🎨 **TABLA DE ICONOS DISPONIBLES**

| Nombre en BD | Componente Tabler | Uso Recomendado |
|--------------|-------------------|-----------------|
| `aperture` | IconAperture | Dashboard principal |
| `shield` | IconShield | Seguridad, roles |
| `users` | IconUsers | Gestión de usuarios |
| `heartbeat` | IconHeartbeat | Pacientes, médico |
| `stethoscope` | IconStethoscope | Personal médico |
| `medical_cross` | IconMedicalCross | Terapias, medicina |
| `clipboard_list` | IconClipboardList | Historiales, reportes |
| `calendar` | IconCalendar | Citas, agenda |
| `calendar_event` | IconCalendarEvent | Gestión de citas |
| `package` | IconPackage | Productos, inventario |
| `cash` | IconCash | Facturación, pagos |
| `credit_card` | IconCreditCard | Métodos de pago |
| `percentage` | IconPercentage | Promociones, descuentos |
| `chart_bar` | IconChartBar | Reportes, estadísticas |
| `virus` | IconVirus | Enfermedades |
| `alert_triangle` | IconAlertTriangle | Alergias |
| `report_medical` | IconReportMedical | Valoraciones médicas |

---

## 🔧 **CONFIGURACIÓN DEL FRONTEND**

### **Agregar Nuevo Ícono en DynamicSidebar.js:**
```javascript
// En getIconComponent(), agregar:
const iconMap = {
  // ... iconos existentes
  'nuevo_icono': IconNuevoIcono,  // Importar arriba
};
```

### **Estructura de Respuesta Esperada del Backend:**
```json
{
  "result": true,
  "data": [
    {
      "mod_id": 35,
      "mod_name": "Médico",
      "mod_order": 4,
      "menu": [
        {
          "menu_id": 165,
          "menu_name": "Pacientes",
          "menu_href": "/admin/patients",
          "menu_icon_name": "heartbeat",
          "menu_parent_id": null,
          "submenu": [
            {
              "menu_id": 175,
              "menu_name": "Gestión de Pacientes", 
              "menu_href": "/admin/patients",
              "menu_icon_name": "heartbeat"
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 🚨 **TROUBLESHOOTING COMÚN**

### **Problema: Menús no aparecen después de agregar**
```sql
-- Verificar que el menú existe
SELECT * FROM ceragen.segu_menu WHERE menu_name = 'Tu Menú';

-- Verificar permisos de rol
SELECT m.menu_name, r.rol_name 
FROM ceragen.segu_menu m
LEFT JOIN ceragen.segu_menu_rol mr ON m.menu_id = mr.mr_menu_id
LEFT JOIN ceragen.segu_rol r ON mr.mr_rol_id = r.rol_id
WHERE m.menu_name = 'Tu Menú';
```

### **Problema: Caché del navegador**
```javascript
// En handleRoleChange() del UserProfile.js
localStorage.clear(); // Limpiar todo el caché
window.location.reload(true); // Hard refresh
```

### **Problema: Iconos no aparecen**
1. Verificar que el ícono esté en la tabla `iconMap`
2. Importar el componente en DynamicSidebar.js
3. Verificar el nombre exacto en `menu_icon_name`

---

## 📝 **CHECKLIST PARA AGREGAR MENÚS**

- [ ] ✅ **SQL**: Insertar en `segu_menu` con datos correctos
- [ ] ✅ **Permisos**: Asignar a roles en `segu_menu_rol`  
- [ ] ✅ **Frontend**: Agregar ícono en `iconMap` si es nuevo
- [ ] ✅ **Jerarquía**: Verificar `menu_parent_id` correcto
- [ ] ✅ **Orden**: Establecer `menu_order` lógico
- [ ] ✅ **Rutas**: Verificar que `menu_href` exista en React Router
- [ ] ✅ **Pruebas**: Cambiar rol y verificar que aparece
- [ ] ✅ **Caché**: Hacer hard refresh si no aparece

---

## 🎯 **COMANDOS DE ADMINISTRACIÓN RÁPIDA**

### **Asignar todos los menús al Administrador:**
```sql
INSERT INTO ceragen.segu_menu_rol (mr_menu_id, mr_rol_id, user_created, date_created, mr_state)
SELECT m.menu_id, 1, 'admin', NOW(), true
FROM ceragen.segu_menu m
WHERE m.menu_state = true 
    AND NOT EXISTS (
        SELECT 1 FROM ceragen.segu_menu_rol mr 
        WHERE mr.mr_menu_id = m.menu_id AND mr.mr_rol_id = 1 AND mr.mr_state = true
    );
```

### **Clonar permisos entre roles:**
```sql
-- Copiar todos los permisos del Administrador al Terapeuta
INSERT INTO ceragen.segu_menu_rol (mr_menu_id, mr_rol_id, user_created, date_created, mr_state)
SELECT mr.mr_menu_id, 13, 'admin', NOW(), true  -- 13 = ID Terapeuta
FROM ceragen.segu_menu_rol mr
WHERE mr.mr_rol_id = 1 AND mr.mr_state = true  -- 1 = ID Administrador
    AND NOT EXISTS (
        SELECT 1 FROM ceragen.segu_menu_rol existing 
        WHERE existing.mr_menu_id = mr.mr_menu_id 
            AND existing.mr_rol_id = 13 
            AND existing.mr_state = true
    );
```

---

## 🚀 **EJEMPLO COMPLETO: Agregar "Valoración Médica"**

```sql
-- 1. Insertar el menú
INSERT INTO ceragen.segu_menu (
    menu_name, menu_order, menu_module_id, menu_parent_id,
    menu_icon_name, menu_href, menu_url, menu_key,
    menu_state, user_created, date_created
) VALUES (
    'Valoración Médica', 3, 35, 165,
    'report_medical', '/admin/medical-assessment-report', 
    '/admin/medical-assessment-report', 'medical_assessment_3',
    true, 'admin', NOW()
);

-- 2. Asignar permisos
INSERT INTO ceragen.segu_menu_rol (mr_menu_id, mr_rol_id, user_created, date_created, mr_state)
SELECT m.menu_id, r.rol_id, 'admin', NOW(), true
FROM ceragen.segu_menu m, ceragen.segu_rol r
WHERE m.menu_name = 'Valoración Médica' 
    AND r.rol_name IN ('Administrador', 'Terapeuta', 'Enfermera/Enfermero');

-- 3. Verificar
SELECT 
    '📁 ' || parent.menu_name as padre,
    '  └── ' || child.menu_name as hijo,
    child.menu_href as ruta,
    STRING_AGG(rol.rol_name, ', ') as roles
FROM ceragen.segu_menu child
INNER JOIN ceragen.segu_menu parent ON child.menu_parent_id = parent.menu_id
LEFT JOIN ceragen.segu_menu_rol mr ON child.menu_id = mr.mr_menu_id
LEFT JOIN ceragen.segu_rol rol ON mr.mr_rol_id = rol.rol_id
WHERE child.menu_name = 'Valoración Médica'
GROUP BY parent.menu_name, child.menu_name, child.menu_href;
```

---

**💡 TIP FINAL:** Guarda este prompt y estos scripts para futuras referencias. El sistema está diseñado para ser extensible y fácil de mantener.

**🎯 NOTA IMPORTANTE:** Siempre haz backup de la base de datos antes de ejecutar scripts de modificación masiva.