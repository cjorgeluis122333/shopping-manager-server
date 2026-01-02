# -- 1. Extensiones (si no se usa uuid, eliminar esta línea)
# -- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
#
# -- 2. Tipos ENUM
# CREATE TYPE user_role AS ENUM ('Jefe', 'Trabajador');
# CREATE TYPE metodo_pago_type AS ENUM ('efectivo', 'transferencia');
#
# -- 3. Función para actualizar update_at
# CREATE OR REPLACE FUNCTION update_updated_at_column()
# RETURNS TRIGGER AS $$
# BEGIN
#     NEW.update_at = CURRENT_TIMESTAMP;
#     RETURN NEW;
# END;
# $$ LANGUAGE plpgsql;
#
# -- 4. Tablas de dimensión (en orden correcto, primero las referenciadas)
# -- Tabla de Tiendas
# CREATE TABLE Dim_Tienda (
#     id_tienda SERIAL PRIMARY KEY,
#     nombre_tienda VARCHAR(100) NOT NULL,
#     telefono VARCHAR(20),
#     direccion TEXT,
#     url_foto_local TEXT,
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- Tabla de Contactos (ahora después de Tienda)
# CREATE TABLE Dim_Contacto (
#     id_contacto SERIAL PRIMARY KEY,
#     id_tienda INT NOT NULL REFERENCES Dim_Tienda(id_tienda) ON DELETE CASCADE,
#     nombre_vinculo VARCHAR(50) NOT NULL,
#     url_vinculo TEXT NOT NULL,
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- Tabla de Empleados
# CREATE TABLE Dim_Empleado (
#     id_empleado SERIAL PRIMARY KEY,
#     id_tienda INT NOT NULL REFERENCES Dim_Tienda(id_tienda),
#     username VARCHAR(50) UNIQUE NOT NULL,
#     password_hash VARCHAR(255) NOT NULL,
#     nombre_completo VARCHAR(150) NOT NULL,
#     rol user_role DEFAULT 'Trabajador',
#     activo BOOLEAN DEFAULT TRUE,
#     ultimo_login TIMESTAMP,
#     intentos_fallidos INT DEFAULT 0,
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- Tabla de Productos
# CREATE TABLE Dim_Producto (
#     id_producto SERIAL PRIMARY KEY,
#     codigo_barras VARCHAR(50) UNIQUE,
#     nombre_producto VARCHAR(100) NOT NULL,
#     categoria VARCHAR(50),
#     precio_compra DECIMAL(10,2) NOT NULL,
#     precio_venta DECIMAL(10,2) NOT NULL,
#     url_imagen TEXT,
#     stock_actual INT DEFAULT 0,
#     stock_minimo INT DEFAULT 5,
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- Tabla de Tiempo
# CREATE TABLE Dim_Tiempo (
#     id_tiempo SERIAL PRIMARY KEY,
#     fecha_completa TIMESTAMP NOT NULL,
#     año INT,
#     mes INT,
#     dia INT,
#     hora INT,
#     turno VARCHAR(20),
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- Tabla de Historial de Precios
# CREATE TABLE Historial_Precios (
#     id_historial SERIAL PRIMARY KEY,
#     id_producto INT NOT NULL REFERENCES Dim_Producto(id_producto),
#     precio_anterior DECIMAL(10,2) NOT NULL,
#     precio_nuevo DECIMAL(10,2) NOT NULL,
#     fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     motivo VARCHAR(100),
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- 5. Tablas de Hechos
# CREATE TABLE Fact_Ventas (
#     id_venta SERIAL PRIMARY KEY,
#     id_tiempo INT REFERENCES Dim_Tiempo(id_tiempo),
#     id_tienda INT REFERENCES Dim_Tienda(id_tienda),
#     id_producto INT REFERENCES Dim_Producto(id_producto),
#     id_empleado INT REFERENCES Dim_Empleado(id_empleado),
#     metodo_pago VARCHAR(20) CHECK (metodo_pago IN ('efectivo', 'transferencia')) NOT NULL,
#     cantidad INT NOT NULL CHECK (cantidad > 0),
#     precio_final DECIMAL(12,2) NOT NULL,
#     total_venta DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_final) STORED,
#     create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );
#
# -- 6. Funciones y Triggers
# -- Función para completar datos de tiempo
# CREATE OR REPLACE FUNCTION funcion_completar_tiempo()
# RETURNS TRIGGER AS $$
# BEGIN
#     NEW.año := EXTRACT(YEAR FROM NEW.fecha_completa);
#     NEW.mes := EXTRACT(MONTH FROM NEW.fecha_completa);
#     NEW.dia := EXTRACT(DAY FROM NEW.fecha_completa);
#     NEW.hora := EXTRACT(HOUR FROM NEW.fecha_completa);
#
#     NEW.turno := CASE
#         WHEN NEW.hora BETWEEN 6 AND 13 THEN 'Mañana'
#         WHEN NEW.hora BETWEEN 14 AND 21 THEN 'Tarde'
#         ELSE 'Noche'
#     END;
#     RETURN NEW;
# END;
# $$ LANGUAGE plpgsql;
#
# CREATE TRIGGER tg_completar_tiempo
# BEFORE INSERT ON Dim_Tiempo
# FOR EACH ROW EXECUTE FUNCTION funcion_completar_tiempo();
#
# -- Función para actualizar stock al vender (BEFORE INSERT para evitar venta si no hay stock)
# CREATE OR REPLACE FUNCTION actualizar_stock_venta()
# RETURNS TRIGGER AS $$
# DECLARE
#     stock_actual_var INT;
# BEGIN
#     SELECT stock_actual INTO stock_actual_var
#     FROM Dim_Producto
#     WHERE id_producto = NEW.id_producto;
#
#     IF stock_actual_var < NEW.cantidad THEN
#         RAISE EXCEPTION 'Stock insuficiente para el producto ID: % (Stock: %, Solicitado: %)',
#                         NEW.id_producto, stock_actual_var, NEW.cantidad;
#     END IF;
#
#     UPDATE Dim_Producto
#     SET stock_actual = stock_actual_var - NEW.cantidad,
#         update_at = CURRENT_TIMESTAMP
#     WHERE id_producto = NEW.id_producto;
#
#     RETURN NEW;
# END;
# $$ LANGUAGE plpgsql;
#
# -- Cambiamos a BEFORE INSERT para que la venta no se inserte si no hay stock
# CREATE TRIGGER tg_actualizar_stock_venta
# BEFORE INSERT ON Fact_Ventas
# FOR EACH ROW EXECUTE FUNCTION actualizar_stock_venta();
#
# -- Función para registrar historial de precios (tanto precio_venta como precio_compra)
# CREATE OR REPLACE FUNCTION registrar_historial_precio()
# RETURNS TRIGGER AS $$
# BEGIN
#     -- Si el precio de venta cambia, registrar en historial
#     IF OLD.precio_venta IS DISTINCT FROM NEW.precio_venta THEN
#         INSERT INTO Historial_Precios (id_producto, precio_anterior, precio_nuevo, motivo)
#         VALUES (NEW.id_producto, OLD.precio_venta, NEW.precio_venta, 'Actualización de precio de venta');
#     END IF;
#
#     -- Si el precio de compra cambia, registrar en historial
#     IF OLD.precio_compra IS DISTINCT FROM NEW.precio_compra THEN
#         INSERT INTO Historial_Precios (id_producto, precio_anterior, precio_nuevo, motivo)
#         VALUES (NEW.id_producto, OLD.precio_compra, NEW.precio_compra, 'Actualización de precio de compra');
#     END IF;
#
#     RETURN NEW;
# END;
# $$ LANGUAGE plpgsql;
#
# CREATE TRIGGER tg_registrar_historial_precio
# AFTER UPDATE OF precio_venta, precio_compra ON Dim_Producto
# FOR EACH ROW EXECUTE FUNCTION registrar_historial_precio();
#
# -- Función para verificar stock mínimo
# CREATE OR REPLACE FUNCTION verificar_stock_minimo()
# RETURNS TRIGGER AS $$
# BEGIN
#     -- Notificar si el stock está por debajo del mínimo
#     IF NEW.stock_actual <= NEW.stock_minimo THEN
#         RAISE NOTICE 'ALERTA: Producto "%" (ID: %) tiene stock bajo: % (Mínimo: %)',
#                      NEW.nombre_producto, NEW.id_producto, NEW.stock_actual, NEW.stock_minimo;
#     END IF;
#
#     RETURN NEW;
# END;
# $$ LANGUAGE plpgsql;
#
# CREATE TRIGGER tg_verificar_stock_minimo
# AFTER UPDATE OF stock_actual ON Dim_Producto
# FOR EACH ROW EXECUTE FUNCTION verificar_stock_minimo();
#
# -- Triggers de auditoría (update_at)
# CREATE TRIGGER tg_update_producto
# BEFORE UPDATE ON Dim_Producto
# FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
#
# CREATE TRIGGER tg_update_tienda
# BEFORE UPDATE ON Dim_Tienda
# FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
#
# CREATE TRIGGER tg_update_empleado
# BEFORE UPDATE ON Dim_Empleado
# FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
#
# CREATE TRIGGER tg_update_contacto
# BEFORE UPDATE ON Dim_Contacto
# FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
#
# -- 7. Procedimientos almacenados
# -- Procedimiento para registrar una venta (usa la tienda del empleado)
# CREATE OR REPLACE PROCEDURE registrar_venta(
#     _id_producto INT,
#     _id_empleado INT,
#     _cantidad INT,
#     _metodo_pago VARCHAR(20)
# )
# LANGUAGE plpgsql
# AS $$
# DECLARE
#     _id_tienda INT;
#     _id_tiempo INT;
#     _precio_actual DECIMAL(12,2);
# BEGIN
#     -- Obtener la tienda del empleado
#     SELECT id_tienda INTO _id_tienda
#     FROM Dim_Empleado
#     WHERE id_empleado = _id_empleado;
#
#     IF NOT FOUND THEN
#         RAISE EXCEPTION 'Empleado no encontrado';
#     END IF;
#
#     -- Validar método de pago
#     IF _metodo_pago NOT IN ('efectivo', 'transferencia') THEN
#         RAISE EXCEPTION 'Método de pago inválido. Use "efectivo" o "transferencia"';
#     END IF;
#
#     -- Verificar stock (ya lo hará el trigger, pero podemos hacerlo antes para dar un mensaje más claro)
#     IF (SELECT stock_actual FROM Dim_Producto WHERE id_producto = _id_producto) < _cantidad THEN
#         RAISE EXCEPTION 'Stock insuficiente. Disponible: %, Solicitado: %',
#                         (SELECT stock_actual FROM Dim_Producto WHERE id_producto = _id_producto),
#                         _cantidad;
#     END IF;
#
#     -- Obtener precio actual del producto
#     SELECT precio_venta INTO _precio_actual
#     FROM Dim_Producto
#     WHERE id_producto = _id_producto;
#
#     -- Insertar tiempo actual y obtener ID
#     INSERT INTO Dim_Tiempo (fecha_completa)
#     VALUES (CURRENT_TIMESTAMP)
#     RETURNING id_tiempo INTO _id_tiempo;
#
#     -- Insertar venta
#     INSERT INTO Fact_Ventas (id_tiempo, id_tienda, id_producto, id_empleado,
#                            metodo_pago, cantidad, precio_final)
#     VALUES (_id_tiempo, _id_tienda, _id_producto, _id_empleado,
#             _metodo_pago, _cantidad, _precio_actual);
#
#     RAISE NOTICE 'Venta registrada exitosamente. Total: %', (_cantidad * _precio_actual);
# END;
# $$;
#
# -- Procedimiento para ajustar stock
# CREATE OR REPLACE PROCEDURE ajustar_stock(
#     _id_producto INT,
#     _nuevo_stock INT
# )
# LANGUAGE plpgsql
# AS $$
# BEGIN
#     UPDATE Dim_Producto
#     SET stock_actual = _nuevo_stock,
#         update_at = CURRENT_TIMESTAMP
#     WHERE id_producto = _id_producto;
#
#     IF NOT FOUND THEN
#         RAISE EXCEPTION 'Producto no encontrado';
#     END IF;
#
#     RAISE NOTICE 'Stock ajustado. Producto ID: %, Nuevo stock: %', _id_producto, _nuevo_stock;
# END;
# $$;
#
# -- Procedimiento para actualizar precio de producto
# CREATE OR REPLACE PROCEDURE actualizar_precio_producto(
#     _id_producto INT,
#     _nuevo_precio DECIMAL(10,2),
#     _motivo VARCHAR(100) DEFAULT 'Ajuste de precio'
# )
# LANGUAGE plpgsql
# AS $$
# DECLARE
#     _precio_anterior DECIMAL(10,2);
# BEGIN
#     -- Obtener precio anterior
#     SELECT precio_venta INTO _precio_anterior
#     FROM Dim_Producto
#     WHERE id_producto = _id_producto;
#
#     IF NOT FOUND THEN
#         RAISE EXCEPTION 'Producto no encontrado';
#     END IF;
#
#     -- Actualizar precio
#     UPDATE Dim_Producto
#     SET precio_venta = _nuevo_precio,
#         update_at = CURRENT_TIMESTAMP
#     WHERE id_producto = _id_producto;
#
#     -- El historial se registrará automáticamente por el trigger
#
#     RAISE NOTICE 'Precio actualizado. Producto ID: %, Precio anterior: %, Precio nuevo: %',
#                  _id_producto, _precio_anterior, _nuevo_precio;
# END;
# $$;
#
# -- 8. Índices
# -- Índices para tablas de hechos
# CREATE INDEX idx_fact_ventas_tiempo ON Fact_Ventas(id_tiempo);
# CREATE INDEX idx_fact_ventas_producto ON Fact_Ventas(id_producto);
# CREATE INDEX idx_fact_ventas_tienda ON Fact_Ventas(id_tienda);
# CREATE INDEX idx_fact_ventas_empleado ON Fact_Ventas(id_empleado);
# CREATE INDEX idx_fact_ventas_fecha ON Fact_Ventas(create_at);
# CREATE INDEX idx_fact_ventas_metodo_pago ON Fact_Ventas(metodo_pago);
#
# -- Índices para tablas de dimensión
# CREATE INDEX idx_producto_codigo ON Dim_Producto(codigo_barras);
# CREATE INDEX idx_producto_categoria ON Dim_Producto(categoria);
# CREATE INDEX idx_producto_stock ON Dim_Producto(stock_actual) WHERE stock_actual <= stock_minimo;
# CREATE INDEX idx_producto_precio ON Dim_Producto(precio_venta);
#
# CREATE INDEX idx_empleado_tienda ON Dim_Empleado(id_tienda);
# CREATE INDEX idx_empleado_rol ON Dim_Empleado(rol);
# CREATE INDEX idx_empleado_username ON Dim_Empleado(username);
# CREATE INDEX idx_empleado_activo ON Dim_Empleado(activo) WHERE activo = TRUE;
#
# CREATE INDEX idx_tienda_nombre ON Dim_Tienda(nombre_tienda);
#
# CREATE INDEX idx_contacto_tienda ON Dim_Contacto(id_tienda);
#
# CREATE INDEX idx_tiempo_fecha ON Dim_Tiempo(fecha_completa);
# CREATE INDEX idx_tiempo_año_mes ON Dim_Tiempo(año, mes);
# CREATE INDEX idx_tiempo_turno ON Dim_Tiempo(turno);
#
# -- Índices para historial de precios
# CREATE INDEX idx_historial_producto ON Historial_Precios(id_producto);
# CREATE INDEX idx_historial_fecha ON Historial_Precios(fecha_cambio);
#
# -- 9. Vistas
# -- Vista Reportes Mensuales (sin agrupar por turno, si no se desea)
# CREATE OR REPLACE VIEW Vista_Reporte_Mensual AS
# SELECT
#     t.nombre_tienda,
#     tm.año,
#     tm.mes,
#     COUNT(v.id_venta) AS total_transacciones,
#     SUM(v.cantidad) AS unidades_vendidas,
#     SUM(v.total_venta) AS ingresos_totales,
#     ROUND(AVG(v.total_venta), 2) AS promedio_venta,
#     COUNT(DISTINCT v.id_empleado) AS empleados_activos,
#     SUM(CASE WHEN v.metodo_pago = 'efectivo' THEN v.total_venta ELSE 0 END) AS efectivo_total,
#     SUM(CASE WHEN v.metodo_pago = 'transferencia' THEN v.total_venta ELSE 0 END) AS transferencia_total
# FROM Fact_Ventas v
# JOIN Dim_Tienda t ON v.id_tienda = t.id_tienda
# JOIN Dim_Tiempo tm ON v.id_tiempo = tm.id_tiempo
# GROUP BY t.nombre_tienda, tm.año, tm.mes
# ORDER BY tm.año DESC, tm.mes DESC, t.nombre_tienda;
#
# -- Vista de Productos Más Vendidos
# CREATE OR REPLACE VIEW Vista_Productos_Mas_Vendidos AS
# SELECT
#     p.nombre_producto,
#     p.categoria,
#     COUNT(v.id_venta) AS veces_vendido,
#     SUM(v.cantidad) AS unidades_vendidas,
#     SUM(v.total_venta) AS ingresos_generados,
#     p.stock_actual,
#     p.stock_minimo,
#     CASE
#         WHEN p.stock_actual <= p.stock_minimo THEN 'BAJO'
#         ELSE 'NORMAL'
#     END AS estado_stock
# FROM Fact_Ventas v
# JOIN Dim_Producto p ON v.id_producto = p.id_producto
# GROUP BY p.id_producto, p.nombre_producto, p.categoria, p.stock_actual, p.stock_minimo
# ORDER BY unidades_vendidas DESC;
#
# -- Vista de Ventas por Empleado
# CREATE OR REPLACE VIEW Vista_Ventas_Empleado AS
# SELECT
#     e.nombre_completo,
#     e.rol,
#     t.nombre_tienda,
#     COUNT(v.id_venta) AS total_ventas,
#     SUM(v.cantidad) AS unidades_vendidas,
#     SUM(v.total_venta) AS monto_total,
#     ROUND(AVG(v.total_venta), 2) AS promedio_venta,
#     MAX(v.create_at) AS ultima_venta
# FROM Fact_Ventas v
# JOIN Dim_Empleado e ON v.id_empleado = e.id_empleado
# JOIN Dim_Tienda t ON v.id_tienda = t.id_tienda
# GROUP BY e.nombre_completo, e.rol, t.nombre_tienda
# ORDER BY monto_total DESC;
#
# -- Vista de Stock Bajo
# CREATE OR REPLACE VIEW Vista_Stock_Bajo AS
# SELECT
#     p.nombre_producto,
#     p.categoria,
#     p.stock_actual,
#     p.stock_minimo,
#     p.precio_venta,
#     p.precio_compra,
#     ROUND((p.precio_venta - p.precio_compra) / p.precio_compra * 100, 2) AS margen_porcentaje,
#     CASE
#         WHEN p.stock_actual = 0 THEN 'AGOTADO'
#         WHEN p.stock_actual <= p.stock_minimo THEN 'BAJO'
#         ELSE 'SUFICIENTE'
#     END AS estado
# FROM Dim_Producto p
# WHERE p.stock_actual <= p.stock_minimo
# ORDER BY p.stock_actual ASC;
#
# -- Vista de Historial de Precios
# CREATE OR REPLACE VIEW Vista_Historial_Precios AS
# SELECT
#     p.nombre_producto,
#     p.categoria,
#     hp.precio_anterior,
#     hp.precio_nuevo,
#     hp.fecha_cambio,
#     hp.motivo,
#     ROUND(((hp.precio_nuevo - hp.precio_anterior) / hp.precio_anterior * 100), 2) AS porcentaje_cambio
# FROM Historial_Precios hp
# JOIN Dim_Producto p ON hp.id_producto = p.id_producto
# ORDER BY hp.fecha_cambio DESC;
#
# -- 10. Funciones adicionales
# -- Función para obtener estadísticas rápidas del día
# CREATE OR REPLACE FUNCTION obtener_estadisticas_dia(_fecha DATE DEFAULT CURRENT_DATE)
# RETURNS TABLE (
#     total_ventas DECIMAL(12,2),
#     total_transacciones BIGINT,
#     promedio_venta DECIMAL(12,2),
#     producto_mas_vendido VARCHAR(100),
#     empleado_destacado VARCHAR(150)
# ) AS $$
# BEGIN
#     RETURN QUERY
#     WITH ventas_dia AS (
#         SELECT
#             COALESCE(SUM(v.total_venta), 0) as total,
#             COUNT(v.id_venta) as count
#         FROM Fact_Ventas v
#         JOIN Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
#         WHERE t.fecha_completa::DATE = _fecha
#     ),
#     producto_top AS (
#         SELECT p.nombre_producto
#         FROM Fact_Ventas v
#         JOIN Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
#         JOIN Dim_Producto p ON v.id_producto = p.id_producto
#         WHERE t.fecha_completa::DATE = _fecha
#         GROUP BY p.nombre_producto
#         ORDER BY SUM(v.cantidad) DESC
#         LIMIT 1
#     ),
#     empleado_top AS (
#         SELECT e.nombre_completo
#         FROM Fact_Ventas v
#         JOIN Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
#         JOIN Dim_Empleado e ON v.id_empleado = e.id_empleado
#         WHERE t.fecha_completa::DATE = _fecha
#         GROUP BY e.nombre_completo
#         ORDER BY SUM(v.total_venta) DESC
#         LIMIT 1
#     )
#     SELECT
#         vd.total,
#         vd.count,
#         CASE
#             WHEN vd.count > 0 THEN ROUND(vd.total / vd.count, 2)
#             ELSE 0
#         END,
#         COALESCE((SELECT nombre_producto FROM producto_top), 'Sin ventas'),
#         COALESCE((SELECT nombre_completo FROM empleado_top), 'Sin ventas')
#     FROM ventas_dia vd;
# END;
# $$ LANGUAGE plpgsql;
#
# -- Función para verificar integridad de datos
# CREATE OR REPLACE FUNCTION verificar_integridad()
# RETURNS TABLE (tabla VARCHAR, registros BIGINT, problema TEXT) AS $$
# BEGIN
#     RETURN QUERY
#     SELECT 'Dim_Producto' as tabla, COUNT(*)::BIGINT,
#            CASE
#                WHEN COUNT(*) FILTER (WHERE stock_actual < 0) > 0
#                THEN 'Productos con stock negativo'
#                ELSE 'OK'
#            END
#     FROM Dim_Producto
#
#     UNION ALL
#
#     SELECT 'Fact_Ventas' as tabla, COUNT(*)::BIGINT,
#            CASE
#                WHEN COUNT(*) FILTER (WHERE cantidad <= 0) > 0
#                THEN 'Ventas con cantidad <= 0'
#                ELSE 'OK'
#            END
#     FROM Fact_Ventas;
# END;
# $$ LANGUAGE plpgsql;
#
# -- Función para iniciar sesión
# CREATE OR REPLACE FUNCTION iniciar_sesion(
#     _username VARCHAR(50),
#     _password_hash VARCHAR(255)
# )
# RETURNS TABLE (
#     id_empleado INT,
#     id_tienda INT,
#     nombre_tienda VARCHAR(100),
#     nombre_completo VARCHAR(150),
#     rol user_role,
#     autenticado BOOLEAN
# ) AS $$
# BEGIN
#     RETURN QUERY
#     SELECT
#         e.id_empleado,
#         e.id_tienda,
#         t.nombre_tienda,
#         e.nombre_completo,
#         e.rol,
#         (e.password_hash = _password_hash AND e.activo = TRUE) as autenticado
#     FROM Dim_Empleado e
#     JOIN Dim_Tienda t ON e.id_tienda = t.id_tienda
#     WHERE e.username = _username;
# END;
# $$ LANGUAGE plpgsql;
#
# -- 11. Datos de ejemplo (actualizados)
# INSERT INTO Dim_Tienda (nombre_tienda, telefono, direccion)
# VALUES
# ('Tienda Central', '123456789', 'Av. Principal 123'),
# ('Sucursal Norte', '987654321', 'Av. Norte 456');
#
# -- Nota: Los password_hash deben ser generados por el backend con bcrypt o similar.
# -- Aquí se usan placeholders, en producción deben ser hashes reales.
# INSERT INTO Dim_Empleado (id_tienda, username, password_hash, nombre_completo, rol)
# VALUES
# (1, 'jperez', '$2b$10$EjemploHashParaJuanPerez', 'Juan Pérez', 'Jefe'),
# (1, 'mgarcia', '$2b$10$EjemploHashParaMariaGarcia', 'María García', 'Trabajador'),
# (2, 'clopez', '$2b$10$EjemploHashParaCarlosLopez', 'Carlos López', 'Trabajador');
#
# INSERT INTO Dim_Producto (codigo_barras, nombre_producto, categoria, precio_compra, precio_venta, stock_actual, stock_minimo)
# VALUES
# ('7501001234567', 'Laptop HP', 'Electrónica', 1500.00, 2000.00, 10, 2),
# ('7501001234568', 'Mouse Inalámbrico', 'Electrónica', 20.00, 35.00, 50, 10),
# ('7501001234569', 'Camiseta Básica', 'Ropa', 15.00, 30.00, 100, 20),
# ('7501001234570', 'Arroz 5kg', 'Alimentos', 10.00, 15.00, 5, 50);
#
# INSERT INTO Dim_Contacto (id_tienda, nombre_vinculo, url_vinculo)
# VALUES
# (1, 'WhatsApp', 'https://wa.me/123456789'),
# (1, 'Sitio Web', 'https://tiendacentral.com'),
# (2, 'WhatsApp', 'https://wa.me/987654321');
#
# -- Registrar algunas ventas de ejemplo
# CALL registrar_venta(1, 1, 2, 'efectivo');
# CALL registrar_venta(2, 2, 5, 'transferencia');
# CALL registrar_venta(3, 3, 3, 'efectivo');