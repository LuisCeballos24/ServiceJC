package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Servicio {
    @DocumentId // <--- ¡Asegúrate de que esta línea esté aquí!
    private String id;
    private String nombre;
    private String categoriaPrincipalId;
}