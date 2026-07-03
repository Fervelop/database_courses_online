# 📚 Semana 16: Índices y Funciones Integradas

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Crear índices B-tree con `CREATE INDEX`
- ✅ Usar `EXPLAIN` y `EXPLAIN ANALYZE` para optimizar queries
- ✅ Implementar funciones de texto: `UPPER()`, `LOWER()`, `LENGTH()`
- ✅ Usar funciones de fecha: `TO_CHAR()`, `AGE()`, `EXTRACT()`
- ✅ Calcular con funciones numéricas: `ROUND()`, `CEIL()`, `FLOOR()`
- ✅ Optimizar performance de consultas

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con:

- **Estudiantes**: Nombre, email, fecha de registro
- **Cursos**: Precio, descripción, fecha de creación
- **Análisis de antigüedad**: Cuánto tiempo lleva un estudiante registrado

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio
- **docker-compose.yml**: Configuración Docker para PostgreSQL

## 🔍 Conceptos Clave

### EXPLAIN - Planes de Ejecución

```sql
EXPLAIN SELECT * FROM students WHERE course_id = 5;
EXPLAIN ANALYZE SELECT * FROM students WHERE course_id = 5;
```

### CREATE INDEX

```sql
CREATE INDEX idx_students_course_id ON students(course_id);
```

### Funciones de Texto

| Función | Ejemplo | Resultado |
|---------|---------|-----------|
| `UPPER()` | `UPPER('SQL')` | `SQL` |
| `LOWER()` | `LOWER('SQL')` | `sql` |
| `LENGTH()` | `LENGTH('SQL')` | `3` |
| `SUBSTR()` | `SUBSTR('SQL', 1, 2)` | `SQ` |

### Funciones de Fecha

```sql
TO_CHAR(fecha, 'DD/MM/YYYY')      -- Formato: 25/12/2024
AGE(CURRENT_DATE, fecha_registro)  -- Intervalo de edad
EXTRACT(YEAR FROM fecha)           -- Extrae año
```

## 🐳 Docker Setup

```bash
# Iniciar PostgreSQL en Docker
docker-compose up -d

# Conectarse a la base de datos
docker-compose exec postgres psql -U postgres -d database_courses_online

# Ver logs
docker-compose logs -f postgres

# Detener
docker-compose down
```

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-16/3-proyecto/starter/proyecto.sql
```

## 💡 Casos de Uso Reales

1. **Búsqueda rápida**: Índices en columnas WHERE frecuentes
2. **Reportes formateados**: Fechas y textos con formato
3. **Análisis de antigüedad**: Cuántos años tiene el registro
4. **Performance tuning**: Identificar queries lentas

## 🎓 Próxima Semana

**Semana 17**: Transacciones y ACID (BEGIN, COMMIT, ROLLBACK, SAVEPOINT)
