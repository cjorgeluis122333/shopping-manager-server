package com.shopping.manager.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "dim_tienda")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tienda {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tienda")
    private Long id;

    @Column(name = "nombre_tienda", nullable = false, length = 100)
    private String nombre;

    @Column(length = 20)
    private String telefono;

    @Column(columnDefinition = "TEXT")
    private String direccion;

    @Column(name = "url_foto_local", columnDefinition = "TEXT")
    private String urlFotoLocal;

    @CreationTimestamp
    @Column(name = "create_at", updatable = false)
    private LocalDateTime createAt;

    @UpdateTimestamp
    @Column(name = "update_at")
    private LocalDateTime updateAt;

    @OneToMany(mappedBy = "tienda", cascade = CascadeType.ALL)
    @JsonManagedReference  //Infinity cicle prebent
    private List<Contacto> contactos;

    @OneToMany(mappedBy = "tienda",fetch = FetchType.LAZY)
    @JsonManagedReference  //Infinity cicle prebent
    private List<Empleado> empleados;
}
