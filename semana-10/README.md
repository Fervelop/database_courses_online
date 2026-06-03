# Semana 10: SELF JOIN y Datos Jerárquicos

## 📚 ¿Qué se vio esta semana?

En la **Semana 10** estudiamos cómo **trabajar con datos jerárquicos y estructuras de árbol** usando **SELF JOIN** (una tabla unida consigo misma). Los temas cubiertos fueron:

- **SELF JOIN** - Joinear una tabla con ella misma
- **Datos jerárquicos** - Categorías padre-hijo
- **CROSS JOIN** - Producto cartesiano
- **Múltiples niveles** - Abuelo → Padre → Hijo
- **Contar elementos jerárquicos** - COUNT con SELF JOIN

## 🎯 ¿Por qué se enseña de esta manera?

### El Problema: Datos con Estructura de Árbol

Muchos sistemas del mundo real tienen **datos organizados jerárquicamente**:

```
Casos reales:
├── Categorías de productos (subcategorías)
├── Organización empresarial (departamentos, equipos)
├── Carpetas de archivos (directorios anidados)
├── Menús de aplicaciones (submenús)
└── Comentarios en redes sociales (respuestas a comentarios)

Plataforma de Cursos:
└── Online Courses (raíz)
    ├── Programming
    │   ├── Web Development
    │   └── Mobile Development
    ├── Design
    │   ├── UI UX Design
    │   └── Graphic Design
    └── Marketing
        ├── SEO
        └── Social Media Marketing
```

### El Desafío: AUTO-REFERENCIAS

```sql
-- ¿Cómo juntas categorías con sus subcategorías?
-- Si ambas están en la MISMA tabla...

CREATE TABLE categories_hierarchy (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INTEGER REFERENCES categories_hierarchy(id)
    -- ↑ Referencia a sí misma
);
```

## 🔑 Conceptos Clave

### 1. Tabla Auto-Referencial
```sql
CREATE TABLE categories_hierarchy (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES categories_hierarchy(id)
);

-- INSERCIÓN DE DATOS
-- Nivel 0: Raíz (sin padre)
INSERT INTO categories_hierarchy (name, parent_id)
VALUES ('Online Courses', NULL);

-- Nivel 1: Hijos de Online Courses
INSERT INTO categories_hierarchy (name, parent_id)
VALUES 
('Programming', 1),      -- parent_id = 1 (Online Courses)
('Design', 1),
('Marketing', 1);

-- Nivel 2: Nietos de Online Courses
INSERT INTO categories_hierarchy (name, parent_id)
VALUES
('Web Development', 2),   -- parent_id = 2 (Programming)
('Mobile Development', 2),
('UI UX Design', 3),      -- parent_id = 3 (Design)
('Graphic Design', 3);
```

**Por qué:** Una sola tabla puede representar toda la jerarquía.

### 2. SELF JOIN Básico
```sql
SELECT
    child.name  AS item,
    parent.name AS parent_item
FROM categories_hierarchy child
INNER JOIN categories_hierarchy parent
    ON child.parent_id = parent.id;

Resultado:
┌────────────────────┬──────────────┐
│ item               │ parent_item  │
├────────────────────┼──────────────┤
│ Programming        │ Online Courses
│ Design             │ Online Courses
│ Web Development    │ Programming
│ Mobile Development │ Programming
│ UI UX Design       │ Design
└────────────────────┴──────────────┘
```

**Por qué:** Necesitamos dos aliases de la misma tabla: `child` y `parent`.

### 3. LEFT JOIN Incluyendo la Raíz
```sql
SELECT
    child.name AS item,
    COALESCE(parent.name, 'Raíz') AS parent_item
FROM categories_hierarchy child
LEFT JOIN categories_hierarchy parent
    ON child.parent_id = parent.id
ORDER BY parent_item, item;

Resultado:
┌────────────────────┬──────────────┐
│ item               │ parent_item  │
├────────────────────┼──────────────┤
│ Online Courses     │ Raíz         │ ← Sin padre
│ Programming        │ Online Courses
│ Design             │ Online Courses
│ Web Development    │ Programming
│ UI UX Design       │ Design
└────────────────────┴──────────────┘
```

**Por qué:** LEFT JOIN muestra elementos sin padre (la raíz).

### 4. Contar Hijos por Padre
```sql
SELECT
    parent.name AS parent_item,
    COUNT(child.id) AS total_children
FROM categories_hierarchy parent
LEFT JOIN categories_hierarchy child
    ON child.parent_id = parent.id
GROUP BY parent.id, parent.name
HAVING COUNT(child.id) > 0
ORDER BY total_children DESC;

Resultado:
┌──────────────────┬──────────────┐
│ parent_item      │ total_children
├──────────────────┼──────────────┤
│ Programming      │ 2            │
│ Design           │ 2            │
│ Online Courses   │ 3            │
└──────────────────┴──────────────┘
```

