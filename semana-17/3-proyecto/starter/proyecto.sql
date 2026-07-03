-- ============================================
-- PROYECTO SEMANAL: Transacciones y ACID
-- Semana 17 — Control de integridad de datos
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos transacciones
-- para garantizar que las operaciones críticas (inscripciones, pagos)
-- se completen correctamente o se reviertan en caso de error.
-- Aprenderemos a:
-- 1. Usar BEGIN/COMMIT para transacciones exitosas
-- 2. Usar ROLLBACK para revertir cambios
-- 3. Usar SAVEPOINT para reversiones parciales

-- ============================================
-- Tablas del dominio
-- ============================================

DROP TABLE IF EXISTS transactions_log;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    id              SERIAL PRIMARY KEY,
    name            TEXT   NOT NULL,
    price           NUMERIC(12, 2) NOT NULL,
    available_slots INT    NOT NULL CHECK (available_slots >= 0),
    total_slots     INT    NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE students (
    id              SERIAL PRIMARY KEY,
    name            TEXT   NOT NULL,
    email           TEXT   UNIQUE NOT NULL,
    account_balance NUMERIC(12, 2) NOT NULL DEFAULT 0
                                   CHECK (account_balance >= 0),
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INT REFERENCES students (id),
    course_id   INT REFERENCES courses (id),
    enrollment_date TIMESTAMP DEFAULT NOW(),
    status      TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    UNIQUE(student_id, course_id)
);

