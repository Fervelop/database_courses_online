# 📚 Semana 15: Window Functions - Navegación y Vistas

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Usar `LAG()` para obtener el valor de la fila anterior
- ✅ Usar `LEAD()` para obtener el valor de la fila siguiente
- ✅ Implementar `FIRST_VALUE()` y `LAST_VALUE()` en frames
- ✅ Crear vistas con `CREATE VIEW` para encapsular análisis
- ✅ Consultar vistas y filtrar resultados
- ✅ Calcular variaciones y deltas entre períodos

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con:

- **Inscripciones por mes**: Tendencia de estudiantes nuevos
- **Ingresos por mes**: Variación de ingresos mensuales
- **Análisis de crecimiento**: Delta y porcentaje de cambio

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio

## 🔍 Conceptos Clave

### Window Functions de Navegación

| Función | Descripción |
|---------|---|
| `LAG(col, 1)` | Valor de 1 fila anterior |
| `LEAD(col, 1)` | Valor de 1 fila siguiente |
| `FIRST_VALUE(col)` | Primer valor en la ventana |
| `LAST_VALUE(col)` | Último valor en la ventana (requiere frame especial) |

### CREATE VIEW

```sql
CREATE OR REPLACE VIEW v_nombre AS
SELECT ... FROM tabla WHERE ...;
```

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-15/3-proyecto/starter/proyecto.sql
```

## 💡 Casos de Uso Reales

1. **Análisis de tendencias**: Comparar mes actual vs anterior
2. **Detección de anomalías**: Cambios drásticos en métricas
3. **Reportes encapsulados**: Vistas para usuarios finales
4. **Cálculo de deltas**: Variación porcentual de ingresos

## 🎓 Próxima Semana

**Semana 16**: Índices y Funciones Integradas (EXPLAIN, CREATE INDEX, TO_CHAR, AGE)
