package com.backend.servicejc.model;

public class CategoriaPrincipalModel {

    private String id;
    private String nombre;
    private String imageUrl; // 👇 NUEVO CAMPO

    public CategoriaPrincipalModel() {}

    public CategoriaPrincipalModel(String id, String nombre, String imageUrl) {
        this.id = id;
        this.nombre = nombre;
        this.imageUrl = imageUrl;
    }

    // Getters y Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}