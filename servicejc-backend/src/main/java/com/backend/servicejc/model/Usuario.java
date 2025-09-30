package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;
// ASUME que UserAddressModel está en el mismo paquete o importado.

public class Usuario {
    @DocumentId
    private String id;
    private String nombre;
    private String correo;
    private String contrasena; // Se debe guardar encriptada
    private String telefono;
    // CORREGIDO: Se cambia el tipo a Rol para usar el enum existente.
    private Rol rol; 
    
    // CAMPO PARA OBJETO ANIDADO
    private UserAddressModel direccion; 

    // Constructor vacío requerido por Firestore
    public Usuario() {}

    // Constructor con todos los campos (ACTUALIZADO)
    // Se cambia el tipo de 'rol' en el constructor a Rol
    public Usuario(String id, String nombre, String correo, String contrasena, String telefono, Rol rol, UserAddressModel direccion) {
        this.id = id;
        this.nombre = nombre;
        this.correo = correo;
        this.contrasena = contrasena;
        this.telefono = telefono;
        this.rol = rol;
        this.direccion = direccion; // NUEVO
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

    // CORREGIDO: Se cambia el tipo de retorno a Rol
    public Rol getRol() {
        return rol;
    }

    // CORREGIDO: Se cambia el tipo de parámetro a Rol
    public void setRol(Rol rol) {
        this.rol = rol;
    }
    
    // NUEVOS GETTER Y SETTER para la dirección
    public UserAddressModel getDireccion() {
        return direccion;
    }

    public void setDireccion(UserAddressModel direccion) {
        this.direccion = direccion;
    }
}
