package com.backend.servicejc.model;

import com.fasterxml.jackson.annotation.JsonCreator;

// Necesitarás tener la dependencia 'com.fasterxml.jackson.core:jackson-databind'
// en tu proyecto para usar @JsonCreator.
public enum Rol {
    // Definimos la clave JSON interna para cada constante
    ADMINISTRATIVO("admin"),
    TECNICO("tecnico"),
    USUARIO_FINAL("user");

    private final String key;

    Rol(String key) {
        this.key = key;
    }

    // Este método permite a Jackson (el deserializador) convertir el String
    // recibido en el JSON de Flutter (e.g., "user") al enum correcto (USUARIO_FINAL).
    @JsonCreator
    public static Rol fromString(String key) {
        if (key == null) return null;
        for (Rol rol : Rol.values()) {
            if (rol.key.equalsIgnoreCase(key)) {
                return rol;
            }
        }
        // Lanza una excepción si el rol no coincide con ninguna clave definida
        throw new IllegalArgumentException("Rol '" + key + "' no reconocido para la deserialización.");
    }
    
    // Este método se usa si necesitas serializar el enum de vuelta a JSON (e.g., {"rol": "user"})
    // No es estrictamente necesario para Firestore, pero es buena práctica.
    @Override
    public String toString() {
        return key;
    }
}
