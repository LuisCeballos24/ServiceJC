package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;

public class Usuario {
    @DocumentId
    private String id;
    private String nombre;
    private String correo;
    private String contrasena;
    private String telefono;
    
    // ⚠️ CAMBIO CRÍTICO: Usamos String para evitar el error de mapeo del Enum
    private String rol; 
    
    private UserAddressModel direccion;

    public Usuario() {}

    // --- GETTERS Y SETTERS ---

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    // ✅ TRABAJAMOS DIRECTAMENTE CON STRING
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public UserAddressModel getDireccion() { return direccion; }
    public void setDireccion(UserAddressModel direccion) { this.direccion = direccion; }

    // --- MÉTODOS OBLIGATORIOS PARA SPRING SECURITY ---
    
    public String getPassword() { return this.contrasena; }
    public String getUsername() { return this.correo; }
}