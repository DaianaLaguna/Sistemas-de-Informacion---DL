-- Crear la tabla principal (reaseguro_data)
CREATE TABLE reaseguro_data (
    tipo_seguro TEXT,
    asegurado TEXT,
    poliza_endoso TEXT,
    vig_desde DATE,
    vig_hasta DATE,
    suma_asegurada NUMERIC, 
    prima_emitida NUMERIC,  
    comisiones NUMERIC,     
    porc_comis_fronting NUMERIC,
    comisiones_fronting NUMERIC,
    reasegurador TEXT,
    nombre_programa TEXT,
    referencia TEXT,
    cotizacion_moneda TEXT,
    nro_core TEXT
);

-- Luego de importar los datos a la tabla, verificamos la carga. 
SELECT * 
FROM public.reaseguro_data;

-- Crear tabla para HD (Pesos)
CREATE TABLE reaseguro_hd_pesos AS
SELECT *
FROM public.reaseguro_data
WHERE 
    LOWER(reasegurador) = 'hd'
    AND CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1;

-- Visualizar los datos creados en la nueva tabla
SELECT * 
FROM reaseguro_hd_pesos
ORDER BY EXTRACT(YEAR FROM vig_desde), poliza_endoso;

-- Crear tabla para HD (USD)
CREATE TABLE reaseguro_hd_usd AS
SELECT *
FROM public.reaseguro_data
WHERE 
    LOWER(reasegurador) = 'hd'
    AND CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1;

-- Visualizar los datos creados en la nueva tabla
SELECT * 
FROM reaseguro_hd_usd
ORDER BY EXTRACT(YEAR FROM vig_desde), poliza_endoso;

-- Crear tabla para almacenar los datos en pesos de AXA XL
CREATE TABLE reaseguro_ax_pesos AS
SELECT *
FROM public.reaseguro_data
WHERE 
    LOWER(reasegurador) = 'ax'
    AND CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1;

-- Verificar los datos creados en la tabla de AXA XL en pesos
SELECT * 
FROM reaseguro_ax_pesos
ORDER BY EXTRACT(YEAR FROM vig_desde), poliza_endoso;

-- Crear tabla para almacenar los datos en USD de AXA XL
CREATE TABLE reaseguro_ax_usd AS
SELECT *
FROM public.reaseguro_data
WHERE 
    LOWER(reasegurador) = 'ax'
    AND CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1;

-- Verificar los datos creados en la tabla de AXA XL en USD
SELECT * 
FROM reaseguro_ax_usd
ORDER BY EXTRACT(YEAR FROM vig_desde), poliza_endoso;

-- Verificar las tablas existentes en el esquema público
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Consultas particulares por caso. 
-- Total de pólizas HD (pesos)
SELECT COUNT(*) AS total_registros FROM reaseguro_hd_pesos;

-- Total de pólizas HD (pesos) por año
SELECT EXTRACT(YEAR FROM vig_desde) AS año, COUNT(*) AS total
FROM reaseguro_hd_pesos
GROUP BY año
ORDER BY año;

-- Total de pólizas HD (USD)
SELECT COUNT(*) AS total_registros 
FROM reaseguro_hd_usd;

-- Total de pólizas HD (USD) por año
SELECT EXTRACT(YEAR FROM vig_desde) AS año, COUNT(*) AS total
FROM reaseguro_hd_usd
GROUP BY año
ORDER BY año;

-- Total de pólizas AX (Pesos)
SELECT COUNT(*) AS total_registros 
FROM reaseguro_ax_pesos;

-- Total de pólizas AX (Pesos) por año
SELECT EXTRACT(YEAR FROM vig_desde) AS año, COUNT(*) AS total
FROM reaseguro_ax_pesos
GROUP BY año
ORDER BY año;

-- Total de pólizas AX (USD)
SELECT COUNT(*) AS total_registros 
FROM reaseguro_ax_usd;

-- Total de pólizas AX (USD) por año
SELECT EXTRACT(YEAR FROM vig_desde) AS año, COUNT(*) AS total
FROM reaseguro_ax_usd
GROUP BY año
ORDER BY año;

-- Luego realizamos una consulta para obtener todos los casos de reaseguradores clasificados por tipo de moneda
SELECT
    reasegurador AS grupo_reaseguradora,
    EXTRACT(YEAR FROM vig_desde) AS año,
    prima_emitida,
    cotizacion_moneda,
    CASE
        WHEN CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1 THEN 'Cotización = 1 (Pesos)'
        WHEN CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1 THEN 'Cotización > 1 (USD)'
    END AS tipo_cotizacion
FROM public.reaseguro_data
WHERE (LOWER(reasegurador) = 'hd' OR LOWER(reasegurador) = 'ax')
AND (
    CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1 OR
    CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1
)
ORDER BY grupo_reaseguradora, año, tipo_cotizacion;

-- Concluyendo el análisis, agrupamos primas por reaseguradora (HD y AX) y año, con distinción de moneda (Pesos y USD)
SELECT
    reasegurador AS grupo_reaseguradora,
    EXTRACT(YEAR FROM vig_desde) AS año,
    CASE
        WHEN CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1 THEN 'Pesos'
        WHEN CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1 THEN 'USD'
    END AS tipo_moneda,
    SUM(prima_emitida) AS total_prima_emitida
FROM public.reaseguro_data
WHERE (LOWER(reasegurador) = 'hd' OR LOWER(reasegurador) = 'ax')
AND (
    CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) = 1 OR
    CAST(REPLACE(cotizacion_moneda, ',', '.') AS NUMERIC) > 1
)
GROUP BY grupo_reaseguradora, año, tipo_moneda
ORDER BY grupo_reaseguradora, año, tipo_moneda;
