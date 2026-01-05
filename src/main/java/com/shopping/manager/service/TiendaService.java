package com.shopping.manager.service;

import com.shopping.manager.entity.Tienda;
import com.shopping.manager.repository.TiendaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TiendaService {

    @Autowired
    private TiendaRepository tiendaRepository;

    public List<Tienda> findAll() {
        return tiendaRepository.findAll();
    }

    public Optional<Tienda> findById(Long id) {
        return tiendaRepository.findById(id);
    }

    public Optional<Tienda> findByNombreTienda(String nombreTienda) {
        return tiendaRepository.findTiendaByNombre(nombreTienda);
    }

    public Tienda save(Tienda tienda) {
        return tiendaRepository.save(tienda);
    }

    public void deleteById(Long id) {
        tiendaRepository.deleteById(id);
    }

    public Tienda update(Long id, Tienda tienda) {
        return tiendaRepository.findById(id)
                .map(existing -> {
                    existing.setNombre(tienda.getNombre());
                    existing.setTelefono(tienda.getTelefono());
                    existing.setDireccion(tienda.getDireccion());
                    existing.setUrlFotoLocal(tienda.getUrlFotoLocal());
                    return tiendaRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("Tienda no encontrada"));
    }
}
