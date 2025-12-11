package com.backend.servicejc.controller;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.backend.servicejc.model.CategoriaPrincipalModel; // 💡 Importar el nuevo modelo
import com.backend.servicejc.service.ServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:8080/")
public class ServicioController {

    private final ServicioService servicioService;

    @Autowired
    public ServicioController(ServicioService servicioService) {
        this.servicioService = servicioService;
    }

    // 💡 NIVEL 1: Endpoint para obtener las Categorías Principales (Pantalla Principal)
    @GetMapping("/categorias_principales")
    public List<CategoriaPrincipalModel> getCategoriasPrincipales() throws ExecutionException, InterruptedException {
        // La implementación del servicio ahora usa la nueva colección
        return servicioService.fetchCategoriasPrincipales();
    }

    // 💡 NIVEL 2: Endpoint modificado para filtrar servicios por Categoría Principal ID
    @GetMapping("/servicios")
    public List<Servicio> getServicios(
        @RequestParam(required = false) String categoriaPrincipalId
    ) throws ExecutionException, InterruptedException {
        if (categoriaPrincipalId != null && !categoriaPrincipalId.isEmpty()) {
            // Si el ID está presente, usamos el nuevo método de filtrado
            return servicioService.fetchServiciosByCategoriaId(categoriaPrincipalId);
        } else {
            // Si no hay ID, mantenemos la lógica antigua (opcional, pero seguro)
            return servicioService.getAllCategorias();
        }
    }

    // Endpoint para obtener los productos de un servicio específico (Nivel 3)
    @GetMapping("/servicios/{id}/productos")
    public List<Producto> getProductosByServicioId(@PathVariable String id) throws ExecutionException, InterruptedException {
        return servicioService.getProductosByServicioId(id);
    }
}