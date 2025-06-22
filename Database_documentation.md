# 📋 DOCUMENTACIÓN BASE DE DATOS CERAGEN
## Centro Médico de Terapia Física

**Proyecto:** DAWA (Desarrollo de Aplicaciones Web Avanzadas)  
**Base de datos:** PostgreSQL 17  
**Esquema:** ceragen  
**Total tablas:** 36  

---

## Comandos basicos
pip install -r requirements.txt


## 🏗️ ARQUITECTURA DEL SISTEMA

### **Módulos Principales**

#### 🔐 **SEGU (Seguridad) - 7 tablas**
- **segu_user** - Usuarios del sistema
- **segu_rol** - Roles del sistema  
- **segu_user_rol** - Relación usuarios-roles (multirol)
- **segu_menu** - Menús del sistema
- **segu_menu_rol** - Menús por rol
- **segu_module** - Módulos del sistema
- **segu_login** - Control de sesiones
- **segu_user_notification** - Notificaciones

#### 🏥 **ADMIN (Administración) - 17 tablas**

**Gestión de Personas:**
- **admin_person** - Datos básicos de personas
- **admin_person_genre** - Catálogo de géneros
- **admin_marital_status** - Estados civiles

**Clientes y Pacientes:**
- **admin_client** - Clientes (facturación)
- **admin_patient** - Pacientes del centro médico

**Personal Médico:**
- **admin_medical_staff** - Personal médico
- **admin_medic_person_type** - Tipos de personal (terapista, enfermera, etc.)

**Productos y Servicios:**
- **admin_product** - Paquetes de terapias
- **admin_therapy_type** - Tipos de terapia
- **admin_product_promotion** - Promociones de productos

**Sistema de Facturación:**
- **admin_invoice** - Facturas principales
- **admin_invoice_detail** - Detalles de factura
- **admin_invoice_payment** - Pagos realizados
- **admin_invoice_tax** - Impuestos aplicados

**Control de Gastos:**
- **admin_expense** - Gastos del centro
- **admin_expense_type** - Tipos de gastos

**Catálogos:**
- **admin_payment_method** - Métodos de pago
- **admin_tax** - Catálogo de impuestos
- **admin_parameter_list** - Parámetros del sistema

#### 🏥 **CLINIC (Clínico) - 7 tablas**

**Historiales Médicos:**
- **clinic_patient_medical_history** - Historial médico completo

**Gestión de Alergias:**
- **clinic_allergy_catalog** - Catálogo de alergias
- **clinic_patient_allergy** - Alergias por paciente

**Gestión de Enfermedades:**
- **clinic_disease_catalog** - Catálogo de enfermedades
- **clinic_disease_type** - Tipos de enfermedades
- **clinic_patient_disease** - Enfermedades por paciente

**Control de Sesiones:**
- **clinic_session_control** - Control de sesiones de terapia

#### 📋 **AUDI (Auditoría) - 2 tablas**
- **audi_tables** - Tablas auditadas
- **audi_sql_events_register** - Registro de eventos SQL

---

## 🔗 RELACIONES PRINCIPALES

### **Flujo de Datos Principal:**

```
admin_person (datos básicos)
    ↓
├─ admin_client (para facturación)
├─ segu_user (usuarios del sistema)  
├─ admin_medical_staff (personal médico)
└─ admin_patient (pacientes)
    ↓
    ├─ clinic_patient_medical_history (historial)
    ├─ clinic_patient_allergy (alergias)
    ├─ clinic_patient_disease (enfermedades)
    └─ admin_invoice (facturación)
        ↓
        ├─ admin_invoice_detail (productos)
        ├─ admin_invoice_payment (pagos)
        └─ clinic_session_control (sesiones)
```

### **Relaciones Críticas:**

1. **admin_person** es la tabla central de personas
2. **admin_patient** conecta con **admin_person** y **admin_client**
3. **admin_invoice** es el núcleo de facturación
4. **clinic_session_control** maneja todas las sesiones de terapia
5. **segu_user_rol** permite multirol por usuario

---

## 📊 ESTRUCTURA DE TABLAS CLAVE

### **admin_person** (Tabla Central)
```sql
per_id (PK)
per_identification (cédula)
per_names, per_surnames
per_genre_id (FK)
per_marital_status_id (FK)
per_country, per_city, per_address
per_phone, per_mail
per_birth_date
```

### **admin_patient** (Pacientes)
```sql
pat_id (PK)
pat_person_id (FK → admin_person)
pat_client_id (FK → admin_client)
pat_code (código del paciente)
pat_medical_conditions
pat_allergies, pat_blood_type
pat_emergency_contact_name, pat_emergency_contact_phone
```

