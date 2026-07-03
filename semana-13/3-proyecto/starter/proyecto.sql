-- ============================================
-- PROYECTO SEMANAL: Jerarquías con CTEs Recursivas
-- Semana 13 — WITH RECURSIVE
-- PostgreSQL 16
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- En el dominio de Plataforma de Cursos Online, usamos CTEs recursivas
-- para modelar la estructura jerárquica de lecciones dentro de cursos.
-- Las lecciones pueden tener sublecciones, creando una jerarquía
-- de múltiples niveles (tema principal > subtema > lección > sublección).

-- ============================================
-- Tabla de Cursos (raíz de la jerarquía)
-- ============================================

DROP TABLE IF EXISTS course_hierarchy CASCADE;

CREATE TABLE course_hierarchy (
    id          SERIAL  PRIMARY KEY,
    name        TEXT    NOT NULL,
    parent_id   INT     REFERENCES course_hierarchy (id),
    level_type  TEXT    NOT NULL,  -- 'course', 'module', 'lesson', 'sublesson'
    course_id   INT,                -- ID del curso raíz
    created_at  TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- Insertar datos con al menos 4 niveles
-- Nivel 1: Cursos (parent_id = NULL)
-- Nivel 2: Módulos del curso
-- Nivel 3: Lecciones del módulo
-- Nivel 4: Sublecciones de la lección
-- ============================================

INSERT INTO course_hierarchy (name, parent_id, level_type, course_id) VALUES
    -- Nivel 1: Curso raíz
    ('SQL Avanzado', NULL, 'course', 1),
    
    -- Nivel 2: Módulos
    ('Módulo 1: CTEs', 1, 'module', 1),
    ('Módulo 2: Window Functions', 1, 'module', 1),
    
    -- Nivel 3: Lecciones del Módulo 1
    ('Lección 1.1: CTEs Básicas', 2, 'lesson', 1),
    ('Lección 1.2: CTEs Recursivas', 2, 'lesson', 1),
    
    -- Nivel 4: Sublecciones de Lección 1.1
    ('Sublección 1.1.1: Concepto básico', 4, 'sublesson', 1),
    ('Sublección 1.1.2: Ejemplo práctico', 4, 'sublesson', 1),
    
    -- Nivel 4: Sublecciones de Lección 1.2
    ('Sublección 1.2.1: Recursión con UNION', 5, 'sublesson', 1),
    ('Sublección 1.2.2: Árbol de categorías', 5, 'sublesson', 1),
    
    -- Nivel 3: Lecciones del Módulo 2
    ('Lección 2.1: ROW_NUMBER()', 3, 'lesson', 1),
    ('Lección 2.2: RANK() y DENSE_RANK()', 3, 'lesson', 1);


-- ============================================
-- CONSULTA 1: Árbol completo con depth y path
-- Recorre todos los nodos desde la raíz
-- Calcula: depth (1, 2, 3, 4...) y path (nombre > nombre > ...)
-- ============================================

WITH RECURSIVE arbol_jerarquico AS (
    -- Caso base: nodos raíz (cursos sin parent)
    SELECT
        id,
        name,
        parent_id,
        level_type,
        1 AS depth,
        name AS path,
        ARRAY[id] AS path_ids
    FROM course_hierarchy
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo: nodos hijo
    SELECT
        ch.id,
        ch.name,
        ch.parent_id,
        ch.level_type,
        aj.depth + 1,
        aj.path || ' > ' || ch.name,
        aj.path_ids || ARRAY[ch.id]
    FROM course_hierarchy ch
    INNER JOIN arbol_jerarquico aj ON ch.parent_id = aj.id
)
SELECT
    depth,
    REPEAT('  ', depth - 1) || name AS indented_name,
    path,
    level_type
FROM arbol_jerarquico
ORDER BY path;


-- ============================================
-- CONSULTA 2: Nodos de un nivel específico
-- Filtra solo los nodos de depth = N (elige el nivel)
-- En este caso, mostramos todas las lecciones (depth = 3)
-- ============================================

WITH RECURSIVE arbol_jerarquico AS (
    SELECT
        id,
        name,
        parent_id,
        level_type,
        1 AS depth,
        name AS path
    FROM course_hierarchy
    WHERE parent_id IS NULL
    UNION ALL
    SELECT
        ch.id,
        ch.name,
        ch.parent_id,
        ch.level_type,
        aj.depth + 1,
        aj.path || ' > ' || ch.name
    FROM course_hierarchy ch
    INNER JOIN arbol_jerarquico aj ON ch.parent_id = aj.id
)
SELECT 
    name, 
    depth, 
    path,
    level_type
FROM arbol_jerarquico
WHERE depth = 3  -- Lecciones principales
ORDER BY path;


-- ============================================
-- CONSULTA 3: Hojas del árbol (nodos sin hijos)
-- Detecta nodos que NO tienen hijos (sublecciones)
-- ============================================

SELECT
    ch.id,
    ch.name,
    ch.level_type,
    ch.created_at
FROM course_hierarchy ch
WHERE NOT EXISTS (
    SELECT 1
    FROM course_hierarchy child
    WHERE child.parent_id = ch.id
)
ORDER BY ch.name;


-- ============================================
-- CONSULTA 4: Camino completo desde la raíz hasta cada sublección
-- Útil para generar breadcrumbs de navegación
-- ============================================

WITH RECURSIVE arbol_jerarquico AS (
    SELECT
        id,
        name,
        parent_id,
        level_type,
        1 AS depth,
        name AS path
    FROM course_hierarchy
    WHERE parent_id IS NULL
    UNION ALL
    SELECT
        ch.id,
        ch.name,
        ch.parent_id,
        ch.level_type,
        aj.depth + 1,
        aj.path || ' > ' || ch.name
    FROM course_hierarchy ch
    INNER JOIN arbol_jerarquico aj ON ch.parent_id = aj.id
)
SELECT
    id,
    name,
    level_type,
    depth,
    path AS breadcrumb
FROM arbol_jerarquico
WHERE level_type = 'sublesson'
ORDER BY path;
