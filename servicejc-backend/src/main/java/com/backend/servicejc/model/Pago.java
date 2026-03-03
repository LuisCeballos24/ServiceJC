package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;

public class Pago {
    @DocumentId
    private String id;
    private String citaId; // Referencia a la cita que se está pagando
    private double monto;
    private String estado; // Ej: "aprobado", "rechazado", "pendiente"
    private String metodoDePago; // Ej: "tarjeta de crédito", "transferencia"
    
    // 🔴 NUEVOS CAMPOS VITALES PARA AUDITORÍA EN PRODUCCIÓN
    private String transaccionCuboId; 
    private String usuarioId;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "America/Panama")
    private Date fechaHora;

    // Constructor vacío
    public Pago() {}
    
    // Constructor con los campos originales (puedes generar uno con todos si lo deseas)
    public Pago(String id, String citaId, double monto, String estado, String metodoDePago) {
        this.id = id;
        this.citaId = citaId;
        this.monto = monto;
        this.estado = estado;
        this.metodoDePago = metodoDePago;
    }
    
    // ================= Getters y Setters =================
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getCitaId() { return citaId; }
    public void setCitaId(String citaId) { this.citaId = citaId; }

    public double getMonto() { return monto; }
    public void setMonto(double monto) { this.monto = monto; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getMetodoDePago() { return metodoDePago; }
    public void setMetodoDePago(String metodoDePago) { this.metodoDePago = metodoDePago; }

    // Getters y Setters de los campos nuevos
    public String getTransaccionCuboId() { return transaccionCuboId; }
    public void setTransaccionCuboId(String transaccionCuboId) { this.transaccionCuboId = transaccionCuboId; }

    public String getUsuarioId() { return usuarioId; }
    public void setUsuarioId(String usuarioId) { this.usuarioId = usuarioId; }

    public Date getFechaHora() { return fechaHora; }
    public void setFechaHora(Date fechaHora) { this.fechaHora = fechaHora; }
}