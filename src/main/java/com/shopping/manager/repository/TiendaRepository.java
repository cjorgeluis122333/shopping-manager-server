package com.shopping.manager.repository;

import com.shopping.manager.entity.Tienda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TiendaRepository extends JpaRepository<Tienda, Long> {
    Optional<Tienda> findByNombreTienda(String nombreTienda);
    List<Tienda> findAll();
}
