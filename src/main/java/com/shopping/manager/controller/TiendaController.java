package com.shopping.manager.controller;

import com.shopping.manager.entity.Tienda;
import com.shopping.manager.service.TiendaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tiendas")
@CrossOrigin(origins = "*", maxAge = 3600)
public class TiendaController {

    @Autowired
    private TiendaService tiendaService;

    @GetMapping
    public ResponseEntity<List<Tienda>> getAll() {
        return ResponseEntity.ok(tiendaService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tienda> getById(@PathVariable Long id) {
        return tiendaService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Tienda> create(@RequestBody Tienda tienda) {
        return ResponseEntity.ok(tiendaService.save(tienda));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tienda> update(@PathVariable Long id, @RequestBody Tienda tienda) {
        try {
            return ResponseEntity.ok(tiendaService.update(id, tienda));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        tiendaService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
