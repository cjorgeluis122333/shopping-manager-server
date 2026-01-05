# Shopping Manager Server - Documentación de Endpoints API

**Versión:** 1.0.0  
**Base URL:** `http://localhost:8080/api`  
**Última Actualización:** Enero 2026

---

## Tabla de Contenidos

1. [Autenticación](#autenticación)
2. [Tiendas](#tiendas)
3. [Productos](#productos)
4. [Contactos](#contactos)
5. [Ventas](#ventas)
6. [Reportes](#reportes)

---

## Autenticación

### 1. Login

**Descripción:** Autentica un usuario y retorna un token JWT válido por 15 días.

**Método:** `POST`  
**Endpoint:** `/auth/login`  
**URL Completa:** `http://localhost:8080/api/auth/login`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "jperez",
  "password": "password123"
}
```

**Respuesta Exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJqcGVyZXoiLCJpYXQiOjE2NzA0MDAwMDAsImV4cCI6MTY3MTcwMDAwMH0.xyz...",
  "username": "jperez",
  "roles": ["ROLE_JEFE"]
}
```

**Respuesta Error (401):**
```json
{
  "error": "Unauthorized",
  "message": "Bad credentials"
}
```

**Datos de Prueba:**
- Username: `jperez` | Password: `password123` (Jefe)
- Username: `mgarcia` | Password: `password123` (Trabajador)
- Username: `clopez` | Password: `password123` (Trabajador)

---

### 2. Registro

**Descripción:** Registra un nuevo empleado en el sistema.

**Método:** `POST`  
**Endpoint:** `/auth/register`  
**URL Completa:** `http://localhost:8080/api/auth/register`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "nuevo_usuario",
  "password": "password123",
  "nombreCompleto": "Juan Nuevo",
  "rol": "Trabajador",
  "idTienda": 1
}
```

**Parámetros:**
- `username` (string, requerido): Nombre de usuario único
- `password` (string, requerido): Contraseña del usuario
- `nombreCompleto` (string, requerido): Nombre completo del empleado
- `rol` (string, requerido): Rol del empleado (`Jefe` o `Trabajador`)
- `idTienda` (number, requerido): ID de la tienda a la que pertenece

**Respuesta Exitosa (200):**
```json
{
  "message": "User registered successfully!"
}
```

**Respuesta Error (400):**
```json
{
  "error": "Error: Username is already taken!"
}
```

---

### 3. Logout

**Descripción:** Cierra la sesión del usuario actual.

**Método:** `POST`  
**Endpoint:** `/auth/logout`  
**URL Completa:** `http://localhost:8080/api/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:** (vacío)

**Respuesta Exitosa (200):**
```json
{
  "message": "Log out successful!"
}
```

---

### 4. Refresh Token

**Descripción:** Genera un nuevo token JWT válido a partir de un token existente.

**Método:** `POST`  
**Endpoint:** `/auth/refresh-token`  
**URL Completa:** `http://localhost:8080/api/auth/refresh-token`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJqcGVyZXoiLCJpYXQiOjE2NzA0MDAwMDAsImV4cCI6MTY3MTcwMDAwMH0.xyz..."
}
```

**Respuesta Exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJqcGVyZXoiLCJpYXQiOjE2NzA0MDAwMDAsImV4cCI6MTY3MTcwMDAwMH0.abc..."
}
```

**Respuesta Error (400):**
```json
{
  "error": "Invalid token"
}
```

---

## Tiendas

### 1. Listar Todas las Tiendas

**Descripción:** Obtiene la lista de todas las tiendas registradas en el sistema.

**Método:** `GET`  
**Endpoint:** `/tiendas`  
**URL Completa:** `http://localhost:8080/api/tiendas`

**Headers:**
```
Accept: application/json
```

**Parámetros:** Ninguno

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "nombreTienda": "Tienda Central",
    "telefono": "123456789",
    "direccion": "Av. Principal 123",
    "urlFotoLocal": null,
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  },
  {
    "id": 2,
    "nombreTienda": "Sucursal Norte",
    "telefono": "987654321",
    "direccion": "Av. Norte 456",
    "urlFotoLocal": null,
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  }
]
```

---

### 2. Obtener Tienda por ID

**Descripción:** Obtiene los detalles de una tienda específica.

**Método:** `GET`  
**Endpoint:** `/tiendas/{id}`  
**URL Completa:** `http://localhost:8080/api/tiendas/1`

**Headers:**
```
Accept: application/json
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID de la tienda

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "nombreTienda": "Tienda Central",
  "telefono": "123456789",
  "direccion": "Av. Principal 123",
  "urlFotoLocal": null,
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-02T11:43:00"
}
```

**Respuesta Error (404):**
```json
{
  "error": "Not Found"
}
```

---

### 3. Crear Tienda

**Descripción:** Crea una nueva tienda en el sistema.

**Método:** `POST`  
**Endpoint:** `/tiendas`  
**URL Completa:** `http://localhost:8080/api/tiendas`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "nombreTienda": "Tienda Este",
  "telefono": "555666777",
  "direccion": "Av. Este 789",
  "urlFotoLocal": "https://example.com/foto.jpg"
}
```

**Parámetros:**
- `nombreTienda` (string, requerido): Nombre de la tienda
- `telefono` (string, opcional): Teléfono de contacto
- `direccion` (string, opcional): Dirección de la tienda
- `urlFotoLocal` (string, opcional): URL de la foto de la tienda

**Respuesta Exitosa (200):**
```json
{
  "id": 3,
  "nombreTienda": "Tienda Este",
  "telefono": "555666777",
  "direccion": "Av. Este 789",
  "urlFotoLocal": "https://example.com/foto.jpg",
  "creatAt": "2024-01-05T10:30:00",
  "updateAt": "2024-01-05T10:30:00"
}
```

---

### 4. Actualizar Tienda

**Descripción:** Actualiza los datos de una tienda existente.

**Método:** `PUT`  
**Endpoint:** `/tiendas/{id}`  
**URL Completa:** `http://localhost:8080/api/tiendas/1`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "nombreTienda": "Tienda Central Actualizada",
  "telefono": "123456789",
  "direccion": "Av. Principal 123 - Piso 2",
  "urlFotoLocal": "https://example.com/foto-nueva.jpg"
}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID de la tienda a actualizar

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "nombreTienda": "Tienda Central Actualizada",
  "telefono": "123456789",
  "direccion": "Av. Principal 123 - Piso 2",
  "urlFotoLocal": "https://example.com/foto-nueva.jpg",
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-05T10:35:00"
}
```

---

### 5. Eliminar Tienda

**Descripción:** Elimina una tienda del sistema.

**Método:** `DELETE`  
**Endpoint:** `/tiendas/{id}`  
**URL Completa:** `http://localhost:8080/api/tiendas/3`

