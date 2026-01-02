package com.shopping.manager.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "dim_tiempo")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tiempo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tiempo")
    private Long id;

    @Column(name = "fecha_completa", nullable = false)
    private LocalDateTime fechaCompleta;

    private Integer año;
    private Integer mes;
    private Integer dia;
    private Integer hora;

    @Column(length = 20)
    private String turno;

    @CreationTimestamp
    @Column(name = "create_at", updatable = false)
    private LocalDateTime createAt;
}
