package com.shopping.manager.controller;

import com.shopping.manager.entity.Contacto;
import com.shopping.manager.service.ContactoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contactos")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ContactoController {

    @Autowired
    private ContactoService contactoService;

    @GetMapping("/tienda/{tiendaId}")
    public ResponseEntity<List<Contacto>> getByTiendaId(@PathVariable Long tiendaId) {
        return ResponseEntity.ok(contactoService.findByTiendaId(tiendaId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Contacto> getById(@PathVariable Long id) {
        return contactoService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Contacto> create(@RequestBody Contacto contacto) {
        return ResponseEntity.ok(contactoService.save(contacto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Contacto> update(@PathVariable Long id, @RequestBody Contacto contacto) {
        try {
            return ResponseEntity.ok(contactoService.update(id, contacto));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        contactoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