**Headers:**
```
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID de la tienda a eliminar

**Respuesta Exitosa (204):**
```
(sin contenido)
```

---

## Productos

### 1. Listar Todos los Productos

**Descripción:** Obtiene la lista de todos los productos registrados.

**Método:** `GET`  
**Endpoint:** `/productos`  
**URL Completa:** `http://localhost:8080/api/productos`

**Headers:**
```
Accept: application/json
```

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "codigoBarras": "7501001234567",
    "nombreProducto": "Laptop HP",
    "categoria": "Electrónica",
    "precioCompra": 1500.00,
    "precioVenta": 2000.00,
    "urlImagen": null,
    "stockActual": 10,
    "stockMinimo": 2,
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  },
  {
    "id": 2,
    "codigoBarras": "7501001234568",
    "nombreProducto": "Mouse Inalámbrico",
    "categoria": "Electrónica",
    "precioCompra": 20.00,
    "precioVenta": 35.00,
    "urlImagen": null,
    "stockActual": 50,
    "stockMinimo": 10,
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  }
]
```

---

### 2. Obtener Producto por ID

**Descripción:** Obtiene los detalles de un producto específico.

**Método:** `GET`  
**Endpoint:** `/productos/{id}`  
**URL Completa:** `http://localhost:8080/api/productos/1`

