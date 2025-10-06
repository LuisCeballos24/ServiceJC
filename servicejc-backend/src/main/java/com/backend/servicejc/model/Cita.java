package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import java.util.Date; 
import java.util.List;

public class Cita {
    @DocumentId
    private String id;
    private String usuarioId; // ID del usuario que solicita la cita
    private String tecnicoId; // ID del técnico asignado a la cita
    private List<String>serviciosSeleccionados; // IDs de los servicios seleccionados
    private Date fechaHora;
    private String estado; // Ej: "pendiente", "confirmada", "cancelada", "completada"
    private double costoTotal; // Costo total de los servicios

    // Constructor vacío requerido por Firestore
    public Cita() {}

    // Constructor con todos los campos
    public Cita(String id, String usuarioId, String tecnicoId, List<String> serviciosSeleccionados, Date fechaHora, String estado, double costoTotal) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.tecnicoId = tecnicoId;
        this.serviciosSeleccionados = serviciosSeleccionados;
        this.fechaHora = fechaHora;
        this.estado = estado;
        this.costoTotal = costoTotal;
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

    public String getTecnicoId() {
        return tecnicoId;
    }

    public void setTecnicoId(String tecnicoId) {
        this.tecnicoId = tecnicoId;
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

    public double getCostoTotal() {
        return costoTotal;
    }

    public void setCostoTotal(double costoTotal) {
        this.costoTotal = costoTotal;
    }
}