-- =====================================================
-- BASE DE DATOS: Encuestas de Polos de Desarrollo
-- Plan México - Noviembre 2025
-- Para Supabase (PostgreSQL)
-- =====================================================

-- =====================================================
-- TABLA: Polos de Desarrollo (18 polos reales)
-- =====================================================
DROP TABLE IF EXISTS respuestas CASCADE;
DROP TABLE IF EXISTS polos CASCADE;

CREATE TABLE polos (
    id INT PRIMARY KEY,
    estado VARCHAR(50) NOT NULL,
    polo VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar los 18 polos reales desde data.json
INSERT INTO polos (id, estado, polo, tipo, descripcion) VALUES
(1,  'Sonora',      'Golfo de California / Hermosillo',  'energy',    'Hub de Electromovilidad y Semiconductores.'),
(2,  'Sonora',      'Plan Sonora (Puerto Peñasco)',      'energy',    'Corazón Energético del Plan Nacional.'),
(3,  'Tamaulipas',  'Nuevo Laredo',                      'logistics', 'Aduana Terrestre #1 de América.'),
(4,  'Tamaulipas',  'Puerto Seco / Golfo',               'logistics', 'Conectividad marítima Europa/Costa Este.'),
(5,  'Puebla',      'Centro',                            'industry',  'Transición a Electromovilidad (VW/Audi).'),
(6,  'Durango',     'Durango Capital',                   'industry',  'Minería y Valor Agregado.'),
(7,  'Yucatán',     'Maya (Mérida y Progreso)',          'tourism',   'Renacimiento Maya: Tech & Logistics.'),
(8,  'Coahuila',    'Norte – AHMSA',                     'industry',  'Acero para la Industria Nacional.'),
(9,  'Coahuila',    'Piedras Negras',                    'logistics', 'Cruce Ferroviario Estratégico.'),
(10, 'Nuevo León',  'Colombia / Frontera',               'industry',  'Hub de Nearshoring Tecnológico.'),
(11, 'Chihuahua',   'Norte (Región Multinodal)',         'industry',  'Manufactura de Exportación.'),
(12, 'Guanajuato',  'Bajío (Celaya)',                    'industry',  'Puerto Seco del Bajío.'),
(13, 'Edomex',      'AIFA (Corredor)',                   'logistics', 'Hub de Carga Aérea Central.'),
(14, 'CDMX',        'Polígono AIFA (Zona Metro)',        'logistics', 'Servicios Corporativos.'),
(15, 'Oaxaca',      'Istmo (Salina Cruz)',               'logistics', 'Puerta al Pacífico (Corredor Interoceánico).'),
(16, 'Veracruz',    'Istmo (Coatzacoalcos)',             'logistics', 'Puerta al Atlántico (Corredor Interoceánico).'),
(17, 'Tabasco',     'Istmo (Polo Sur)',                  'energy',    'Soberanía Energética.'),
(18, 'Campeche',    'Maya / Regiones SE',                'tourism',   'Turismo y Economía Verde.');

-- =====================================================
-- TABLA: Respuestas de Encuestas
-- =====================================================
CREATE TABLE respuestas (
    id SERIAL PRIMARY KEY,
    polo_id INT NOT NULL REFERENCES polos(id),
    
    -- Pregunta 1 (0-10): ¿Qué tan clara te pareció la información sobre este polo?
    pregunta_1_claridad INT NOT NULL CHECK (pregunta_1_claridad >= 0 AND pregunta_1_claridad <= 10),
    
    -- Pregunta 2 (0-10): ¿Consideras que este polo traerá beneficios reales a tu región?
    pregunta_2_beneficios INT NOT NULL CHECK (pregunta_2_beneficios >= 0 AND pregunta_2_beneficios <= 10),
    
    -- Pregunta 3 (0-10): ¿Qué aspectos crees que necesitan mejorar?
    pregunta_3_mejoras INT NOT NULL CHECK (pregunta_3_mejoras >= 0 AND pregunta_3_mejoras <= 10),
    
    -- Pregunta 4 (Abierta): ¿Tienes alguna recomendación específica sobre este polo?
    pregunta_4_recomendacion TEXT,
    
    -- Metadatos
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- VISTA: Promedio por Polo (General y por Pregunta)
-- =====================================================
DROP VIEW IF EXISTS vista_promedios_polos;
CREATE VIEW vista_promedios_polos AS
SELECT 
    p.id AS polo_id,
    p.estado,
    p.polo AS polo_nombre,
    p.tipo,
    p.descripcion,
    COUNT(r.id) AS total_respuestas,
    
    -- Promedios por pregunta
    ROUND(AVG(r.pregunta_1_claridad)::numeric, 2) AS promedio_claridad,
    ROUND(AVG(r.pregunta_2_beneficios)::numeric, 2) AS promedio_beneficios,
    ROUND(AVG(r.pregunta_3_mejoras)::numeric, 2) AS promedio_mejoras,
    
    -- Promedio general del polo
    ROUND(
        ((COALESCE(AVG(r.pregunta_1_claridad), 0) + COALESCE(AVG(r.pregunta_2_beneficios), 0) + COALESCE(AVG(r.pregunta_3_mejoras), 0)) / 3)::numeric, 
        2
    ) AS promedio_general
    
FROM polos p
LEFT JOIN respuestas r ON p.id = r.polo_id
GROUP BY p.id, p.estado, p.polo, p.tipo, p.descripcion;

-- =====================================================
-- VISTA: Resumen General
-- =====================================================
DROP VIEW IF EXISTS vista_resumen_general;
CREATE VIEW vista_resumen_general AS
SELECT 
    COUNT(DISTINCT polo_id) AS total_polos_evaluados,
    COUNT(*) AS total_respuestas,
    ROUND(AVG(pregunta_1_claridad)::numeric, 2) AS promedio_global_claridad,
    ROUND(AVG(pregunta_2_beneficios)::numeric, 2) AS promedio_global_beneficios,
    ROUND(AVG(pregunta_3_mejoras)::numeric, 2) AS promedio_global_mejoras,
    ROUND(
        ((AVG(pregunta_1_claridad) + AVG(pregunta_2_beneficios) + AVG(pregunta_3_mejoras)) / 3)::numeric,
        2
    ) AS promedio_global_general
FROM respuestas;

-- =====================================================
-- VISTA: Recomendaciones por Polo
-- =====================================================
DROP VIEW IF EXISTS vista_recomendaciones;
CREATE VIEW vista_recomendaciones AS
SELECT 
    p.id AS polo_id,
    p.estado,
    p.polo AS polo_nombre,
    r.pregunta_4_recomendacion AS recomendacion,
    r.created_at AS fecha
FROM respuestas r
JOIN polos p ON r.polo_id = p.id
WHERE r.pregunta_4_recomendacion IS NOT NULL 
  AND r.pregunta_4_recomendacion != ''
ORDER BY r.created_at DESC;

-- =====================================================
-- VISTA: Promedios por Estado
-- =====================================================
DROP VIEW IF EXISTS vista_promedios_estado;
CREATE VIEW vista_promedios_estado AS
SELECT 
    p.estado,
    COUNT(DISTINCT p.id) AS total_polos,
    COUNT(r.id) AS total_respuestas,
    ROUND(AVG(r.pregunta_1_claridad)::numeric, 2) AS promedio_claridad,
    ROUND(AVG(r.pregunta_2_beneficios)::numeric, 2) AS promedio_beneficios,
    ROUND(AVG(r.pregunta_3_mejoras)::numeric, 2) AS promedio_mejoras,
    ROUND(
        ((COALESCE(AVG(r.pregunta_1_claridad), 0) + COALESCE(AVG(r.pregunta_2_beneficios), 0) + COALESCE(AVG(r.pregunta_3_mejoras), 0)) / 3)::numeric,
        2
    ) AS promedio_general
FROM polos p
LEFT JOIN respuestas r ON p.id = r.polo_id
GROUP BY p.estado
ORDER BY promedio_general DESC;

-- =====================================================
-- VISTA: Promedios por Tipo de Polo
-- =====================================================
DROP VIEW IF EXISTS vista_promedios_tipo;
CREATE VIEW vista_promedios_tipo AS
SELECT 
    p.tipo,
    COUNT(DISTINCT p.id) AS total_polos,
    COUNT(r.id) AS total_respuestas,
    ROUND(AVG(r.pregunta_1_claridad)::numeric, 2) AS promedio_claridad,
    ROUND(AVG(r.pregunta_2_beneficios)::numeric, 2) AS promedio_beneficios,
    ROUND(AVG(r.pregunta_3_mejoras)::numeric, 2) AS promedio_mejoras,
    ROUND(
        ((COALESCE(AVG(r.pregunta_1_claridad), 0) + COALESCE(AVG(r.pregunta_2_beneficios), 0) + COALESCE(AVG(r.pregunta_3_mejoras), 0)) / 3)::numeric,
        2
    ) AS promedio_general
FROM polos p
LEFT JOIN respuestas r ON p.id = r.polo_id
GROUP BY p.tipo
ORDER BY promedio_general DESC;

-- =====================================================
-- DATOS DE EJEMPLO (Para pruebas)
-- =====================================================
INSERT INTO respuestas (polo_id, pregunta_1_claridad, pregunta_2_beneficios, pregunta_3_mejoras, pregunta_4_recomendacion) VALUES
-- Sonora
(1, 8, 9, 7, 'Mejorar la comunicación con comunidades locales'),
(1, 7, 8, 6, 'Más información sobre empleos disponibles'),
(2, 9, 10, 8, 'Excelente proyecto de energía renovable'),
-- Tamaulipas
(3, 7, 8, 5, 'Agilizar más los cruces fronterizos'),
(4, 6, 7, 8, 'Mejorar infraestructura portuaria'),
-- Puebla
(5, 8, 9, 7, 'Capacitación para trabajadores automotrices'),
-- Durango
(6, 7, 7, 6, NULL),
-- Yucatán
(7, 9, 9, 8, 'Muy buen proyecto para el sureste'),
-- Coahuila
(8, 6, 7, 7, 'Modernizar la planta siderúrgica'),
(9, 8, 8, 7, 'Ampliar capacidad ferroviaria'),
-- Nuevo León
(10, 10, 10, 9, 'El mejor proyecto de nearshoring'),
-- Chihuahua
(11, 8, 8, 7, 'Más apoyo a proveedores locales'),
-- Guanajuato
(12, 7, 8, 6, 'Mejorar conexión con otros estados'),
-- Edomex y CDMX
(13, 8, 9, 7, 'Acelerar desarrollo del AIFA'),
(14, 7, 7, 6, NULL),
-- Oaxaca y Veracruz (Istmo)
(15, 9, 10, 8, 'Proyecto clave para el desarrollo del sur'),
(16, 8, 9, 7, 'Conectar mejor con comunidades locales'),
-- Tabasco
(17, 7, 8, 7, 'Transición a energías limpias'),
-- Campeche
(18, 8, 8, 8, 'Proteger el medio ambiente');

-- =====================================================
-- HABILITAR RLS (Row Level Security) para Supabase
-- =====================================================
ALTER TABLE polos ENABLE ROW LEVEL SECURITY;
ALTER TABLE respuestas ENABLE ROW LEVEL SECURITY;

-- Política para leer polos (público)
CREATE POLICY "Polos son públicos" ON polos FOR SELECT USING (true);

-- Política para leer respuestas (público)
CREATE POLICY "Respuestas son públicas para lectura" ON respuestas FOR SELECT USING (true);

-- Política para insertar respuestas (público - cualquiera puede responder)
CREATE POLICY "Cualquiera puede responder encuestas" ON respuestas FOR INSERT WITH CHECK (true);
