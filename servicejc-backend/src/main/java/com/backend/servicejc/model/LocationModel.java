package com.backend.servicejc.model;
import com.google.cloud.firestore.annotation.DocumentId;

// Nota: Esta clase es la representación de los documentos en la colección 'geolocations' en Firestore.

public class LocationModel {
    @DocumentId
    private String id; // El ID único (ej: P01, D01A, C01A1). Mapeado automáticamente al ID del documento de Firestore.
    private String name; // Nombre de la ubicación (ej: "Panamá", "Ancón")
    private String type; // Tipo de ubicación (province, district, corregimiento)

    // Campos de relación para la jerarquía:
    private String provinceId; // ID del padre, si el tipo es 'district'
    private String districtId; // ID del padre, si el tipo es 'corregimiento'
    
    // Constructor vacío requerido por Firestore
    public LocationModel() {}

    // Constructor completo para la inicialización (el que estabas llamando en el Service)
    public LocationModel(String id, String name, String type, String provinceId, String districtId) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.provinceId = provinceId;
        this.districtId = districtId;
    }

    // --- Getters y Setters (necesarios para Firestore) ---

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(String provinceId) {
        this.provinceId = provinceId;
    }

    public String getDistrictId() {
        return districtId;
    }

    public void setDistrictId(String districtId) {
        this.districtId = districtId;
    }
}
