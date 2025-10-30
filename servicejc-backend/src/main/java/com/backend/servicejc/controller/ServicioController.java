package com.backend.servicejc.controller;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.backend.servicejc.service.ServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:8080/") // ¡Añade esta línea!
public class ServicioController {

    private final ServicioService servicioService;

    @Autowired
    public ServicioController(ServicioService servicioService) {
        this.servicioService = servicioService;
    }

    @GetMapping("/servicios")
    public List<Servicio> getAllCategorias() throws ExecutionException, InterruptedException {
        return servicioService.getAllCategorias();
    }

    @GetMapping("/servicios/{id}/productos")
    public List<Producto> getProductosByServicioId(@PathVariable String id) throws ExecutionException, InterruptedException {
        return servicioService.getProductosByServicioId(id);
    }
}