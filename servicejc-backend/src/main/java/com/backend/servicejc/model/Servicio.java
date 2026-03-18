package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Servicio {
    @DocumentId 
    private String id;
    private String nombre;
    private String categoriaPrincipalId;
    
    // 👇 NUEVOS CAMPOS
    private Integer orden; 
    private String imageUrl; 
}