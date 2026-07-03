-- ============================================
-- PROYECTO SEMANAL: Ranking con Window Functions
-- Semana 14 — ROW_NUMBER, RANK, DENSE_RANK
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos window functions
-- para clasificar estudiantes según su desempeño en cada curso.
-- Aprenderemos a:
-- 1. Usar ROW_NUMBER() para deduplicación
-- 2. Implementar RANK() y DENSE_RANK() para rankings
-- 3. Combinar con CTEs para obtener Top-N por grupo

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
    difficulty  TEXT   CHECK (difficulty IN ('beginner', 'intermediate', 'advanced'))
);

CREATE TABLE students (
    id       SERIAL PRIMARY KEY,
    name     TEXT   NOT NULL,
    email    TEXT   UNIQUE NOT NULL
);

CREATE TABLE enrollments (
    id           SERIAL PRIMARY KEY,
    student_id   INT REFERENCES students (id),
    course_id    INT REFERENCES courses (id),
    grade        NUMERIC(5, 2) NOT NULL CHECK (grade >= 0 AND grade <= 100),
    enrollment_date TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

-- ============================================
-- Datos de prueba
-- ============================================

INSERT INTO courses (name, description, difficulty) VALUES
    ('SQL Avanzado', 'Domina CTEs y Window Functions', 'advanced'),
    ('Bases de Datos Relacionales', 'Fundamentos de SQL', 'beginner'),
    ('Optimización de Consultas', 'EXPLAIN, índices y performance', 'advanced');

INSERT INTO students (name, email) VALUES
    ('Ana García', 'ana@example.com'),
    ('Bruno López', 'bruno@example.com'),
    ('Carlos Ruiz', 'carlos@example.com'),
    ('Diana Martín', 'diana@example.com'),
    ('Eva Sánchez', 'eva@example.com');

INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (1, 1, 95.5),   -- Ana - SQL Avanzado
    (1, 2, 88.0),   -- Ana - Bases de Datos
    (2, 1, 92.0),   -- Bruno - SQL Avanzado
    (2, 2, 85.0),   -- Bruno - Bases de Datos
    (3, 1, 92.0),   -- Carlos - SQL Avanzado (empate con Bruno)
    (3, 2, 90.0),   -- Carlos - Bases de Datos
    (4, 1, 88.0),   -- Diana - SQL Avanzado
    (4, 3, 91.5),   -- Diana - Optimización
    (5, 2, 92.0),   -- Eva - Bases de Datos
    (5, 3, 94.0);   -- Eva - Optimización


-- ============================================
-- CONSULTA 1: Deduplicación con ROW_NUMBER()
-- ============================================
-- Caso: Tenemos registros duplicados. Usa ROW_NUMBER()
-- para quedarte con uno por estudiante (el más reciente).
-- Pista: ROW_NUMBER() PARTITION BY student_id ORDER BY enrollment_date DESC

WITH enrollments_dedup AS (
    SELECT
        id,
        student_id,
        course_id,
        grade,
        ROW_NUMBER() OVER (
            PARTITION BY student_id 
            ORDER BY enrollment_date DESC
        ) AS rn
    FROM enrollments
)
SELECT
    id,
    student_id,
    course_id,
    grade
FROM enrollments_dedup
WHERE rn = 1
ORDER BY student_id;


-- ============================================
-- CONSULTA 2: RANK y DENSE_RANK por curso
-- ============================================
-- Clasifica los estudiantes por calificación dentro de cada curso.
-- Observa la diferencia entre RANK y DENSE_RANK en caso de empates.
-- Pista: OVER (PARTITION BY course_id ORDER BY grade DESC)

WITH rankings AS (
    SELECT
        s.name AS student_name,
        c.name AS course_name,
        e.grade,
        RANK() OVER (
            PARTITION BY c.id 
            ORDER BY e.grade DESC
        ) AS rank_position,
        DENSE_RANK() OVER (
            PARTITION BY c.id 
            ORDER BY e.grade DESC
        ) AS dense_rank_position
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    JOIN courses c ON e.course_id = c.id
)
SELECT
    student_name,
    course_name,
    grade,
    rank_position,
    dense_rank_position
FROM rankings
ORDER BY course_name, grade DESC;


-- ============================================
-- CONSULTA 3: Top-2 de estudiantes por curso con CTE
-- ============================================
-- Obtén los 2 mejores estudiantes (por DENSE_RANK) en cada curso.
-- Pista: CTE que calcula DENSE_RANK por curso,
--        luego filtra WHERE dense_rnk <= 2 en el exterior.

WITH top_students AS (
    SELECT
        s.id,
        s.name AS student_name,
        c.id AS course_id,
        c.name AS course_name,
        e.grade,
        DENSE_RANK() OVER (
            PARTITION BY c.id 
            ORDER BY e.grade DESC
        ) AS position
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    JOIN courses c ON e.course_id = c.id
)
SELECT
    course_name,
    position,
    student_name,
    grade
FROM top_students
WHERE position <= 2
ORDER BY course_name, position;


-- ============================================
-- CONSULTA 4: Análisis de desempeño por estudiante
-- ============================================
-- Para cada estudiante, muestra su ranking en TODOS los cursos
-- Incluye: estudiante, curso, calificación, posición en el curso

SELECT
    s.name AS student_name,
    c.name AS course_name,
    e.grade,
    RANK() OVER (
        PARTITION BY c.id 
        ORDER BY e.grade DESC
    ) AS rank_in_course,
    COUNT(*) OVER (
        PARTITION BY c.id
    ) AS total_students_in_course
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
ORDER BY c.name, e.grade DESC;
