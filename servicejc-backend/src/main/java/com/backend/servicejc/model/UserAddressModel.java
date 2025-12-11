package com.backend.servicejc.model;

/**
 * Modelo para representar la dirección detallada del usuario,
 * que se guarda como un objeto anidado en el documento de Usuario.
 */
public class UserAddressModel {
    
    // Campos que recibes del modelo Dart (Flutter)
    private String provincia;
    private String distrito;
    private String corregimiento;
    private String callePrincipal; // Mapeado desde 'barrio' en Flutter
    private String referencias;    // Mapeado desde 'house' en Flutter
    
    // NUEVOS CAMPOS: Coordenadas del mapa
    private Double latitude;
    private Double longitude;

    // Constructor vacío requerido por Firestore/Jackson
    public UserAddressModel() {}

    // Constructor con todos los campos (incluyendo coordenadas)
    public UserAddressModel(String provincia, String distrito, String corregimiento, 
                            String callePrincipal, String referencias, 
                            Double latitude, Double longitude) {
        this.provincia = provincia;
        this.distrito = distrito;
        this.corregimiento = corregimiento;
        this.callePrincipal = callePrincipal;
        this.referencias = referencias;
        this.latitude = latitude;
        this.longitude = longitude;
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

    // Nuevos Getters y Setters para coordenadas
    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
}