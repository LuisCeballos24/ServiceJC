package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;

public class TestimonioModel {

    @DocumentId
    private String id; 
    
    private String nombreCliente;
    private String comentario;
    
    // ⚠️ CAMBIO CRÍTICO: Usar Long en lugar de int
    // Firestore devuelve Long. Si usas int, puede fallar el casteo.
    private Long calificacion; 
    
    // ⚠️ CAMBIO CRÍTICO: Usar Boolean en lugar de boolean
    // Permite valores nulos sin romper la app.
    private Boolean destacado; 
    
    // 1. CONSTRUCTOR VACÍO
    public TestimonioModel() {
    }

    // 2. CONSTRUCTOR COMPLETO
    public TestimonioModel(String id, String nombreCliente, String comentario, Long calificacion, Boolean destacado) {
        this.id = id;
        this.nombreCliente = nombreCliente;
        this.comentario = comentario;
        this.calificacion = calificacion;
        this.destacado = destacado;
    }

    // 3. GETTERS Y SETTERS
    
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNombreCliente() {
        return nombreCliente;
    }

    public void setNombreCliente(String nombreCliente) {
        this.nombreCliente = nombreCliente;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    // Getter y Setter actualizados a Long
    public Long getCalificacion() {
        return calificacion;
    }

    public void setCalificacion(Long calificacion) {
        this.calificacion = calificacion;
    }

    // Getter y Setter actualizados a Boolean
    // Nota: Cambié 'isDestacado' por 'getDestacado' para asegurar compatibilidad máxima con Firestore
    public Boolean getDestacado() {
        return destacado;
    }

    public void setDestacado(Boolean destacado) {
        this.destacado = destacado;
    }
}