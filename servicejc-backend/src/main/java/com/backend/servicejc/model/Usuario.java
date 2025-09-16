package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;

public class Usuario {
    @DocumentId
    private String id;
    private String nombre;
    private String correo;
    private String contrasena; // Se debe guardar encriptada
    private String telefono;

    // Constructor vacío requerido por Firestore
    public Usuario() {}

    // Constructor con todos los campos
    public Usuario(String id, String nombre, String correo, String contrasena, String telefono) {
        this.id = id;
        this.nombre = nombre;
        this.correo = correo;
        this.contrasena = contrasena;
        this.telefono = telefono;
    }

    // Getters y Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
}