**Headers:**
```
Accept: application/json
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del producto

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "codigoBarras": "7501001234567",
  "nombreProducto": "Laptop HP",
  "categoria": "Electrónica",
  "precioCompra": 1500.00,
  "precioVenta": 2000.00,
  "urlImagen": null,
  "stockActual": 10,
  "stockMinimo": 2,
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-02T11:43:00"
}
```

---

### 3. Crear Producto

**Descripción:** Crea un nuevo producto en el sistema.

**Método:** `POST`  
**Endpoint:** `/productos`  
**URL Completa:** `http://localhost:8080/api/productos`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "codigoBarras": "7501001234571",
  "nombreProducto": "Teclado Mecánico",
  "categoria": "Electrónica",
  "precioCompra": 80.00,
  "precioVenta": 120.00,
  "urlImagen": "https://example.com/teclado.jpg",
  "stockActual": 25,
  "stockMinimo": 5
}
```

**Parámetros:**
- `codigoBarras` (string, opcional): Código de barras único
- `nombreProducto` (string, requerido): Nombre del producto
- `categoria` (string, opcional): Categoría del producto
- `precioCompra` (number, requerido): Precio de compra
- `precioVenta` (number, requerido): Precio de venta
- `urlImagen` (string, opcional): URL de la imagen del producto
- `stockActual` (number, requerido): Stock actual
- `stockMinimo` (number, requerido): Stock mínimo

**Respuesta Exitosa (200):**
```json
{
  "id": 5,
  "codigoBarras": "7501001234571",
  "nombreProducto": "Teclado Mecánico",
  "categoria": "Electrónica",
  "precioCompra": 80.00,
  "precioVenta": 120.00,
  "urlImagen": "https://example.com/teclado.jpg",
  "stockActual": 25,
  "stockMinimo": 5,
  "creatAt": "2024-01-05T10:40:00",
  "updateAt": "2024-01-05T10:40:00"
}
```

---

### 4. Actualizar Producto

**Descripción:** Actualiza los datos de un producto existente.

**Método:** `PUT`  
**Endpoint:** `/productos/{id}`  
**URL Completa:** `http://localhost:8080/api/productos/1`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "codigoBarras": "7501001234567",
  "nombreProducto": "Laptop HP Pavilion",
  "categoria": "Electrónica",
  "precioCompra": 1500.00,
  "precioVenta": 2100.00,
  "urlImagen": "https://example.com/laptop-hp.jpg",
  "stockActual": 8,
  "stockMinimo": 2
}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del producto a actualizar

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "codigoBarras": "7501001234567",
  "nombreProducto": "Laptop HP Pavilion",
  "categoria": "Electrónica",
  "precioCompra": 1500.00,
  "precioVenta": 2100.00,
  "urlImagen": "https://example.com/laptop-hp.jpg",
  "stockActual": 8,
  "stockMinimo": 2,
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-05T10:45:00"
}
```

---

### 5. Eliminar Producto

**Descripción:** Elimina un producto del sistema.

**Método:** `DELETE`  
**Endpoint:** `/productos/{id}`  
**URL Completa:** `http://localhost:8080/api/productos/5`

**Headers:**
```
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del producto a eliminar

**Respuesta Exitosa (204):**
```
(sin contenido)
```

---

## Contactos

### 1. Obtener Contactos de una Tienda

**Descripción:** Obtiene todos los contactos (redes sociales) de una tienda específica.

**Método:** `GET`  
**Endpoint:** `/contactos/tienda/{tiendaId}`  
**URL Completa:** `http://localhost:8080/api/contactos/tienda/1`

