package com.backend.servicejc.controller;

import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.service.TecnicoService;
import com.backend.servicejc.service.AdminDashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private TecnicoService tecnicoService;
    @Autowired
    private AdminDashboardService dashboardService;

    @PostMapping("/tecnicos")
    public ResponseEntity<?> crearTecnico(@RequestBody Usuario tecnico) throws ExecutionException, InterruptedException {
        tecnicoService.crearTecnico(tecnico);
        return ResponseEntity.ok("Técnico creado exitosamente");
    }

    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> getMetrics() throws ExecutionException, InterruptedException {
        Map<String, Object> metrics = dashboardService.getMetrics();
        return ResponseEntity.ok(metrics);
    }
    
    @DeleteMapping("/tecnicos/{tecnicoId}")
    public ResponseEntity<?> eliminarTecnico(@PathVariable String tecnicoId) throws ExecutionException, InterruptedException {
        try {
            tecnicoService.eliminarTecnico(tecnicoId);
            return ResponseEntity.ok("Técnico eliminado exitosamente");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al eliminar el técnico: " + e.getMessage());
        }
    }

    // Nuevo endpoint para reasignar una cita
    @PatchMapping("/citas/{citaId}/reasignar")
    public ResponseEntity<?> reasignarCita(@PathVariable String citaId, @RequestBody Map<String, Object> body) throws ExecutionException, InterruptedException {
        try {
            String nuevoTecnicoId = (String) body.get("nuevoTecnicoId");
            Date nuevaFechaHora = (Date) body.get("nuevaFechaHora");

            tecnicoService.reasignarHorario(citaId, nuevoTecnicoId, nuevaFechaHora);
            return ResponseEntity.ok("Horario de la cita reasignado exitosamente");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al reasignar el horario de la cita: " + e.getMessage());
        }
    }
}