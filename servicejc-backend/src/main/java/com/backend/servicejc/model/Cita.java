package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import java.util.Date;
import java.util.List;

public class Cita {
    @DocumentId
    private String id;
    private String usuarioId;
    private String imageUrl;
    private String tecnicoId;
    private List<String> serviciosSeleccionados;
    private Date fechaHora;
    private String estado;
    private double costoTotal;
    private String descripcion; // Campo agregado
    private List<Producto> productosSeleccionados;

    // Constructor vacío requerido por Firestore
    public Cita() {}

    // Constructor con todos los campos
    public Cita(String id, String usuarioId, String tecnicoId, List<String> serviciosSeleccionados, Date fechaHora, String estado, double costoTotal, String descripcion, String imageUrl) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.tecnicoId = tecnicoId;
        this.serviciosSeleccionados = serviciosSeleccionados;
        this.fechaHora = fechaHora;
        this.estado = estado;
        this.costoTotal = costoTotal;
        this.descripcion = descripcion;
        this.imageUrl = imageUrl;
    }

    // Getters y Setters
    public String getId() {
        return id;
    }

    public List<Producto> getProductosSeleccionados() {
        return productosSeleccionados;
    }

    public void setProductosSeleccionados(List<Producto> productosSeleccionados) {
        this.productosSeleccionados = productosSeleccionados;
    }
    
    public void setId(String id) {
        this.id = id;
    }

    public String getUsuarioId() {
        return usuarioId;
    }

     public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getImageUrl() {
        return imageUrl;
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
    
    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}