-- CONSULTA 1: INNER JOIN principal
-- Cursos con estudiantes inscritos

SELECT
    courses.title AS course,
    enrollments.recorded_at
FROM courses co
INNER JOIN enrollments en ON en.course_id = co.id;

-- CONSULTA 2: JOIN con tres tablas
-- courses + enrollments + categories

SELECT
    courses.title AS course,
    categories.name AS category,
    enrollments.recorded_at
FROM courses
INNER JOIN categories
    ON courses.category_id = categories.id
INNER JOIN enrollments
    ON enrollments.course_id = courses.id;

-- CONSULTA 3: LEFT JOIN
-- Todos los cursos aunque no tengan estudiantes

SELECT
    courses.title AS course,
    enrollments.recorded_at AS activity
FROM courses
LEFT JOIN enrollments
    ON enrollments.course_id = courses.id;


-- CONSULTA 4: Detectar cursos sin estudiantes

SELECT
    courses.title AS course_without_students
FROM courses
LEFT JOIN enrollments
    ON enrollments.course_id = courses.id
WHERE enrollments.id IS NULL;


-- CONSULTA 5: LEFT JOIN + COUNT
-- Cantidad de inscripciones por curso

SELECT
    courses.title AS course,
    COUNT(enrollments.id) AS total_records
FROM courses
LEFT JOIN enrollments
    ON enrollments.course_id = courses.id
GROUP BY courses.title
ORDER BY total_records DESC;