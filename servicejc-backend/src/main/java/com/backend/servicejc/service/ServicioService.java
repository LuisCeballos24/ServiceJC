package com.backend.servicejc.service;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.backend.servicejc.model.CategoriaPrincipalModel;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import com.google.cloud.firestore.FieldPath;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.Map;

@Service
public class ServicioService {

    private final Firestore firestore;

    @Autowired
    public ServicioService(Firestore firestore) {
        this.firestore = firestore;
    }

    // --- MÉTODOS DE LECTURA (GET) ---

    public List<Servicio> getAllCategorias() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream().map(doc -> doc.toObject(Servicio.class)).collect(Collectors.toList());
    }

    public List<Producto> getProductosByServicioId(String servicioId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("productos")
                .whereEqualTo("servicioId", servicioId)
                .get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream().map(doc -> doc.toObject(Producto.class)).collect(Collectors.toList());
    }

    // Obtiene la lista para la PANTALLA PRINCIPAL
    public List<CategoriaPrincipalModel> fetchCategoriasPrincipales() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("categorias_principales").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream().map(doc -> doc.toObject(CategoriaPrincipalModel.class)).collect(Collectors.toList());
    }

    public List<Servicio> fetchServiciosByCategoriaId(String categoriaPrincipalId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios")
                .whereEqualTo("categoriaPrincipalId", categoriaPrincipalId)
                .get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream().map(doc -> doc.toObject(Servicio.class)).collect(Collectors.toList());
    }

    public List<Producto> getProductosByIds(List<String> productoIds) throws ExecutionException, InterruptedException {
        if (productoIds == null || productoIds.isEmpty()) return new ArrayList<>();
        QuerySnapshot querySnapshot = firestore.collection("productos")
                .whereIn(FieldPath.documentId(), productoIds).get().get();
        return querySnapshot.getDocuments().stream()
                .map(doc -> {
                    Producto p = doc.toObject(Producto.class);
                    if (p != null) p.setId(doc.getId());
                    return p;
                })
                .filter(p -> p != null).collect(Collectors.toList());
    }

    // --- 🟢 NUEVA LISTA DE LA PANTALLA PRINCIPAL ---
    // Esta lista define lo que se verá en el 'Home'.
    private final List<String> LISTA_PANTALLA_PRINCIPAL = List.of(
        "Aire Acondicionado (Instalación y Mantenimiento)",
        "Trabajos de Repello Bofo de Edificios",
        "Plomería",
        "Filtraciones",
        "Limpieza de sillones",
        "Ebanistas",
        "Electricidad",
        "Mantenimientos Preventivos",
        "Instalaciones Decorativas",
        "Trabajos de Pintura Exterior de Edificios",
        "Limpieza General",
        "Construcción",
        "Trabajo de Limpieza de Vidrio y Cambio de Silicón de Ventanas",
        "Revestimientos de piso y paredes",
        "Remodelaciones",
        "Limpieza de Canales de Techado",
        "Pintores",
        "Aluminio y Vidrio",
        "Paneles solares",
        "Instalaciones Menores",
        "Inspecciones con Dron Profesional: Herramienta moderna para la evaluación rápida y segura del estado de la azotea, fachada y repello bofo sin el costo de andamios.",
        "Soldadura",
        "Chefs",
        "Valet Parking / Conductor Designado: Movilidad Exclusiva. Servicios de logística y seguridad para los invitados y la familia.",
        "Limpieza de Cocinas, Baños, Recámaras: Servicios de desinfección y limpieza detallada, que son importantes para la prevención de enfermedades.",
        "Saloneros",
        "Bartenders",
        "Decoradores",
        "Movilizacion y acomodo de moviliario",
        "Cielo raso"
    );

    // --- MÉTODO DE POBLAMIENTO (SEED) ---
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        // Verificar si ya existen datos para no duplicar
        ApiFuture<QuerySnapshot> check = firestore.collection("categorias_principales").get();
        if (!check.get().isEmpty()) {
            System.out.println("⚠️ La base de datos ya tiene datos. No se realizará la inserción.");
            return;
        }

        System.out.println("🚀 Iniciando población de la nueva lista principal...");

        // Mapa para guardar los IDs generados de los servicios y poder asignarles productos
        Map<String, String> mapaServiciosIds = new HashMap<>();

        // 1. Crear Categorías Principales y Servicios Automáticos
        for (String nombreItem : LISTA_PANTALLA_PRINCIPAL) {
            
            // A. Insertar en 'categorias_principales' (Para que salga en el Home)
            Map<String, Object> categoria = new HashMap<>();
            categoria.put("nombre", nombreItem); 
            // Usamos un ID generado automáticamente por Firestore
            ApiFuture<DocumentReference> catRef = firestore.collection("categorias_principales").add(categoria);
            String categoriaId = catRef.get().getId();

            // B. Crear un Servicio espejo vinculado a esa categoría (Para mantener la lógica de navegación)
            Map<String, Object> servicio = new HashMap<>();
            servicio.put("nombre", nombreItem); // El servicio se llama igual
            servicio.put("categoriaPrincipalId", categoriaId); // Enlace
            
            ApiFuture<DocumentReference> servRef = firestore.collection("servicios").add(servicio);
            String servicioId = servRef.get().getId();

            // Guardamos el ID en el mapa usando el nombre como clave para buscarlo abajo
            mapaServiciosIds.put(nombreItem, servicioId);
        }

        // 2. Crear Productos y asignarlos a los IDs generados
        List<Producto> productos = new ArrayList<>();
        final Double COSTO_INSPECCION = 10.00;

        // --- ASIGNACIÓN DE PRODUCTOS A LA NUEVA LISTA ---

        String idAire = mapaServiciosIds.get("Aire Acondicionado (Instalación y Mantenimiento)");
        if (idAire != null) {
            productos.add(new Producto(null, "Limpieza y Mantenimiento de A/C (9 a 18 BTU)", 30.00, idAire));
            productos.add(new Producto(null, "Carga de Válvula o Recarga de Filtro", 25.00, idAire));
            productos.add(new Producto(null, "Inspección y Cotización: Instalación Nueva o Reparación Mayor", COSTO_INSPECCION, idAire));
        }

        String idRepello = mapaServiciosIds.get("Trabajos de Repello Bofo de Edificios");
        if (idRepello != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Repello Bofo en Viviendas o Edificios", COSTO_INSPECCION, idRepello));
        }

        String idPlomeria = mapaServiciosIds.get("Plomería");
        if (idPlomeria != null) {
            productos.add(new Producto(null, "Instalación/Cambio: Grifo de Lavamanos/Fregador", 30.00, idPlomeria));
            productos.add(new Producto(null, "Instalación/Revisión: Ferretería de Inodoro", 80.00, idPlomeria));
            productos.add(new Producto(null, "Destape de Desagües y Tuberías", 30.00, idPlomeria));
            productos.add(new Producto(null, "Inspección y Cotización de Proyecto Nuevo", COSTO_INSPECCION, idPlomeria));
        }

        String idFiltraciones = mapaServiciosIds.get("Filtraciones");
        if (idFiltraciones != null) {
            productos.add(new Producto(null, "Inspección Visual para Determinación de Herramienta", COSTO_INSPECCION, idFiltraciones));
            productos.add(new Producto(null, "Inspección con Cámara Térmica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con Dron (Fachadas)", 150.00, idFiltraciones));
        }

        String idSillones = mapaServiciosIds.get("Limpieza de sillones");
        if (idSillones != null) {
            productos.add(new Producto(null, "Limpieza de Sillón (1 puesto)", 40.00, idSillones));
            productos.add(new Producto(null, "Limpieza de Sillón Grande (5 puestos)", 75.00, idSillones));
            productos.add(new Producto(null, "Limpieza de Comedor (4 puestos)", 40.00, idSillones));
        }

        String idEbanistas = mapaServiciosIds.get("Ebanistas");
        if (idEbanistas != null) {
            productos.add(new Producto(null, "Instalación: Puerta de Madera", 40.00, idEbanistas));
            productos.add(new Producto(null, "Instalación: Cerradura", 25.00, idEbanistas));
            productos.add(new Producto(null, "Inspección y Cotización: Muebles a medida", COSTO_INSPECCION, idEbanistas));
        }

        String idElectricidad = mapaServiciosIds.get("Electricidad");
        if (idElectricidad != null) {
            productos.add(new Producto(null, "Instalación: Lámpara/Bombilla/Toma", 25.00, idElectricidad));
            productos.add(new Producto(null, "Revisión: Breaker/Caja de Fusibles", 40.00, idElectricidad));
            productos.add(new Producto(null, "Inspección y Cotización General", COSTO_INSPECCION, idElectricidad));
        }

        String idMantPrev = mapaServiciosIds.get("Mantenimientos Preventivos");
        if (idMantPrev != null) {
            productos.add(new Producto(null, "Levantamiento para Plan de Mantenimiento Preventivo", COSTO_INSPECCION, idMantPrev));
        }

        String idDecorativas = mapaServiciosIds.get("Instalaciones Decorativas");
        if (idDecorativas != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Paneles, Vinilos, Microcemento", COSTO_INSPECCION, idDecorativas));
        }

        String idPinturaExt = mapaServiciosIds.get("Trabajos de Pintura Exterior de Edificios");
        if (idPinturaExt != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Fachadas/Azoteas/Fosos", COSTO_INSPECCION, idPinturaExt));
        }

        String idLimpiezaGen = mapaServiciosIds.get("Limpieza General");
        if (idLimpiezaGen != null) {
            productos.add(new Producto(null, "Limpieza de Estacionamiento con Hidrolavadora", 75.00, idLimpiezaGen));
            productos.add(new Producto(null, "Inspección por Solicitud Específica", COSTO_INSPECCION, idLimpiezaGen));
        }

        String idConstruccion = mapaServiciosIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Proyectos de Construcción", COSTO_INSPECCION, idConstruccion));
        }

        String idVentanas = mapaServiciosIds.get("Trabajo de Limpieza de Vidrio y Cambio de Silicón de Ventanas");
        if (idVentanas != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Mantenimiento de Ventanas", COSTO_INSPECCION, idVentanas));
        }

        String idRevestimientos = mapaServiciosIds.get("Revestimientos de piso y paredes");
        if (idRevestimientos != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Instalación de Pisos/Azulejos", COSTO_INSPECCION, idRevestimientos));
        }

        String idRemodelaciones = mapaServiciosIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Remodelación General", COSTO_INSPECCION, idRemodelaciones));
        }

        String idCanales = mapaServiciosIds.get("Limpieza de Canales de Techado");
        if (idCanales != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Limpieza de Canaletas", COSTO_INSPECCION, idCanales));
        }

        String idPintores = mapaServiciosIds.get("Pintores");
        if (idPintores != null) {
            productos.add(new Producto(null, "Costo por m² (Mano de obra)", 8.00, idPintores));
            productos.add(new Producto(null, "Pintura en Interiores (por m²)", 15.00, idPintores));
            productos.add(new Producto(null, "Inspección y Cotización: Pintura Especializada", COSTO_INSPECCION, idPintores));
        }

        String idAluminio = mapaServiciosIds.get("Aluminio y Vidrio");
        if (idAluminio != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Ventanas y Puertas de Vidrio", COSTO_INSPECCION, idAluminio));
        }

        String idSolares = mapaServiciosIds.get("Paneles solares");
        if (idSolares != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Instalación o Mantenimiento Solar", COSTO_INSPECCION, idSolares));
        }

        String idMenores = mapaServiciosIds.get("Instalaciones Menores");
        if (idMenores != null) {
            productos.add(new Producto(null, "Instalación de Cuadro/Espejo", 25.00, idMenores));
            productos.add(new Producto(null, "Instalación de Soporte de TV", 30.00, idMenores));
            productos.add(new Producto(null, "Inspección y Cotización Varias", COSTO_INSPECCION, idMenores));
        }

        String idDron = mapaServiciosIds.get("Inspecciones con Dron Profesional: Herramienta moderna para la evaluación rápida y segura del estado de la azotea, fachada y repello bofo sin el costo de andamios.");
        if (idDron != null) {
            productos.add(new Producto(null, "Inspección de Techados y Fachadas", COSTO_INSPECCION, idDron));
            productos.add(new Producto(null, "Servicio de Dron para Eventos", COSTO_INSPECCION, idDron));
        }

        String idSoldadura = mapaServiciosIds.get("Soldadura");
        if (idSoldadura != null) {
            productos.add(new Producto(null, "Instalación de Puerta de Hierro/Verja", 75.00, idSoldadura));
            productos.add(new Producto(null, "Reparación de Pasamanos", 50.00, idSoldadura));
            productos.add(new Producto(null, "Inspección y Cotización", COSTO_INSPECCION, idSoldadura));
        }

        String idChefs = mapaServiciosIds.get("Chefs");
        if (idChefs != null) {
            productos.add(new Producto(null, "Contratación: Cocinero (2 horas)", 60.00, idChefs));
            productos.add(new Producto(null, "Hora adicional Cocinero", 30.00, idChefs));
        }

        String idValet = mapaServiciosIds.get("Valet Parking / Conductor Designado: Movilidad Exclusiva. Servicios de logística y seguridad para los invitados y la familia.");
        if (idValet != null) {
            productos.add(new Producto(null, "Logística: Valet Parking (2 horas)", 40.00, idValet));
            productos.add(new Producto(null, "Logística: Conductor Designado (2 horas)", 70.00, idValet));
        }

        String idLimpiezaEsp = mapaServiciosIds.get("Limpieza de Cocinas, Baños, Recámaras: Servicios de desinfección y limpieza detallada, que son importantes para la prevención de enfermedades.");
        if (idLimpiezaEsp != null) {
            productos.add(new Producto(null, "Limpieza Profunda de Cocina", 50.00, idLimpiezaEsp));
            productos.add(new Producto(null, "Limpieza Profunda de Baño", 50.00, idLimpiezaEsp));
            productos.add(new Producto(null, "Limpieza Profunda de Recámara", 50.00, idLimpiezaEsp));
        }

        String idSaloneros = mapaServiciosIds.get("Saloneros");
        if (idSaloneros != null) {
            productos.add(new Producto(null, "Contratación: Salonero (2 horas)", 50.00, idSaloneros));
            productos.add(new Producto(null, "Hora adicional Salonero", 25.00, idSaloneros));
        }

        String idBartenders = mapaServiciosIds.get("Bartenders");
        if (idBartenders != null) {
            productos.add(new Producto(null, "Contratación: Bartender (2 horas)", 60.00, idBartenders));
            productos.add(new Producto(null, "Hora adicional Bartender", 30.00, idBartenders));
        }

        String idDecoradores = mapaServiciosIds.get("Decoradores");
        if (idDecoradores != null) {
            productos.add(new Producto(null, "Contratación: Decorador (2 horas)", 60.00, idDecoradores));
            productos.add(new Producto(null, "Inspección y Cotización de Decoración", COSTO_INSPECCION, idDecoradores));
        }

        String idMovilizacion = mapaServiciosIds.get("Movilizacion y acomodo de moviliario");
        if (idMovilizacion != null) {
            productos.add(new Producto(null, "Logística: Movilización de Mobiliario (2 horas)", 80.00, idMovilizacion));
            productos.add(new Producto(null, "Inspección para Mudanzas Pequeñas", COSTO_INSPECCION, idMovilizacion));
        }

        String idCielo = mapaServiciosIds.get("Cielo raso");
        if (idCielo != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Cielo Raso", COSTO_INSPECCION, idCielo));
        }

        // 3. Inserción Final
        for (Producto p : productos) {
            firestore.collection("productos").add(p);
        }

        System.out.println("✅ Base de datos poblada con la nueva lista de Pantalla Principal.");
    }
}