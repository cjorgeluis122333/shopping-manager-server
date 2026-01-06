## Up just the database not the app
``` shell
 docker-compose up -d db
```

## Prevent Infinity recursion
In the bidirectional relations you have to use the annotation ***@JsonManagedReference*** for the class owner of the relation 
and for the reference table you use ***@JsonBackReference***

### ***@JsonManagedReference***
```java

@Entity
@Table(name = "dim_tienda")
public class Tienda {
    @OneToMany(mappedBy = "tienda", fetch = FetchType.LAZY)
    @JsonManagedReference  //Infinity cicle prebent
    private List<Empleado> empleados;
}
```

### ***@JsonBackReference***
```java
@Entity
@Table(name = "dim_empleado")
public class Empleado {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tienda", nullable = false)
    @JsonBackReference
    private Tienda tienda;
}
```