package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;

public class Pago {
    @DocumentId
    private String id;
    private String citaId; // Referencia a la cita que se está pagando
    private double monto;
    private String estado; // Ej: "aprobado", "rechazado", "pendiente"
    private String metodoDePago; // Ej: "tarjeta de crédito", "transferencia"
    
    // Constructor vacío
    public Pago() {}
    
    public Pago(String id, String citaId, double monto, String estado, String metodoDePago) {
        this.id = id;
        this.citaId = citaId;
        this.monto = monto;
        this.estado = estado;
        this.metodoDePago = metodoDePago;
    }
    
    // Getters y Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCitaId() {
        return citaId;
    }

    public void setCitaId(String citaId) {
        this.citaId = citaId;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getMetodoDePago() {
        return metodoDePago;
    }

    public void setMetodoDePago(String metodoDePago) {
        this.metodoDePago = metodoDePago;
    }
}