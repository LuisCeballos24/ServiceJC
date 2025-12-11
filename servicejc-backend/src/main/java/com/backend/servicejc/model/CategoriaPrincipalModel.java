package com.backend.servicejc.model;

/**
 * Modelo para la categoría principal (Nivel 1 de la app).
 * Representa colecciones como "Mantenimiento y Reparaciones Técnicas".
 */
public class CategoriaPrincipalModel {

    // El ID se usa para enlazar con la colección 'servicios'
    private String id;
    private String nombre;
    // Opcional: Para almacenamiento en Firestore, puede usar Map<String, String> o campos específicos
    // para metadatos como íconos. Por simplicidad, usamos solo el nombre y el ID.

    // Constructor sin argumentos requerido por Firestore para deserialización
    public CategoriaPrincipalModel() {
    }

    // Constructor con argumentos
    public CategoriaPrincipalModel(String id, String nombre) {
        this.id = id;
        this.nombre = nombre;
    }

    // Getters y Setters requeridos por Firestore/Spring para serialización/deserialización
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

    @Override
    public String toString() {
        return "CategoriaPrincipalModel{" +
                "id='" + id + '\'' +
                ", nombre='" + nombre + '\'' +
                '}';
    }
}