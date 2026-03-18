package com.backend.servicejc.model;

import com.google.cloud.firestore.annotation.DocumentId;

public class Usuario {
    @DocumentId
    private String id;
    private String nombre;
    private String correo;
    private String contrasena;
    private String telefono;
    private String rol; 
    private UserAddressModel direccion;

    // 👇 NUEVOS CAMPOS PARA AFILIADOS Y MEMBRESÍA
    private Boolean isPremium;
    private Double walletBalance;
    private String codigoReferido;

    public Usuario() {}

    // --- GETTERS Y SETTERS ORIGINALES ---
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
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    public UserAddressModel getDireccion() { return direccion; }
    public void setDireccion(UserAddressModel direccion) { this.direccion = direccion; }

    // 👇 NUEVOS GETTERS Y SETTERS
    public Boolean getIsPremium() { return isPremium; }
    public void setIsPremium(Boolean isPremium) { this.isPremium = isPremium; }
    
    public Double getWalletBalance() { return walletBalance; }
    public void setWalletBalance(Double walletBalance) { this.walletBalance = walletBalance; }
    
    public String getCodigoReferido() { return codigoReferido; }
    public void setCodigoReferido(String codigoReferido) { this.codigoReferido = codigoReferido; }

    // --- MÉTODOS OBLIGATORIOS PARA SPRING SECURITY ---
    public String getPassword() { return this.contrasena; }
    public String getUsername() { return this.correo; }
}