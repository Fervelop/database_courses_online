# 📚 Semana 13: CTEs Recursivas

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Crear CTEs (Common Table Expressions) recursivas con `WITH RECURSIVE`
- ✅ Modelar datos jerárquicos (árboles y grafos)
- ✅ Calcular profundidad (depth) en estructuras recursivas
- ✅ Generar rutas completas (paths) con concatenación
- ✅ Detectar hojas de un árbol (nodos sin hijos)
- ✅ Implementar breadcrumbs de navegación

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con **jerarquías de contenido de cursos**:

- **Nivel 1**: Curso (raíz)
- **Nivel 2**: Módulos
- **Nivel 3**: Lecciones
- **Nivel 4**: Sublecciones

Esta estructura es perfecta para demostrar la potencia de las CTEs recursivas.

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio

## 🔍 Conceptos Clave

### WITH RECURSIVE

```sql
WITH RECURSIVE nombre_cte AS (
    -- Caso base (anchor member)
    SELECT ... WHERE condition_base
    
    UNION ALL
    
    -- Caso recursivo (recursive member)
    SELECT ... JOIN nombre_cte ON condition
)
SELECT * FROM nombre_cte;
```

### Estructura del Proyecto

El archivo `proyecto.sql` incluye:

1. **Tabla `course_hierarchy`**: Estructura auto-referencial para modelar cursos, módulos, lecciones y sublecciones
2. **Consulta 1**: Árbol completo con depth y path
3. **Consulta 2**: Filtrado por nivel específico
4. **Consulta 3**: Detección de hojas (nodos sin hijos)
5. **Consulta 4**: Breadcrumbs de navegación

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-13/3-proyecto/starter/proyecto.sql
```

## 📝 Conceptos SQL Principales

| Concepto | Descripción |
|----------|-------------|
| `WITH RECURSIVE` | Define una CTE recursiva |
| `UNION ALL` | Combina el caso base con el recursivo |
| `ARRAY[id]` | Crea un array con IDs para detectar ciclos |
| `REPEAT()` | Genera indentación visual (espacios) |
| `NOT EXISTS` | Detecta nodos sin hijos |

## 💡 Casos de Uso Reales

1. **Navegación jerárquica**: Generar menús con subcategorías
2. **Breadcrumbs**: Mostrar ruta completa desde la raíz
3. **Búsqueda en profundidad**: Obtener todos los descendientes
4. **Análisis de niveles**: Reportes por nivel de profundidad
5. **Árbol orgánico**: Estructuras sin profundidad fija

## 🎓 Próxima Semana

**Semana 14**: Window Functions - Ranking (ROW_NUMBER, RANK, DENSE_RANK)
