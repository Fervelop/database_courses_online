-- PROYECTO SEMANAL: SELF JOIN en tu dominio
-- Semana 10 — CROSS JOIN y SELF JOIN
-- Dominio: Plataforma de Cursos Online

PRAGMA foreign_keys = ON;

-- TABLA AUTO-REFERENCIAL
-- categories

DROP TABLE IF EXISTS categories_hierarchy;

CREATE TABLE categories_hierarchy (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    parent_id INTEGER
    REFERENCES categories_hierarchy(id)
);

-- REGISTRO RAÍZ

INSERT INTO categories_hierarchy (name, parent_id)
VALUES
('Online Courses', NULL);
-- HIJOS NIVEL 1

INSERT INTO categories_hierarchy (name, parent_id)
VALUES
('Programming', 1),
('Design', 1),
('Marketing', 1);

-- NIETOS (NIVEL 2)

INSERT INTO categories_hierarchy (name, parent_id)
VALUES
('Web Development', 2),
('Mobile Development', 2),
('UI UX Design', 3),
('Graphic Design', 3),
('SEO', 4),
('Social Media Marketing', 4);

-- CONSULTA 1: SELF JOIN BÁSICO
-- item hijo y su padre

SELECT
    child.name  AS item,
    parent.name AS parent_item
FROM categories_hierarchy child
INNER JOIN categories_hierarchy parent
    ON child.parent_id = parent.id;

-- CONSULTA 2: LEFT JOIN incluyendo raíz

SELECT
    child.name AS item,
    COALESCE(parent.name, 'Raíz')
    AS parent_item
FROM categories_hierarchy child
LEFT JOIN categories_hierarchy parent
    ON child.parent_id = parent.id
ORDER BY parent_item, item;

-- CONSULTA 3: Contar hijos por padre

SELECT
    parent.name AS parent_item,
    COUNT(child.id) AS total_children
FROM categories_hierarchy parent
LEFT JOIN categories_hierarchy child
    ON child.parent_id = parent.id
GROUP BY parent.id, parent.name
HAVING COUNT(child.id) > 0
ORDER BY total_children DESC;

-- CONSULTA 4: DOS NIVELES JERÁRQUICOS
-- item → padre → abuelo

SELECT
    child.name       AS item,
    parent.name      AS parent_item,
    grandparent.name AS grandparent_item
FROM categories_hierarchy child
LEFT JOIN categories_hierarchy parent
    ON child.parent_id = parent.id
LEFT JOIN categories_hierarchy grandparent
    ON parent.parent_id = grandparent.id
ORDER BY grandparent_item,
         parent_item,
         item;