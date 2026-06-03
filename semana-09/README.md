# Semana 09: JOIN de Tablas

## 📚 ¿Qué se vio esta semana?

En la **Semana 09** estudiamos cómo **combinar datos de múltiples tablas** usando JOINs. Este es uno de los conceptos más poderosos de SQL. Los temas cubiertos fueron:

- **INNER JOIN** - Solo registros que coinciden en ambas tablas
- **LEFT JOIN** - Todos los de la tabla izquierda + coincidencias
- **CROSS JOIN** (implícito)
- **Agregación con JOINs** - Combinar datos relacionados
- **Detectar datos sin relaciones** - Identificar registros "huérfanos"

## 🎯 ¿Por qué se enseña de esta manera?

### El Problema: Datos Relacionados

En una BD real, **los datos están en múltiples tablas**:

```
Plataforma de Cursos Online:
├── courses (tabla de cursos)
├── categories (tabla de categorías)
├── enrollments (tabla de inscripciones)
└── students (tabla de estudiantes)

❌ Sin JOIN: No podemos relacionar datos
✅ Con JOIN: Podemos preguntas como:
   "¿Qué categoría tiene cada curso?"
   "¿Cuántos estudiantes se inscribieron por curso?"
```

### Estructura de Datos

```
Tabla: courses
┌────┬──────────────────────┬──────────────┐
│ id │ title                │ category_id  │
├────┼──────────────────────┼──────────────┤
│ 1  │ Python for Beginners │ 1 (Program)  │
│ 2  │ UI UX Design Basics  │ 2 (Design)   │
└────┴──────────────────────┴──────────────┘

Tabla: categories
┌────┬──────────────┐
│ id │ name         │
├────┼──────────────┤
│ 1  │ Programming  │
│ 2  │ Design       │
└────┴──────────────┘

Tabla: enrollments
┌────┬──────────┬───────────┐
│ id │ course_id│ student_id│
├────┼──────────┼───────────┤
│ 1  │ 1        │ 5         │
│ 2  │ 1        │ 10        │
└────┴──────────┴───────────┘
```

## 🔑 Tipos de JOINs

### 1. INNER JOIN - Solo Coincidencias
```sql
SELECT
    courses.title AS course,
    categories.name AS category
FROM courses
INNER JOIN categories ON courses.category_id = categories.id;
```

```
Resultado:
┌────────────────────────┬──────────────┐
│ course                 │ category     │
├────────────────────────┼──────────────┤
│ Python for Beginners   │ Programming  │
│ UI UX Design Basics    │ Design       │
└────────────────────────┴──────────────┘

✅ Solo cursos que tienen categoría válida
```

**Por qué:** Cuando necesitas SOLO datos relacionados (sin datos "huérfanos").

### 2. LEFT JOIN - Todos de la Izquierda + Coincidencias
```sql
SELECT
    courses.title AS course,
    COUNT(enrollments.id) AS total_students
FROM courses
LEFT JOIN enrollments ON enrollments.course_id = courses.id
GROUP BY courses.title;
```

```
Resultado:
┌────────────────────────┬────────────────┐
│ course                 │ total_students │
├────────────────────────┼────────────────┤
│ Python for Beginners   │ 3              │
│ Java Advanced          │ 0              │ ← Sin inscripciones
│ UI UX Design Basics    │ 2              │
└────────────────────────┴────────────────┘

✅ Todos los cursos, aunque no tengan estudiantes
```

**Por qué:** Cuando necesitas ver TODOS los registros de una tabla, incluso si no hay coincidencias.

### 3. Detectar Datos Sin Relaciones
```sql
SELECT
    courses.title AS course_without_students
FROM courses
LEFT JOIN enrollments ON enrollments.course_id = courses.id
WHERE enrollments.id IS NULL;
```

```
Resultado:
┌────────────────────────┐
│ course_without_students│
├────────────────────────┤
│ Java Advanced          │
│ C# Fundamentals        │
└────────────────────────┘

✅ Solo cursos que NADIE se inscribió
```

