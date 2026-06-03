# Semana 11: Subqueries (Consultas Anidadas)

## 📚 ¿Qué se vio esta semana?

En la **Semana 11** estudiamos cómo **anidar consultas dentro de otras consultas** usando **Subqueries**. Este es uno de los conceptos más poderosos de SQL para análisis complejos. Los temas cubiertos fueron:

- **Subquery escalar en WHERE** - Filtrar basado en agregaciones
- **Subquery escalar en SELECT** - Mostrar valor calculado junto a cada fila
- **NOT EXISTS** - Encontrar registros que NO cumplen una condición
- **Tabla derivada en FROM** - Usar resultado de query como tabla
- **Correlated subqueries** - Subqueries que referencian la query externa

## 🎯 ¿Por qué se enseña de esta manera?

### El Problema: Preguntas Complejas

Muchas preguntas de negocio requieren **múltiples pasos de análisis**:

```
❌ Sin subqueries: Necesitamos 2-3 queries manuales
✅ Con subqueries: Una sola query automatizada

Ejemplo:
"Mostrar cursos cuyo precio es mayor al promedio
de su categoría"

Sin subqueries:
1. Calcular promedio por categoría (query 1)
2. Comparar cada curso con su promedio (query 2)

Con subqueries:
SELECT * FROM courses 
WHERE price > (SELECT AVG(price) FROM courses WHERE ...)
```

### Casos de Uso en la Plataforma de Cursos

```
Preguntas que responden subqueries:
1. ¿Qué cursos están arriba del promedio de su categoría?
2. ¿Cuáles son los cursos sin inscripciones?
3. ¿Qué categorías tienen más de 5 inscripciones?
4. ¿Cuál es el promedio global junto a cada curso?
```

## 🔑 Tipos de Subqueries

### 1. Subquery Escalar en WHERE
```sql
SELECT
    title,
    price,
    category
FROM courses c
WHERE price > (
    SELECT AVG(c2.price)
    FROM courses c2
    WHERE c2.category = c.category
)
ORDER BY category, price DESC;
```

**Estructura:**
```
┌─────────────────────────────────────────┐
│ SELECT title, price, category           │ ← Query externa
│ FROM courses c                          │
│ WHERE price > (                         │
│   ┌───────────────────────────────────┐ │
│   │ SELECT AVG(c2.price)              │ │ ← Subquery
│   │ FROM courses c2                   │ │
│   │ WHERE c2.category = c.category    │ │ ← Correlated
│   └───────────────────────────────────┘ │
│ )                                       │
└─────────────────────────────────────────┘
```

**Resultado:**
```
title                    price   category
────────────────────────────────────────────
Advanced Python          95      Programming
Full Stack Developer     150     Programming
Spring Boot Masterclass  120     Programming

(Solo cursos arriba del promedio de su categoría)
```

**Por qué:** Comparar cada registro con un agregado de su grupo.

### 2. Subquery Escalar en SELECT
```sql
SELECT
    title,
    price,
    ROUND(
        (SELECT AVG(price) FROM courses),
    2) AS overall_avg
FROM courses
ORDER BY price DESC;
```

**Resultado:**
```
title                       price   overall_avg
────────────────────────────────────────────────
Full Stack Developer        150     89.53
Machine Learning Essentials 145     89.53
Project Management Pro      140     89.53
```

**Por qué:** Mostrar el promedio global junto a cada registro para comparación visual.

### 3. NOT EXISTS - Encontrar Registros "Huérfanos"
```sql
SELECT
    title AS course_without_enrollments
FROM courses c
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.course_id = c.id
);
```

**Lógica:**
```
Para cada curso:
  IF NO EXISTE inscripción con ese course_id
    THEN mostrar el curso
```

**Resultado:**
```
course_without_enrollments
──────────────────────────
Big Data Fundamentals
```

**Por qué:** Encontrar cursos sin ventas, estudiantes sin inscripciones, etc.

### 4. Tabla Derivada en FROM
```sql
SELECT
    category_stats.category,
    category_stats.total_records
FROM (
    SELECT
        c.category,
        COUNT(e.id) AS total_records
    FROM courses c
    LEFT JOIN enrollments e ON e.course_id = c.id
    GROUP BY c.category
) AS category_stats
WHERE category_stats.total_records > 2
ORDER BY category_stats.total_records DESC;
```

**Estructura:**
```
┌──────────────────────────────────────────────┐
│ SELECT category_stats.category, ...          │ ← Query externa
│ FROM (                                       │
│   ┌────────────────────────────────────────┐ │
│   │ SELECT c.category, COUNT(...) ...      │ │ ← Tabla derivada
│   │ FROM courses c LEFT JOIN enrollments   │ │
│   │ GROUP BY c.category                    │ │
│   └────────────────────────────────────────┘ │
│ ) AS category_stats                          │ ← Alias obligatorio
│ WHERE category_stats.total_records > 2       │
└──────────────────────────────────────────────┘
```

