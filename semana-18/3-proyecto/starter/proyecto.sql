-- ============================================
-- PROYECTO SEMANAL: Funciones y Procedimientos
-- Semana 18 — PL/pgSQL
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos funciones
-- y procedimientos para encapsular lógica de negocio compleja.
-- Aprenderemos a:
-- 1. Crear funciones escalares para cálculos
-- 2. Crear funciones que retornan tablas
-- 3. Crear procedimientos para operaciones con transacciones
-- 4. Manejar excepciones y auditoría

-- ============================================
-- Tablas del dominio
-- ============================================

DROP FUNCTION IF EXISTS fn_classify_student(NUMERIC);
DROP FUNCTION IF EXISTS fn_get_active_courses(INT);
DROP FUNCTION IF EXISTS fn_calculate_discount(NUMERIC, TEXT);
DROP PROCEDURE IF EXISTS sp_enroll_student(INT, INT);
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    id              SERIAL PRIMARY KEY,
    name            TEXT   NOT NULL,
    price           NUMERIC(12, 2) NOT NULL,
    capacity        INT    NOT NULL CHECK (capacity > 0),
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE students (
    id              SERIAL PRIMARY KEY,
    name            TEXT   NOT NULL,
    email           TEXT   UNIQUE NOT NULL,
    account_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_courses   INT    DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE enrollments (
    id              SERIAL PRIMARY KEY,
    student_id      INT REFERENCES students (id),
    course_id       INT REFERENCES courses (id),
    enrollment_date TIMESTAMP DEFAULT NOW(),
    status          TEXT DEFAULT 'active',
    UNIQUE(student_id, course_id)
);

CREATE TABLE audit_log (
    id              SERIAL PRIMARY KEY,
    action          TEXT   NOT NULL,
    detail          TEXT,
    affected_table  TEXT,
    student_id      INT,
    course_id       INT,
    executed_at     TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- Insertar datos representativos
-- ============================================

INSERT INTO courses (name, price, capacity) VALUES
    ('SQL Avanzado', 99.99, 30),
    ('Bases de Datos', 79.99, 25),
    ('Optimización', 129.99, 15),
    ('PL/pgSQL', 109.99, 20),
    ('Data Analytics', 89.99, 35);

INSERT INTO students (name, email, account_balance, total_courses) VALUES
    ('Ana García', 'ana@example.com', 500.00, 2),
    ('Bruno López', 'bruno@example.com', 300.00, 1),
    ('Carlos Ruiz', 'carlos@example.com', 150.00, 0),
    ('Diana Martín', 'diana@example.com', 1000.00, 3),
    ('Eva Sánchez', 'eva@example.com', 750.00, 2);

INSERT INTO enrollments (student_id, course_id) VALUES
    (1, 1), (1, 2),
    (2, 1),
    (4, 1), (4, 2), (4, 3),
    (5, 2), (5, 5);


-- ============================================
-- REQUISITO 1: Función escalar
-- ============================================
-- Función que clasifique estudiantes por número de cursos realizados
-- Debe usar IF/ELSIF/ELSE

CREATE OR REPLACE FUNCTION fn_classify_student(p_total_courses NUMERIC)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_total_courses >= 5 THEN
        RETURN 'Expert';
    ELSIF p_total_courses >= 3 THEN
        RETURN 'Advanced';
    ELSIF p_total_courses >= 1 THEN
        RETURN 'Beginner';
    ELSE
        RETURN 'No courses';
    END IF;
END;
$$;

-- Usar la función para todos los estudiantes
SELECT
    s.name,
    s.total_courses,
    fn_classify_student(s.total_courses) AS classification
FROM students s
ORDER BY s.total_courses DESC;


-- ============================================
-- REQUISITO 2: Función RETURNS TABLE
-- ============================================
-- Función que retorne los cursos activos de un estudiante
-- Debe aceptar student_id como parámetro y usar RETURN QUERY

CREATE OR REPLACE FUNCTION fn_get_student_courses(p_student_id INT)
RETURNS TABLE(
    course_id INT,
    course_name TEXT,
    price NUMERIC,
    enrollment_date TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            c.id,
            c.name,
            c.price,
            e.enrollment_date
        FROM enrollments e
        JOIN courses c ON e.course_id = c.id
        WHERE e.student_id = p_student_id
        AND e.status = 'active'
        ORDER BY e.enrollment_date DESC;
END;
$$;

-- Usar la función para ver cursos del estudiante 1
SELECT * FROM fn_get_student_courses(1);

-- Función adicional: Calcular descuento según tipo de estudiante
CREATE OR REPLACE FUNCTION fn_calculate_discount(
    p_price NUMERIC,
    p_student_type TEXT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    CASE p_student_type
        WHEN 'Expert' THEN
            RETURN ROUND(p_price * 0.85, 2);  -- 15% descuento
        WHEN 'Advanced' THEN
            RETURN ROUND(p_price * 0.90, 2);  -- 10% descuento
        WHEN 'Beginner' THEN
            RETURN ROUND(p_price * 0.95, 2);  -- 5% descuento
        ELSE
            RETURN p_price;
    END CASE;
END;
$$;

-- Mostrar precios con descuento según clasificación
SELECT
    s.name,
    fn_classify_student(s.total_courses) AS classification,
    c.price AS original_price,
    fn_calculate_discount(c.price, fn_classify_student(s.total_courses)) AS discounted_price
FROM students s
CROSS JOIN courses c
WHERE c.is_active = TRUE
LIMIT 5;


-- ============================================
-- REQUISITO 3 y 4: Procedimiento con COMMIT y EXCEPTION
-- ============================================
-- Procedimiento que encapsule la inscripción de un estudiante
-- Debe: verificar condiciones → lanzar excepciones si falla →
--       registrar en audit_log → COMMIT si OK

CREATE OR REPLACE PROCEDURE sp_enroll_student(
    p_student_id INT,
    p_course_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_student_name TEXT;
    v_course_name TEXT;
    v_student_balance NUMERIC;
    v_course_price NUMERIC;
    v_capacity INT;
    v_enrolled_count INT;
BEGIN
    -- Leer el estado actual
    SELECT name, account_balance INTO v_student_name, v_student_balance
    FROM students
    WHERE id = p_student_id;
    
    SELECT name, price, capacity INTO v_course_name, v_course_price, v_capacity
    FROM courses
    WHERE id = p_course_id;
    
    -- Contar inscritos actuales
    SELECT COUNT(*) INTO v_enrolled_count
    FROM enrollments
    WHERE course_id = p_course_id AND status = 'active';
    
    -- Validación 1: ¿Existe el estudiante?
    IF v_student_name IS NULL THEN
        RAISE EXCEPTION 'El estudiante con ID % no existe', p_student_id;
    END IF;
    
    -- Validación 2: ¿Existe el curso?
    IF v_course_name IS NULL THEN
        RAISE EXCEPTION 'El curso con ID % no existe', p_course_id;
    END IF;
    
    -- Validación 3: ¿Tiene balance suficiente?
    IF v_student_balance < v_course_price THEN
        RAISE EXCEPTION 'Balance insuficiente. Necesita %.2f, tiene %.2f', 
            v_course_price, v_student_balance;
    END IF;
    
    -- Validación 4: ¿Hay lugares disponibles?
    IF v_enrolled_count >= v_capacity THEN
        RAISE EXCEPTION 'El curso % no tiene lugares disponibles', v_course_name;
    END IF;
    
    -- Operaciones principales
    INSERT INTO enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id);
    
    UPDATE students
    SET account_balance = account_balance - v_course_price,
        total_courses = total_courses + 1
    WHERE id = p_student_id;
    
    -- Registrar en audit log
    INSERT INTO audit_log (action, detail, affected_table, student_id, course_id)
    VALUES (
        'ENROLLMENT',
        CONCAT(v_student_name, ' inscrito en ', v_course_name),
        'enrollments',
        p_student_id,
        p_course_id
    );
    
    COMMIT;
    
EXCEPTION
    WHEN UNIQUE_VIOLATION THEN
        ROLLBACK;
        RAISE EXCEPTION 'El estudiante ya está inscrito en este curso';
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Error en inscripción: %', SQLERRM;
END;
$$;


-- ============================================
-- REQUISITO 5: Bloque DO con múltiples pruebas
-- ============================================
-- Bloque DO que llame al procedimiento en 3 escenarios:
-- 2 exitosos y 1 que genere excepción

DO $$
BEGIN
    RAISE NOTICE '=== PRUEBA 1: Inscripción Exitosa ===';
    CALL sp_enroll_student(3, 1);  -- Carlos a SQL Avanzado
    RAISE NOTICE 'Inscripción exitosa para Carlos';
    
    RAISE NOTICE '=== PRUEBA 2: Inscripción Exitosa ===';
    CALL sp_enroll_student(3, 2);  -- Carlos a Bases de Datos
    RAISE NOTICE 'Inscripción exitosa para Carlos en segundo curso';
    
    RAISE NOTICE '=== PRUEBA 3: Inscripción Fallida (Balance insuficiente) ===';
    BEGIN
        CALL sp_enroll_student(2, 4);  -- Bruno a PL/pgSQL (balance insuficiente)
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Capturada excepción esperada: %', SQLERRM;
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en bloque DO: %', SQLERRM;
END;
$$;


-- ============================================
-- Verificación final del estado completo
-- ============================================

SELECT '=== ESTADO DE ESTUDIANTES DESPUÉS DE TRANSACCIONES ===' AS section;

SELECT
    s.id,
    s.name,
    s.account_balance,
    s.total_courses,
    fn_classify_student(s.total_courses) AS classification
FROM students s
ORDER BY s.id;

SELECT '=== INSCRIPCIONES ACTIVAS ===' AS section;

SELECT
    s.name AS student_name,
    c.name AS course_name,
    c.price,
    e.enrollment_date
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
WHERE e.status = 'active'
ORDER BY s.name;

SELECT '=== LOG DE AUDITORÍA ===' AS section;

SELECT
    id,
    action,
    detail,
    executed_at
FROM audit_log
ORDER BY id DESC
LIMIT 10;

SELECT '=== RESUMEN DE CAPACIDAD POR CURSO ===' AS section;

SELECT
    c.name,
    c.capacity,
    COUNT(e.id) AS enrolled,
    c.capacity - COUNT(e.id) AS available
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id AND e.status = 'active'
GROUP BY c.id, c.name, c.capacity
ORDER BY c.name;
