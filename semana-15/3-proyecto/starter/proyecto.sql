-- ============================================
-- PROYECTO SEMANAL: Análisis temporal con Window Functions y Vistas
-- Semana 15 — LEAD, LAG, FIRST_VALUE, LAST_VALUE, CREATE VIEW
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos window functions
-- de navegación para analizar tendencias mensuales de estudiantes e ingresos.
-- Aprenderemos a:
-- 1. Calcular variaciones con LAG()
-- 2. Crear vistas encapsuladas para reportes
-- 3. Analizar extremos con FIRST_VALUE y LAST_VALUE

-- ============================================
-- Tablas del dominio
-- ============================================

DROP VIEW IF EXISTS v_monthly_metrics CASCADE;
DROP TABLE IF EXISTS monthly_metrics CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

CREATE TABLE courses (
    id      SERIAL PRIMARY KEY,
    name    TEXT   NOT NULL
);

CREATE TABLE monthly_metrics (
    id              SERIAL         PRIMARY KEY,
    month_date      DATE           NOT NULL,
    course_id       INT            REFERENCES courses (id),
    new_enrollments INT            NOT NULL DEFAULT 0,
    revenue         NUMERIC(12, 2) NOT NULL DEFAULT 0,
    UNIQUE(month_date, course_id)
);

-- ============================================
-- Datos de prueba: 4 meses, 2 cursos
-- ============================================

INSERT INTO courses (name) VALUES
    ('SQL Avanzado'),
    ('Bases de Datos Relacionales');

INSERT INTO monthly_metrics (month_date, course_id, new_enrollments, revenue) VALUES
    ('2024-01-01', 1, 50,   2500.00),
    ('2024-01-01', 2, 45,   2250.00),
    ('2024-02-01', 1, 65,   3250.00),
    ('2024-02-01', 2, 38,   1900.00),
    ('2024-03-01', 1, 55,   2750.00),
    ('2024-03-01', 2, 50,   2500.00),
    ('2024-04-01', 1, 80,   4000.00),
    ('2024-04-01', 2, 60,   3000.00);


-- ============================================
-- CONSULTA 1: LAG para calcular la variación entre períodos
-- ============================================
-- Muestra el valor actual, el del período anterior (LAG),
-- y la diferencia (delta = valor - prev_valor).
-- Aplica PARTITION BY course_id para comparar
-- cada curso con su propio período anterior.

SELECT
    c.name AS course_name,
    mm.month_date,
    mm.new_enrollments,
    LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    ) AS prev_enrollments,
    mm.new_enrollments - LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    ) AS enrollment_delta,
    ROUND(100.0 * (mm.new_enrollments - LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    )) / LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    ), 2) AS enrollment_change_pct
FROM monthly_metrics mm
JOIN courses c ON mm.course_id = c.id
ORDER BY c.name, mm.month_date;


-- ============================================
-- CONSULTA 2: FIRST_VALUE y LAST_VALUE por curso
-- ============================================
-- Para cada fila muestra:
--   - El mejor mes histórico (FIRST_VALUE ORDER BY revenue DESC)
--   - El peor mes histórico (LAST_VALUE con frame extendido)
-- Usa WINDOW alias para no repetir la definición.

SELECT
    c.name AS course_name,
    mm.month_date,
    mm.revenue,
    FIRST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS best_month_revenue,
    LAST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS worst_month_revenue,
    ROUND(100.0 * (mm.revenue - LAST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )) / LAST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ), 2) AS revenue_vs_worst_pct
FROM monthly_metrics mm
JOIN courses c ON mm.course_id = c.id
ORDER BY c.name, mm.revenue DESC;


-- ============================================
-- CONSULTA 3: CREATE VIEW — encapsular el análisis
-- ============================================
-- Crea la vista v_monthly_metrics que incluya:
--   month_date, course_id, new_enrollments, revenue,
--   LAG(enrollments) como prev_enrollments,
--   FIRST_VALUE(revenue) como best_revenue,
--   LAST_VALUE(revenue) como worst_revenue

CREATE OR REPLACE VIEW v_monthly_metrics AS
SELECT
    c.name AS course_name,
    mm.month_date,
    mm.course_id,
    mm.new_enrollments,
    LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    ) AS prev_enrollments,
    mm.new_enrollments - LAG(mm.new_enrollments) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.month_date
    ) AS enrollment_delta,
    mm.revenue,
    FIRST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS best_month_revenue,
    LAST_VALUE(mm.revenue) OVER (
        PARTITION BY mm.course_id 
        ORDER BY mm.revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS worst_month_revenue
FROM monthly_metrics mm
JOIN courses c ON mm.course_id = c.id;

-- Consultar la vista filtrando por curso específico
SELECT
    course_name,
    month_date,
    new_enrollments,
    prev_enrollments,
    enrollment_delta,
    revenue,
    best_month_revenue,
    worst_month_revenue
FROM v_monthly_metrics
WHERE course_id = 1
ORDER BY month_date;


-- ============================================
-- CONSULTA 4: Análisis de tendencia completo
-- ============================================
-- Usa LEAD() para predecir el próximo mes
-- y calcula el promedio móvil de 3 períodos

SELECT
    course_name,
    month_date,
    new_enrollments,
    LEAD(new_enrollments) OVER (
        PARTITION BY course_id 
        ORDER BY month_date
    ) AS next_month_enrollments,
    ROUND(AVG(new_enrollments) OVER (
        PARTITION BY course_id 
        ORDER BY month_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) AS moving_avg_3_months
FROM v_monthly_metrics
ORDER BY course_name, month_date;
