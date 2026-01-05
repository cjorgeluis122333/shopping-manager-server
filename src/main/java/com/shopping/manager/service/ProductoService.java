package com.shopping.manager.service;

import com.shopping.manager.entity.Producto;
import com.shopping.manager.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductoService {

    @Autowired
    private ProductoRepository productoRepository;

    public List<Producto> findAll() {
        return productoRepository.findAll();
    }

    public Optional<Producto> findById(Long id) {
        return productoRepository.findById(id);
    }

    public Producto save(Producto producto) {
        return productoRepository.save(producto);
    }

    public void deleteById(Long id) {
        productoRepository.deleteById(id);
    }

    public Producto update(Long id, Producto producto) {
        return productoRepository.findById(id)
                .map(existing -> {
                    existing.setNombreProducto(producto.getNombreProducto());
                    existing.setCategoria(producto.getCategoria());
                    existing.setPrecioCompra(producto.getPrecioCompra());
                    existing.setPrecioVenta(producto.getPrecioVenta());
                    existing.setStockActual(producto.getStockActual());
                    existing.setStockMinimo(producto.getStockMinimo());
                    existing.setUrlImagen(producto.getUrlImagen());
                    existing.setCodigoBarras(producto.getCodigoBarras());
                    return productoRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
    }

    public List<Producto> findByTienda(Long tiendaId) {
        // Este método requeriría una relación directa entre Producto y Tienda
        // Por ahora retornamos todos los productos
        return productoRepository.findAll();
    }
}
