# Semana 12: CTEs y CASE WHEN

## 📚 ¿Qué se vio esta semana?

En la **Semana 12** estudiamos **Common Table Expressions (CTEs)** con la cláusula `WITH` y el operador condicional **`CASE WHEN`**. Estos son herramientas fundamentales para escribir consultas legibles, reutilizables y altamente expresivas en SQL.

Los temas cubiertos fueron:

- **CTEs simples** - Crear tablas temporales con `WITH`
- **CTEs encadenados** - Referenciar un CTE dentro de otro
- **CASE WHEN** - Expresiones condicionales en SELECT, GROUP BY y agregaciones
- **Combinación CTE + CASE WHEN** - Crear reportes analíticos complejos
- **COUNT condicional** - `COUNT(CASE WHEN ...)` para agregaciones discriminadas

## 🎯 ¿Por qué se enseña de esta manera?

### Contexto: Plataforma de Cursos Online

Continuamos con la **base de datos de una plataforma de cursos online** porque:

```
Tablas principales:
├── categories (5 categorías)
├── courses (12 cursos)
├── students (20 estudiantes)
├── enrollments (50+ inscripciones)
├── course_reviews (30 reseñas)
└── lessons (20 lecciones)
```

### Razón pedagógica

Los CTEs y CASE WHEN permiten responder preguntas de negocio complejas:

1. **CTEs simples** - *¿Cuáles son los cursos con actividad significativa?*
2. **CASE WHEN** - *¿En qué banda de precio se encuentran y cuál es su popularidad?*
3. **CTEs encadenados** - *¿Cuáles categorías tienen inscritos por encima del promedio?*
4. **COUNT condicional** - *¿Cuántos cursos hay en cada banda de precio, por categoría?*
5. **Combinación avanzada** - *¿Cuál es el perfil de rendimiento de cada categoría?*

## 📊 Ejemplos de Queries

### Reporte 1: Clasificación con CTE simple + CASE WHEN

```sql
WITH cursos_con_actividad AS (
    SELECT
        c.id,
        c.title,
        c.price,
        ca.name AS categoria,
        COUNT(e.id) AS total_inscritos,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio
    FROM courses c
    LEFT JOIN categories ca ON c.category_id = ca.id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY c.id, c.title, c.price, c.category_id, ca.name
)
SELECT
    title AS curso,
    categoria,
    price AS precio,
    total_inscritos,
    CASE
        WHEN price >= 150 THEN 'Premium'
        WHEN price >= 100 THEN 'Estándar'
        ELSE 'Económico'
    END AS banda_precio
FROM cursos_con_actividad
ORDER BY price DESC;
```

**Por qué:** Separa la lógica de pre-procesamiento (CTE) de la lógica de clasificación (CASE WHEN), haciendo el código más mantenible.

### Reporte 2: CTEs Encadenados

```sql
WITH inscritos_por_categoria AS (
    SELECT
        ca.name,
        COUNT(DISTINCT e.student_id) AS total_inscritos
    FROM categories ca
    LEFT JOIN courses c ON ca.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY ca.id, ca.name
),
categorias_top AS (
    SELECT name, total_inscritos
    FROM inscritos_por_categoria
    WHERE total_inscritos > (SELECT AVG(total_inscritos) FROM inscritos_por_categoria)
)
SELECT * FROM categorias_top
ORDER BY total_inscritos DESC;
```

**Por qué:** El segundo CTE filtra sobre las métricas del primero, permitiendo análisis de dos niveles.

### Reporte 3: COUNT Condicional en CTE

```sql
WITH clasificados AS (
    SELECT
        ca.name AS categoria,
        c.price,
        CASE
            WHEN c.price >= 150 THEN 'Premium'
            WHEN c.price >= 100 THEN 'Estándar'
            ELSE 'Económico'
        END AS banda_precio
    FROM courses c
    INNER JOIN categories ca ON c.category_id = ca.id
)
SELECT
    categoria,
    COUNT(CASE WHEN banda_precio = 'Premium' THEN 1 END) AS premium_count,
    COUNT(CASE WHEN banda_precio = 'Estándar' THEN 1 END) AS estandar_count,
    COUNT(CASE WHEN banda_precio = 'Económico' THEN 1 END) AS economico_count
FROM clasificados
GROUP BY categoria
ORDER BY categoria;
```

**Por qué:** La agregación condicional transforma datos categóricos en pivots sin necesidad de `PIVOT`.

## 🔑 Conceptos Clave

| Concepto | Uso | Ejemplo |
|----------|-----|---------|
| **WITH** | Definir un CTE reutilizable | `WITH nombre_cte AS (SELECT ...)` |
| **CTE encadenado** | Referenciar un CTE en otro | `WITH cte1 AS (...), cte2 AS (SELECT ... FROM cte1)` |
| **CASE WHEN** | Lógica condicional en SELECT | `CASE WHEN condición THEN valor ELSE otro END` |
| **COUNT(CASE)** | Contar filas que cumplen una condición | `COUNT(CASE WHEN banda = 'Premium' THEN 1 END)` |
| **NULLIF** | Retornar NULL si dos valores son iguales | `NULLIF(denominador, 0)` |

## 💡 Ventajas de CTEs sobre Subqueries

| Aspecto | Subquery | CTE |
|--------|----------|-----|
| **Legibilidad** | Anidado, difícil de seguir | Secuencial, fácil de leer |
| **Reutilización** | Se repite código | Se define una sola vez |
| **Debugging** | Difícil de aislar lógica | Se testea cada CTE por separado |
| **Desempeño** | Similar en muchos motores | Potencialmente mejor (materialización) |

## 🎓 Aprendizajes Aplicables

Estos conceptos son fundamentales para:

- **Reportes ejecutivos** - Clasificaciones, métricas y KPIs
- **Dashboards** - Agregaciones condicionales y segmentaciones
- **ETL/ELT** - Transformación de datos en pipelines
- **Análisis exploratorio** - Aislamiento y testeo de lógica compleja
- **Mantenibilidad** - Código autodocumentado y modular

## 📚 Estructura de esta semana

```
semana-12/
├── README.md          # Este archivo
└── query.sql          # Ejemplos y proyectos de Semana 12
```

## 🚀 Próximos Pasos

En las semanas siguientes profundizaremos en:

- **Semana 13** - CTEs Recursivas (para jerarquías y series)
- **Semana 14** - Window Functions (Ranking, ROW_NUMBER, LAG/LEAD)
- **Semana 15** - Optimización de queries con índices y EXPLAIN/ANALYZE