**Headers:**
```
Accept: application/json
```

**Parámetros de Ruta:**
- `tiendaId` (number, requerido): ID de la tienda

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "tienda": {
      "id": 1,
      "nombreTienda": "Tienda Central"
    },
    "nombreVinculo": "WhatsApp",
    "urlVinculo": "https://wa.me/123456789",
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  },
  {
    "id": 2,
    "tienda": {
      "id": 1,
      "nombreTienda": "Tienda Central"
    },
    "nombreVinculo": "Sitio Web",
    "urlVinculo": "https://tiendacentral.com",
    "creatAt": "2024-01-02T11:43:00",
    "updateAt": "2024-01-02T11:43:00"
  }
]
```

---

### 2. Obtener Contacto por ID

**Descripción:** Obtiene los detalles de un contacto específico.

**Método:** `GET`  
**Endpoint:** `/contactos/{id}`  
**URL Completa:** `http://localhost:8080/api/contactos/1`

**Headers:**
```
Accept: application/json
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del contacto

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "tienda": {
    "id": 1,
    "nombreTienda": "Tienda Central"
  },
  "nombreVinculo": "WhatsApp",
  "urlVinculo": "https://wa.me/123456789",
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-02T11:43:00"
}
```

---

### 3. Crear Contacto

**Descripción:** Crea un nuevo contacto (red social) para una tienda.

**Método:** `POST`  
**Endpoint:** `/contactos`  
**URL Completa:** `http://localhost:8080/api/contactos`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "tienda": {
    "id": 1
  },
  "nombreVinculo": "Facebook",
  "urlVinculo": "https://facebook.com/tiendacentral"
}
```

**Parámetros:**
- `tienda.id` (number, requerido): ID de la tienda
- `nombreVinculo` (string, requerido): Nombre del vinculo (WhatsApp, Facebook, Instagram, etc.)
- `urlVinculo` (string, requerido): URL del vinculo

**Respuesta Exitosa (200):**
```json
{
  "id": 4,
  "tienda": {
    "id": 1,
    "nombreTienda": "Tienda Central"
  },
  "nombreVinculo": "Facebook",
  "urlVinculo": "https://facebook.com/tiendacentral",
  "creatAt": "2024-01-05T10:50:00",
  "updateAt": "2024-01-05T10:50:00"
}
```

---

### 4. Actualizar Contacto

**Descripción:** Actualiza los datos de un contacto existente.

**Método:** `PUT`  
**Endpoint:** `/contactos/{id}`  
**URL Completa:** `http://localhost:8080/api/contactos/1`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "nombreVinculo": "WhatsApp Actualizado",
  "urlVinculo": "https://wa.me/123456789?text=Hola"
}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del contacto a actualizar

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "tienda": {
    "id": 1,
    "nombreTienda": "Tienda Central"
  },
  "nombreVinculo": "WhatsApp Actualizado",
  "urlVinculo": "https://wa.me/123456789?text=Hola",
  "creatAt": "2024-01-02T11:43:00",
  "updateAt": "2024-01-05T10:55:00"
}
```

---

### 5. Eliminar Contacto

**Descripción:** Elimina un contacto del sistema.

**Método:** `DELETE`  
**Endpoint:** `/contactos/{id}`  
**URL Completa:** `http://localhost:8080/api/contactos/4`

