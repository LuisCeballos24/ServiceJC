package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import java.util.Date;
import java.util.List;

public class Cita {
    @DocumentId
    private String id;
    private String usuarioId; // Referencia al ID del usuario
    private List<String> serviciosSeleccionados; // IDs de los servicios seleccionados
    private Date fechaHora;
    private String estado; // Ej: "pendiente", "confirmada", "cancelada"

    // Constructor vacío
    public Cita() {}

    public Cita(String id, String usuarioId, List<String> serviciosSeleccionados, Date fechaHora, String estado) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.serviciosSeleccionados = serviciosSeleccionados;
        this.fechaHora = fechaHora;
        this.estado = estado;
    }

    // Getters y Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(String usuarioId) {
        this.usuarioId = usuarioId;
    }

    public List<String> getServiciosSeleccionados() {
        return serviciosSeleccionados;
    }

    public void setServiciosSeleccionados(List<String> serviciosSeleccionados) {
        this.serviciosSeleccionados = serviciosSeleccionados;
    }

    public Date getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Date fechaHora) {
        this.fechaHora = fechaHora;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}