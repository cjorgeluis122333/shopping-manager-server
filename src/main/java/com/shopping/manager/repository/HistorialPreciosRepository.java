package com.shopping.manager.repository;

import com.shopping.manager.entity.HistorialPrecios;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HistorialPreciosRepository extends JpaRepository<HistorialPrecios, Long> {
    List<HistorialPrecios> findByProductoId(Long productoId);
}