### **admin_invoice** (Facturación)
```sql
inv_id (PK)
inv_number (número de factura)
inv_date (fecha)
inv_client_id (FK → admin_person)
inv_patient_id (FK → admin_patient)
inv_subtotal, inv_discount, inv_tax, inv_grand_total
```

### **clinic_session_control** (Control de Sesiones)
```sql
sec_id (PK)
sec_inv_id (FK → admin_invoice)
sec_pro_id (FK → admin_product)
sec_ses_number (número de sesión)
sec_ses_agend_date (fecha agendada)
sec_ses_exec_date (fecha ejecutada)
sec_typ_id (FK → admin_therapy_type)
sec_med_staff_id (FK → admin_medical_staff)
ses_consumed (sesión consumida)
```

### **admin_product** (Paquetes de Terapia)
```sql
pro_id (PK)
pro_code, pro_name
pro_description
pro_price (precio)
pro_total_sessions (total de sesiones)
pro_duration_days (duración en días)
pro_therapy_type_id (FK → admin_therapy_type)
```

---

## 💰 SISTEMA DE PAGOS

### **Métodos de Pago (admin_payment_method)**
- Efectivo
- Transferencia (requiere evidencia)
- Tarjeta de crédito (recargo 20%)

### **Control de Pagos**
```sql
-- admin_invoice_payment
inp_invoice_id (FK → admin_invoice)
inp_payment_method_id (FK → admin_payment_method)
inp_amount (monto)
inp_reference (referencia)
inp_proof_image_path (evidencia)
```

### **Cálculo Automático**
- Subtotal + Impuestos - Descuentos = Total
- Control de pagos parciales vs completos

---

## 🎯 FUNCIONALIDADES IMPLEMENTADAS

### ✅ **Sistema de Usuarios**
- Multirol por usuario
- Control de sesiones con tokens
- Notificaciones internas
- Menús dinámicos por rol

### ✅ **Gestión de Pacientes**
- Historiales médicos completos
- Catálogo de alergias y enfermedades
- Información de emergencia
- Códigos únicos de paciente

### ✅ **Control de Terapias**
- Paquetes de sesiones
- Tipos de terapia (física/alternativa)
- Promociones y descuentos
- Asignación de personal médico

### ✅ **Facturación Empresarial**
- Facturas con detalles
- Múltiples métodos de pago
- Control de impuestos
- Evidencias de pago

### ✅ **Control de Sesiones**
- Agendamiento vs ejecución
- Personal asignado
- Estado de consumo
- Seguimiento por factura

### ✅ **Sistema de Auditoría**
- Log de todos los cambios
- Trazabilidad completa
- Soft delete en todas las tablas

---

## 🔧 COMANDOS DE RESTAURACIÓN

### **PostgreSQL**
```bash
# Navegar a PostgreSQL (La ubicacion de PostgreSQL)
cd "C:\Program Files\PostgreSQL\17\bin"

# Crear base de datos 
createdb -U postgres DAWA

# Restaurar backup (ruta = donde esta)
# ejemplo = pg_restore -U postgres -W -d DAWA --if-exists --clean "C:\Users\ASUS\Downloads\BCK_BD_CERAGEN_18_junio.sql"
pg_restore -U postgres -W -d DAWA --verbose --clean --no-acl --no-owner "ruta/BCK_BD_CERAGEN_18_junio.sql"
```

### **Verificar Restauración**
```sql
-- Ver esquemas
SELECT schema_name FROM information_schema.schemata;

-- Ver tablas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'ceragen' ORDER BY table_name;

-- Contar registros
SELECT schemaname, tablename, n_tup_ins as registros
FROM pg_stat_user_tables 
WHERE schemaname = 'ceragen';

-- Limpiar intentos fallidos y desbloquear admin
UPDATE ceragen.segu_user 
SET login_attempts = 0,
    user_locked = false
WHERE user_login_id = 'admin';
```

---

## 📈 POWER BI - CONFIGURACIÓN

### **Conexión**
```
Tipo: PostgreSQL database
Servidor: localhost
Base de datos: DAWA_Project
Usuario: postgres
```

### **Tablas Prioritarias para Dashboards**

#### **Dashboard de Ventas**
```sql
-- Tablas principales
admin_invoice (ventas)
admin_invoice_detail (productos vendidos)
admin_invoice_payment (pagos)
admin_patient (pacientes)
admin_product (paquetes)
```

#### **Dashboard de Sesiones**
```sql
-- Control operativo
clinic_session_control (sesiones)
admin_medical_staff (personal)
admin_therapy_type (tipos de terapia)
admin_patient (pacientes)
```

