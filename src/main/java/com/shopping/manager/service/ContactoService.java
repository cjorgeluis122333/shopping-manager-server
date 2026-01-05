package com.shopping.manager.service;

import com.shopping.manager.entity.Contacto;
import com.shopping.manager.repository.ContactoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ContactoService {

    @Autowired
    private ContactoRepository contactoRepository;

    public List<Contacto> findByTiendaId(Long tiendaId) {
        return contactoRepository.findByTiendaId(tiendaId);
    }

    public Optional<Contacto> findById(Long id) {
        return contactoRepository.findById(id);
    }

    public Contacto save(Contacto contacto) {
        return contactoRepository.save(contacto);
    }

    public void deleteById(Long id) {
        contactoRepository.deleteById(id);
    }

    public Contacto update(Long id, Contacto contacto) {
        return contactoRepository.findById(id)
                .map(existing -> {
                    existing.setNombreVinculo(contacto.getNombreVinculo());
                    existing.setUrlVinculo(contacto.getUrlVinculo());
                    return contactoRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("Contacto no encontrado"));
    }
}
