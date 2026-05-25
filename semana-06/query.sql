-- CREACIÓN DE BASE DE DATOS MYSQL
-- Plataforma de Cursos Online

CREATE DATABASE online_courses_platform;
USE online_courses_platform;

-- TABLA: categories

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- TABLA: courses

CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    instructor VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_hours INT NOT NULL,
    level ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- TABLA: students

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    country VARCHAR(100),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA: lessons

CREATE TABLE lessons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    content TEXT,
    video_duration_minutes INT,
    lesson_order INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- TABLA: enrollments

CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    status ENUM('Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- INSERTS PARA categories

INSERT INTO categories (name, description) VALUES
('Programming', 'Software development and coding courses'),
('Design', 'Graphic and UI/UX design courses'),
('Marketing', 'Digital marketing and business growth'),
('Business', 'Entrepreneurship and management'),
('Data Science', 'Data analysis and machine learning');

-- DISTRIBUCIÓN DESIGUAL POR CATEGORÍA

INSERT INTO courses 
(category_id, title, description, instructor, price, duration_hours, level)
VALUES
(1, 'Python for Beginners', 'Learn Python from scratch', 'Carlos Ramirez', 49.99, 20, 'Beginner'),
(1, 'Advanced Java Programming', 'Deep dive into Java enterprise development', 'Laura Gomez', 89.99, 40, 'Advanced'),
(1, 'Web Development Bootcamp', 'HTML CSS JavaScript and React', 'Andres Torres', 120.00, 60, 'Intermediate'),
(1, 'Node.js API Development', 'Build REST APIs with Node.js', 'Miguel Castro', 75.50, 30, 'Intermediate'),
(1, 'Full Stack Developer Course', 'Frontend and backend complete guide', 'Sofia Martinez', 150.00, 80, 'Advanced'),
(1, 'SQL Database Essentials', 'Learn SQL and database modeling', 'Daniel Perez', 55.00, 18, 'Beginner'),
(1, 'Spring Boot Masterclass', 'Java backend with Spring Boot', 'Julian Herrera', 95.00, 45, 'Advanced'),
(1, 'React Native Mobile Apps', 'Create Android and iOS apps', 'Camila Ruiz', 110.00, 50, 'Intermediate'),
(1, 'C# Fundamentals', 'Introduction to C# programming', 'Sebastian Diaz', 40.00, 15, 'Beginner'),
(1, 'Docker and Kubernetes', 'Containerization and orchestration', 'Felipe Vargas', 130.00, 55, 'Advanced'),
(1, 'PHP and MySQL Development', 'Dynamic websites with PHP', 'Oscar Medina', 65.00, 25, 'Intermediate'),
(1, 'Algorithms and Data Structures', 'Problem solving techniques', 'Natalia Rojas', 85.00, 35, 'Advanced'),
(2, 'UI UX Design Basics', 'Introduction to user experience design', 'Paula Jimenez', 60.00, 22, 'Beginner'),
(2, 'Adobe Photoshop Mastery', 'Professional photo editing', 'Ricardo Silva', 70.00, 28, 'Intermediate'),
(2, 'Figma for Designers', 'Collaborative interface design', 'Valentina Lopez', 58.00, 20, 'Beginner'),
(2, 'Brand Identity Design', 'Create professional brands', 'Tatiana Mora', 95.00, 35, 'Advanced'),
(2, 'Motion Graphics with After Effects', 'Animation and visual effects', 'Juan Velasquez', 115.00, 45, 'Advanced'),
(3, 'Digital Marketing Strategy', 'Marketing campaigns and funnels', 'Andrea Castillo', 80.00, 30, 'Intermediate'),
(3, 'Facebook Ads Expert', 'Advertising on Meta platforms', 'Diego Suarez', 65.00, 18, 'Beginner'),
(3, 'SEO Positioning Course', 'Improve Google rankings', 'Maria Fernanda Gil', 72.00, 24, 'Intermediate'),
(3, 'TikTok Content Creation', 'Viral content strategies', 'Kevin Morales', 45.00, 12, 'Beginner'),
(3, 'Email Marketing Automation', 'Automated email campaigns', 'Sandra Cifuentes', 68.00, 20, 'Intermediate'),
(3, 'Instagram Growth Masterclass', 'Grow followers organically', 'Nicolas Romero', 90.00, 32, 'Advanced'),
(4, 'Entrepreneurship Fundamentals', 'How to start a business', 'Jorge Mendoza', 50.00, 16, 'Beginner'),
(4, 'Project Management Professional', 'Agile and Scrum methodologies', 'Patricia Leon', 140.00, 55, 'Advanced'),
(4, 'Financial Analysis for Managers', 'Business finance essentials', 'Mauricio Pardo', 88.00, 34, 'Intermediate'),
(4, 'Leadership and Team Building', 'Improve leadership skills', 'Angela Fonseca', 77.00, 26, 'Intermediate'),
(5, 'Data Analysis with Python', 'Analyze datasets using pandas', 'Esteban Gutierrez', 98.00, 40, 'Intermediate'),
(5, 'Machine Learning Essentials', 'Introduction to ML models', 'Cristina Navarro', 145.00, 60, 'Advanced'),
(5, 'Power BI Dashboard Creation', 'Business intelligence dashboards', 'Fernando Acosta', 85.00, 30, 'Intermediate');

-- INSERTS PARA students

INSERT INTO students 
(first_name, last_name, email, phone, birth_date, country)
VALUES
('Juan', 'Perez', 'juan.perez@gmail.com', '3001234567', '1998-04-12', 'Colombia'),
('Maria', 'Gonzalez', 'maria.gonzalez@gmail.com', '3017654321', '1995-09-22', 'Mexico'),
('Carlos', 'Rodriguez', 'carlos.rodriguez@gmail.com', '3209876543', '2000-01-15', 'Argentina'),
('Laura', 'Martinez', 'laura.martinez@gmail.com', '3154567890', '1997-06-08', 'Chile'),
('Andres', 'Lopez', 'andres.lopez@gmail.com', '3112223344', '1993-11-30', 'Peru'),
('Sofia', 'Ramirez', 'sofia.ramirez@gmail.com', '3005551122', '1999-03-10', 'Colombia'),
('Daniel', 'Torres', 'daniel.torres@gmail.com', '3014442233', '1994-08-14', 'Mexico'),
('Camila', 'Ruiz', 'camila.ruiz@gmail.com', '3207778899', '2001-12-01', 'Chile'),
('Miguel', 'Castro', 'miguel.castro@gmail.com', '3159997766', '1996-07-18', 'Peru'),
('Valentina', 'Morales', 'valentina.morales@gmail.com', '3115558899', '1998-11-25', 'Argentina'),
('Sebastian', 'Diaz', 'sebastian.diaz@gmail.com', '3008882233', '1997-01-09', 'Colombia'),
('Paula', 'Jimenez', 'paula.jimenez@gmail.com', '3013336677', '1993-05-21', 'Mexico'),
('Ricardo', 'Silva', 'ricardo.silva@gmail.com', '3204449988', '1990-09-11', 'Chile'),
('Tatiana', 'Mora', 'tatiana.mora@gmail.com', '3151112233', '1992-02-17', 'Peru'),
('Felipe', 'Vargas', 'felipe.vargas@gmail.com', '3116665544', '1995-04-04', 'Colombia'),
('Natalia', 'Rojas', 'natalia.rojas@gmail.com', '3002227788', '2000-10-13', 'Argentina'),
('Oscar', 'Medina', 'oscar.medina@gmail.com', '3017778899', '1989-06-19', 'Mexico'),
('Angela', 'Fonseca', 'angela.fonseca@gmail.com', '3201114455', '1998-12-30', 'Chile'),
('Kevin', 'Morales', 'kevin.morales@gmail.com', '3158881122', '1996-03-28', 'Peru'),
('Sandra', 'Cifuentes', 'sandra.cifuentes@gmail.com', '3119993344', '1991-07-07', 'Colombia'),
('Nicolas', 'Romero', 'nicolas.romero@gmail.com', '3004446677', '1994-09-02', 'Argentina'),
('Patricia', 'Leon', 'patricia.leon@gmail.com', '3011239988', '1988-01-27', 'Mexico'),
('Mauricio', 'Pardo', 'mauricio.pardo@gmail.com', '3206661122', '1992-11-08', 'Chile'),
('Cristina', 'Navarro', 'cristina.navarro@gmail.com', '3152225566', '1999-06-15', 'Peru'),
('Esteban', 'Gutierrez', 'esteban.gutierrez@gmail.com', '3114447788', '1993-08-29', 'Colombia'),
('Andrea', 'Castillo', 'andrea.castillo@gmail.com', '3007772233', '1997-05-03', 'Argentina'),
('Diego', 'Suarez', 'diego.suarez@gmail.com', '3018883344', '1995-10-20', 'Mexico'),
('Maria Fernanda', 'Gil', 'maria.gil@gmail.com', '3205557788', '1996-04-26', 'Chile'),
('Jorge', 'Mendoza', 'jorge.mendoza@gmail.com', '3157774455', '1987-12-12', 'Peru'),
('Fernando', 'Acosta', 'fernando.acosta@gmail.com', '3113339988', '1991-02-06', 'Colombia');

-- INSERTS PARA enrollments

INSERT INTO enrollments
(student_id, course_id, progress_percentage, status)
VALUES
(1, 1, 75.00, 'Active'),
(1, 3, 100.00, 'Completed'),
(2, 5, 20.00, 'Active'),
(3, 18, 50.00, 'Active'),
(4, 27, 100.00, 'Completed'),
(5, 14, 10.00, 'Active'),
(6, 2, 40.00, 'Active'),
(7, 8, 85.00, 'Active'),
(8, 10, 100.00, 'Completed'),
(9, 12, 15.00, 'Active'),
(10, 7, 65.00, 'Active'),
(11, 4, 90.00, 'Completed'),
(12, 6, 25.00, 'Active'),
(13, 9, 55.00, 'Active'),
(14, 11, 100.00, 'Completed'),
(15, 13, 5.00, 'Active'),
(16, 15, 30.00, 'Active'),
(17, 16, 80.00, 'Active'),
(18, 17, 100.00, 'Completed'),
(19, 19, 45.00, 'Active'),
(20, 20, 60.00, 'Active'),
(21, 21, 35.00, 'Active'),
(22, 22, 95.00, 'Completed'),
(23, 23, 50.00, 'Active'),
(24, 24, 12.00, 'Active'),
(25, 25, 100.00, 'Completed'),
(26, 26, 72.00, 'Active'),
(27, 27, 28.00, 'Active'),
(28, 28, 88.00, 'Active'),
(29, 29, 100.00, 'Completed');

-- INSERTS PARA lessons

INSERT INTO lessons
(course_id, title, content, video_duration_minutes, lesson_order)
VALUES
(1, 'Introduction to Python', 'Python basics and installation', 15, 1),
(1, 'Variables and Data Types', 'Working with variables', 20, 2),
(1, 'Conditional Statements', 'If else structures', 18, 3),
(2, 'Java Fundamentals', 'Introduction to Java language', 22, 1),
(2, 'Object Oriented Programming', 'Classes and objects', 35, 2),
(2, 'Exception Handling', 'Managing runtime errors', 25, 3),
(3, 'HTML Fundamentals', 'Basic structure of web pages', 25, 1),
(3, 'CSS Styling', 'Designing responsive websites', 30, 2),
(3, 'JavaScript Basics', 'Programming interactions on web pages', 35, 3),
(4, 'Introduction to Node.js', 'Backend development basics', 20, 1),
(4, 'Creating REST APIs', 'API endpoints and routing', 28, 2),
(4, 'Database Integration', 'Connecting MySQL databases', 32, 3),
(5, 'Frontend Architecture', 'Understanding frontend layers', 18, 1),
(5, 'Backend Services', 'Business logic implementation', 24, 2),
(5, 'Deployment Process', 'Deploying full stack apps', 27, 3),
(6, 'Introduction to SQL', 'Basic SQL syntax', 16, 1),
(6, 'JOIN Operations', 'Combining multiple tables', 22, 2),
(6, 'Database Optimization', 'Improving query performance', 29, 3),
(7, 'Spring Boot Setup', 'Environment configuration', 19, 1),
(7, 'Controllers and APIs', 'Creating REST controllers', 26, 2),
(7, 'Security with JWT', 'Authentication and authorization', 34, 3),
(8, 'React Native Basics', 'Mobile development introduction', 21, 1),
(8, 'Navigation Systems', 'Screen navigation handling', 24, 2),
(8, 'Publishing Apps', 'Deploying to app stores', 31, 3),
(9, 'C# Syntax', 'Basic syntax and variables', 17, 1),
(9, 'Working with Methods', 'Functions and parameters', 23, 2),
(10, 'Docker Containers', 'Container fundamentals', 20, 1),
(10, 'Kubernetes Pods', 'Managing clusters and pods', 33, 2),
(11, 'PHP Fundamentals', 'Introduction to PHP development', 18, 1),
(12, 'Algorithms Basics', 'Introduction to algorithms', 26, 1);

-- Consultas

-- ============================================
-- PROYECTO SEMANAL: Funciones de Agregación
-- Semana 06 — COUNT, SUM, AVG, GROUP BY, HAVING
-- ============================================

-- NOTA: Usa el esquema de tu Semana 03. Adapta nombres al dominio.

-- ============================================
-- REPORTE 1: Totales globales
-- ============================================
-- TODO: Cuenta todos los registros y calcula suma/promedio
--       de la columna numérica más relevante de tu dominio

SELECT
    COUNT(*)     AS total_cursos,
    SUM(price)   AS suma_precios,
    AVG(price)   AS promedio_precio
FROM courses;

-- ============================================
-- REPORTE 2: Extremos
-- ============================================
-- TODO: Obtén el valor mínimo y máximo de la columna numérica

SELECT
    MIN(price) AS precio_minimo,
    MAX(price) AS precio_maximo
FROM courses;

-- ============================================
-- REPORTE 3: Subtotales por categoría (GROUP BY)
-- ============================================
-- TODO: Agrupa por la columna de categoría/tipo principal de tu dominio
--       y calcula COUNT + AVG o SUM para cada grupo

SELECT
    level,
    COUNT(*) AS total,
    AVG(price) AS promedio
FROM courses
GROUP BY level
ORDER BY total DESC;

-- ============================================
-- REPORTE 4: Filtro de grupos (HAVING)
-- ============================================
-- TODO: Muestra solo los grupos que superen un umbral de negocio

SELECT
    level,
    COUNT(*) AS total
FROM courses
GROUP BY level
HAVING COUNT(*) > umbral;