#### **Dashboard de Gastos**
```sql
-- Control financiero
admin_expense (gastos)
admin_expense_type (categorías)
admin_payment_method (métodos)
```

### **Métricas Clave**
- **Ingresos:** SUM(inv_grand_total) por período
- **Sesiones:** COUNT(sec_id) por terapista/fecha
- **Gastos:** SUM(exp_amount) por categoría
- **Pacientes:** COUNT(DISTINCT pat_id) activos
- **Utilización:** Sesiones ejecutadas vs agendadas

---

## 🚀 CONSULTAS ÚTILES

### **Resumen de Ventas por Mes**
```sql
SELECT 
    DATE_TRUNC('month', inv_date) as mes,
    COUNT(*) as facturas,
    SUM(inv_grand_total) as ingresos_total,
    SUM(inv_subtotal) as subtotal,
    SUM(inv_tax) as impuestos
FROM ceragen.admin_invoice 
WHERE inv_state = true
GROUP BY DATE_TRUNC('month', inv_date)
ORDER BY mes DESC;
```

### **Sesiones por Terapista**
```sql
SELECT 
    p.per_names || ' ' || p.per_surnames as terapista,
    COUNT(sc.sec_id) as sesiones_total,
    COUNT(CASE WHEN sc.ses_consumed THEN 1 END) as sesiones_ejecutadas,
    COUNT(CASE WHEN NOT sc.ses_consumed THEN 1 END) as sesiones_pendientes
FROM ceragen.clinic_session_control sc
JOIN ceragen.admin_medical_staff ms ON sc.sec_med_staff_id = ms.med_id
JOIN ceragen.admin_person p ON ms.med_person_id = p.per_id
WHERE sc.ses_state = true
GROUP BY p.per_names, p.per_surnames
ORDER BY sesiones_total DESC;
```

### **Estado de Pagos**
```sql
SELECT 
    i.inv_number,
    p.per_names || ' ' || p.per_surnames as paciente,
    i.inv_grand_total as total_factura,
    COALESCE(SUM(ip.inp_amount), 0) as pagado,
    i.inv_grand_total - COALESCE(SUM(ip.inp_amount), 0) as pendiente,
    CASE 
        WHEN COALESCE(SUM(ip.inp_amount), 0) = 0 THEN 'Sin pago'
        WHEN COALESCE(SUM(ip.inp_amount), 0) < i.inv_grand_total THEN 'Parcial'
        ELSE 'Completo'
    END as estado_pago
FROM ceragen.admin_invoice i
JOIN ceragen.admin_patient pat ON i.inv_patient_id = pat.pat_id
JOIN ceragen.admin_person p ON pat.pat_person_id = p.per_id
LEFT JOIN ceragen.admin_invoice_payment ip ON i.inv_id = ip.inp_invoice_id
WHERE i.inv_state = true
GROUP BY i.inv_id, i.inv_number, p.per_names, p.per_surnames, i.inv_grand_total
ORDER BY i.inv_date DESC;
```

---

## 📝 NOTAS IMPORTANTES

### **Consideraciones de Diseño**
1. **Soft Delete:** Todas las tablas tienen campos de eliminación lógica
2. **Auditoría:** Sistema completo de trazabilidad
3. **Multirol:** Un usuario puede tener múltiples roles activos
4. **Facturación:** Separación clara entre cliente (paga) y paciente (recibe)
5. **Sesiones:** Control granular de ejecución vs agendamiento

### **Restricciones del Sistema**
- No contempla facturación electrónica (SUNAT/SRI)
- Sistema monousuario por centro médico
- Backup manual (no automático)
- Sin integración con sistemas externos

### **Escalabilidad**
- Preparado para multisucursal (campo de ubicación)
- Soporte para múltiples tipos de terapia
- Sistema de promociones flexible
- Roles configurables

---

## 🎯 PRÓXIMOS PASOS

### **Para continuar el proyecto:**
1. **Conectar Power BI** con las tablas principales
2. **Crear dashboards** de ventas, sesiones y gastos  
3. **Desarrollar frontend** con los microservicios definidos
4. **Implementar APIs** para cada módulo (SEGU, ADMIN, CLINIC)
5. **Configurar notificaciones** automáticas del sistema

### **Recursos adicionales:**
- **GitHub:** https://github.com/Mickaell22/ceragen-database
- **Archivo original:** BCK_BD_CERAGEN_18_junio.sql
- **Esquema:** ceragen (PostgreSQL 17)

---

**Documento generado:** Junio 2025  
**Proyecto:** DAWA - Centro Médico CERAGEN  
**Estado:** Base de datos restaurada y documentada
