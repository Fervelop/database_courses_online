# 📚 Semana 17: Transacciones y ACID

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Entender principios ACID (Atomicity, Consistency, Isolation, Durability)
- ✅ Usar `BEGIN` y `COMMIT` para transacciones exitosas
- ✅ Implementar `ROLLBACK` para revertir cambios
- ✅ Crear `SAVEPOINT` para reversiones parciales
- ✅ Manejar excepciones en transacciones
- ✅ Asegurar integridad referencial

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con:

- **Estudiantes**: Registro y balance de créditos
- **Cursos**: Disponibilidad de lugares
- **Transacciones**: Inscripción de estudiante a curso

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio

## 🔍 Conceptos Clave

### ACID Properties

| Propiedad | Descripción | Ejemplo |
|-----------|---|---|
| **Atomicity** | Todo o nada | Inscripción: actualiza estudiante Y curso |
| **Consistency** | Integridad de datos | Estudiantes activos >= 0 |
| **Isolation** | No interferencia entre transacciones | 2 inscripciones simultáneas |
| **Durability** | Permanencia en almacenamiento | Commit confirmado en disco |

### Estructura Básica

```sql
BEGIN;
    -- Operaciones
    UPDATE ...
    INSERT ...
COMMIT;  -- O ROLLBACK para revertir
```

### SAVEPOINT

```sql
BEGIN;
    -- Operación 1 (se guardará)
    UPDATE ...
    SAVEPOINT sp1;
    -- Operación 2 (será revertida)
    UPDATE ...
    ROLLBACK TO SAVEPOINT sp1;
COMMIT;
```

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-17/3-proyecto/starter/proyecto.sql
```

## 💡 Casos de Uso Reales

1. **Inscripción**: Garantizar que se reservan lugares
2. **Pago**: Confirmar dinero y acceso simultáneamente
3. **Cancelación**: Reversión parcial de cambios
4. **Auditoria**: Registro de todas las operaciones

## 🎓 Próxima Semana

**Semana 18**: Funciones y Procedimientos PL/pgSQL (CREATE FUNCTION, CREATE PROCEDURE)
