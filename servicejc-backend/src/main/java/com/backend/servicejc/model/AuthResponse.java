package com.backend.servicejc.model;

public class AuthResponse {
    private String token;
    private String rol;
    private String userId; // <-- NUEVO CAMPO

    public AuthResponse(String token, String rol, String userId) {
        this.token = token;
        this.rol = rol;
        this.userId = userId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }
}