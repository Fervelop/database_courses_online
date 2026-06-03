# Semana 06: Funciones de Agregación

## 📚 ¿Qué se vio esta semana?

En la **Semana 06** estudiamos las **funciones de agregación** en SQL, que son herramientas fundamentales para analizar y resumir datos. Los temas cubiertos fueron:

- **COUNT()** - Contar registros
- **SUM()** - Sumar valores numéricos
- **AVG()** - Calcular promedio
- **MIN() y MAX()** - Encontrar valores extremos
- **GROUP BY** - Agrupar datos por categorías
- **HAVING** - Filtrar grupos

## 🎯 ¿Por qué se enseña de esta manera?

### Contexto: Plataforma de Cursos Online

Usamos una base de datos de una **plataforma de cursos online** porque permite entender conceptos de agregación de forma práctica:

```
Tablas principales:
├── categories (5 categorías)
├── courses (30 cursos)
├── students (30 estudiantes)
├── enrollments (29 inscripciones)
└── lessons (20 lecciones)
```

### Razón pedagógica

1. **COUNT()** - Responde: *¿Cuántos cursos tenemos en total?*
2. **SUM()** - Responde: *¿Cuál es el ingreso total de todos los cursos?*
3. **AVG()** - Responde: *¿Cuál es el precio promedio de los cursos?*
4. **MIN/MAX** - Responde: *¿Cuál es el curso más caro y más barato?*
5. **GROUP BY** - Responde: *¿Cuántos cursos hay por cada nivel de dificultad?*
6. **HAVING** - Responde: *¿Cuáles niveles de dificultad tienen más de X cursos?*

## 📊 Ejemplos de Queries

### Reporte 1: Totales Globales
```sql
SELECT
    COUNT(*)     AS total_cursos,
    SUM(price)   AS suma_precios,
    AVG(price)   AS promedio_precio
FROM courses;
```
**Por qué:** Obtiene un resumen ejecutivo de la plataforma en una sola consulta.

### Reporte 2: Extremos
```sql
SELECT
    MIN(price) AS precio_minimo,
    MAX(price) AS precio_maximo
FROM courses;
```
**Por qué:** Identifica rangos de precios para análisis de estrategia de pricing.

### Reporte 3: Subtotales por Categoría
```sql
SELECT
    level,
    COUNT(*) AS total,
    AVG(price) AS promedio
FROM courses
GROUP BY level
ORDER BY total DESC;
```
**Por qué:** Permite ver cómo se distribuyen los cursos por nivel (Beginner, Intermediate, Advanced) y su precio promedio. Útil para decisiones de negocio.

### Reporte 4: Filtro de Grupos
```sql
SELECT
    level,
    COUNT(*) AS total
FROM courses
GROUP BY level
HAVING COUNT(*) > umbral;
```
**Por qué:** Solo muestra grupos que cumplen un criterio específico (por ejemplo, niveles con más de 5 cursos).

## 🔑 Conceptos Clave

| Concepto | Uso | Ejemplo |
|----------|-----|---------|
| **COUNT(\*)** | Contar todas las filas | `COUNT(*) AS total_registros` |
| **SUM(columna)** | Sumar valores | `SUM(price) AS ingreso_total` |
| **AVG(columna)** | Promedio aritmético | `AVG(price) AS precio_medio` |
| **GROUP BY** | Agrupar resultados | `GROUP BY level` |
| **HAVING** | Filtrar grupos | `HAVING COUNT(*) > 5` |

## 💡 Diferencia: WHERE vs HAVING

- **WHERE:** Filtra filas **antes** de agrupar (se aplica a datos individuales)
- **HAVING:** Filtra grupos **después** de agrupar (se aplica a resultados agregados)

```sql
-- WHERE: filtro antes del GROUP BY
WHERE price > 50

-- HAVING: filtro después del GROUP BY
HAVING COUNT(*) > 5
```

## 🎓 Aprendizajes Aplicables

Estos conceptos son fundamentales para:
- **Dashboards gerenciales** - Reportes de KPIs
- **Análisis de datos** - Estadísticas y tendencias
- **Optimización de negocio** - Identificar oportunidades
- **Reporting** - Generar insights automáticos
