package com.backend.servicejc.controller;

import com.backend.servicejc.model.LocationModel;
import com.backend.servicejc.service.LocationDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

/**
 * Controlador REST para manejar la obtención de datos de ubicación geográfica (Provincias, Distritos, Corregimientos).
 */
@RestController
@RequestMapping("/api/locations") // Endpoint base: /api/locations
public class LocationController {

    private final LocationDataService locationDataService;

    @Autowired
    public LocationController(LocationDataService locationDataService) {
        this.locationDataService = locationDataService;
    }

    /**
     * GET /api/locations/provinces
     * Obtiene la lista de todas las provincias.
     */
    @GetMapping("/provinces")
    public ResponseEntity<List<LocationModel>> getProvinces() {
        try {
            List<LocationModel> provinces = locationDataService.fetchProvinces();
            return new ResponseEntity<>(provinces, HttpStatus.OK);
        } catch (ExecutionException | InterruptedException e) {
            // Manejo de errores de Firestore o interrupciones
            Thread.currentThread().interrupt(); // Restablecer el estado de interrupción
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * GET /api/locations/districts/{provinceId}
     * Obtiene los distritos filtrados por el ID de la provincia.
     */
    @GetMapping("/districts/{provinceId}")
    public ResponseEntity<List<LocationModel>> getDistrictsByProvince(
            @PathVariable String provinceId) {
        try {
            List<LocationModel> districts = locationDataService.fetchDistrictsByProvinceId(provinceId);
            return new ResponseEntity<>(districts, HttpStatus.OK);
        } catch (ExecutionException | InterruptedException e) {
            Thread.currentThread().interrupt();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * GET /api/locations/corregimientos/{districtId}
     * Obtiene los corregimientos filtrados por el ID del distrito.
     */
    @GetMapping("/corregimientos/{districtId}")
    public ResponseEntity<List<LocationModel>> getCorregimientosByDistrict(
            @PathVariable String districtId) {
        try {
            List<LocationModel> corregimientos = locationDataService.fetchCorregimientosByDistrictId(districtId);
            return new ResponseEntity<>(corregimientos, HttpStatus.OK);
        } catch (ExecutionException | InterruptedException e) {
            Thread.currentThread().interrupt();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
