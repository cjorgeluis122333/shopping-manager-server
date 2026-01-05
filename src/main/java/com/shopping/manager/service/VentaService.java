package com.shopping.manager.service;

import com.shopping.manager.entity.Venta;
import com.shopping.manager.repository.VentaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class VentaService {

    @Autowired
    private VentaRepository ventaRepository;

    public List<Venta> findAll() {
        return ventaRepository.findAll();
    }

    public Optional<Venta> findById(Long id) {
        return ventaRepository.findById(id);
    }

    public List<Venta> findByTiendaId(Long tiendaId) {
        return ventaRepository.findByTiendaId(tiendaId);
    }

    public List<Venta> findByTiendaIdAndDateRange(Long tiendaId, LocalDateTime startDate, LocalDateTime endDate) {
        return ventaRepository.findByTiendaIdAndDateRange(tiendaId, startDate, endDate);
    }

    public List<Venta> findByEmpleadoId(Long empleadoId) {
        return ventaRepository.findByEmpleadoId(empleadoId);
    }

    public Venta save(Venta venta) {
        return ventaRepository.save(venta);
    }

    public void deleteById(Long id) {
        ventaRepository.deleteById(id);
    }
}
