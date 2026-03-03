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

    // 💡 MODIFICADO: Trae las categorías y las ORDENA según el Excel antes de mandarlas a Flutter
    public List<CategoriaPrincipalModel> fetchCategoriasPrincipales() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        // 1. Convertimos los documentos a nuestra lista
        List<CategoriaPrincipalModel> categorias = documents.stream().map(doc -> {
            Servicio serv = doc.toObject(Servicio.class);
            return new CategoriaPrincipalModel(serv.getId(), serv.getNombre()); 
        }).collect(Collectors.toList());

        // 2. ORDENAMOS LA LISTA basándonos en tu LISTA_PANTALLA_PRINCIPAL
        categorias.sort((c1, c2) -> {
            int index1 = LISTA_PANTALLA_PRINCIPAL.indexOf(c1.getNombre());
            int index2 = LISTA_PANTALLA_PRINCIPAL.indexOf(c2.getNombre());
            
            // Si por alguna razón un servicio no está en la lista, lo mandamos al final
            if (index1 == -1) index1 = 999;
            if (index2 == -1) index2 = 999;
            
            return Integer.compare(index1, index2);
        });

        // 3. Devolvemos la lista perfectamente ordenada a Flutter
        return categorias;
    }

    public List<Servicio> fetchServiciosByCategoriaId(String categoriaPrincipalId) throws ExecutionException, InterruptedException {
        return new ArrayList<>(); 
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

    // LISTA DE CATEGORÍAS
    private final List<String> LISTA_PANTALLA_PRINCIPAL = List.of(
        "Aire acondicionado",
        "Repello bofo viviendas, edificio",
        "Plomería",
        "Filtraciones",
        "Limpieza textil",
        "Ebanistería",
        "Electricidad",
        "Mantenimientos preventivos",
        "Instalaciones decorativas",
        "Pintura exterior",
        "Limpieza general",
        "Construcción",
        "Mantenimiento de ventanas",
        "Revestimiento de pisos y paredes",
        "Remodelaciones",
        "Limpieza de canales",
        "Pintura",
        "Aluminio y vidrio",
        "Energía solar",
        "Instalaciones menores",
        "Inspección con drones profesional",
        "Soldadura",
        "Reuniones y festividades",
        "Cielo rasos"
    );

    // --- MÉTODO DE POBLAMIENTO PLANO (SEED) ---
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> check = firestore.collection("servicios").get();
        if (!check.get().isEmpty()) {
            System.out.println("⚠️ La colección 'servicios' ya tiene datos. No se realizará la inserción.");
            return;
        }

        System.out.println("🚀 Iniciando población plana según los Excel (Servicios -> Productos)...");
        Map<String, String> mapaServiciosIds = new HashMap<>();

        // Crear servicios (Página 1)
        for (String nombreItem : LISTA_PANTALLA_PRINCIPAL) {
            Map<String, Object> servicio = new HashMap<>();
            servicio.put("nombre", nombreItem);
            
            ApiFuture<DocumentReference> servRef = firestore.collection("servicios").add(servicio);
            String servicioId = servRef.get().getId();
            mapaServiciosIds.put(nombreItem, servicioId);
        }

        List<Producto> productos = new ArrayList<>();
        final Double COSTO_INSPECCION = 10.00; 

        // =========================================================
        // PRODUCTOS Y PRECIOS EXTRAÍDOS DIRECTO DE TUS EXCEL
        // =========================================================

        // AIRE ACONDICIONADO
        String idAire = mapaServiciosIds.get("Aire acondicionado");
        if (idAire != null) {
            productos.add(new Producto(null, "Limpieza de aire de 9 a 18 BTU", 30.00, idAire));
            productos.add(new Producto(null, "Proyectos nuevos / Reparaciones (Inspección)", COSTO_INSPECCION, idAire));
        }

        // REPELLO BOFO
        String idRepello = mapaServiciosIds.get("Repello bofo viviendas, edificio");
        if (idRepello != null) {
            productos.add(new Producto(null, "Viviendas (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Oficinas (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Instituciones (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Propiedades verticales/horizontales (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Fábricas (Inspección)", COSTO_INSPECCION, idRepello));
        }

        // PLOMERÍA
        String idPlomeria = mapaServiciosIds.get("Plomería");
        if (idPlomeria != null) {
            productos.add(new Producto(null, "Grifo de lavamanos de 2 mangueras", 30.00, idPlomeria));
            productos.add(new Producto(null, "Grifo de fregador de 2 mangueras", 30.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de ángulo", 30.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de chorro", 30.00, idPlomeria));
            productos.add(new Producto(null, "Ferretería de inodoro", 80.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de silicón", 30.00, idPlomeria));
            productos.add(new Producto(null, "Proyectos nuevos (Inspección)", COSTO_INSPECCION, idPlomeria));
        }

        // FILTRACIONES
        String idFiltraciones = mapaServiciosIds.get("Filtraciones");
        if (idFiltraciones != null) {
            productos.add(new Producto(null, "Inspección visual para determinar herramienta (Inspección)", 10.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con cámara térmica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con cámara endoscópica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con ultra sonido", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Revisión con dron filtraciones en fachadas", 150.00, idFiltraciones));
        }

        // LIMPIEZA TEXTIL
        String idLimpiezaTextil = mapaServiciosIds.get("Limpieza textil");
        if (idLimpiezaTextil != null) {
            productos.add(new Producto(null, "Sillón 1 puesto", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón 2 puestos", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón 3 puestos", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón grande tipo L", 65.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón grande 5 puestos", 75.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor 2 puestos", 30.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor 4 puestos", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor 8 puestos", 65.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Colchones (unidad)", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones sedán", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería sedán", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso (alfombra de fábrica) sedán", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones camioneta 1", 65.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería camioneta 1", 65.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso camioneta 1", 65.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones camioneta 2", 80.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería camioneta 2", 80.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso camioneta 2", 80.00, idLimpiezaTextil));
        }

        // EBANISTERÍA
        String idEbanisteria = mapaServiciosIds.get("Ebanistería");
        if (idEbanisteria != null) {
            productos.add(new Producto(null, "Instalación de puertas de madera (sin cerradura)", 40.00, idEbanisteria));
            productos.add(new Producto(null, "Instalación de cerraduras en puertas de madera", 25.00, idEbanisteria));
            productos.add(new Producto(null, "Instalación de jambas de madera", 25.00, idEbanisteria));
            productos.add(new Producto(null, "Renovaciones de mobiliario (Inspección)", COSTO_INSPECCION, idEbanisteria));
            productos.add(new Producto(null, "Reparaciones de mobiliario (Inspección)", COSTO_INSPECCION, idEbanisteria));
            productos.add(new Producto(null, "Confección de mobiliario nuevo (Inspección)", COSTO_INSPECCION, idEbanisteria));
        }

        // ELECTRICIDAD
        String idElectricidad = mapaServiciosIds.get("Electricidad");
        if (idElectricidad != null) {
            productos.add(new Producto(null, "Instalación de Lámpara", 25.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de Tomas", 25.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de Interruptores", 25.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de Breker", 25.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de Abanico", 25.00, idElectricidad));
            productos.add(new Producto(null, "Proyectos nuevos (Inspección)", COSTO_INSPECCION, idElectricidad));
        }

        // MANTENIMIENTOS PREVENTIVOS
        String idMantenimientos = mapaServiciosIds.get("Mantenimientos preventivos");
        if (idMantenimientos != null) {
            productos.add(new Producto(null, "Viviendas (Inspección)", COSTO_INSPECCION, idMantenimientos));
            productos.add(new Producto(null, "Oficinas (Inspección)", COSTO_INSPECCION, idMantenimientos));
            productos.add(new Producto(null, "Instituciones (Inspección)", COSTO_INSPECCION, idMantenimientos));
            productos.add(new Producto(null, "Propiedades verticales/horizontales (Inspección)", COSTO_INSPECCION, idMantenimientos));
            productos.add(new Producto(null, "Fábricas (Inspección)", COSTO_INSPECCION, idMantenimientos));
        }

        // INSTALACIONES DECORATIVAS
        String idInstDecorativas = mapaServiciosIds.get("Instalaciones decorativas");
        if (idInstDecorativas != null) {
            productos.add(new Producto(null, "Paneles decorativos 3D (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles de PVC textura mármol (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles tipo piedra (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Separador de ambiente tipo pérgola (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles WPC (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Follaje artificial (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Microcemento (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Papel tapiz (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Impresión e instalación de vinilos (Inspección)", COSTO_INSPECCION, idInstDecorativas));
        }

        // PINTURA EXTERIOR
        String idPinturaExt = mapaServiciosIds.get("Pintura exterior");
        if (idPinturaExt != null) {
            productos.add(new Producto(null, "Pintura de fachadas de edificios (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Reparación de fisuras en fachadas (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Reparación de albañilería en general (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Impermeabilización de filtraciones en fachadas (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de estacionamientos (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de azoteas (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de foso de ascensores (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de lobby (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de escaleras de servicio (Inspección)", COSTO_INSPECCION, idPinturaExt));
        }

        // LIMPIEZA GENERAL
        String idLimpiezaGeneral = mapaServiciosIds.get("Limpieza general");
        if (idLimpiezaGeneral != null) {
            productos.add(new Producto(null, "Describe tu solicitud (Inspección)", 10.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de cocina", 50.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de recámara", 50.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de sala", 50.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de baño", 50.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de garaje", 50.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Áreas sociales", 60.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de baños (múltiples)", 60.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de gimnasios", 60.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de veredas", 170.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de estacionamiento con hidrolavadora", 75.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de rampas", 30.00, idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de tinas de basura", 31.00, idLimpiezaGeneral));
        }

        // CONSTRUCCIÓN
        String idConstruccion = mapaServiciosIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null, "Construcción de hormigón (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Construcción metálica (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Construcción liviana (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Paneles Estructurales Aislados (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Paneles prefabricados de concreto (Inspección)", COSTO_INSPECCION, idConstruccion));
        }

        // MANTENIMIENTO DE VENTANAS
        String idVentanas = mapaServiciosIds.get("Mantenimiento de ventanas");
        if (idVentanas != null) {
            productos.add(new Producto(null, "Cambio de sello de goma de vidrio (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Cambio de silicón (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Limpieza de riel (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Lubricación de ferretería (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Limpieza de vidrios (Inspección)", COSTO_INSPECCION, idVentanas));
        }

        // REVESTIMIENTO DE PISOS Y PAREDES
        String idRevestimiento = mapaServiciosIds.get("Revestimiento de pisos y paredes");
        if (idRevestimiento != null) {
            productos.add(new Producto(null, "Azulejos (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Mozaiquillos (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Baldosas (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Mármol (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Cuarzo (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Porcelanatos (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Piso CPS (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Micro cemento (Inspección)", COSTO_INSPECCION, idRevestimiento));
            productos.add(new Producto(null, "Resina epóxica (Inspección)", COSTO_INSPECCION, idRevestimiento));
        }

        // REMODELACIONES
        String idRemodelaciones = mapaServiciosIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null, "Planificación y diseño (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Demoliciones (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Instalaciones (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Albañilería (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Sistemas de drenaje (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Pérgolas (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Muros (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Portales (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Piscinas (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Reformas estructurales (Inspección)", COSTO_INSPECCION, idRemodelaciones));
        }

        // LIMPIEZA DE CANALES
        String idCanales = mapaServiciosIds.get("Limpieza de canales");
        if (idCanales != null) {
            productos.add(new Producto(null, "Limpieza de canaletas de techados (Inspección)", COSTO_INSPECCION, idCanales));
            productos.add(new Producto(null, "Limpieza de canales pluviales (Inspección)", COSTO_INSPECCION, idCanales));
        }

        // PINTURA
        String idPintura = mapaServiciosIds.get("Pintura");
        if (idPintura != null) {
            productos.add(new Producto(null, "Aplicación de pintura arquitectónica (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Impermeabilizaciones de techo y losas (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura texturizada (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura satinada (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura grado alimenticio (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura epóxica (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura poliuretano (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Aplicación de pintura laca y esmaltes (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Proyectos artísticos (Inspección)", COSTO_INSPECCION, idPintura));
            productos.add(new Producto(null, "Pintura de piscinas (Inspección)", COSTO_INSPECCION, idPintura));
        }

        // ALUMINIO Y VIDRIO
        String idAluminio = mapaServiciosIds.get("Aluminio y vidrio");
        if (idAluminio != null) {
            productos.add(new Producto(null, "Instalación de puerta (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Instalación de verja (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Reparación de pasamanos (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Instalación de cerradura (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Mantenimiento de puertas corredizas (Inspección)", COSTO_INSPECCION, idAluminio));
        }

        // ENERGÍA SOLAR
        String idEnergia = mapaServiciosIds.get("Energía solar");
        if (idEnergia != null) {
            productos.add(new Producto(null, "Mantenimiento (Inspección)", COSTO_INSPECCION, idEnergia));
            productos.add(new Producto(null, "Reparaciones (Inspección)", COSTO_INSPECCION, idEnergia));
            productos.add(new Producto(null, "Suministros e instalaciones nuevas (Inspección)", COSTO_INSPECCION, idEnergia));
        }

        // INSTALACIONES MENORES
        String idInstMenores = mapaServiciosIds.get("Instalaciones menores");
        if (idInstMenores != null) {
            productos.add(new Producto(null, "Instalación de cuadro", 25.00, idInstMenores));
            productos.add(new Producto(null, "Instalación de tablillas", 25.00, idInstMenores));
            productos.add(new Producto(null, "Soporte de TV hasta 50 pulgadas", 30.00, idInstMenores));
            productos.add(new Producto(null, "Soporte de TV más de 50 pulgadas", 50.00, idInstMenores));
            productos.add(new Producto(null, "Instalación de cortina", 25.00, idInstMenores));
            productos.add(new Producto(null, "Elemento decorativo", 25.00, idInstMenores));
        }

        // INSPECCIÓN CON DRONES
        String idDrones = mapaServiciosIds.get("Inspección con drones profesional");
        if (idDrones != null) {
            productos.add(new Producto(null, "Ceremonias (Inspección)", COSTO_INSPECCION, idDrones));
            productos.add(new Producto(null, "Techados (Inspección)", COSTO_INSPECCION, idDrones));
            productos.add(new Producto(null, "Fisuras en fachadas (Inspección)", COSTO_INSPECCION, idDrones));
            productos.add(new Producto(null, "Seguimiento de trabajos (Inspección)", COSTO_INSPECCION, idDrones));
        }

        // SOLDADURA
        String idSoldadura = mapaServiciosIds.get("Soldadura");
        if (idSoldadura != null) {
            productos.add(new Producto(null, "Instalación de puerta de hierro", 75.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de verja unidad", 50.00, idSoldadura));
            productos.add(new Producto(null, "Reparación de pasamanos", 50.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de cerradura", 50.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas enrollables (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de canales (Inspección)", COSTO_INSPECCION, idSoldadura));
        }

        // REUNIONES Y FESTIVIDADES
        String idReuniones = mapaServiciosIds.get("Reuniones y festividades");
        if (idReuniones != null) {
            productos.add(new Producto(null, "Cocinero (2 horas)", 60.00, idReuniones));
            productos.add(new Producto(null, "Saloneros (2 horas)", 50.00, idReuniones));
            productos.add(new Producto(null, "Bartenders (2 horas)", 60.00, idReuniones));
            productos.add(new Producto(null, "Decoradores (2 horas)", 60.00, idReuniones));
            productos.add(new Producto(null, "Movilización y acomodo de mobiliario", 80.00, idReuniones));
            productos.add(new Producto(null, "Valet parking (2 horas)", 40.00, idReuniones));
            productos.add(new Producto(null, "Conductor designado (2 horas)", 70.00, idReuniones));
        }

        // CIELO RASOS
        String idCieloRasos = mapaServiciosIds.get("Cielo rasos");
        if (idCieloRasos != null) {
            productos.add(new Producto(null, "Cielo raso de gypsum liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
            productos.add(new Producto(null, "Cielo raso de acm liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
            productos.add(new Producto(null, "Cielo raso de pvc liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
            productos.add(new Producto(null, "Cielo raso de playcem liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
            productos.add(new Producto(null, "Cielo raso de modulares liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
            productos.add(new Producto(null, "Cielo raso reticulado liso y diseños (Inspección)", COSTO_INSPECCION, idCieloRasos));
        }

        // 3. Inserción Final
        for (Producto p : productos) {
            firestore.collection("productos").add(p);
        }

        System.out.println("✅ Base de datos poblada con estructura plana y etiquetas de (Inspección).");
    }
}