**Por qué:** Saber cuántas subcategorías tiene cada categoría.

### 5. Dos Niveles Jerárquicos (Abuelo → Padre → Hijo)
```sql
SELECT
    child.name       AS item,
    parent.name      AS parent_item,
    grandparent.name AS grandparent_item
FROM categories_hierarchy child
LEFT JOIN categories_hierarchy parent
    ON child.parent_id = parent.id
LEFT JOIN categories_hierarchy grandparent
    ON parent.parent_id = grandparent.id
ORDER BY grandparent_item, parent_item, item;

Resultado:
┌────────────────────┬──────────────┬────────────────────┐
│ item               │ parent       │ grandparent        │
├────────────────────┼──────────────┼────────────────────┤
│ Programming        │ Online Courses│ NULL               │
│ Web Development    │ Programming  │ Online Courses     │
│ Mobile Development │ Programming  │ Online Courses     │
│ Design             │ Online Courses│ NULL               │
│ UI UX Design       │ Design       │ Online Courses     │
└────────────────────┴──────────────┴────────────────────┘
```

**Por qué:** Mostrar la ruta completa (breadcrumb) desde la raíz.

## 💡 Visualización del SELF JOIN

```
Tabla: categories_hierarchy

id  name                      parent_id
1   Online Courses           NULL
2   Programming              1
3   Design                   1
4   Web Development          2
5   Mobile Development       2
6   UI UX Design             3
7   Graphic Design           3

SELF JOIN: child ⟺ parent

child.name         parent.name
─────────────────────────────────
Programming        Online Courses    (parent_id=1 matches id=1)
Design             Online Courses    (parent_id=1 matches id=1)
Web Development    Programming       (parent_id=2 matches id=2)
UI UX Design       Design            (parent_id=3 matches id=3)
```

## 📊 Comparación: Normal JOIN vs SELF JOIN

```sql
-- NORMAL JOIN (dos tablas diferentes)
SELECT c.title, cat.name
FROM courses c
INNER JOIN categories cat ON c.category_id = cat.id;

-- SELF JOIN (una tabla con ella misma)
SELECT child.name, parent.name
FROM categories_hierarchy child
INNER JOIN categories_hierarchy parent
    ON child.parent_id = parent.id;
```

## 🎯 Casos de Uso Reales

| Caso | SELF JOIN | Utilidad |
|------|-----------|----------|
| Org charts | Empleado → Manager | Estructura empresarial |
| Categorías anidadas | Categoría → Subcategoría | E-commerce, blogs |
| Comentarios | Comentario → Comentario padre | Redes sociales |
| Archivos | Carpeta → Carpeta padre | Sistemas de archivos |
| Recetas | Ingrediente → Componente | Cadena de suministro |

## 🎓 Aprendizajes Aplicables

- **Org structure** - Crear árboles organizacionales
- **Navigation** - Menús jerárquicos
- **Breadcrumbs** - Rutas de navegación
- **Recursion patterns** - Entender bases de datos recursivas
- **Reporting** - Reportes jerárquicos

## ⚡ Performance en SELF JOIN

```sql
-- ✅ OPTIMIZADO: Usar índice en parent_id
CREATE INDEX idx_parent_id ON categories_hierarchy(parent_id);

-- ✅ OPTIMIZADO: Limitar profundidad (máx 3 niveles)
SELECT child.name, parent.name, grandparent.name
FROM categories_hierarchy child
LEFT JOIN categories_hierarchy parent ON child.parent_id = parent.id
LEFT JOIN categories_hierarchy grandparent ON parent.parent_id = grandparent.id
WHERE grandparent.id IS NOT NULL;  -- Evita más de 3 niveles

-- ❌ LENTO: SELF JOIN muy profundo (5+ niveles)
-- Considerar: almacenar ruta completa o usar soluciones especializadas
```

## 📝 CROSS JOIN Implícito

```sql
-- Producto cartesiano: cada fila de una tabla se combina
-- con todas las filas de otra

SELECT 
    parent.name,
    child.name
FROM categories_hierarchy parent, categories_hierarchy child
-- Sin ON: genera todas las combinaciones posibles

Resultado: 7 × 7 = 49 filas
```

**Cuidado:** CROSS JOIN puede producir resultados masivos. Usar con precaución.
