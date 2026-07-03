# 📚 Semana 14: Window Functions - Ranking

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Usar `ROW_NUMBER()` para eliminar duplicados
- ✅ Implementar `RANK()` y `DENSE_RANK()` para clasificaciones
- ✅ Particionar datos con `PARTITION BY`
- ✅ Ordenar resultados con `ORDER BY` dentro de window functions
- ✅ Combinar window functions con CTEs
- ✅ Obtener Top-N por grupo (top-2, top-3, etc.)

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con:

- **Cursos**: Nombres, calificaciones y ranking
- **Estudiantes**: Enrollments y calificaciones por curso
- **Rankings**: Posición del estudiante dentro de cada curso

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio

## 🔍 Conceptos Clave

### Window Functions de Ranking

| Función | Comportamiento | Caso de Uso |
|---------|---|---|
| `ROW_NUMBER()` | 1, 2, 3... (sin empates) | Deduplicación |
| `RANK()` | 1, 1, 3... (salta números en empates) | Competencias |
| `DENSE_RANK()` | 1, 1, 2... (sin saltos) | Niveles de logro |

### Sintaxis

```sql
WINDOW_FUNCTION() OVER (
    PARTITION BY column1
    ORDER BY column2 DESC
)
```

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-14/3-proyecto/starter/proyecto.sql
```

## 💡 Casos de Uso Reales

1. **Ranking de estudiantes**: Por calificación en cada curso
2. **Deduplicación**: Mantener un registro por estudiante
3. **Medallas**: Gold (top 3), Silver (top 10), Bronze (top 20)
4. **Análisis de desempeño**: Comparar posición del estudiante

## 🎓 Próxima Semana

**Semana 15**: Window Functions - Navegación y Vistas (LEAD, LAG, CREATE VIEW)
