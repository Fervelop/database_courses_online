# 📚 Semana 18: Funciones y Procedimientos PL/pgSQL

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana serás capaz de:

- ✅ Crear funciones escalares con `CREATE FUNCTION`
- ✅ Implementar funciones que retornan tablas `RETURNS TABLE`
- ✅ Crear procedimientos con `CREATE PROCEDURE`
- ✅ Usar `DECLARE` para variables locales
- ✅ Implementar lógica condicional con `IF/ELSIF/ELSE`
- ✅ Manejar excepciones con `EXCEPTION`
- ✅ Usar bloques `DO` para pruebas

## 📊 Dominio: Plataforma de Cursos Online

En esta semana trabajaremos con:

- **Funciones**: Calcular bonificación, categorizar estudiantes
- **Procedimientos**: Inscribir estudiante, procesar pago
- **Auditoría**: Registrar todas las operaciones

## 📁 Contenidos de la Carpeta

- **README.md**: Este archivo
- **3-proyecto/starter/proyecto.sql**: Proyecto semanal adaptado al dominio

## 🔍 Conceptos Clave

### CREATE FUNCTION - Función Escalar

```sql
CREATE OR REPLACE FUNCTION fn_discount(price NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    IF price > 100 THEN
        RETURN price * 0.9;  -- 10% descuento
    ELSE
        RETURN price;
    END IF;
END;
$$;

SELECT fn_discount(150.00);  -- 135.00
```

### CREATE FUNCTION - RETURNS TABLE

```sql
CREATE OR REPLACE FUNCTION fn_get_courses(p_difficulty TEXT)
RETURNS TABLE(id INT, name TEXT, price NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT c.id, c.name, c.price
        FROM courses c
        WHERE c.difficulty = p_difficulty;
END;
$$;

SELECT * FROM fn_get_courses('advanced');
```

### CREATE PROCEDURE

```sql
CREATE OR REPLACE PROCEDURE sp_enroll(
    p_student_id INT,
    p_course_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id);
    COMMIT;
EXCEPTION
    WHEN UNIQUE_VIOLATION THEN
        RAISE EXCEPTION 'El estudiante ya está inscrito';
END;
$$;

CALL sp_enroll(1, 2);
```

## 🚀 Cómo Ejecutar

```bash
# Ejecutar el proyecto semanal
psql -U usuario -d database_courses_online -f semana-18/3-proyecto/starter/proyecto.sql
```

## 💡 Casos de Uso Reales

1. **Funciones**: Cálculos reutilizables (descuentos, bonificaciones)
2. **Procedimientos**: Operaciones complejas (inscripción, pago)
3. **Auditoría**: Registrar automáticamente cambios
4. **Validación**: Verificar reglas de negocio

## 🎓 Semana Finalizada

¡Felicidades! Has completado el curso completo de SQL Avanzado con Dominio en Plataforma de Cursos Online.

**Temas cubiertos:**
- ✅ Semanas 13-15: Advanced SQL (CTEs, Window Functions)
- ✅ Semanas 16-18: Optimization & Automation (Índices, Transacciones, PL/pgSQL)

**Próximos pasos:**
- Aplica estos conceptos en proyectos reales
- Explora triggers, vistas materializadas y extensiones
- Estudia performance tuning avanzado
