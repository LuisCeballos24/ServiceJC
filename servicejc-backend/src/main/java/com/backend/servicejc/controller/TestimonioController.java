package com.backend.servicejc.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import com.backend.servicejc.model.TestimonioModel;
import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.service.TestimonioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication; // O tu modelo de usuario
import com.backend.servicejc.service.UsuarioService;

import java.util.List;

@RestController
@RequestMapping("/api/testimonios")
public class TestimonioController {

    private final TestimonioService testimonioService;

    @Autowired
    public TestimonioController(TestimonioService testimonioService) {
        this.testimonioService = testimonioService;
    }

    @GetMapping("/destacados")
    public ResponseEntity<?> getDestacados() {
        System.out.println("🔵 1. Entrando al endpoint /destacados");

        try {
            System.out.println("🔵 2. Llamando al servicio...");
            List<TestimonioModel> lista = testimonioService.getTestimoniosDestacados();

            System.out.println("🔵 3. Servicio respondió. Datos recibidos: " + (lista != null ? lista.size() : "NULL"));

            if (lista != null && !lista.isEmpty()) {
                // Intentamos leer el primer objeto para ver si explota aquí
                System.out.println("🔵 4. Verificando primer objeto: " + lista.get(0).getNombreCliente());
            }

            return ResponseEntity.ok(lista);

        } catch (Exception e) {
            System.err.println("🔴 5. ¡ERROR CAPTURADO EN CONTROLLER!");
            e.printStackTrace(); // Esto OBLIGA a imprimir el error en la consola
            return ResponseEntity.status(500).body("Error interno: " + e.getMessage());
        }
    }

    @GetMapping("/seed")
    public String seedData() {
        try {
            testimonioService.seedTestimonios();
            return "✅ Seed ejecutado correctamente.";
        } catch (Exception e) {
            return "❌ Error en seed: " + e.getMessage();
        }
    }
    @Autowired
    private UsuarioService usuarioService;
    @PostMapping("/crear")
    public ResponseEntity<?> crearTestimonio(@RequestBody TestimonioModel testimonio, Authentication authentication) {
        try {
            // 1. Obtenemos el ID del usuario desde el Token (Spring Security ya lo validó)
            String userId = authentication.getName(); 
            
            // 2. Buscamos al Usuario completo en Firestore
            Usuario usuarioReal = usuarioService.getUsuarioById(userId); 

            if (usuarioReal == null) {
                return ResponseEntity.status(404).body("Usuario no encontrado.");
            }

            // 3. ✅ ASIGNAMOS EL NOMBRE REAL DEL USUARIO AL TESTIMONIO
            // Aquí usamos el getter que acabamos de agregar en el Modelo Usuario
            testimonio.setNombreCliente(usuarioReal.getNombre()); 
            
            // 4. Configuraciones automáticas
            testimonio.setDestacado(true); 

            // 5. Guardar
            String idNuevo = testimonioService.guardarTestimonio(testimonio);
            
            return ResponseEntity.ok("Comentario guardado correctamente con ID: " + idNuevo);

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al guardar: " + e.getMessage());
        }
    }
}