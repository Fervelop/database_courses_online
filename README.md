# 📚 Plataforma de Cursos Online - Curso SQL Avanzado

## 🎯 Descripción del Proyecto

Este repositorio contiene un curso completo de **SQL Avanzado** adaptado al dominio de una **Plataforma de Cursos Online**. Cubre desde CTEs recursivas hasta funciones y procedimientos PL/pgSQL.

**Semanas 13-18**: SQL Avanzado con casos reales de negocio

---

## 📋 Tabla de Contenidos

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

# Ejecutar un proyecto
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
| 13 | Jerarquías | REPEAT, ARRAY | WITH RECURSIVE |
| 14 | Rankings | ROW_NUMBER, RANK, DENSE_RANK | CTE de ranking |
| 15 | Tendencias | LAG, LEAD, FIRST_VALUE, LAST_VALUE | CREATE VIEW |
| 16 | Optimización | EXPLAIN, CREATE INDEX, TO_CHAR | Índices B-tree |
| 17 | Integridad | BEGIN, COMMIT, ROLLBACK | SAVEPOINT |
| 18 | Automatización | CREATE FUNCTION, CREATE PROCEDURE | PL/pgSQL |

---

## 💡 Ejemplos de Consultas

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

## 📝 Licencia

Este proyecto está bajo licencia MIT. Úsalo libremente en fines educativos.

---

## 👨‍💻 Autor

Curso adaptado al dominio de Plataforma de Cursos Online con el bootcamp de SQL de `ergrato-dev/bc-sql`.

**Fecha**: Julio 2026  
**Versión**: 1.0
