package com.backend.servicejc.controller;

import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.service.TecnicoService;
import com.backend.servicejc.service.AdminDashboardService;
import com.backend.servicejc.service.UsuarioService; // Importación necesaria
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize; // Importación necesaria
import org.springframework.web.bind.annotation.*;
import java.util.Date;
import java.util.List; // Importación necesaria
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final TecnicoService tecnicoService;
    private final AdminDashboardService dashboardService;
    private final UsuarioService usuarioService;

    @Autowired
    public AdminController(TecnicoService tecnicoService, AdminDashboardService dashboardService, UsuarioService usuarioService) {
        this.tecnicoService = tecnicoService;
        this.dashboardService = dashboardService;
        this.usuarioService = usuarioService;
    }

    @PostMapping("/tecnicos")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
    public ResponseEntity<?> crearTecnico(@RequestBody Usuario tecnico) throws ExecutionException, InterruptedException {
        tecnicoService.crearTecnico(tecnico);
        return ResponseEntity.ok("Técnico creado exitosamente");
    }

    @GetMapping("/metrics")
    @PreAuthorize("hasAnyAuthority('ADMINISTRATIVO', 'TECNICO')")
    public ResponseEntity<Map<String, Object>> getMetrics() throws ExecutionException, InterruptedException {
        Map<String, Object> metrics = dashboardService.getMetrics();
        return ResponseEntity.ok(metrics);
    }
    
    @DeleteMapping("/tecnicos/{tecnicoId}")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
    public ResponseEntity<?> eliminarTecnico(@PathVariable String tecnicoId) throws ExecutionException, InterruptedException {
        try {
            tecnicoService.eliminarTecnico(tecnicoId);
            return ResponseEntity.ok("Técnico eliminado exitosamente");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al eliminar el técnico: " + e.getMessage());
        }
    }

    @PatchMapping("/citas/{citaId}/reasignar")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
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

    @GetMapping("/clients")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
    public List<Usuario> getClients() {
        return usuarioService.getUsersByRole("USUARIO_FINAL");
    }

    @DeleteMapping("/clients/{userId}")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
    public ResponseEntity<Void> deleteUser(@PathVariable String userId) {
        usuarioService.deleteUser(userId);
        return ResponseEntity.noContent().build();
    }
}