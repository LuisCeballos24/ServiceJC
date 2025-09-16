package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Producto {
    @DocumentId
    private String id;
    private String nombre; // Ej: "Lámpara", "Tomas"
    private double costo;
    private String servicioId; // Para vincularlo a la categoría de servicio
}