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

    public List<CategoriaPrincipalModel> fetchCategoriasPrincipales() throws ExecutionException, InterruptedException {
        // 🔥 Usamos la ruta completa de Query.Direction para evitar errores de importación
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios")
                .orderBy("orden", com.google.cloud.firestore.Query.Direction.ASCENDING) 
                .get();
        
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        return documents.stream().map(doc -> {
            Servicio serv = doc.toObject(Servicio.class);
            return new CategoriaPrincipalModel(
                serv.getId(), 
                serv.getNombre(), 
                serv.getImageUrl()
            ); 
        }).collect(Collectors.toList());
    }

    // 💡 Método auxiliar para buscar sin que importen mayúsculas o espacios extra
    private int obtenerIndice(String nombreFirebase) {
        if (nombreFirebase == null) return 999;
        
        String nombreLimpio = nombreFirebase.trim().toLowerCase();

        for (int i = 0; i < LISTA_PANTALLA_PRINCIPAL.size(); i++) {
            String itemLista = LISTA_PANTALLA_PRINCIPAL.get(i).trim().toLowerCase();
            if (itemLista.equals(nombreLimpio)) {
                return i; // Lo encontró perfectamente
            }
        }
        
        // Opcional: Imprime en consola de GCP cuáles no está encontrando
        System.out.println("⚠️ ATENCIÓN: No encontré el orden para -> '" + nombreFirebase + "'");
        return 999; 
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

    // 🔴 LA LISTA DE LAS 30 CATEGORÍAS (EN ORDEN PERFECTO)
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

    private String obtenerUrlImagen(String nombreServicio) {
        // La ruta base que vimos en tu captura (usamos %2F que significa "/")
        String baseUrl = "https://firebasestorage.googleapis.com/v0/b/servicejc-d3aca.firebasestorage.app/o/images%2Fservices%2F";
        String suffix = "?alt=media"; 
        
        String nombreArchivo = "mantenimiento.png"; // Imagen por defecto si no encuentra
        String nombreLower = nombreServicio.toLowerCase();

        // Mapeo basado en tus archivos de Flutter anteriores
        if (nombreLower.contains("aire acondicionado")) nombreArchivo = "aire_acondicionado.png";
        else if (nombreLower.contains("repello")) nombreArchivo = "repello.png";
        else if (nombreLower.contains("plomer")) nombreArchivo = "plomeria.png";
        else if (nombreLower.contains("filtraciones")) nombreArchivo = "filtraciones.png";
        else if (nombreLower.contains("sillones")) nombreArchivo = "sillones.png";
        else if (nombreLower.contains("ebanistas")) nombreArchivo = "ebanistas.png";
        else if (nombreLower.contains("electricidad")) nombreArchivo = "electricidad.png";
        else if (nombreLower.contains("preventivos")) nombreArchivo = "preventivos.png";
        else if (nombreLower.contains("decorativas") || nombreLower.contains("decoradores")) nombreArchivo = "decoracion.png";
        else if (nombreLower.contains("pintura exterior") || nombreLower.contains("pintores")) nombreArchivo = "pintura.png";
        else if (nombreLower.contains("limpieza general") || nombreLower.contains("cocinas, baños")) nombreArchivo = "limpieza_general.png";
        else if (nombreLower.contains("construcción")) nombreArchivo = "construccion.png";
        else if (nombreLower.contains("vidrio") || nombreLower.contains("ventanas")) nombreArchivo = "ventanas.png";
        else if (nombreLower.contains("revestimientos")) nombreArchivo = "revestimientos.png";
        else if (nombreLower.contains("remodelaciones")) nombreArchivo = "remodelaciones.png";
        else if (nombreLower.contains("canales")) nombreArchivo = "canales.png";
        else if (nombreLower.contains("aluminio")) nombreArchivo = "aluminio.png";
        else if (nombreLower.contains("paneles solares")) nombreArchivo = "paneles.png";
        else if (nombreLower.contains("menores")) nombreArchivo = "instalaciones_menores.png";
        else if (nombreLower.contains("dron")) nombreArchivo = "dron.png";
        else if (nombreLower.contains("soldadura")) nombreArchivo = "soldadura.png";
        else if (nombreLower.contains("chef")) nombreArchivo = "chef.png";
        else if (nombreLower.contains("valet")) nombreArchivo = "valet.png";
        else if (nombreLower.contains("saloneros")) nombreArchivo = "saloneros.png";
        else if (nombreLower.contains("bartender")) nombreArchivo = "bartender.png";
        else if (nombreLower.contains("movilizacion")) nombreArchivo = "mudanza.png";
        else if (nombreLower.contains("cielo raso")) nombreArchivo = "cieloraso.png";

        return baseUrl + nombreArchivo + suffix;
    }
    // --- MÉTODO DE POBLAMIENTO PLANO (SEED) ---
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> check = firestore.collection("servicios").get();
        if (!check.get().isEmpty()) {
            System.out.println("⚠️ La colección 'servicios' ya tiene datos. No se realizará la inserción.");
            return;
        }

        System.out.println("🚀 Iniciando población plana según los Excel (Con orden e imágenes)...");
        com.google.cloud.firestore.WriteBatch batch = firestore.batch(); 
        
        Map<String, String> mapaServiciosIds = new HashMap<>();

        for (int i = 0; i < LISTA_PANTALLA_PRINCIPAL.size(); i++) {
            String nombreItem = LISTA_PANTALLA_PRINCIPAL.get(i);
            
            // Creamos una referencia vacía para obtener el ID sin llamar a la red
            DocumentReference servRef = firestore.collection("servicios").document();
            
            Map<String, Object> servicio = new HashMap<>();
            servicio.put("nombre", nombreItem);
            servicio.put("orden", i + 1); 
            servicio.put("imageUrl", obtenerUrlImagen(nombreItem));

            // 👇 EN LUGAR DE .add(), LO METEMOS AL LOTE
            batch.set(servRef, servicio); 
            
            String servicioId = servRef.getId();
            mapaServiciosIds.put(nombreItem, servicioId);
        }

        
        List<Producto> productos = new ArrayList<>();
        final Double COSTO_INSPECCION = 10.00; 

        // =========================================================
        // PRODUCTOS COMPLETOS, EXTENDIDOS TAL CUAL TUS DOCUMENTOS
        // =========================================================

        String idAire = mapaServiciosIds.get("Aire Acondicionado (Instalación y Mantenimiento)");
        if (idAire != null) {
            productos.add(new Producto(null, "Limpieza de aire de 9 a 18 btu", 30.00, idAire));
            productos.add(new Producto(null, "Proyectos nuevos: tipo de proyecto pdf/reseña (Inspección)", COSTO_INSPECCION, idAire));
            productos.add(new Producto(null, "Proyectos nuevos: posee documento relacionado pdf (Inspección)", COSTO_INSPECCION, idAire));
        }

        String idRepello = mapaServiciosIds.get("Trabajos de Repello Bofo de Edificios");
        if (idRepello != null) {
            productos.add(new Producto(null, "Viviendas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Oficinas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Instituciones documento pdf/reseña (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Propiedades verticales/horizontales documento pdf/reseña (Inspección)", COSTO_INSPECCION, idRepello));
            productos.add(new Producto(null, "Fábricas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idRepello));
        }

        String idPlomeria = mapaServiciosIds.get("Plomería");
        if (idPlomeria != null) {
            productos.add(new Producto(null, "Grifo de lavamanos de 2 mangueras", 30.00, idPlomeria));
            productos.add(new Producto(null, "Grifo de fregador de 2 mangueras", 30.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de angulo", 30.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de chorro", 30.00, idPlomeria));
            productos.add(new Producto(null, "Ferreteria de inodoro", 80.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de silicon", 30.00, idPlomeria));
            productos.add(new Producto(null, "Proyectos nuevos: tipo de proyecto pdf/reseña (Inspección)", COSTO_INSPECCION, idPlomeria));
            productos.add(new Producto(null, "Proyectos nuevos: posee documento relacionado pdf (Inspección)", COSTO_INSPECCION, idPlomeria));
        }

        String idFiltraciones = mapaServiciosIds.get("Filtraciones");
        if (idFiltraciones != null) {
            productos.add(new Producto(null, "Inspeccion visual para determinar la herramienta a utilizar (Inspección)", 10.00, idFiltraciones));
            productos.add(new Producto(null, "Camara termica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Camara endoscopica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspeccion con ultra sonido", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Revicion con dron filtraciones en fachadas", 150.00, idFiltraciones));
        }

        String idSillones = mapaServiciosIds.get("Limpieza de sillones");
        if (idSillones != null) {
            productos.add(new Producto(null, "Sillón 1 puesto", 40.00, idSillones));
            productos.add(new Producto(null, "Sillón 2 puesto", 50.00, idSillones));
            productos.add(new Producto(null, "Sillón 3 puesto", 60.00, idSillones));
            productos.add(new Producto(null, "Sillón grandes tipo L 4 puesto", 65.00, idSillones));
            productos.add(new Producto(null, "Sillón grandes 5 puesto", 75.00, idSillones));
            productos.add(new Producto(null, "Comedor 2 puesto", 30.00, idSillones));
            productos.add(new Producto(null, "Comedor 4 puesto", 40.00, idSillones));
            productos.add(new Producto(null, "Comedor 8 puesto", 65.00, idSillones));
            productos.add(new Producto(null, "Colchones unidad", 40.00, idSillones));
            productos.add(new Producto(null, "Sillones 1 sedan", 50.00, idSillones));
            productos.add(new Producto(null, "Techo tapicería 1 sedan", 50.00, idSillones));
            productos.add(new Producto(null, "Piso (alfombra de fabrica) 1 sedan", 50.00, idSillones));
            productos.add(new Producto(null, "Sillones 1 camioneta 1", 65.00, idSillones));
            productos.add(new Producto(null, "Techo tapicería 1 camioneta 1", 65.00, idSillones));
            productos.add(new Producto(null, "Piso (alfombra de fabrica) 1 camioneta 1", 65.00, idSillones));
            productos.add(new Producto(null, "Sillones 1 camioneta 2", 80.00, idSillones));
            productos.add(new Producto(null, "Techo tapicería 1 camioneta 2", 80.00, idSillones));
            productos.add(new Producto(null, "Piso (alfombra de fabrica) 1 camioneta 2", 80.00, idSillones));
        }

        String idEbanistas = mapaServiciosIds.get("Ebanistas");
        if (idEbanistas != null) {
            productos.add(new Producto(null, "Instalacion de puertas de madera (sin cerradura)", 40.00, idEbanistas));
            productos.add(new Producto(null, "Instalacion de cerraduras en puertas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Instalacion de jambas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Proyectos nuevos (Inspección)", COSTO_INSPECCION, idEbanistas));
            productos.add(new Producto(null, "Renovaciones de moviliario (laca, poliuretano y sintetico) (Inspección)", COSTO_INSPECCION, idEbanistas));
            productos.add(new Producto(null, "Reparaciones de moviliario (Inspección)", COSTO_INSPECCION, idEbanistas));
            productos.add(new Producto(null, "Confeccion de moviliario nuevo (Inspección)", COSTO_INSPECCION, idEbanistas));
        }

        String idElectricidad = mapaServiciosIds.get("Electricidad");
        if (idElectricidad != null) {
            productos.add(new Producto(null, "Lampara", 25.00, idElectricidad));
            productos.add(new Producto(null, "Tomas", 25.00, idElectricidad));
            productos.add(new Producto(null, "Interruptores", 25.00, idElectricidad));
            productos.add(new Producto(null, "Breker", 25.00, idElectricidad));
            productos.add(new Producto(null, "Abanico", 25.00, idElectricidad));
            productos.add(new Producto(null, "Proyectos nuevos: tipo de proyecto pdf/reseña (Inspección)", COSTO_INSPECCION, idElectricidad));
            productos.add(new Producto(null, "Proyectos nuevos: posee documento relacionado pdf (Inspección)", COSTO_INSPECCION, idElectricidad));
        }

        String idMantPrev = mapaServiciosIds.get("Mantenimientos Preventivos");
        if (idMantPrev != null) {
            productos.add(new Producto(null, "Viviendas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Oficinas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Instituciones documento pdf/reseña (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Propiedades verticales/horizontales documento pdf/reseña (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Fabricas documento pdf/reseña (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: electricidad (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: plomería (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: mantenimiento de a/a (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: ebanistería (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: pintura (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: soldadura (Inspección)", COSTO_INSPECCION, idMantPrev));
            productos.add(new Producto(null, "Actividades del plan: impermeabilización (Inspección)", COSTO_INSPECCION, idMantPrev));
        }

        String idInstDecorativas = mapaServiciosIds.get("Instalaciones Decorativas");
        if (idInstDecorativas != null) {
            productos.add(new Producto(null, "Paneles decorativos 3d (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles de PVC decorativos de textura de mármol (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles tipo piedra decorativos (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Separador de ambiente tipo pergola giratoria (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Paneles wpc decorativos (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Follaje artificial (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Microcemento (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Papel tapis (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Impresión e instalación de vinilos decorativos (Inspección)", COSTO_INSPECCION, idInstDecorativas));
            productos.add(new Producto(null, "Proyectos nuevos (Inspección)", COSTO_INSPECCION, idInstDecorativas));
        }

        String idPinturaExt = mapaServiciosIds.get("Trabajos de Pintura Exterior de Edificios");
        if (idPinturaExt != null) {
            productos.add(new Producto(null, "Pintura de fachadas de edificios (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Reparacion de fisuras en fachadas (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Reparacion de albañileria en general (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Impermeavilizacion de filtraciones en fachadas (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de estacionamientos (limpieza y pintura) (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de azoteas (limpieza y empermeavilizaciones) (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de foso de ascensores (limpieza e impermeavilizacion) (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de lobby (limpieza y pintura) (Inspección)", COSTO_INSPECCION, idPinturaExt));
            productos.add(new Producto(null, "Mantenimiento de escaleras de servicio (limpieza y pintura) (Inspección)", COSTO_INSPECCION, idPinturaExt));
        }

        String idLimpiezaGen = mapaServiciosIds.get("Limpieza General");
        if (idLimpiezaGen != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", 10.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de cocina", 50.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de recamara", 50.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de sala", 50.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de baño", 50.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de garaje", 50.00, idLimpiezaGen));
            productos.add(new Producto(null, "Areas sociales", 60.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de baños", 60.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de gimnasios", 60.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de veredas", 170.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de estacionamiento con hidrolavadora", 75.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpieza de rampas", 30.00, idLimpiezaGen));
            productos.add(new Producto(null, "Limpiesa de tinas de basura", 31.00, idLimpiezaGen));
        }

        String idConstruccion = mapaServiciosIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Construccion de hormigon (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Construccion metalica (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Construccion liviana (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Paneles Estructurales Aislados (Inspección)", COSTO_INSPECCION, idConstruccion));
            productos.add(new Producto(null, "Paneles prefabricados de concreto (Inspección)", COSTO_INSPECCION, idConstruccion));
        }

        String idVentanas = mapaServiciosIds.get("Trabajo de Limpieza de Vidrio y Cambio de Silicón de Ventanas");
        if (idVentanas != null) {
            productos.add(new Producto(null, "Viviendas (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Oficinas (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Instituciones (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Edificios (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Fabricas (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Cambio de sello de goma de vidrio (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Cambio de silicon (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Limpieza de riel (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Lubricacion de ferreteria (Inspección)", COSTO_INSPECCION, idVentanas));
            productos.add(new Producto(null, "Limpieza de vidrios (Inspección)", COSTO_INSPECCION, idVentanas));
        }

        String idRevestimientos = mapaServiciosIds.get("Revestimientos de piso y paredes");
        if (idRevestimientos != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Azulejos (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Mozaiquilllos (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Baldosas (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Marmol (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Cuarzo (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Porcelanatos (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Piso cps (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Micro cemento (Inspección)", COSTO_INSPECCION, idRevestimientos));
            productos.add(new Producto(null, "Resina epoxica (Inspección)", COSTO_INSPECCION, idRevestimientos));
        }

        String idRemodelaciones = mapaServiciosIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Planificacion y diseño (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Demoliciones (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Instalaciones (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Albañileria (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Sistemas de drenje (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Pergolas (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Muros (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Portales (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Piscinas (Inspección)", COSTO_INSPECCION, idRemodelaciones));
            productos.add(new Producto(null, "Reformas estructurales (Inspección)", COSTO_INSPECCION, idRemodelaciones));
        }

        String idCanales = mapaServiciosIds.get("Limpieza de Canales de Techado");
        if (idCanales != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idCanales));
            productos.add(new Producto(null, "Limpieza de canaletas de techados (Inspección)", COSTO_INSPECCION, idCanales));
            productos.add(new Producto(null, "Limpieza de canales plubiales (Inspección)", COSTO_INSPECCION, idCanales));
        }

        String idPintores = mapaServiciosIds.get("Pintores");
        if (idPintores != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Aplicación de pintura arquitectonica (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Limpieza de canales plubiales (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Impermeavilizaciones de techo y losas (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Aplicación de pintura texturizada (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Aplicación de pintura satinada (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Apliaccion de pintura grado alimenticio (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Apliaccion de pintura epoxica (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Aplicación de pintura poliuretano (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Aplicación de pintura laca y acabados esmaltes (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Proyectos artisticos (Inspección)", COSTO_INSPECCION, idPintores));
            productos.add(new Producto(null, "Apliaccion de pintura de piscinas (piscinas y piso frio) (Inspección)", COSTO_INSPECCION, idPintores));
        }

        String idAluminio = mapaServiciosIds.get("Aluminio y Vidrio");
        if (idAluminio != null) {
            productos.add(new Producto(null, "Instalacion de puerta (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Instalacion de verja unidad (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Confeccion de proyecto nuevo (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Reparacion de pasamanos (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Instalacion de cerradura (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles (Inspección)", COSTO_INSPECCION, idAluminio));
            productos.add(new Producto(null, "Mantenimiento de puertas corrediza (Inspección)", COSTO_INSPECCION, idAluminio));
        }

        String idSolares = mapaServiciosIds.get("Paneles solares");
        if (idSolares != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idSolares));
            productos.add(new Producto(null, "Mantenimiento (Inspección)", COSTO_INSPECCION, idSolares));
            productos.add(new Producto(null, "Reparaciones (Inspección)", COSTO_INSPECCION, idSolares));
            productos.add(new Producto(null, "Suministros e instalaciones nuevas (Inspección)", COSTO_INSPECCION, idSolares));
        }

        String idMenores = mapaServiciosIds.get("Instalaciones Menores");
        if (idMenores != null) {
            productos.add(new Producto(null, "Cuadro", 25.00, idMenores));
            productos.add(new Producto(null, "Tablillas", 25.00, idMenores));
            productos.add(new Producto(null, "Soporte de tv hasta 50 pulgadas", 30.00, idMenores));
            productos.add(new Producto(null, "Soporte de tv mas de 50 pulgadas", 50.00, idMenores));
            productos.add(new Producto(null, "Instalacion de cortina", 25.00, idMenores));
            productos.add(new Producto(null, "Elemento decoratibo", 25.00, idMenores));
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idMenores));
        }

        String idDron = mapaServiciosIds.get("Inspecciones con Dron Profesional: Herramienta moderna para la evaluación rápida y segura del estado de la azotea, fachada y repello bofo sin el costo de andamios.");
        if (idDron != null) {
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idDron));
            productos.add(new Producto(null, "Seremonias (Inspección)", COSTO_INSPECCION, idDron));
            productos.add(new Producto(null, "Techados (Inspección)", COSTO_INSPECCION, idDron));
            productos.add(new Producto(null, "Fisuras en fachadas (Inspección)", COSTO_INSPECCION, idDron));
            productos.add(new Producto(null, "Seguimiento de trabajos (Inspección)", COSTO_INSPECCION, idDron));
        }

        String idSoldadura = mapaServiciosIds.get("Soldadura");
        if (idSoldadura != null) {
            productos.add(new Producto(null, "Instalacion de puerta de hierro", 75.00, idSoldadura));
            productos.add(new Producto(null, "Instalacion de verja unidad", 50.00, idSoldadura));
            productos.add(new Producto(null, "Reparacion de pasamanos", 50.00, idSoldadura));
            productos.add(new Producto(null, "Instalacion de cerradura", 50.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas enrollables (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de canales (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Confeccion de proyecto nuevo (Inspección)", COSTO_INSPECCION, idSoldadura));
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idSoldadura));
        }

        String idChefs = mapaServiciosIds.get("Chefs");
        if (idChefs != null) {
            productos.add(new Producto(null, "Cocinero 2 horas", 60.00, idChefs));
        }

        String idValet = mapaServiciosIds.get("Valet Parking / Conductor Designado: Movilidad Exclusiva. Servicios de logística y seguridad para los invitados y la familia.");
        if (idValet != null) {
            productos.add(new Producto(null, "Valet parking 2 horas", 40.00, idValet));
            productos.add(new Producto(null, "Conductor designado 2 horas", 70.00, idValet));
        }

        String idLimpiezaEsp = mapaServiciosIds.get("Limpieza de Cocinas, Baños, Recámaras: Servicios de desinfección y limpieza detallada, que son importantes para la prevención de enfermedades.");
        if (idLimpiezaEsp != null) {
            productos.add(new Producto(null, "Limpieza profunda de cocina", 50.00, idLimpiezaEsp));
            productos.add(new Producto(null, "Limpieza profunda de baño", 50.00, idLimpiezaEsp));
            productos.add(new Producto(null, "Limpieza profunda de recámara", 50.00, idLimpiezaEsp));
        }

        String idSaloneros = mapaServiciosIds.get("Saloneros");
        if (idSaloneros != null) {
            productos.add(new Producto(null, "Saloneros 2 horas", 50.00, idSaloneros));
        }

        String idBartenders = mapaServiciosIds.get("Bartenders");
        if (idBartenders != null) {
            productos.add(new Producto(null, "Bartenders 2 horas", 60.00, idBartenders));
        }

        String idDecoradores = mapaServiciosIds.get("Decoradores");
        if (idDecoradores != null) {
            productos.add(new Producto(null, "Decoradores 2 horas", 60.00, idDecoradores));
        }

        String idMovilizacion = mapaServiciosIds.get("Movilizacion y acomodo de moviliario");
        if (idMovilizacion != null) {
            productos.add(new Producto(null, "Movilizacion y acomodo de moviliario 2 horas", 80.00, idMovilizacion));
        }

        String idCielo = mapaServiciosIds.get("Cielo raso");
        if (idCielo != null) {
            productos.add(new Producto(null, "Cielo raso de gypsum liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Cielo raso de acm liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Proyectos nuevos (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Cielo raso de pvc liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Cielo raso de playcem liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Describe tu solisitud (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Cielo raso de modulares liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
            productos.add(new Producto(null, "Cielo raso reticulado liso y diseños (Inspección)", COSTO_INSPECCION, idCielo));
        }

        // 3. Inserción Final
       for (Producto p : productos) {
            DocumentReference prodRef = firestore.collection("productos").document();
            batch.set(prodRef, p);
        }

        // 👇 ¡ESTE ES EL COMANDO MÁGICO QUE EJECUTA LAS 230 OPERACIONES DE GOLPE!
        batch.commit().get();

        System.out.println("✅ Base de datos poblada de forma estricta (BATCH COMPLETADO).");

        System.out.println("✅ Base de datos poblada de forma estricta según documentos.");
    }
}