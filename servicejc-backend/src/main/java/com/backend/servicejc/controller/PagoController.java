package com.backend.servicejc.controller;

import com.backend.servicejc.model.Pago;
import com.backend.servicejc.service.PagoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/pagos")
public class PagoController {

    private final PagoService pagoService;

    public PagoController(PagoService pagoService) {
        this.pagoService = pagoService;
    }

    @PostMapping
    public ResponseEntity<String> processPayment(@RequestBody Pago pago) {
        try {
            pagoService.processPayment(pago);
            return new ResponseEntity<>("Pago procesado exitosamente.", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}