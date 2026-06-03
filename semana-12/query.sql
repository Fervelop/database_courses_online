-- ============================================
-- SEMANA 12: CTEs y CASE WHEN
-- Plataforma de Cursos Online (MySQL/PostgreSQL)
-- ============================================

-- CREACIÓN DE BASE DE DATOS Y TABLAS
-- Nota: Usa el esquema de tu Semana 06 (o superior)
-- Adapta nombres según tu motor (MySQL: CREATE DATABASE; PostgreSQL: CREATE SCHEMA)

-- ============================================
-- SCHEMA: Plataforma de Cursos Online
-- ============================================

-- DROP TABLE IF EXISTS course_reviews;
-- DROP TABLE IF EXISTS enrollments;
-- DROP TABLE IF EXISTS courses;
-- DROP TABLE IF EXISTS students;
-- DROP TABLE IF EXISTS categories;

-- CREATE TABLE categories (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     name VARCHAR(100) NOT NULL UNIQUE
-- );

-- CREATE TABLE students (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     name VARCHAR(100) NOT NULL UNIQUE,
--     email VARCHAR(150) NOT NULL UNIQUE,
--     registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE courses (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     title VARCHAR(150) NOT NULL UNIQUE,
--     category_id INT NOT NULL REFERENCES categories(id),
--     price DECIMAL(10,2) NOT NULL CHECK (price > 0),
--     duration_hours INT CHECK (duration_hours > 0)
-- );

-- CREATE TABLE enrollments (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     student_id INT NOT NULL REFERENCES students(id),
--     course_id INT NOT NULL REFERENCES courses(id),
--     enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     progress_percentage INT DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
-- );

-- CREATE TABLE course_reviews (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     course_id INT NOT NULL REFERENCES courses(id),
--     student_id INT NOT NULL REFERENCES students(id),
--     rating INT CHECK (rating >= 1 AND rating <= 5),
--     review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- ============================================
-- INSERCIÓN DE DATOS (Usa tu semana anterior)
-- ============================================

-- INSERT INTO categories (name) VALUES
--     ('Programming'), ('Design'), ('Marketing'), ('Business'), ('Data Science');

-- INSERT INTO students (name, email) VALUES
--     ('Juan Perez', 'juan@example.com'), ... (30 estudiantes)

-- INSERT INTO courses (...) VALUES (...);

-- INSERT INTO enrollments (...) VALUES (...);

-- INSERT INTO course_reviews (...) VALUES (...);


-- ============================================
-- CONSULTA 1: CTE simple + CASE WHEN de clasificación
-- Clasifica cursos por banda de precio y popularidad
-- ============================================

-- OBJETIVO:
-- - CTE pre-procesa: JOIN courses, categories, enrollments
-- - Calcula: total de inscritos y progreso promedio
-- - Clasifica: banda de precio y popularidad con CASE WHEN

WITH cursos_con_actividad AS (
    -- CTE: Información completa de cada curso con métricas
    SELECT
        c.id,
        c.title,
        c.price,
        c.category_id,
        cat.name AS categoria,
        COUNT(DISTINCT e.id) AS total_inscritos,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio
    FROM courses c
    LEFT JOIN categories cat ON c.category_id = cat.id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY c.id, c.title, c.price, c.category_id, cat.name
)
-- Consulta principal: Clasifica con CASE WHEN
SELECT
    title AS curso,
    categoria,
    price AS precio,
    total_inscritos,
    progreso_promedio,
    CASE
        WHEN price >= 150 THEN 'Premium'
        WHEN price >= 100 THEN 'Estándar'
        ELSE 'Económico'
    END AS banda_precio,
    CASE
        WHEN progreso_promedio >= 75 THEN 'Muy Popular'
        WHEN progreso_promedio >= 50 THEN 'Popular'
        WHEN progreso_promedio > 0 THEN 'En Desarrollo'
        ELSE 'Sin Actividad'
    END AS popularidad
FROM cursos_con_actividad
ORDER BY price DESC;


-- ============================================
-- CONSULTA 2: Dos CTEs encadenados
-- Primer CTE: total de inscritos por categoría
-- Segundo CTE: categorías por encima del promedio
-- ============================================

-- OBJETIVO:
-- - Primer CTE: Calcula inscritos totales por categoría
-- - Segundo CTE: Filtra categorías con inscritos > promedio
-- - Consulta final: Muestra solo las categorías TOP con clasificación

WITH inscritos_por_categoria AS (
    -- Primer CTE: Total de inscritos únicos por categoría
    SELECT
        cat.id,
        cat.name,
        COUNT(DISTINCT e.student_id) AS total_inscritos,
        COUNT(DISTINCT c.id) AS total_cursos
    FROM categories cat
    LEFT JOIN courses c ON cat.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY cat.id, cat.name
),
categorias_top AS (
    -- Segundo CTE: Filtra categorías por encima del promedio
    SELECT
        id,
        name,
        total_inscritos,
        total_cursos
    FROM inscritos_por_categoria
    WHERE total_inscritos > (
        SELECT AVG(total_inscritos)
        FROM inscritos_por_categoria
    )
)
-- Consulta final: Clasifica categorías TOP
SELECT
    cat.name AS categoria,
    cat.total_inscritos,
    cat.total_cursos,
    CASE
        WHEN cat.total_inscritos >= 15 THEN 'Top Tier'
        WHEN cat.total_inscritos >= 10 THEN 'Mid Tier'
        ELSE 'Emergente'
    END AS clasificacion
FROM categorias_top cat
ORDER BY cat.total_inscritos DESC;


-- ============================================
-- CONSULTA 3: CTE + COUNT condicional por banda de precio
-- Por categoría, contar cuántos cursos en cada banda
-- ============================================

-- OBJETIVO:
-- - CTE: Clasifica cada curso en banda de precio (Premium/Estándar/Económico)
-- - Agregación: COUNT(CASE WHEN ...) para contar por banda
-- - Resultado: Tabla de contingencia (crosstab)

WITH clasificados AS (
    -- CTE: Agrega clasificación de banda de precio a cada curso
    SELECT
        c.id,
        c.title,
        cat.name AS categoria,
        c.price,
        CASE
            WHEN c.price >= 150 THEN 'Premium'
            WHEN c.price >= 100 THEN 'Estándar'
            ELSE 'Económico'
        END AS banda_precio
    FROM courses c
    INNER JOIN categories cat ON c.category_id = cat.id
)
-- Agregación: Cuenta por banda de precio y categoría
SELECT
    categoria,
    COUNT(CASE WHEN banda_precio = 'Premium' THEN 1 END) AS premium_count,
    COUNT(CASE WHEN banda_precio = 'Estándar' THEN 1 END) AS estandar_count,
    COUNT(CASE WHEN banda_precio = 'Económico' THEN 1 END) AS economico_count,
    COUNT(*) AS total_cursos
FROM clasificados
GROUP BY categoria
ORDER BY categoria;


-- ============================================
-- CONSULTA 4: Análisis de desempeño de estudiantes
-- Clasificación por actividad y rendimiento
-- ============================================

-- OBJETIVO:
-- - CTE: Calcula actividad total de cada estudiante
-- - Clasificación: Dos dimensiones con CASE WHEN (rendimiento + tipo)

WITH actividad_estudiantes AS (
    -- CTE: Agrupa actividad por estudiante
    SELECT
        s.id,
        s.name,
        s.email,
        COUNT(DISTINCT e.course_id) AS cursos_inscritos,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS cursos_completados
    FROM students s
    LEFT JOIN enrollments e ON s.id = e.student_id
    GROUP BY s.id, s.name, s.email
)
-- Clasificación dual: Rendimiento + Tipo de Estudiante
SELECT
    name AS estudiante,
    email,
    cursos_inscritos,
    progreso_promedio,
    cursos_completados,
    CASE
        WHEN cursos_inscritos = 0 THEN 'Sin Actividad'
        WHEN progreso_promedio >= 80 THEN 'Alto Rendimiento'
        WHEN progreso_promedio >= 50 THEN 'Rendimiento Medio'
        ELSE 'Bajo Rendimiento'
    END AS rendimiento,
    CASE
        WHEN cursos_completados >= 2 THEN 'Completador'
        WHEN cursos_inscritos >= 3 THEN 'Activo'
        WHEN cursos_inscritos > 0 THEN 'Iniciador'
        ELSE 'Inactivo'
    END AS tipo_estudiante
FROM actividad_estudiantes
ORDER BY progreso_promedio DESC;


-- ============================================
-- CONSULTA 5: Análisis detallado por curso (avanzado)
-- Múltiples CTEs y CASE WHEN
-- ============================================

-- OBJETIVO:
-- - Primer CTE: Estadísticas completas por curso
-- - Segundo CTE: Clasificación según tasa de completación
-- - Resultado: Reporte ejecutivo con recomendaciones

WITH estadisticas_curso AS (
    -- Primer CTE: Métricas integrales por curso
    SELECT
        c.id,
        c.title,
        c.price,
        cat.name AS categoria,
        COUNT(DISTINCT e.student_id) AS total_inscritos,
        COUNT(DISTINCT CASE WHEN e.progress_percentage = 100 THEN e.student_id END) AS completados,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        ROUND(AVG(COALESCE(cr.rating, 0)), 2) AS rating_promedio
    FROM courses c
    INNER JOIN categories cat ON c.category_id = cat.id
    LEFT JOIN enrollments e ON c.id = e.course_id
    LEFT JOIN course_reviews cr ON c.id = cr.course_id
    GROUP BY c.id, c.title, c.price, cat.name
),
calificacion_desempenio AS (
    -- Segundo CTE: Añade clasificación de desempeño
    SELECT
        id,
        title,
        categoria,
        price,
        total_inscritos,
        completados,
        progreso_promedio,
        rating_promedio,
        CASE
            WHEN total_inscritos = 0 THEN 'Sin Inscritos'
            WHEN completados = 0 THEN 'Sin Completados'
            WHEN (CAST(completados AS FLOAT) / total_inscritos) >= 0.75 THEN 'Excelente'
            WHEN (CAST(completados AS FLOAT) / total_inscritos) >= 0.50 THEN 'Bueno'
            ELSE 'Regular'
        END AS tasa_completacion
    FROM estadisticas_curso
)
-- Consulta final: Reporte con recomendaciones
SELECT
    title AS curso,
    categoria,
    price,
    total_inscritos,
    completados,
    ROUND((CAST(completados AS FLOAT) / NULLIF(total_inscritos, 0)) * 100, 2) AS pct_completacion,
    progreso_promedio,
    rating_promedio,
    tasa_completacion,
    CASE
        WHEN rating_promedio >= 4.5 AND total_inscritos >= 3 THEN 'Top Course'
        WHEN rating_promedio >= 4 AND progreso_promedio >= 60 THEN 'Recomendado'
        WHEN rating_promedio < 3 THEN 'Necesita Mejoras'
        ELSE 'Estándar'
    END AS recomendacion
FROM calificacion_desempenio
ORDER BY rating_promedio DESC, total_inscritos DESC;


-- ============================================
-- CONSULTA 6: Análisis de ingresos potenciales
-- Segmentación por banda de precio y categoría
-- ============================================

-- OBJETIVO:
-- - Mostrar ingresos totales y potenciales por categoría
-- - Usar CTE para precalcular ingresos reales y máximos posibles

WITH ingresos_realizado AS (
    -- CTE: Ingresos reales por categoría (solo completados/activos)
    SELECT
        cat.id,
        cat.name,
        COUNT(DISTINCT e.student_id) AS estudiantes_activos,
        ROUND(SUM(c.price), 2) AS ingreso_total,
        ROUND(AVG(c.price), 2) AS precio_promedio
    FROM categories cat
    LEFT JOIN courses c ON cat.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    WHERE e.progress_percentage > 0  -- Solo con actividad
    GROUP BY cat.id, cat.name
)
SELECT
    name AS categoria,
    estudiantes_activos,
    ingreso_total,
    precio_promedio,
    CASE
        WHEN ingreso_total IS NULL THEN 'Sin Ingresos'
        WHEN ingreso_total >= 1000 THEN 'Alta Generación'
        WHEN ingreso_total >= 500 THEN 'Media Generación'
        ELSE 'Baja Generación'
    END AS clasificacion_ingresos
FROM ingresos_realizado
ORDER BY ingreso_total DESC NULLS LAST;


-- ============================================
-- PROYECTO SEMANAL: Implementa tu propia consulta
-- ============================================

-- TODO: Crea una consulta con:
-- 1. Un CTE que filtre o procese datos (mínimo dos tablas)
-- 2. Un segundo CTE que referencia al primero (encadenamiento)
-- 3. Usa CASE WHEN con mínimo 3 ramas (2 WHEN + ELSE)
-- 4. Incluye al menos una agregación condicional COUNT(CASE ...)
-- 5. Comenta en español explicando el propósito de cada CTE

-- Ejemplo de estructura (comentada):
/*
WITH primer_cte AS (
    SELECT ...
    FROM ...
    WHERE ...
),
segundo_cte AS (
    SELECT ...
    FROM primer_cte
    WHERE ...
)
SELECT
    columna,
    CASE
        WHEN condicion1 THEN 'Valor1'
        WHEN condicion2 THEN 'Valor2'
        ELSE 'OtroValor'
    END AS clasificacion,
    COUNT(CASE WHEN subcondicion THEN 1 END) AS contador_condicional
FROM segundo_cte
GROUP BY ...
ORDER BY ...;
*/