**Resultado:**
```
category            total_records
────────────────────────────────
Data Science        9
Programming         8
Design              6
```

**Por qué:** Usar agregaciones como si fuera una tabla normal.

## 💡 Tipos de Subqueries

| Tipo | Ubicación | Resultado | Uso |
|------|-----------|-----------|-----|
| **Escalar** | WHERE, SELECT | 1 valor | Comparar/mostrar agregado |
| **Lista** | WHERE IN/NOT IN | Múltiples valores | Filtrar por lista |
| **Correlated** | WHERE | Varía por fila | Comparar con cada registro |
| **Tabla derivada** | FROM | Tabla completa | Usarla como tabla |

## 🎯 Ejemplos Prácticos

### Ejemplo 1: Cursos Above Average
```sql
-- Problema: ¿Qué cursos son más caros que el promedio?
SELECT title, price
FROM courses
WHERE price > (SELECT AVG(price) FROM courses)
ORDER BY price DESC;
```

### Ejemplo 2: Cursos Sin Ventas
```sql
-- Problema: ¿Qué cursos nunca han sido vendidos?
SELECT title
FROM courses c
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.course_id = c.id
);
```

### Ejemplo 3: Ranking por Categoría
```sql
-- Problema: ¿Cuáles categorías tienen más inscripciones?
SELECT
    cat_summary.category,
    cat_summary.enrollments
FROM (
    SELECT
        c.category,
        COUNT(e.id) AS enrollments
    FROM courses c
    LEFT JOIN enrollments e ON e.course_id = c.id
    GROUP BY c.category
) cat_summary
ORDER BY cat_summary.enrollments DESC;
```

### Ejemplo 4: Comparar con Global
```sql
-- Problema: ¿Cuál es el precio de cada curso vs el promedio global?
SELECT
    title,
    price,
    price - (SELECT AVG(price) FROM courses) AS diff_from_avg
FROM courses
ORDER BY diff_from_avg DESC;
```

## 📊 Comparación: Sin Subquery vs Con Subquery

```sql
-- ❌ SIN SUBQUERY: Dos queries manuales
-- Query 1: Calcular promedio
SELECT AVG(price) FROM courses;  -- Resultado: 89.53

-- Query 2: Filtrar manualmente
SELECT * FROM courses WHERE price > 89.53;

---

-- ✅ CON SUBQUERY: Una sola query automática
SELECT title, price
FROM courses
WHERE price > (SELECT AVG(price) FROM courses);
```

## 🔑 Subquery Correlada vs No Correlada

```sql
-- NO CORRELADA: se ejecuta 1 sola vez
SELECT title FROM courses
WHERE price > (SELECT AVG(price) FROM courses);
-- El promedio se calcula UNA VEZ

---

-- CORRELADA: se ejecuta N veces (una por cada fila)
SELECT title FROM courses c
WHERE price > (
    SELECT AVG(price) 
    FROM courses c2
    WHERE c2.category = c.category
);
-- El promedio se calcula para CADA categoría
```

## ⚡ Performance Tips

```sql
-- ✅ RÁPIDO: Subquery no correlada
SELECT * FROM courses 
WHERE price > (SELECT AVG(price) FROM courses);

-- ❌ LENTO: Múltiples subqueries correladas
SELECT * FROM courses c WHERE 
  price > (SELECT AVG(price) FROM courses c2 WHERE c2.category = c.category)
  AND duration_hours > (SELECT AVG(duration_hours) FROM courses c3 WHERE c3.category = c.category);

-- ✅ MEJOR: Usar JOIN en lugar de subqueries
SELECT c.* 
FROM courses c
INNER JOIN (
    SELECT category, AVG(price) as avg_price
    FROM courses
    GROUP BY category
) stats ON c.category = stats.category AND c.price > stats.avg_price;
```

## 🎓 Aprendizajes Aplicables

- **Business analytics** - Análisis comparativos
- **Data exploration** - Entender patrones
- **Reporting** - Reportes con múltiples niveles
- **Data quality** - Auditoría (NOT EXISTS)
- **Optimization** - Cuando usar subqueries vs JOINs

## ⚠️ Cuándo Usar Subqueries

| Situación | Usar | Razón |
|-----------|------|-------|
| Comparar con agregado global | ✅ Subquery escalar | Simple y clara |
| Listar registros sin relación | ✅ NOT EXISTS | Más eficiente |
| Filtrar por lista | ✅ IN (subquery) | Dinámica |
| Agregar y luego filtrar | ✅ Tabla derivada | Se necesita alias |
| Relacionar dos tablas | ❌ JOIN mejor | Más eficiente |

## 📝 Resumen: Semana 11

```
Semana 06: Agregación básica (COUNT, SUM, AVG)
Semana 07: Validación de datos (NULL, Constraints)
Semana 09: Relacionar tablas (JOIN)
Semana 10: Datos jerárquicos (SELF JOIN)
Semana 11: Análisis complejo (Subqueries) ← AQUÍ
```

**Conclusión:** Subqueries es la herramienta que une todos los conceptos anteriores.
