# 📚 Plataforma de Cursos Online - Curso SQL Avanzado

## 🎯 Descripción del Proyecto

Este repositorio contiene un curso completo de **SQL Avanzado** adaptado al dominio de una **Plataforma de Cursos Online**. Cubre desde CTEs recursivas hasta funciones y procedimientos PL/pgSQL.

**Semanas 06-18**: Desde fundamentos de SQL (agregaciones, JOINs, subqueries) hasta SQL Avanzado con casos reales de negocio (CTEs recursivas, window functions, transacciones y PL/pgSQL)

---

## 📋 Tabla de Contenidos

### Semana 06: Funciones de Agregación
- **Tema**: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`, `GROUP BY`, `HAVING`
- **Dominio**: Reportes y resúmenes de cursos, estudiantes e inscripciones
- **Archivos**: `semana-06/query.sql`

### Semana 07: NULL y Constraints (Restricciones)
- **Tema**: `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `COALESCE()`, `IS NULL / IS NOT NULL`
- **Dominio**: Integridad de datos incompletos en cursos y estudiantes
- **Archivos**: `semana-07/query.sql`

### Semana 09: JOIN de Tablas
- **Tema**: `INNER JOIN`, `LEFT JOIN`, agregación con JOINs, detección de registros huérfanos
- **Dominio**: Relación entre cursos, categorías, estudiantes e inscripciones
- **Archivos**: `semana-09/query.sql`

### Semana 10: SELF JOIN y Datos Jerárquicos
- **Tema**: `SELF JOIN`, `CROSS JOIN`, jerarquías de categorías (padre-hijo)
- **Dominio**: Categorías anidadas de cursos (Programming > Web Development, etc.)
- **Archivos**: `semana-10/query.sql`

### Semana 11: Subqueries (Consultas Anidadas)
- **Tema**: Subquery escalar en `WHERE`/`SELECT`, `NOT EXISTS`, tabla derivada en `FROM`, subqueries correlacionadas
- **Dominio**: Análisis comparativo de cursos frente al promedio de su categoría
- **Archivos**: `semana-11/query.sql`

### Semana 12: CTEs y CASE WHEN
- **Tema**: `WITH` (CTEs simples y encadenados), `CASE WHEN`, `COUNT` condicional
- **Dominio**: Reportes analíticos de rendimiento por categoría y banda de precio
- **Archivos**: `semana-12/query.sql`

### Semana 13: CTEs Recursivas
- **Tema**: `WITH RECURSIVE` para jerarquías
- **Dominio**: Estructura jerárquica de cursos/módulos/lecciones
- **Archivos**: `semana-13/3-proyecto/starter/proyecto.sql`

### Semana 14: Window Functions - Ranking
- **Tema**: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`
- **Dominio**: Ranking de estudiantes por calificación
- **Archivos**: `semana-14/3-proyecto/starter/proyecto.sql`

### Semana 15: Window Functions - Navegación y Vistas
- **Tema**: `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`, `CREATE VIEW`
- **Dominio**: Análisis de tendencias mensuales
- **Archivos**: `semana-15/3-proyecto/starter/proyecto.sql`

### Semana 16: Índices y Funciones Integradas
- **Tema**: `CREATE INDEX`, `EXPLAIN`, Funciones de texto/fecha
- **Dominio**: Optimización de consultas y reportes
- **Archivos**: `semana-16/3-proyecto/starter/proyecto.sql`

### Semana 17: Transacciones y ACID
- **Tema**: `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`
- **Dominio**: Inscripciones seguras de estudiantes
- **Archivos**: `semana-17/3-proyecto/starter/proyecto.sql`

### Semana 18: Funciones y Procedimientos PL/pgSQL
- **Tema**: `CREATE FUNCTION`, `CREATE PROCEDURE`, `EXCEPTION`
- **Dominio**: Lógica de negocio compleja (inscripciones, validaciones)
- **Archivos**: `semana-18/3-proyecto/starter/proyecto.sql`

---

## 🚀 Quick Start

### Opción 1: Con Docker

```bash
# Iniciar PostgreSQL y Adminer
docker-compose up -d

# Verificar que está funcionando
docker-compose ps

# Conectarse a la base de datos
docker-compose exec postgres psql -U postgres -d database_courses_online
```

**Acceso a Adminer** (interfaz web):
- URL: http://localhost:8080
- Usuario: postgres
- Contraseña: postgres123
- Base de datos: database_courses_online

### Opción 2: PostgreSQL Local

```bash
# Crear la base de datos
createdb database_courses_online

# Ejecutar un proyecto de las semanas 06-12 (fundamentos)
psql -U usuario -d database_courses_online -f semana-06/query.sql

# Ejecutar un proyecto de las semanas 13-18 (SQL avanzado)
psql -U usuario -d database_courses_online -f semana-13/3-proyecto/starter/proyecto.sql
```

---

## 📊 Estructura del Dominio

### Entidades Principales

```
courses (cursos)
├── id: SERIAL
├── name: TEXT
├── price: NUMERIC
└── ...

students (estudiantes)
├── id: SERIAL
├── name: TEXT
├── email: TEXT
└── account_balance: NUMERIC

