package com.backend.servicejc.model;

/**
 * Modelo para representar la dirección detallada del usuario,
 * que se guarda como un objeto anidado en el documento de Usuario.
 */
public class UserAddressModel {
    
    // Campos que recibes del modelo Dart
    private String provincia;
    private String distrito;
    private String corregimiento;
    private String callePrincipal;
    private String referencias;

    // Constructor vacío requerido por Firestore/Jackson
    public UserAddressModel() {}

    // Constructor con todos los campos
    public UserAddressModel(String provincia, String distrito, String corregimiento, String callePrincipal, String referencias) {
        this.provincia = provincia;
        this.distrito = distrito;
        this.corregimiento = corregimiento;
        this.callePrincipal = callePrincipal;
        this.referencias = referencias;
    }

    // --- Getters y Setters ---

    public String getProvincia() {
        return provincia;
    }

    public void setProvincia(String provincia) {
        this.provincia = provincia;
    }

    public String getDistrito() {
        return distrito;
    }

    public void setDistrito(String distrito) {
        this.distrito = distrito;
    }

    public String getCorregimiento() {
        return corregimiento;
    }

    public void setCorregimiento(String corregimiento) {
        this.corregimiento = corregimiento;
    }

    public String getCallePrincipal() {
        return callePrincipal;
    }

    public void setCallePrincipal(String callePrincipal) {
        this.callePrincipal = callePrincipal;
    }

    public String getReferencias() {
        return referencias;
    }

    public void setReferencias(String referencias) {
        this.referencias = referencias;
    }
}
