package com.backend.servicejc.service;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.DocumentSnapshot; // Importación necesaria
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import com.google.cloud.firestore.FieldPath;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Service
public class ServicioService {

    private final Firestore firestore;

    @Autowired
    public ServicioService(Firestore firestore) {
        this.firestore = firestore;
    }

    public List<Servicio> getAllCategorias() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream()
                .map(doc -> doc.toObject(Servicio.class))
                .collect(Collectors.toList());
    }

    public List<Producto> getProductosByServicioId(String servicioId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("productos")
                .whereEqualTo("servicioId", servicioId)
                .get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream()
                .map(doc -> doc.toObject(Producto.class))
                .collect(Collectors.toList());
    }

   public List<Producto> getProductosByIds(List<String> productoIds) throws ExecutionException, InterruptedException {
    if (productoIds == null || productoIds.isEmpty()) {
        return new ArrayList<>();
    }

    // Usar whereIn para obtener todos los documentos con una sola llamada
    QuerySnapshot querySnapshot = firestore.collection("productos")
            .whereIn(FieldPath.documentId(), productoIds) // Importar FieldPath
            .get()
            .get();

    return querySnapshot.getDocuments().stream()
            .map(doc -> {
                Producto p = doc.toObject(Producto.class);
                if (p != null) p.setId(doc.getId());
                return p;
            })
            .filter(p -> p != null)
            .collect(Collectors.toList());
    }

    // Método de poblamiento mejorado con la fusión de todos los datos del Excel
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> futureServicios = firestore.collection("servicios").get();
        if (!futureServicios.get().isEmpty()) {
            System.out.println("Las colecciones ya contienen datos. No se poblarán.");
            return;
        }

        System.out.println("Poblando colecciones 'servicios' y 'productos'...");

        // 1. Población de Categorías (Servicios) y almacenamiento de IDs en un mapa
        Map<String, String> categoriaIds = new HashMap<>();
        List<String> nombresCategorias = Arrays.asList(
            "Electricidad", "Plomería", "Instalaciones menores",
            "Aire acondicionado (instalación y mantenimiento)", "Pintores", "Ebanistas",
            "Soldadura", "Aluminio y vidrio", "Cielo raso",
            "Instalaciones decorativas", "Revestimientos de piso y paredes", "Remodelaciones",
            "Construcción", "Mantenimientos preventivos", "Limpieza de sillones", // Limpieza de sillones (original)
            "Limpieza de áreas", "Chefs", "Salonerros", "Bartender", "Decoraciones",
            
            // Servicios NUEVOS del Excel que no estaban en la lista inicial, pero estaban en las hojas
            "Repello Bofo", 
            "Pintura de Altura",
            "Mantenimiento de Ventanas",
            "Inspecciones con dron profesional",
            "Limpieza Textil", // Mantenido si ya existe, si no, se agrega. Limpieza de sillones/textil se consolida
            "Limpieza del Hogar",
            "Reuniones y Festividades"
        );
        
        // Usamos un Stream para asegurar que no haya duplicados si las hojas de cálculo
        // repetían nombres, y luego volvemos a una lista.
        nombresCategorias = nombresCategorias.stream().distinct().collect(Collectors.toList());

        for (String nombre : nombresCategorias) {
            Servicio categoria = new Servicio(null, nombre);
            ApiFuture<DocumentReference> addedDocRef = firestore.collection("servicios").add(categoria);
            categoriaIds.put(nombre, addedDocRef.get().getId());
        }

        // 2. Población de Productos (ítems específicos)
        List<Producto> productos = new ArrayList<>();
        
        // --- 1. Electricidad (Datos fusionados) ---
        String idElectricidad = categoriaIds.get("Electricidad");
        if (idElectricidad != null) {
            // Datos del código original
            productos.add(new Producto(null, "Lámpara", 25.00, idElectricidad));
            productos.add(new Producto(null, "Tomas", 25.00, idElectricidad));
            productos.add(new Producto(null, "Interruptores", 25.00, idElectricidad));
            productos.add(new Producto(null, "Breaker", 25.00, idElectricidad));
            productos.add(new Producto(null, "Abanico", 25.00, idElectricidad));
            
            // Datos del Excel (Electricidad)
            productos.add(new Producto(null, "Revisión y solución de mal funcionamiento eléctrico", 15.00, idElectricidad));
            productos.add(new Producto(null, "Asesoría en cambio de medidor eléctrico, instalación y revisión", 25.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de interruptores y revisión", 15.00, idElectricidad));
            productos.add(new Producto(null, "Instalación y revisión de salidas eléctricas", 15.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de bombillas y revisión", 10.00, idElectricidad));
            productos.add(new Producto(null, "Instalación y revisión de luces led", 15.00, idElectricidad));
            productos.add(new Producto(null, "Instalación y revisión de ventiladores de techo", 30.00, idElectricidad));
            productos.add(new Producto(null, "Instalación de caja de fusibles (si ya cuenta con el material)", 40.00, idElectricidad));
            productos.add(new Producto(null, "Solución de mal funcionamiento", 20.00, idElectricidad));
            productos.add(new Producto(null, "Revisión y solución eléctrica", 20.00, idElectricidad));
        }

        // --- 2. Plomería (Datos fusionados) ---
        String idPlomeria = categoriaIds.get("Plomería");
        if (idPlomeria != null) {
            // Datos del código original
            productos.add(new Producto(null, "Grifo de lavamanos de 2 mangueras", 25.00, idPlomeria));
            productos.add(new Producto(null, "Grifo de fregador de 2 mangueras", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de angulo", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de chorro", 25.00, idPlomeria));
            productos.add(new Producto(null, "Ferretería de inodoro", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de silicón", 25.00, idPlomeria));

            // Datos del Excel (Plomería)
            productos.add(new Producto(null, "Instalación, revisión y mantenimiento de tuberías y grifos", 25.00, idPlomeria));
            productos.add(new Producto(null, "Instalación y destape de desagües", 30.00, idPlomeria));
            productos.add(new Producto(null, "Solución de mal funcionamiento (General)", 20.00, idPlomeria));
            productos.add(new Producto(null, "Instalación de medidor de agua", 25.00, idPlomeria));
            productos.add(new Producto(null, "Revisión de bomba de agua", 25.00, idPlomeria));
            productos.add(new Producto(null, "Instalación y revisión de calentadores de cilindros", 35.00, idPlomeria));
            productos.add(new Producto(null, "Instalación y revisión de tinacos y cisternas", 45.00, idPlomeria));
            productos.add(new Producto(null, "Instalación, inspección y revisión de grifería y accesorios", 25.00, idPlomeria));
            productos.add(new Producto(null, "Instalación de fregaderos de cocina", 25.00, idPlomeria));
            productos.add(new Producto(null, "Instalación de inodoros y lavamanos", 30.00, idPlomeria));
            productos.add(new Producto(null, "Instalación y revisión de bañeras", 40.00, idPlomeria));
            productos.add(new Producto(null, "Instalación de platos de ducha", 35.00, idPlomeria));
        }

        // --- 3. Instalaciones menores (Datos fusionados) ---
        String idInstalacionesMenores = categoriaIds.get("Instalaciones menores");
        if (idInstalacionesMenores != null) {
            // Datos del código original
            productos.add(new Producto(null, "Cuadro", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Tablillas", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Soporte de TV", 30.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de cortina", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Elemento decorativo", 25.00, idInstalacionesMenores));

            // Datos del Excel (Instalaciones menores)
            productos.add(new Producto(null, "Instalación de manos de ducha", 15.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de repisas", 15.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de rodapie", 10.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de riel de cortinas", 10.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de spots", 10.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Colocación de espejos", 15.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Colocación de cuadros", 10.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Reparación de luces led", 15.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación y reparación de ventiladores de cielo", 30.00, idInstalacionesMenores));
        }

        // --- 4. Aire acondicionado (Datos fusionados) ---
        String idAireAcondicionado = categoriaIds.get("Aire acondicionado (instalación y mantenimiento)");
        if (idAireAcondicionado != null) {
            // Datos del código original
            productos.add(new Producto(null, "Limpieza de aire de 9 a 18 btu", 30.00, idAireAcondicionado));
            productos.add(new Producto(null, "Reparaciones inspeccion", 25.00, idAireAcondicionado));
            productos.add(new Producto(null, "Instalaciones de 9 a 18 btu", 60.00, idAireAcondicionado));

            // Datos del Excel (Aire Acondicionado)
            productos.add(new Producto(null, "Limpieza, mantenimiento y solución de aire acondicionado (General)", 30.00, idAireAcondicionado));
            productos.add(new Producto(null, "Instalación de aires inverter", 40.00, idAireAcondicionado));
            productos.add(new Producto(null, "Instalación de aires tradicionales", 35.00, idAireAcondicionado));
            productos.add(new Producto(null, "Reubicación de aires acondicionados", 40.00, idAireAcondicionado));
            productos.add(new Producto(null, "Carga de válvula o recarga de filtro", 25.00, idAireAcondicionado));
        }

        // --- 5. Pintores (Datos fusionados) ---
        String idPintores = categoriaIds.get("Pintores");
        if (idPintores != null) {
            // Datos del código original
            productos.add(new Producto(null, "Costo por metro cuadrado SOLO MANO DE OBRA", 8.00, idPintores));
            
            // Datos del Excel (Pintores)
            productos.add(new Producto(null, "Pintura y repello en interiores (por m2)", 15.00, idPintores));
            productos.add(new Producto(null, "Pintura y empaste en exteriores (por m2)", 20.00, idPintores));
        }

        // --- 6. Ebanistas (Datos fusionados) ---
        String idEbanistas = categoriaIds.get("Ebanistas");
        if (idEbanistas != null) {
            // Datos del código original
            productos.add(new Producto(null, "Instalación de puertas de madera (sin cerradura)", 40.00, idEbanistas));
            productos.add(new Producto(null, "Instalación de cerraduras en puertas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Instalación de jambas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Renovaciones de moviliario (laca, poliuretano y sintético) inspección", 10.00, idEbanistas));
            productos.add(new Producto(null, "Reparaciones de moviliario inspección", 10.00, idEbanistas));
            
            // Datos del Excel (Ebanistería)
            productos.add(new Producto(null, "Instalación y reparación de muebles", 35.00, idEbanistas));
            productos.add(new Producto(null, "Instalación de closets", 45.00, idEbanistas));
        }

        // --- 7. Soldadura (Datos fusionados) ---
        String idSoldadura = categoriaIds.get("Soldadura");
        if (idSoldadura != null) {
            // Datos del código original
            productos.add(new Producto(null, "Instalación de puerta de hierro", 75.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de verja unidad", 50.00, idSoldadura));
            productos.add(new Producto(null, "Reparación de pasamanos", 50.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de cerradura", 50.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles", 10.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas enrollables", 10.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de canales", 10.00, idSoldadura));
            
            // Datos del Excel (Soldadura)
            productos.add(new Producto(null, "Instalación y reparación de puertas metálicas (General)", 35.00, idSoldadura));
            productos.add(new Producto(null, "Instalación y reparación de verjas (General)", 30.00, idSoldadura));
        }

        // --- 8. Aluminio y vidrio (Datos fusionados) ---
        String idAluminioVidrio = categoriaIds.get("Aluminio y vidrio");
        if (idAluminioVidrio != null) {
            // Datos del código original
            productos.add(new Producto(null, "Instalación de puerta", 75.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación de verja unidad", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Reparación de pasamanos", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación de cerradura", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Mantenimiento de puertas corrediza", 50.00, idAluminioVidrio));
            
            // Datos del Excel (Aluminio y Vidrio)
            productos.add(new Producto(null, "Instalación de ventanas", 35.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación y reparación de puertas (General)", 30.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación, inspección y revisión de vidrio", 30.00, idAluminioVidrio));
            productos.add(new Producto(null, "Reemplazo o solución de fallas en vidrios", 25.00, idAluminioVidrio));
        }

        // --- 9. Cielo raso (Datos fusionados) ---
        String idCieloRaso = categoriaIds.get("Cielo raso");
        if (idCieloRaso != null) {
            // Datos del código original
            productos.add(new Producto(null, "Cielo raso de gypsum liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de acm liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de pvc liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de playcem liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de modulares liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso reticulado liso y diseños", 10.00, idCieloRaso));
            
            // Datos del Excel (Cielo Rasos)
            productos.add(new Producto(null, "Instalación (General)", 30.00, idCieloRaso));
            productos.add(new Producto(null, "Reparación (General)", 20.00, idCieloRaso));
        }

        // --- 10. Instalaciones decorativas (Datos fusionados) ---
        String idInstalacionesDecorativas = categoriaIds.get("Instalaciones decorativas");
        if (idInstalacionesDecorativas != null) {
            // Datos del código original
            productos.add(new Producto(null, "Paneles decorativos 3d", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles de PVC decorativos de textura de mármol", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles tipo piedra decorativos", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Separador de ambiente tipo pergola giratoria", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles wpc decorativos", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Follaje artificial", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Microcemento", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Papel tapiz", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Impresión e instalación de vinilos decorativos", 10.00, idInstalacionesDecorativas));
            
            // Datos del Excel (Instalaciones Decorativas)
            productos.add(new Producto(null, "Instalación e inspección", 20.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Mantenimiento", 15.00, idInstalacionesDecorativas));
        }

        // --- 11. Revestimientos de piso y paredes (Datos fusionados) ---
        String idRevestimientos = categoriaIds.get("Revestimientos de piso y paredes");
        if (idRevestimientos != null) {
            // Datos del código original
            productos.add(new Producto(null, "Azulejos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Mozaiquillos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Baldosas", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Mármol", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Cuarzo", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Porcelanatos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Piso cps", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Micro cemento", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Resina epóxica", 10.00, idRevestimientos));

            // Datos del Excel (Revestimiento de Pisos y Paredes)
            productos.add(new Producto(null, "Instalación (General)", 25.00, idRevestimientos));
            productos.add(new Producto(null, "Reparación (General)", 20.00, idRevestimientos));
        }
        
        // --- 12. Limpieza textil (Limpieza de sillones) ---
        // Se consolida en "Limpieza Textil"
        String idLimpiezaTextil = categoriaIds.get("Limpieza textil");
        if (idLimpiezaTextil != null) {
            // Datos del Excel (Limpieza Textil / Sillones)
            productos.add(new Producto(null, "Sillón de 1 puesto", 30.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón de 2 puestos", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillón de 3 puestos", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones grandes tipo L (4 puestos)", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones grandes (5 puestos)", 75.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor de 2 puestos", 30.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor de 4 puestos", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Comedor de 8 puestos", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Colchones (unidad)", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones de sedan", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería de sedan", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso (alfombra de fábrica) de sedan", 50.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones de camioneta 1", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería de camioneta 1", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso (alfombra de fábrica) de camioneta 1", 60.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Sillones de camioneta 2", 80.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Techo tapicería de camioneta 2", 80.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Piso (alfombra de fábrica) de camioneta 2", 80.00, idLimpiezaTextil));
        }

        // --- 13. Limpieza de áreas (Datos fusionados) ---
        String idLimpiezaAreas = categoriaIds.get("Limpieza de áreas");
        if (idLimpiezaAreas != null) {
            // Datos del Excel (Limpieza de áreas)
            productos.add(new Producto(null, "Limpieza de cocinas", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de baños", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de recámaras", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza general de vivienda", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de estacionamientos con hidrolavadora", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de canales de techado", 25.00, idLimpiezaAreas));
            
            // Dato del Excel (Limpieza del Hogar - Fusionado en áreas)
            productos.add(new Producto(null, "Limpieza profunda", 30.00, idLimpiezaAreas));
        }
        
        // --- 14. Mantenimientos preventivos ---
        String idMantenimientosPreventivos = categoriaIds.get("Mantenimientos preventivos");
        if (idMantenimientosPreventivos != null) {
            // Dato del código original
            productos.add(new Producto(null, "Mantenimiento preventivo mensual", 25.00, idMantenimientosPreventivos));
            
            // Dato del Excel (Mantenimientos Preventivos)
            productos.add(new Producto(null, "Asesoría, revisión y valoración de áreas (incluye informe con las prioridades de mantenimiento)", 50.00, idMantenimientosPreventivos));
        }
        
        // --- 15. Trabajos de repello bofo de edificios (Repello Bofo) ---
        String idRepello = categoriaIds.get("Trabajos de repello bofo de edificios");
        if (idRepello != null) {
             productos.add(new Producto(null, "Repello bofo de viviendas/edificios", 10.00, idRepello));
             
             // Dato del Excel (Repello Bofo)
             productos.add(new Producto(null, "Inspección y reparación de repello bofo", 30.00, idRepello));
        }
        
        // --- 16. Trabajos de pintura exterior de edificios (Pintura de Altura) ---
        String idPinturaExterior = categoriaIds.get("Trabajos de pintura exterior de edificios");
        if (idPinturaExterior != null) {
            productos.add(new Producto(null, "Pintura de altura", 10.00, idPinturaExterior));
            
            // Dato del Excel (Pintura de Altura)
            productos.add(new Producto(null, "Reparación/Pintura de altura (General)", 40.00, idPinturaExterior));
        }
        
        // --- 17. Trabajo de limpieza de vidrio y cambio de silicón de ventanas (Mantenimiento de Ventanas) ---
        String idLimpiezaVentanas = categoriaIds.get("Trabajo de limpieza de vidrio y cambio de silicón de ventanas");
        if (idLimpiezaVentanas != null) {
            productos.add(new Producto(null, "Mantenimiento de ventanas", 10.00, idLimpiezaVentanas));
            
            // Dato del Excel (Mantenimiento de Ventanas)
            productos.add(new Producto(null, "Inspección y reparación de ventanas (General)", 25.00, idLimpiezaVentanas));
        }

        // --- 18. Inspecciones con dron profesional ---
        String idInspeccionDrones = categoriaIds.get("Inspecciones con dron profesional");
        if (idInspeccionDrones != null) {
            productos.add(new Producto(null, "Inspección de áreas", 50.00, idInspeccionDrones));
            
            // Dato del Excel (Inspeccion con Drones)
            productos.add(new Producto(null, "Inspección y revisión con drones", 50.00, idInspeccionDrones));
        }
        
        // --- 19. Remodelaciones ---
        String idRemodelaciones = categoriaIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null, "Proyecto de remodelación", 10.00, idRemodelaciones));
            
            // Dato del Excel (Remodelaciones)
            productos.add(new Producto(null, "Asesoría en remodelación", 50.00, idRemodelaciones));
        }
        
        // --- 20. Construcción ---
        String idConstruccion = categoriaIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null, "Proyecto de construcción", 10.00, idConstruccion));
            
            // Dato del Excel (Construcción)
            productos.add(new Producto(null, "Asesoría en construcción", 50.00, idConstruccion));
        }
        
        // --- 21. Chefs ---
        String idChefs = categoriaIds.get("Chefs");
        if (idChefs != null) {
            productos.add(new Producto(null, "Chef (festividades)", 25.00, idChefs));
        }
        
        // --- 22. Salonerros ---
        String idSalonerros = categoriaIds.get("Salonerros");
        if (idSalonerros != null) {
            productos.add(new Producto(null, "Saloneros", 25.00, idSalonerros));
        }
        
        // --- 23. Bartender ---
        String idBartender = categoriaIds.get("Bartender");
        if (idBartender != null) {
            productos.add(new Producto(null, "Bartender", 25.00, idBartender));
        }
        
        // --- 24. Decoraciones ---
        String idDecoraciones = categoriaIds.get("Decoraciones");
        if (idDecoraciones != null) {
            productos.add(new Producto(null, "Decoraciones para fiestas", 25.00, idDecoraciones));
        }
        
        // --- 25. Reuniones y Festividades ---
        String idReuniones = categoriaIds.get("Reuniones y Festividades");
        if (idReuniones != null) {
            productos.add(new Producto(null, "Otros (Festividades)", 25.00, idReuniones));
        }

        // FIN DE LA FUSIÓN DE DATOS

        for (Producto producto : productos) {
            firestore.collection("productos").add(producto);
        }

        System.out.println("✅ Datos de categorías y productos poblados exitosamente.");
    }
}