enrollments (inscripciones)
├── id: SERIAL
├── student_id: INT (FK)
├── course_id: INT (FK)
└── grade: NUMERIC
```

### Relaciones

```
courses --< enrollments >-- students
```

---

## 📝 Cómo Usar Este Repositorio

### Para Estudiantes

1. **Estudia el README** de cada semana para entender conceptos
2. **Ejecuta el proyecto SQL** de la semana
3. **Modifica las consultas** para entender mejor
4. **Experimenta** creando nuevas consultas

### Para Instructores

1. Usa los archivos SQL como **base para ejercicios**
2. Adapta el dominio a tus necesidades
3. Agrega nuevas consultas a cada semana
4. Proporciona retroalimentación basada en los READMEs

---

## 🔧 Conceptos Clave por Semana

| Semana | Concepto Principal | Funciones SQL | CTEs/Vistas |
|--------|-------------------|---------------|------------|
| 06 | Agregaciones | COUNT, SUM, AVG, MIN, MAX | GROUP BY / HAVING |
| 07 | Integridad de datos | COALESCE, IS NULL | NOT NULL, UNIQUE, CHECK, FOREIGN KEY |
| 09 | Combinación de tablas | — | INNER JOIN, LEFT JOIN |
| 10 | Jerarquías simples | COUNT | SELF JOIN, CROSS JOIN |
| 11 | Consultas anidadas | — | Subqueries escalares y correlacionadas, NOT EXISTS |
| 12 | Reportes analíticos | CASE WHEN, COUNT condicional | WITH (CTEs simples y encadenados) |
| 13 | Jerarquías | REPEAT, ARRAY | WITH RECURSIVE |
| 14 | Rankings | ROW_NUMBER, RANK, DENSE_RANK | CTE de ranking |
| 15 | Tendencias | LAG, LEAD, FIRST_VALUE, LAST_VALUE | CREATE VIEW |
| 16 | Optimización | EXPLAIN, CREATE INDEX, TO_CHAR | Índices B-tree |
| 17 | Integridad | BEGIN, COMMIT, ROLLBACK | SAVEPOINT |
| 18 | Automatización | CREATE FUNCTION, CREATE PROCEDURE | PL/pgSQL |

---

## 💡 Ejemplos de Consultas

### Funciones de Agregación (Semana 06)
```sql
SELECT
    c.difficulty_level,
    COUNT(*) AS total_courses,
    AVG(c.price) AS avg_price
FROM courses c
GROUP BY c.difficulty_level
HAVING COUNT(*) > 2;
```

### Manejo de NULL y Constraints (Semana 07)
```sql
SELECT
    name,
    COALESCE(phone, 'Sin teléfono registrado') AS phone
FROM students
WHERE phone IS NULL;
```

### JOIN de Tablas (Semana 09)
```sql
SELECT
    c.title,
    cat.name AS category,
    COUNT(e.id) AS total_enrollments
FROM courses c
INNER JOIN categories cat ON c.category_id = cat.id
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.title, cat.name;
```

### SELF JOIN Jerárquico (Semana 10)
```sql
SELECT
    child.name AS subcategory,
    parent.name AS parent_category
FROM categories child
JOIN categories parent ON child.parent_id = parent.id;
```

### Subqueries (Semana 11)
```sql
SELECT title, price
FROM courses c
WHERE price > (
    SELECT AVG(price) FROM courses
    WHERE category_id = c.category_id
);
```

### CTE y CASE WHEN (Semana 12)
```sql
WITH course_activity AS (
    SELECT course_id, COUNT(*) AS total_enrollments
    FROM enrollments
    GROUP BY course_id
)
SELECT
    c.title,
    CASE
        WHEN ca.total_enrollments > 10 THEN 'Alta demanda'
        WHEN ca.total_enrollments > 3 THEN 'Demanda media'
        ELSE 'Baja demanda'
    END AS popularidad
FROM courses c
JOIN course_activity ca ON ca.course_id = c.id;
```

### Jerarquía de Cursos (Semana 13)
```sql
WITH RECURSIVE arbol AS (
    SELECT id, name, parent_id, 1 AS depth, name AS path
    FROM course_hierarchy WHERE parent_id IS NULL
    UNION ALL
    SELECT ch.id, ch.name, ch.parent_id, a.depth + 1, 
           a.path || ' > ' || ch.name
    FROM course_hierarchy ch
    INNER JOIN arbol a ON ch.parent_id = a.id
)
SELECT * FROM arbol ORDER BY path;
```

### Ranking de Estudiantes (Semana 14)
```sql
SELECT
    s.name,
    c.name AS course,
    e.grade,
    RANK() OVER (PARTITION BY c.id ORDER BY e.grade DESC) AS rank
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id;
```

### Tendencias Mensuales (Semana 15)
```sql
SELECT
    month_date,
    course_id,
    enrollments,
    LAG(enrollments) OVER (PARTITION BY course_id ORDER BY month_date) AS prev_month
FROM monthly_metrics;
```

### Función Escalable (Semana 18)
```sql
CREATE FUNCTION fn_classify_student(total_courses INT)
RETURNS TEXT AS $$
BEGIN
    IF total_courses >= 5 THEN RETURN 'Expert';
    ELSIF total_courses >= 3 THEN RETURN 'Advanced';
    ELSE RETURN 'Beginner';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

---

## 📚 Recursos Adicionales

- [Documentación PostgreSQL 16](https://www.postgresql.org/docs/16/)
- [PL/pgSQL Documentation](https://www.postgresql.org/docs/16/plpgsql.html)
- [Window Functions Guide](https://www.postgresql.org/docs/16/functions-window.html)

---

## 🐛 Troubleshooting

### Error: "database does not exist"
```bash
# Crear la base de datos
createdb database_courses_online

# O con Docker
docker-compose exec postgres createdb -U postgres database_courses_online
```

### Error: "permission denied"
```bash
# Con Docker, asegúrate de que el contenedor está corriendo
docker-compose ps

# Reinicia si es necesario
docker-compose restart postgres
```

### Puerto 5432 ya en uso
```bash
# Cambiar puerto en docker-compose.yml
# ports: "5433:5432"  # en lugar de 5432:5432
```

---



**Fecha**: Julio 2026  
**Versión**: 1.0