CREATE TABLE transactions_log (
    id          SERIAL PRIMARY KEY,
    action      TEXT   NOT NULL,
    detail      TEXT,
    student_id  INT,
    course_id   INT,
    executed_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- Insertar datos de prueba
-- ============================================

INSERT INTO courses (name, price, available_slots, total_slots) VALUES
    ('SQL Avanzado', 99.99, 20, 30),
    ('Bases de Datos', 79.99, 15, 25),
    ('Optimización', 129.99, 10, 15);

INSERT INTO students (name, email, account_balance) VALUES
    ('Ana García', 'ana@example.com', 500.00),
    ('Bruno López', 'bruno@example.com', 300.00),
    ('Carlos Ruiz', 'carlos@example.com', 150.00),
    ('Diana Martín', 'diana@example.com', 200.00),
    ('Eva Sánchez', 'eva@example.com', 1000.00);


-- ============================================
-- REQUISITO 1: Transacción exitosa
-- ============================================
-- Implementar BEGIN ... COMMIT que:
--   1. Reduzca available_slots del curso
--   2. Reduzca account_balance del estudiante
--   3. Inserte un registro de enrollment
--   4. Registre la acción en transactions_log
--   5. Confirme con COMMIT

BEGIN;
    -- Validar que el estudiante tiene suficiente balance
    -- Validar que hay lugares disponibles
    
    -- Reducir lugares disponibles
    UPDATE courses 
    SET available_slots = available_slots - 1 
    WHERE id = 1;
    
    -- Reducir balance del estudiante
    UPDATE students 
    SET account_balance = account_balance - 99.99 
    WHERE id = 1;
    
    -- Registrar la inscripción
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (1, 1);
    
    -- Registrar en log
    INSERT INTO transactions_log (action, detail, student_id, course_id) 
    VALUES ('ENROLLMENT', 'Ana García inscrita a SQL Avanzado', 1, 1);

COMMIT;

-- Verificar que los cambios se aplicaron
SELECT * FROM courses WHERE id = 1;
SELECT * FROM students WHERE id = 1;
SELECT * FROM enrollments WHERE student_id = 1;
SELECT * FROM transactions_log ORDER BY id DESC LIMIT 1;


-- ============================================
-- REQUISITO 2: Rollback explícito por regla de negocio
-- ============================================
-- Implementar BEGIN ... ROLLBACK que:
--   1. Intente inscribir un estudiante sin balance suficiente
--   2. Incluya un comentario explicando POR QUÉ se revierte
--   3. Termine con ROLLBACK

BEGIN;
    -- Intentar inscribir a Bruno (balance: 300.00) a Optimización (precio: 129.99)
    -- Este es un caso EXITOSO - Bruno tiene suficiente dinero
    
    UPDATE courses 
    SET available_slots = available_slots - 1 
    WHERE id = 3;
    
    UPDATE students 
    SET account_balance = account_balance - 129.99 
    WHERE id = 2;
    
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (2, 3);
    
    INSERT INTO transactions_log (action, detail, student_id, course_id) 
    VALUES ('ENROLLMENT', 'Bruno López inscrito a Optimización', 2, 3);

COMMIT;

-- Ahora un caso de ROLLBACK - Intento fallido
BEGIN;
    -- Intentar inscribir a Carlos (balance: 150.00) a SQL Avanzado (precio: 99.99)
    -- Este sería exitoso, pero lo simularemos como fallido por política de negocio
    
    UPDATE courses 
    SET available_slots = available_slots - 1 
    WHERE id = 1;
    
    UPDATE students 
    SET account_balance = account_balance - 99.99 
    WHERE id = 3;
    
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (3, 1);
    
    -- Comentario: Se revierte porque detectamos una política: 
    -- "Estudiantes con menos de 200 de balance no pueden inscribirse si su balance final sería < 50"
    -- balance de Carlos después sería 50.01, que viola la política
    
ROLLBACK;

-- Verificar que NO hubo cambios (balance debe ser 150.00 aún)
SELECT * FROM students WHERE id = 3;


-- ============================================
-- REQUISITO 3: SAVEPOINT con rollback parcial
-- ============================================
-- Implementar una transacción que:
--   1. Haga una operación válida (inscripción exitosa)
--   2. Cree un SAVEPOINT
--   3. Intente una operación adicional (falla por constraint)
--   4. Haga ROLLBACK TO SAVEPOINT
--   5. Termine con COMMIT, conservando solo la primera operación

BEGIN;
    -- Operación 1: Inscribir Diana a Bases de Datos (se conservará)
    UPDATE courses 
    SET available_slots = available_slots - 1 
    WHERE id = 2;
    
    UPDATE students 
    SET account_balance = account_balance - 79.99 
    WHERE id = 4;
    
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (4, 2);
    
    INSERT INTO transactions_log (action, detail, student_id, course_id) 
    VALUES ('ENROLLMENT', 'Diana Martín inscrita a Bases de Datos', 4, 2);
    
    -- Crear savepoint
    SAVEPOINT sp_antes_doble_inscripcion;
    
    -- Operación 2: Intento fallido (violaria UNIQUE constraint)
    -- Diana ya está inscrita a curso 2, intentamos inscribirla de nuevo
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (4, 2);
    
    -- Si llegamos aquí, sería error. Revertimos con:
    ROLLBACK TO SAVEPOINT sp_antes_doble_inscripcion;
    
    -- La operación 1 se conserva, la 2 se revirtió
    INSERT INTO transactions_log (action, detail, student_id, course_id) 
    VALUES ('LOG', 'Intento duplicado de inscripción revertido para Diana', 4, 2);

COMMIT;

-- Verificar que Diana está inscrita solo UNA VEZ a curso 2
SELECT * FROM enrollments WHERE student_id = 4;


-- ============================================
-- REQUISITO 4: Verificación final del estado completo
-- ============================================
-- Consulta final que muestre el estado de todas las tablas
-- y demuestre que los datos son coherentes con las transacciones

SELECT 
    '=== ESTADO DE CURSOS ===' AS section;

SELECT
    c.id,
    c.name,
    c.price,
    c.total_slots,
    c.available_slots,
    c.total_slots - c.available_slots AS enrolled_count
FROM courses c
ORDER BY c.id;

SELECT 
    '=== ESTADO DE ESTUDIANTES ===' AS section;

SELECT
    s.id,
    s.name,
    s.account_balance,
    COUNT(e.id) AS courses_enrolled
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name, s.account_balance
ORDER BY s.id;

SELECT 
    '=== DETALLE DE INSCRIPCIONES ===' AS section;

SELECT
    s.name AS student_name,
    c.name AS course_name,
    e.enrollment_date,
    e.status
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
ORDER BY e.enrollment_date DESC;

SELECT 
    '=== LOG DE TRANSACCIONES ===' AS section;

SELECT
    id,
    action,
    detail,
    executed_at
FROM transactions_log
ORDER BY id DESC
LIMIT 10;


-- ============================================
-- CONSULTA ADICIONAL: Análisis de consistencia
-- ============================================
-- Verifica que el sistema está en estado consistente

SELECT
    'Validación: Total enrollments por curso' AS check_name,
    c.name AS course_name,
    c.total_slots - c.available_slots AS expected_enrollments,
    (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id) AS actual_enrollments,
    CASE 
        WHEN c.total_slots - c.available_slots = (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id)
        THEN '✓ CONSISTENTE'
        ELSE '✗ INCONSISTENTE'
    END AS status
FROM courses c;
