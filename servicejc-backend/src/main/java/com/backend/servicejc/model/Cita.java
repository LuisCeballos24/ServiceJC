package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
import com.fasterxml.jackson.annotation.JsonFormat; // 💡 Importante
import java.util.Date; // 💡 Importante: Usamos Date, no String
import java.util.List;

public class Cita {

    @DocumentId
    private String id;
    private String usuarioId;
    private String imageUrl;
    private String tecnicoId;
    private List<String> serviciosSeleccionados;
    
    // 🔴 CAMBIO CLAVE: Usamos Date para que Firestore lo entienda.
    // Y usamos @JsonFormat para que Flutter reciba un String bonito.
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "America/Panama")
    private Date fechaHora; 
    
    private String estado;
    private double costoTotal;
    private String descripcion; 
    
    private List<Producto> productosSeleccionados;

    public Cita() {}

    // Actualiza el constructor
    public Cita(String id, String usuarioId, String tecnicoId, List<String> serviciosSeleccionados, Date fechaHora, String estado, double costoTotal, String descripcion, String imageUrl) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.tecnicoId = tecnicoId;
        this.serviciosSeleccionados = serviciosSeleccionados;
        this.fechaHora = fechaHora; // Date
        this.estado = estado;
        this.costoTotal = costoTotal;
        this.descripcion = descripcion;
        this.imageUrl = imageUrl;
    }

    // Getters y Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUsuarioId() { return usuarioId; }
    public void setUsuarioId(String usuarioId) { this.usuarioId = usuarioId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getTecnicoId() { return tecnicoId; }
    public void setTecnicoId(String tecnicoId) { this.tecnicoId = tecnicoId; }

    public List<String> getServiciosSeleccionados() { return serviciosSeleccionados; }
    public void setServiciosSeleccionados(List<String> serviciosSeleccionados) { this.serviciosSeleccionados = serviciosSeleccionados; }

    // 🔴 GETTER Y SETTER ACTUALIZADOS A DATE
    public Date getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(Date fechaHora) {
        this.fechaHora = fechaHora;
    }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public double getCostoTotal() { return costoTotal; }
    public void setCostoTotal(double costoTotal) { this.costoTotal = costoTotal; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public List<Producto> getProductosSeleccionados() { return productosSeleccionados; }
    public void setProductosSeleccionados(List<Producto> productosSeleccionados) { this.productosSeleccionados = productosSeleccionados; }
}