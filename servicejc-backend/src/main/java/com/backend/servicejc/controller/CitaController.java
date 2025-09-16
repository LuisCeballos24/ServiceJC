package com.backend.servicejc.controller;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.service.CitaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/citas")
public class CitaController {

    private final CitaService citaService;

    public CitaController(CitaService citaService) {
        this.citaService = citaService;
    }

    @PostMapping
    public ResponseEntity<String> createCita(@RequestBody Cita cita) {
        try {
            citaService.createCita(cita);
            return new ResponseEntity<>("Cita creada exitosamente.", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getCitasByUsuarioId(@PathVariable String usuarioId) {
        try {
            List<Cita> citas = citaService.getCitasByUsuarioId(usuarioId);
            return new ResponseEntity<>(citas, HttpStatus.OK);
        } catch (Exception e) {
            // Maneja cualquier error que ocurra al obtener las citas
            return new ResponseEntity<>("Error al obtener las citas: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}