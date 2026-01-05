package com.shopping.manager.repository;

import com.shopping.manager.entity.Venta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface VentaRepository extends JpaRepository<Venta, Long> {
    List<Venta> findByTiendaId(Long tiendaId);
    
    @Query("SELECT v FROM Venta v WHERE v.tienda.id = :tiendaId AND v.creatAt BETWEEN :startDate AND :endDate")
    List<Venta> findByTiendaIdAndDateRange(
            @Param("tiendaId") Long tiendaId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );
    
    List<Venta> findByEmpleadoId(Long empleadoId);
}