**Headers:**
```
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID del contacto a eliminar

**Respuesta Exitosa (204):**
```
(sin contenido)
```

---

## Ventas

### 1. Listar Todas las Ventas

**Descripción:** Obtiene la lista de todas las ventas registradas en el sistema.

**Método:** `GET`  
**Endpoint:** `/ventas`  
**URL Completa:** `http://localhost:8080/api/ventas`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "tiempo": {
      "id": 1,
      "fechaCompleta": "2024-01-05T10:30:00",
      "año": 2024,
      "mes": 1,
      "dia": 5,
      "hora": 10,
      "turno": "Mañana"
    },
    "tienda": {
      "id": 1,
      "nombreTienda": "Tienda Central"
    },
    "producto": {
      "id": 1,
      "nombreProducto": "Laptop HP"
    },
    "empleado": {
      "id": 1,
      "nombreCompleto": "Juan Pérez"
    },
    "metodoPago": "efectivo",
    "cantidad": 2,
    "precioFinal": 2000.00,
    "totalVenta": 4000.00,
    "creatAt": "2024-01-05T10:30:00"
  }
]
```

---

### 2. Obtener Venta por ID

**Descripción:** Obtiene los detalles de una venta específica.

**Método:** `GET`  
**Endpoint:** `/ventas/{id}`  
**URL Completa:** `http://localhost:8080/api/ventas/1`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID de la venta

**Respuesta Exitosa (200):**
```json
{
  "id": 1,
  "tiempo": {
    "id": 1,
    "fechaCompleta": "2024-01-05T10:30:00",
    "año": 2024,
    "mes": 1,
    "dia": 5,
    "hora": 10,
    "turno": "Mañana"
  },
  "tienda": {
    "id": 1,
    "nombreTienda": "Tienda Central"
  },
  "producto": {
    "id": 1,
    "nombreProducto": "Laptop HP"
  },
  "empleado": {
    "id": 1,
    "nombreCompleto": "Juan Pérez"
  },
  "metodoPago": "efectivo",
  "cantidad": 2,
  "precioFinal": 2000.00,
  "totalVenta": 4000.00,
  "creatAt": "2024-01-05T10:30:00"
}
```

---

### 3. Obtener Ventas por Tienda

**Descripción:** Obtiene todas las ventas de una tienda específica.

**Método:** `GET`  
**Endpoint:** `/ventas/tienda/{tiendaId}`  
**URL Completa:** `http://localhost:8080/api/ventas/tienda/1`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `tiendaId` (number, requerido): ID de la tienda

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "tiempo": {...},
    "tienda": {...},
    "producto": {...},
    "empleado": {...},
    "metodoPago": "efectivo",
    "cantidad": 2,
    "precioFinal": 2000.00,
    "totalVenta": 4000.00,
    "creatAt": "2024-01-05T10:30:00"
  }
]
```

---

### 4. Obtener Ventas por Rango de Fechas

**Descripción:** Obtiene las ventas de una tienda dentro de un rango de fechas específico.

**Método:** `GET`  
**Endpoint:** `/ventas/tienda/{tiendaId}/rango`  
**URL Completa:** `http://localhost:8080/api/ventas/tienda/1/rango?startDate=2024-01-01T00:00:00&endDate=2024-01-31T23:59:59`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `tiendaId` (number, requerido): ID de la tienda

**Parámetros de Query:**
- `startDate` (datetime, requerido): Fecha de inicio (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)
- `endDate` (datetime, requerido): Fecha de fin (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "tiempo": {...},
    "tienda": {...},
    "producto": {...},
    "empleado": {...},
    "metodoPago": "efectivo",
    "cantidad": 2,
    "precioFinal": 2000.00,
    "totalVenta": 4000.00,
    "creatAt": "2024-01-05T10:30:00"
  }
]
```

---

### 5. Obtener Ventas por Empleado

**Descripción:** Obtiene todas las ventas realizadas por un empleado específico.

**Método:** `GET`  
**Endpoint:** `/ventas/empleado/{empleadoId}`  
**URL Completa:** `http://localhost:8080/api/ventas/empleado/1`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `empleadoId` (number, requerido): ID del empleado

**Respuesta Exitosa (200):**
```json
[
  {
    "id": 1,
    "tiempo": {...},
    "tienda": {...},
    "producto": {...},
    "empleado": {...},
    "metodoPago": "efectivo",
    "cantidad": 2,
    "precioFinal": 2000.00,
    "totalVenta": 4000.00,
    "creatAt": "2024-01-05T10:30:00"
  }
]
```

