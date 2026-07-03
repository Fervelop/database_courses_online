-- ============================================
-- PROYECTO SEMANAL: Índices y Funciones Integradas
-- Semana 16 — CREATE INDEX + Funciones de Texto/Fecha
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos índices
-- para optimizar búsquedas frecuentes de estudiantes y cursos.
-- Además, aplicamos funciones integradas para formatear datos
-- en reportes útiles para usuarios finales.

-- ============================================
-- Tablas del dominio
-- ============================================

DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

CREATE TABLE courses (
    id          SERIAL PRIMARY KEY,
    name        TEXT   NOT NULL,
    description TEXT,
    price       NUMERIC(10, 2),
    created_at  DATE   NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE students (
    id              SERIAL PRIMARY KEY,
    name            TEXT   NOT NULL,
    email           TEXT   UNIQUE NOT NULL,
    registration_date DATE  NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INT REFERENCES students (id),
    course_id   INT REFERENCES courses (id),
    grade       NUMERIC(5, 2),
    enrolled_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

-- ============================================
-- Insertar datos representativos
-- ============================================

INSERT INTO courses (name, description, price, created_at) VALUES
    ('SQL Avanzado', 'Domina CTEs y Window Functions', 99.99, '2023-01-15'),
    ('Bases de Datos', 'Fundamentos de SQL', 79.99, '2023-03-10'),
    ('Optimización', 'EXPLAIN y Performance', 129.99, '2023-06-20'),
    ('PostgreSQL', 'Características avanzadas de PG', 109.99, '2023-09-05'),
    ('Data Analytics', 'Análisis de datos con SQL', 89.99, '2024-01-20');

INSERT INTO students (name, email, registration_date) VALUES
    ('Ana García', 'ana.garcia@example.com', '2022-03-10'),
    ('Bruno López', 'bruno.lopez@example.com', '2021-07-15'),
    ('Carlos Ruiz', 'carlos.ruiz@example.com', '2023-01-05'),
    ('Diana Martín', 'diana.martin@example.com', '2020-11-20'),
    ('Eva Sánchez', 'eva.sanchez@example.com', '2024-02-14'),
    ('Fernando Gómez', 'fernando.gomez@example.com', '2022-09-08'),
    ('Gabriela López', 'gabriela.lopez@example.com', '2023-05-30'),
    ('Hugo Fernández', 'hugo.fernandez@example.com', '2023-11-11');

INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (1, 1, 95.5), (1, 2, 88.0), (1, 3, 91.0),
    (2, 1, 92.0), (2, 2, 85.0), (2, 4, 89.5),
    (3, 2, 90.0), (3, 3, 87.5),
    (4, 1, 98.0), (4, 4, 94.0), (4, 5, 96.5),
    (5, 2, 92.0), (5, 3, 94.0),
    (6, 1, 85.0), (6, 5, 88.0),
    (7, 3, 91.5), (7, 4, 89.0),
    (8, 2, 86.0), (8, 5, 90.0);


-- ============================================
-- TODO 1: Crear un índice y verificar con EXPLAIN
-- ============================================
-- 1. Ejecuta EXPLAIN en una consulta con WHERE course_id = ...
--    ANTES de crear el índice. Observa "Seq Scan".
-- 2. Crea el índice con CREATE INDEX en la columna course_id.
-- 3. Ejecuta el mismo EXPLAIN de nuevo. Observa si cambia a "Index Scan".

-- EXPLAIN ANTES del índice
EXPLAIN SELECT e.* FROM enrollments e WHERE e.course_id = 1;

-- Crear el índice
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);

-- EXPLAIN DESPUÉS del índice
EXPLAIN SELECT e.* FROM enrollments e WHERE e.course_id = 1;

-- Crear índices adicionales para optimización
CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_registration_date ON students(registration_date);
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);


-- ============================================
-- TODO 2: Reporte con funciones de texto y fecha
-- ============================================
-- Crea una consulta que muestre:
--   - name en MAYÚSCULAS
--   - created_at formateado como 'DD/MM/YYYY' con TO_CHAR
--   - Antigüedad del registro en años usando AGE + EXTRACT

SELECT
    UPPER(s.name) AS student_name_upper,
    LOWER(s.email) AS email_lower,
    TO_CHAR(s.registration_date, 'DD/MM/YYYY') AS registration_formatted,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)) AS years_registered,
    CONCAT(EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)), 
           ' años, ',
           EXTRACT(MONTH FROM AGE(CURRENT_DATE, s.registration_date)),
           ' meses') AS age_formatted
FROM students s
ORDER BY s.registration_date;


-- ============================================
-- TODO 3: Reporte numérico con descuento
-- ============================================
-- Calcula para cada curso:
--   - price original
--   - price con 15% de descuento (ROUND a 2 decimales)
--   - el ahorro (original - precio_con_descuento)
-- Ordena por precio descendente.

SELECT
    UPPER(c.name) AS course_name,
    c.price AS original_price,
    ROUND(c.price * 0.85, 2) AS discounted_price_15pct,
    ROUND(c.price * 0.15, 2) AS savings,
    TO_CHAR(c.created_at, 'DD/MM/YYYY') AS course_created,
    ROUND(LENGTH(c.description)) AS description_length
FROM courses c
ORDER BY c.price DESC;


-- ============================================
-- CONSULTA ADICIONAL: Análisis de estudiantes por antigüedad
-- ============================================
-- Agrupa estudiantes por rango de antigüedad

WITH student_age AS (
    SELECT
        s.id,
        UPPER(s.name) AS name,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)) AS years_ago,
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)) >= 3 THEN 'Miembro Antiguo (3+ años)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)) >= 2 THEN 'Miembro Establecido (2-3 años)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.registration_date)) >= 1 THEN 'Miembro Activo (1-2 años)'
            ELSE 'Miembro Nuevo (<1 año)'
        END AS member_category
    FROM students s
)
SELECT
    member_category,
    COUNT(*) AS total_students,
    STRING_AGG(name, ', ') AS students_list
FROM student_age
GROUP BY member_category
ORDER BY years_ago DESC;


-- ============================================
-- CONSULTA ADICIONAL: Reporte de ingresos con análisis
-- ============================================
-- Muestra precio original, con descuento, y porcentaje ahorrado

SELECT
    c.name,
    c.price,
    ROUND(c.price * 0.10, 2) AS discount_10pct,
    ROUND(c.price * 0.15, 2) AS discount_15pct,
    ROUND(c.price * 0.20, 2) AS discount_20pct,
    (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id) AS total_enrollments
FROM courses c
ORDER BY c.price DESC;
