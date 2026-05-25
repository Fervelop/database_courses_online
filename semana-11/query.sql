-- PROYECTO SEMANAL: Subqueries en tu dominio
-- Semana 11 — Subqueries
-- Dominio: Plataforma de Cursos Online

PRAGMA foreign_keys = ON;

-- ELIMINAR TABLAS SI EXISTEN

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;

-- TABLA: courses

CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    price REAL NOT NULL
    CHECK(price > 0),
    category TEXT NOT NULL
);

-- TABLA: enrollments

CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY,
    course_id INTEGER NOT NULL
    REFERENCES courses(id),
    quantity INTEGER NOT NULL
    DEFAULT 1
);

-- INSERTS PARA courses

INSERT INTO courses
(title, price, category)
VALUES
('Python Basics', 50, 'Programming'),
('Advanced Python', 95, 'Programming'),
('Java Fundamentals', 60, 'Programming'),
('Spring Boot', 120, 'Programming'),
('UI UX Design', 55, 'Design'),
('Figma Course', 75, 'Design'),
('Photoshop Mastery', 100, 'Design'),
('SEO Course', 70, 'Marketing'),
('Google Ads', 90, 'Marketing'),
('TikTok Marketing', 45, 'Marketing'),
('Project Management', 130, 'Business'),
('Leadership Skills', 80, 'Business'),
('Data Analysis', 98, 'Data Science'),
('Machine Learning', 160, 'Data Science'),
-- CURSO SIN INSCRIPCIONES
('Big Data Fundamentals', 140, 'Data Science');

-- INSERTS PARA enrollments

INSERT INTO enrollments
(course_id, quantity)
VALUES
(1, 3),
(1, 2),
(2, 5),
(3, 1),
(3, 4),
(4, 6),
(5, 2),
(6, 3),
(6, 2),
(7, 1),
(8, 4),
(9, 5),
(9, 3),
(10, 2),
(11, 6),
(12, 2),
(13, 5),
(14, 4);

-- CONSULTA 1: Subquery escalar en WHERE
-- Cursos cuyo precio supera el promedio
-- de su categoría

SELECT
    title,
    price,
    category
FROM courses c
WHERE price > (
    SELECT AVG(c2.price)
    FROM courses c2
    WHERE c2.category = c.category
)
ORDER BY category,
         price DESC;

-- CONSULTA 2: Subquery escalar en SELECT
-- Mostrar promedio global junto a cada curso

SELECT
    title,
    price,
    ROUND(
        (SELECT AVG(price)
         FROM courses),
    2) AS overall_avg
FROM courses
ORDER BY price DESC;

-- CONSULTA 3: NOT EXISTS
-- Cursos sin inscripciones

SELECT
    title AS course_without_enrollments
FROM courses c
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.course_id = c.id
);

-- CONSULTA 4: Tabla derivada en FROM
-- Categorías con más de 2 inscripciones

SELECT
    category_stats.category,
    category_stats.total_records
FROM (
    SELECT
        c.category,
        COUNT(e.id) AS total_records
    FROM courses c
    LEFT JOIN enrollments e
        ON e.course_id = c.id
    GROUP BY c.category
) AS category_stats
WHERE category_stats.total_records > 2
ORDER BY category_stats.total_records DESC;