---

### 6. Crear Venta

**Descripción:** Registra una nueva venta en el sistema.

**Método:** `POST`  
**Endpoint:** `/ventas`  
**URL Completa:** `http://localhost:8080/api/ventas`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body (JSON):**
```json
{
  "tiempo": {
    "id": 1
  },
  "tienda": {
    "id": 1
  },
  "producto": {
    "id": 2
  },
  "empleado": {
    "id": 2
  },
  "metodoPago": "transferencia",
  "cantidad": 5,
  "precioFinal": 35.00
}
```

**Parámetros:**
- `tiempo.id` (number, requerido): ID del registro de tiempo
- `tienda.id` (number, requerido): ID de la tienda
- `producto.id` (number, requerido): ID del producto
- `empleado.id` (number, requerido): ID del empleado
- `metodoPago` (string, requerido): Método de pago (`efectivo` o `transferencia`)
- `cantidad` (number, requerido): Cantidad de productos vendidos
- `precioFinal` (number, requerido): Precio unitario final

**Respuesta Exitosa (200):**
```json
{
  "id": 2,
  "tiempo": {
    "id": 1,
    "fechaCompleta": "2024-01-05T10:30:00"
  },
  "tienda": {
    "id": 1,
    "nombreTienda": "Tienda Central"
  },
  "producto": {
    "id": 2,
    "nombreProducto": "Mouse Inalámbrico"
  },
  "empleado": {
    "id": 2,
    "nombreCompleto": "María García"
  },
  "metodoPago": "transferencia",
  "cantidad": 5,
  "precioFinal": 35.00,
  "totalVenta": 175.00,
  "creatAt": "2024-01-05T10:35:00"
}
```

---

### 7. Eliminar Venta

**Descripción:** Elimina una venta del sistema.

**Método:** `DELETE`  
**Endpoint:** `/ventas/{id}`  
**URL Completa:** `http://localhost:8080/api/ventas/2`

**Headers:**
```
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `id` (number, requerido): ID de la venta a eliminar

**Respuesta Exitosa (204):**
```
(sin contenido)
```

---

## Reportes

### 1. Generar Reporte Real

**Descripción:** Genera un reporte real de ventas para un rango de fechas específico.

**Método:** `GET`  
**Endpoint:** `/reportes/tienda/{tiendaId}/real`  
**URL Completa:** `http://localhost:8080/api/reportes/tienda/1/real?startDate=2024-01-01T00:00:00&endDate=2024-01-31T23:59:59`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `tiendaId` (number, requerido): ID de la tienda

**Parámetros de Query:**
- `startDate` (datetime, requerido): Fecha de inicio (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)
- `endDate` (datetime, requerido): Fecha de fin (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)

**Respuesta Exitosa (200):**
```json
{
  "tiendaId": 1,
  "fechaInicio": "2024-01-01T00:00:00",
  "fechaFin": "2024-01-31T23:59:59",
  "tipo": "REAL",
  "ventas": [
    {
      "id": 1,
      "fecha": "2024-01-05T10:30:00",
      "producto": "Laptop HP",
      "cantidad": 2,
      "precioFinal": 2000.00,
      "total": 4000.00,
      "metodoPago": "efectivo",
      "empleado": "Juan Pérez",
      "esReporteFalso": false,
      "inflacionAplicada": 0
    }
  ],
  "estadisticas": {
    "totalVentas": 4000.00,
    "totalTransacciones": 1,
    "promedio": 4000.00,
    "totalUnidades": 2
  }
}
```

---

### 2. Generar Reporte Falso (con Inflación)

**Descripción:** Genera un reporte falso (inflado) de ventas basado en datos reales. El porcentaje de inflación puede estar entre 0 y 200%.

