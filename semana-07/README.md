# Semana 07: NULL y Constraints (Restricciones)

## 📚 ¿Qué se vio esta semana?

En la **Semana 07** estudiamos cómo **manejar datos incompletos (NULL)** y cómo **aplicar restricciones** para garantizar la integridad de los datos. Los temas cubiertos fueron:

- **NULL** - Valores ausentes o desconocidos
- **NOT NULL** - Obligar un valor
- **UNIQUE** - Garantizar valores únicos
- **CHECK** - Validar rangos y condiciones
- **FOREIGN KEY** - Mantener relaciones entre tablas
- **COALESCE()** - Reemplazar NULL con valores alternativos
- **IS NULL / IS NOT NULL** - Consultar valores NULL

## 🎯 ¿Por qué se enseña de esta manera?

### El Problema: Datos Incompletos

En una base de datos real, **no siempre tenemos todos los datos**:

```
❌ Problema:
- Un curso sin descripción
- Un estudiante sin teléfono
- Un precio negativo (¡error!)
- Cursos duplicados con mismo título

✅ Solución:
- Usar constraints para prevenir errores
- Manejar NULL apropiadamente
```

### Por qué es importante

1. **Integridad de datos** - Evitar datos inválidos
2. **Consistencia** - Reglas uniformes en toda la BD
3. **Confiabilidad** - Resultados predecibles
4. **Performance** - Índices más eficientes

## 📊 Mejoras en la Semana 07

Comparado con Semana 06, ahora agregamos **restricciones en el esquema**:

```sql
-- SEMANA 06: Sin validación
CREATE TABLE courses (
    price DECIMAL(10,2) NOT NULL
);

-- SEMANA 07: Con validación
CREATE TABLE courses (
    price DECIMAL(10,2) NOT NULL CHECK(price > 0),
    duration_hours INT NOT NULL CHECK(duration_hours BETWEEN 1 AND 200)
);
```

### Nuevas Columnas NULL Permitidas
```sql
(1, 'Advanced Java Programming', NULL, ...)
-- El campo 'description' puede ser NULL
```

## 🔑 Conceptos Clave

### 1. NOT NULL - Campo Obligatorio
```sql
CREATE TABLE students (
    first_name VARCHAR(100) NOT NULL,
    -- ✅ Siempre debe tener valor
);
```
**Por qué:** El nombre de un estudiante es esencial.

### 2. UNIQUE - Evitar Duplicados
```sql
CREATE TABLE categories (
    name VARCHAR(100) NOT NULL UNIQUE,
    -- ✅ No puede haber dos categorías con el mismo nombre
);
```
**Por qué:** Cada categoría debe ser única.

### 3. CHECK - Validar Rangos
```sql
CREATE TABLE courses (
    price DECIMAL(10,2) CHECK(price > 0),
    -- ✅ Solo acepta precios positivos
    duration_hours INT CHECK(duration_hours BETWEEN 1 AND 200)
    -- ✅ Solo acepta 1 a 200 horas
);
```
**Por qué:** Previene datos ilógicos (precios negativos, cursos de 0 horas).

### 4. FOREIGN KEY - Relaciones Válidas
```sql
CREATE TABLE courses (
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
    -- ✅ category_id debe existir en categories
);
```
**Por qué:** Un curso debe estar en una categoría válida.

### 5. COALESCE() - Manejar NULL
```sql
SELECT
    title,
    COALESCE(description, 'Sin descripción') AS descripcion
FROM courses;
```
**Por qué:** Mostrar un valor por defecto cuando falta información.

## 💡 Queries Principales de Semana 07

### Detectar NULL
```sql
SELECT id, title
FROM courses
WHERE description IS NULL;
-- Encuentra cursos sin descripción
```

### Reemplazar NULL
```sql
SELECT
    title,
    COALESCE(description, 'Sin descripción') AS descripcion
FROM courses;
-- Muestra descripción o texto alternativo
```

### Contar NULL
```sql
SELECT 
    COUNT(*) AS total,
    COUNT(description) AS con_descripcion,
    SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS sin_descripcion
FROM courses;
```

## 📋 Comparación: Semana 06 vs Semana 07

| Aspecto | Semana 06 | Semana 07 |
|---------|-----------|----------|
| **Constraints** | Mínimos | Completos |
| **NULL** | Ignorado | Manejado explícitamente |
| **Validación** | A nivel aplicación | A nivel BD |
| **Integridad** | Básica | Fuerte |
| **NULL en datos** | No | Sí (algunos campos) |

## 🎓 Aprendizajes Aplicables

- **Backend validation** - Prevenir datos inválidos desde la fuente
- **Data quality** - Asegurar que los datos sean confiables
- **Error handling** - Entender por qué las inserciones fallan
- **Database design** - Planear qué campos son obligatorios
- **Reporting with NULL** - Crear reportes que manejen información incompleta

## ⚠️ Casos de Uso de NULL

```sql
-- ✅ Correcto usar NULL:
- email VARCHAR(150) UNIQUE  -- Puede no tener email
- phone VARCHAR(20)          -- Puede no tener teléfono
- birth_date DATE            -- Puede no saber la fecha

-- ❌ Evitar NULL:
- id INT NOT NULL PRIMARY KEY
- first_name VARCHAR(100) NOT NULL
- email VARCHAR(150) NOT NULL UNIQUE
```
