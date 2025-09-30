package com.backend.servicejc.service;
import com.backend.servicejc.model.LocationModel;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class LocationDataService {

    private static final String COLLECTION_NAME = "geolocations"; // Colección en Firestore para Provincias/Distritos/Corregimientos
    private final Firestore firestore;

    @Autowired
    public LocationDataService(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Guarda un objeto LocationModel en la colección 'geolocations'.
     */
    public String saveLocation(LocationModel location) throws ExecutionException, InterruptedException {
        // Usa el ID como nombre de documento para asegurar unicidad y fácil consulta
        ApiFuture<com.google.cloud.firestore.WriteResult> future = firestore.collection(COLLECTION_NAME)
                .document(location.getId())
                .set(location);
        
        return "Ubicación guardada con éxito: " + future.get().getUpdateTime().toString();
    }


    // --- Métodos de Consulta ---

    /**
     * Obtiene todas las provincias.
     * Asume que los documentos de provincia tienen un campo 'type' = 'province'.
     */
    public List<LocationModel> fetchProvinces() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
            .whereEqualTo("type", "province")
            .get();
        
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        return documents.stream()
            .map(doc -> {
                LocationModel model = doc.toObject(LocationModel.class);
                // Asegura que el ID del documento coincida con el ID del modelo (necesario para la carga en cascada)
                model.setId(doc.getId()); 
                return model;
            })
            .collect(Collectors.toList());
    }

    /**
     * Obtiene los distritos que pertenecen a una provincia.
     * Asume que los documentos de distrito tienen un campo 'provinceId' con el ID de la provincia padre.
     */
    public List<LocationModel> fetchDistrictsByProvinceId(String provinceId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
            .whereEqualTo("type", "district")
            .whereEqualTo("provinceId", provinceId)
            .get();
        
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        return documents.stream()
            .map(doc -> {
                LocationModel model = doc.toObject(LocationModel.class);
                model.setId(doc.getId()); 
                return model;
            })
            .collect(Collectors.toList());
    }

    /**
     * Obtiene los corregimientos que pertenecen a un distrito.
     * Asume que los documentos de corregimiento tienen un campo 'districtId' con el ID del distrito padre.
     */
    public List<LocationModel> fetchCorregimientosByDistrictId(String districtId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
            .whereEqualTo("type", "corregimiento")
            .whereEqualTo("districtId", districtId)
            .get();
        
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        return documents.stream()
            .map(doc -> {
                LocationModel model = doc.toObject(LocationModel.class);
                model.setId(doc.getId()); 
                return model;
            })
            .collect(Collectors.toList());
    }

    // --- Método de Inicialización de Datos (Panamá) ---

    /**
     * Inicializa las ubicaciones (Provincias, Distritos, Corregimientos) en Firestore.
     * Este método es llamado por LocationInitializer al iniciar la aplicación si la colección está vacía.
     */
    public String initializeLocations() throws ExecutionException, InterruptedException {
        // En un entorno de producción, esta data se cargaría desde un archivo JSON o CSV
        // o una fuente de datos externa. Aquí usamos una lista en memoria para simplificar.

        List<LocationModel> panamaLocations = getPanamaLocationsData();
        int count = 0;
        
        for (LocationModel location : panamaLocations) {
            saveLocation(location);
            count++;
        }

        return "Carga inicial de " + count + " ubicaciones de Panamá completada en Firestore.";
    }


    /**
     * Datos predefinidos de TODAS las provincias, distritos y corregimientos MUESTRA de Panamá.
     */
    private List<LocationModel> getPanamaLocationsData() {
        return Arrays.asList(
            // =========================================================================
            //                         PROVINCIA DE PANAMÁ (P01)
            // =========================================================================
            new LocationModel("P01", "Panamá", "province", null, null),

            // Distritos de Panamá (P01)
            new LocationModel("D01A", "Panamá", "district", "P01", null),
            new LocationModel("D01B", "San Miguelito", "district", "P01", null),
            
            // Corregimientos de Panamá (D01A) - Muestra
            new LocationModel("C01A1", "Ancón", "corregimiento", null, "D01A"),
            new LocationModel("C01A2", "Bella Vista", "corregimiento", null, "D01A"),
            new LocationModel("C01A3", "Betania", "corregimiento", null, "D01A"),
            new LocationModel("C01A4", "Calidonia", "corregimiento", null, "D01A"),
            new LocationModel("C01A5", "Juan Díaz", "corregimiento", null, "D01A"),
            new LocationModel("C01A6", "Las Cumbres", "corregimiento", null, "D01A"),
            
            // Corregimientos de San Miguelito (D01B) - Muestra
            new LocationModel("C01B1", "Amelia Denis de Icaza", "corregimiento", null, "D01B"),
            new LocationModel("C01B2", "Belisario Porras", "corregimiento", null, "D01B"),
            new LocationModel("C01B3", "Rufina Alfaro", "corregimiento", null, "D01B"),


            // =========================================================================
            //                         PROVINCIA DE COLÓN (P02)
            // =========================================================================
            new LocationModel("P02", "Colón", "province", null, null),

            // Distritos de Colón (P02)
            new LocationModel("D02A", "Colón", "district", "P02", null),
            new LocationModel("D02B", "Portobelo", "district", "P02", null),

            // Corregimientos de Colón (D02A) - Muestra
            new LocationModel("C02A1", "Barrio Norte", "corregimiento", null, "D02A"),
            new LocationModel("C02A2", "Barrio Sur", "corregimiento", null, "D02A"),
            new LocationModel("C02A3", "Cativá", "corregimiento", null, "D02A"),


            // =========================================================================
            //                         PROVINCIA DE CHIRIQUÍ (P03)
            // =========================================================================
            new LocationModel("P03", "Chiriquí", "province", null, null),

            // Distritos de Chiriquí (P03)
            new LocationModel("D03A", "David", "district", "P03", null),
            new LocationModel("D03B", "Boquete", "district", "P03", null),

            // Corregimientos de David (D03A) - Muestra
            new LocationModel("C03A1", "David", "corregimiento", null, "D03A"),
            new LocationModel("C03A2", "San Pablo Nuevo", "corregimiento", null, "D03A"),
            
            // Corregimientos de Boquete (D03B) - Muestra
            new LocationModel("C03B1", "Bajo Boquete", "corregimiento", null, "D03B"),


            // =========================================================================
            //                         PROVINCIA DE COCLÉ (P04)
            // =========================================================================
            new LocationModel("P04", "Coclé", "province", null, null),

            // Distritos de Coclé (P04)
            new LocationModel("D04A", "Penonomé", "district", "P04", null),
            new LocationModel("D04B", "Aguadulce", "district", "P04", null),
            
            // Corregimientos de Penonomé (D04A) - Muestra
            new LocationModel("C04A1", "Penonomé", "corregimiento", null, "D04A"),
            
            // Corregimientos de Aguadulce (D04B) - Muestra
            new LocationModel("C04B1", "Aguadulce", "corregimiento", null, "D04B"),


            // =========================================================================
            //                         PROVINCIA DE VERAGUAS (P05)
            // =========================================================================
            new LocationModel("P05", "Veraguas", "province", null, null),

            // Distritos de Veraguas (P05)
            new LocationModel("D05A", "Santiago", "district", "P05", null),
            new LocationModel("D05B", "Soná", "district", "P05", null),

            // Corregimientos de Santiago (D05A) - Muestra
            new LocationModel("C05A1", "Santiago", "corregimiento", null, "D05A"),
            new LocationModel("C05A2", "La Peña", "corregimiento", null, "D05A"),


            // =========================================================================
            //                         PROVINCIA DE LOS SANTOS (P06)
            // =========================================================================
            new LocationModel("P06", "Los Santos", "province", null, null),

            // Distritos de Los Santos (P06)
            new LocationModel("D06A", "Las Tablas", "district", "P06", null),
            new LocationModel("D06B", "Chitré", "district", "P06", null),

            // Corregimientos de Las Tablas (D06A) - Muestra
            new LocationModel("C06A1", "Las Tablas", "corregimiento", null, "D06A"),


            // =========================================================================
            //                         PROVINCIA DE HERRERA (P07)
            // =========================================================================
            new LocationModel("P07", "Herrera", "province", null, null),

            // Distritos de Herrera (P07)
            new LocationModel("D07A", "Chitré", "district", "P07", null),
            new LocationModel("D07B", "Parita", "district", "P07", null),

            // Corregimientos de Chitré (D07A) - Muestra
            new LocationModel("C07A1", "San Juan Bautista", "corregimiento", null, "D07A"),


            // =========================================================================
            //                         PROVINCIA DE BOCAS DEL TORO (P08)
            // =========================================================================
            new LocationModel("P08", "Bocas del Toro", "province", null, null),

            // Distritos de Bocas del Toro (P08)
            new LocationModel("D08A", "Bocas del Toro", "district", "P08", null),

            // Corregimientos de Bocas del Toro (D08A) - Muestra
            new LocationModel("C08A1", "Bocas del Toro", "corregimiento", null, "D08A"),


            // =========================================================================
            //                         PROVINCIA DE DARIÉN (P09)
            // =========================================================================
            new LocationModel("P09", "Darién", "province", null, null),

            // Distritos de Darién (P09)
            new LocationModel("D09A", "Chepigana", "district", "P09", null),

            // Corregimientos de Chepigana (D09A) - Muestra
            new LocationModel("C09A1", "La Palma", "corregimiento", null, "D09A"),


            // =========================================================================
            //                         PROVINCIA DE PANAMÁ OESTE (P10)
            // =========================================================================
            new LocationModel("P10", "Panamá Oeste", "province", null, null),

            // Distritos de Panamá Oeste (P10)
            new LocationModel("D10A", "Arraiján", "district", "P10", null),
            new LocationModel("D10B", "La Chorrera", "district", "P10", null),

            // Corregimientos de Arraiján (D10A) - Muestra
            new LocationModel("C10A1", "Arraiján", "corregimiento", null, "D10A"),
            new LocationModel("C10A2", "Vista Alegre", "corregimiento", null, "D10A"),
            
            // Corregimientos de La Chorrera (D10B) - Muestra
            new LocationModel("C10B1", "Barrio Balboa", "corregimiento", null, "D10B"),
            new LocationModel("C10B2", "Playa Leona", "corregimiento", null, "D10B")
            
            // Si necesitas comarcas indígenas, usa el siguiente esquema:
            // new LocationModel("IC01", "Guna Yala", "province", null, null),
        );
    }
}