**Método:** `GET`  
**Endpoint:** `/reportes/tienda/{tiendaId}/falso`  
**URL Completa:** `http://localhost:8080/api/reportes/tienda/1/falso?startDate=2024-01-01T00:00:00&endDate=2024-01-31T23:59:59&inflacionPorcentaje=50`

**Headers:**
```
Accept: application/json
Authorization: Bearer {token}
```

**Parámetros de Ruta:**
- `tiendaId` (number, requerido): ID de la tienda

**Parámetros de Query:**
- `startDate` (datetime, requerido): Fecha de inicio (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)
- `endDate` (datetime, requerido): Fecha de fin (formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`)
- `inflacionPorcentaje` (number, opcional, default: 10): Porcentaje de inflación a aplicar (0-200)

**Respuesta Exitosa (200):**
```json
{
  "tiendaId": 1,
  "fechaInicio": "2024-01-01T00:00:00",
  "fechaFin": "2024-01-31T23:59:59",
  "tipo": "FALSO",
  "inflacionAplicada": 50,
  "ventas": [
    {
      "id": 1,
      "fecha": "2024-01-05T10:30:00",
      "producto": "Laptop HP",
      "cantidad": 3,
      "precioFinal": 3000.00,
      "total": 6000.00,
      "metodoPago": "efectivo",
      "empleado": "Juan Pérez",
      "esReporteFalso": true,
      "inflacionAplicada": 50
    }
  ],
  "estadisticas": {
    "totalVentas": 6000.00,
    "totalTransacciones": 1,
    "promedio": 6000.00,
    "totalUnidades": 3
  }
}
```

**Respuesta Error (400):**
```json
{
  "error": "El porcentaje de inflación debe estar entre 0 y 200"
}
```

---

## Guía de Pruebas en Insomnia

### Paso 1: Configurar la URL Base

1. Abre Insomnia
2. Crea un nuevo workspace o utiliza uno existente
3. En la esquina superior izquierda, haz clic en "No Environment"
4. Crea un nuevo environment con la siguiente variable:
   - **Variable:** `base_url`
   - **Valor:** `http://localhost:8080/api`

### Paso 2: Crear una Colección

1. Crea una nueva colección llamada "Shopping Manager API"
2. Organiza las peticiones por carpetas:
   - Autenticación
   - Tiendas
   - Productos
   - Contactos
   - Ventas
   - Reportes

### Paso 3: Configurar Autenticación

1. En cada petición que requiera autenticación, ve a la pestaña "Auth"
2. Selecciona "Bearer Token"
3. En el campo de token, ingresa el token obtenido del endpoint de login

### Paso 4: Ejemplo de Flujo de Prueba

1. **Login:**
   - POST `{{base_url}}/auth/login`
   - Body: `{"username": "jperez", "password": "password123"}`
   - Copia el token de la respuesta

2. **Listar Tiendas:**
   - GET `{{base_url}}/tiendas`
   - Sin autenticación requerida

3. **Crear Producto:**
   - POST `{{base_url}}/productos`
   - Usa el token del login
   - Body con datos del producto

4. **Registrar Venta:**
   - POST `{{base_url}}/ventas`
   - Usa el token del login
   - Body con datos de la venta

5. **Generar Reporte:**
   - GET `{{base_url}}/reportes/tienda/1/real?startDate=2024-01-01T00:00:00&endDate=2024-01-31T23:59:59`
   - Usa el token del login

---

## Notas Importantes

- **Autenticación:** Los tokens JWT tienen una validez de 15 días
- **CORS:** Todos los endpoints tienen CORS habilitado para solicitudes desde cualquier origen
- **Errores Comunes:**
  - 401: Token inválido o expirado
  - 404: Recurso no encontrado
  - 400: Solicitud inválida (revisar parámetros)
  - 500: Error interno del servidor

---

**Última Actualización:** Enero 5, 2026
