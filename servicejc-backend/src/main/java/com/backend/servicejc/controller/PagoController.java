package com.backend.servicejc.controller;

import com.backend.servicejc.model.SolicitudPago;
import com.backend.servicejc.service.PagoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/pagos")
public class PagoController {

    private final PagoService pagoService;

    public PagoController(PagoService pagoService) {
        this.pagoService = pagoService;
    }

    @PostMapping // El endpoint será POST /api/pagos
    @PreAuthorize("hasAnyAuthority('USUARIO_FINAL', 'ADMINISTRATIVO')")
    public ResponseEntity<?> processPayment(@RequestBody SolicitudPago solicitud, Authentication authentication) {
        try {
            // Obtenemos el ID del usuario logueado por seguridad
            String usuarioId = authentication.getName();
            
            // Delegamos toda la lógica al servicio
            String pagoId = pagoService.processPayment(solicitud, usuarioId);
            
            // Devolvemos un JSON amigable para Flutter
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Pago procesado exitosamente.");
            response.put("pagoId", pagoId);
            
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(Map.of("error", e.getMessage()), HttpStatus.BAD_REQUEST);
        }
    }
}