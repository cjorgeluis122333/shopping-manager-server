package com.shopping.manager.controller;

import com.shopping.manager.entity.Venta;
import com.shopping.manager.service.VentaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/ventas")
@CrossOrigin(origins = "*", maxAge = 3600)
public class VentaController {

    @Autowired
    private VentaService ventaService;

    @GetMapping
    public ResponseEntity<List<Venta>> getAll() {
        return ResponseEntity.ok(ventaService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Venta> getById(@PathVariable Long id) {
        return ventaService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/tienda/{tiendaId}")
    public ResponseEntity<List<Venta>> getByTiendaId(@PathVariable Long tiendaId) {
        return ResponseEntity.ok(ventaService.findByTiendaId(tiendaId));
    }

    @GetMapping("/tienda/{tiendaId}/rango")
    public ResponseEntity<List<Venta>> getByTiendaIdAndDateRange(
            @PathVariable Long tiendaId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        return ResponseEntity.ok(ventaService.findByTiendaIdAndDateRange(tiendaId, startDate, endDate));
    }

    @GetMapping("/empleado/{empleadoId}")
    public ResponseEntity<List<Venta>> getByEmpleadoId(@PathVariable Long empleadoId) {
        return ResponseEntity.ok(ventaService.findByEmpleadoId(empleadoId));
    }

    @PostMapping
    public ResponseEntity<Venta> create(@RequestBody Venta venta) {
        return ResponseEntity.ok(ventaService.save(venta));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        ventaService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