**Por qué:** Identificar problemas (cursos sin ventas, estudiantes sin cursos, etc.).

## 📊 Ejemplos de Queries de Semana 09

### Query 1: INNER JOIN Básico
```sql
SELECT
    courses.title AS course,
    enrollments.recorded_at
FROM courses
INNER JOIN enrollments ON enrollments.course_id = courses.id;
```
**Resultado:** Solo cursos que tienen inscripciones.

### Query 2: JOIN con Tres Tablas
```sql
SELECT
    courses.title AS course,
    categories.name AS category,
    enrollments.recorded_at
FROM courses
INNER JOIN categories ON courses.category_id = categories.id
INNER JOIN enrollments ON enrollments.course_id = courses.id;
```
**Resultado:** Cursos + categoría + inscripciones en una sola query.

### Query 3: LEFT JOIN Básico
```sql
SELECT
    courses.title AS course,
    enrollments.recorded_at AS activity
FROM courses
LEFT JOIN enrollments ON enrollments.course_id = courses.id;
```
**Resultado:** Todos los cursos, con NULL si no hay inscripciones.

### Query 4: Contar con LEFT JOIN
```sql
SELECT
    courses.title AS course,
    COUNT(enrollments.id) AS total_records
FROM courses
LEFT JOIN enrollments ON enrollments.course_id = courses.id
GROUP BY courses.title
ORDER BY total_records DESC;
```
**Resultado:** Ranking de cursos por cantidad de inscripciones.

## 💡 Diferencia Visual: INNER JOIN vs LEFT JOIN

```
INNER JOIN:
┌─────────────┐       ┌──────────────┐
│  courses    │       │ enrollments  │
│ ───────     │       │ ──────────── │
│ id: 1 ◄────────┼───► id: 1        │
│ id: 2        │ ┘    │ course: 1    │
└─────────────┘       └──────────────┘
Resultado: Solo id 1 (que tiene inscripciones)

LEFT JOIN:
┌─────────────┐       ┌──────────────┐
│  courses    │       │ enrollments  │
│ ───────     │       │ ──────────── │
│ id: 1 ◄────────┼───► id: 1        │
│ id: 2        │ NULL │ course: 1    │
└─────────────┘       └──────────────┘
Resultado: id 1 Y id 2 (todos los cursos)
```

## 🎓 Aprendizajes Aplicables

- **Dashboards** - Combinar datos de múltiples fuentes
- **Reportes complejos** - Análisis multi-tabla
- **Data analysis** - Encontrar relaciones entre datos
- **Auditoría** - Detectar datos faltantes o duplicados
- **Troubleshooting** - ¿Por qué faltan datos? → LEFT JOIN + WHERE IS NULL

## 📋 Casos de Uso Comunes

| Caso | JOIN | Razón |
|------|------|-------|
| "Listar cursos y sus categorías" | INNER | Solo cursos con categoría válida |
| "Todos los cursos, incluso sin ventas" | LEFT | Todos + datos de ventas |
| "Cursos sin inscripciones" | LEFT + WHERE IS NULL | Identificar productos sin demanda |
| "Estudiantes con sus cursos" | INNER | Solo estudiantes inscritos |
| "Todos los estudiantes y sus cursos" | LEFT | Todos, inscritos o no |

## ⚡ Performance Tips

1. **Siempre ON en el JOIN**, no WHERE:
   ```sql
   ✅ LEFT JOIN enrollments ON enrollments.course_id = courses.id
   ❌ LEFT JOIN enrollments WHERE enrollments.course_id = courses.id
   ```

2. **Usar índices** en las columnas de join:
   ```sql
   CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
   ```

3. **Limitar filas antes de joinear**:
   ```sql
   ✅ Filtrar en WHERE después del JOIN
   ❌ Joinear todo y luego filtrar
   ```
