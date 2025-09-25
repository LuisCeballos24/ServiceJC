package com.backend.servicejc.service;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
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

    // Método de poblamiento mejorado con nuevos servicios
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
            "Construcción", "Mantenimientos preventivos", "Limpieza de sillones",
            "Limpieza de áreas", "Chefs", "Salonerros", "Bartender", "Decoraciones",
            "Trabajos de repello bofo de edificios", "Trabajos de pintura exterior de edificios",
            "Trabajo de limpieza de vidrio y cambio de silicón de ventanas",
            "Inspecciones con dron profesional", "Limpieza textil"
        );

        for (String nombre : nombresCategorias) {
            Servicio categoria = new Servicio(null, nombre);
            ApiFuture<DocumentReference> addedDocRef = firestore.collection("servicios").add(categoria);
            categoriaIds.put(nombre, addedDocRef.get().getId());
        }

        // 2. Población de Productos (ítems específicos)
        List<Producto> productos = new ArrayList<>();
        
        // Electricidad
        String idElectricidad = categoriaIds.get("Electricidad");
        if (idElectricidad != null) {
            productos.add(new Producto(null, "Lámpara", 25.00, idElectricidad));
            productos.add(new Producto(null, "Tomas", 25.00, idElectricidad));
            productos.add(new Producto(null, "Interruptores", 25.00, idElectricidad));
            productos.add(new Producto(null, "Breaker", 25.00, idElectricidad));
            productos.add(new Producto(null, "Abanico", 25.00, idElectricidad));
        }

        // Plomería
        String idPlomeria = categoriaIds.get("Plomería");
        if (idPlomeria != null) {
            productos.add(new Producto(null, "Grifo de lavamanos de 2 mangueras", 25.00, idPlomeria));
            productos.add(new Producto(null, "Grifo de fregador de 2 mangueras", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de angulo", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de llave de chorro", 25.00, idPlomeria));
            productos.add(new Producto(null, "Ferretería de inodoro", 25.00, idPlomeria));
            productos.add(new Producto(null, "Cambio de silicón", 25.00, idPlomeria));
        }

        // Instalaciones menores
        String idInstalacionesMenores = categoriaIds.get("Instalaciones menores");
        if (idInstalacionesMenores != null) {
            productos.add(new Producto(null, "Cuadro", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Tablillas", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Soporte de TV", 30.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de cortina", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Elemento decorativo", 25.00, idInstalacionesMenores));
        }

        // Aire acondicionado (instalación y mantenimiento)
        String idAireAcondicionado = categoriaIds.get("Aire acondicionado (instalación y mantenimiento)");
        if (idAireAcondicionado != null) {
            productos.add(new Producto(null, "Limpieza de aire de 9 a 18 btu", 30.00, idAireAcondicionado));
            productos.add(new Producto(null, "Reparaciones inspeccion", 25.00, idAireAcondicionado));
            productos.add(new Producto(null, "Instalaciones de 9 a 18 btu", 60.00, idAireAcondicionado));
        }

        // Pintores
        String idPintores = categoriaIds.get("Pintores");
        if (idPintores != null) {
            productos.add(new Producto(null, "Costo por metro cuadrado SOLO MANO DE OBRA", 8.00, idPintores));
        }
        
        // Ebanistas
        String idEbanistas = categoriaIds.get("Ebanistas");
        if (idEbanistas != null) {
            productos.add(new Producto(null, "Instalación de puertas de madera (sin cerradura)", 40.00, idEbanistas));
            productos.add(new Producto(null, "Instalación de cerraduras en puertas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Instalación de jambas de madera", 25.00, idEbanistas));
            productos.add(new Producto(null, "Renovaciones de moviliario (laca, poliuretano y sintético) inspección", 10.00, idEbanistas));
            productos.add(new Producto(null, "Reparaciones de moviliario inspección", 10.00, idEbanistas));
        }

        // Soldadura
        String idSoldadura = categoriaIds.get("Soldadura");
        if (idSoldadura != null) {
            productos.add(new Producto(null, "Instalación de puerta de hierro", 75.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de verja unidad", 50.00, idSoldadura));
            productos.add(new Producto(null, "Reparación de pasamanos", 50.00, idSoldadura));
            productos.add(new Producto(null, "Instalación de cerradura", 50.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles", 10.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de puertas enrollables", 10.00, idSoldadura));
            productos.add(new Producto(null, "Mantenimiento de canales", 10.00, idSoldadura));
        }

        // Aluminio y vidrio
        String idAluminioVidrio = categoriaIds.get("Aluminio y vidrio");
        if (idAluminioVidrio != null) {
            productos.add(new Producto(null, "Instalación de puerta", 75.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación de verja unidad", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Reparación de pasamanos", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Instalación de cerradura", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Mantenimiento de puertas abatibles", 50.00, idAluminioVidrio));
            productos.add(new Producto(null, "Mantenimiento de puertas corrediza", 50.00, idAluminioVidrio));
        }

        // Cielo raso
        String idCieloRaso = categoriaIds.get("Cielo raso");
        if (idCieloRaso != null) {
            productos.add(new Producto(null, "Cielo raso de gypsum liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de acm liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de pvc liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de playcem liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso de modulares liso y diseños", 10.00, idCieloRaso));
            productos.add(new Producto(null, "Cielo raso reticulado liso y diseños", 10.00, idCieloRaso));
        }

        // Instalaciones decorativas
        String idInstalacionesDecorativas = categoriaIds.get("Instalaciones decorativas");
        if (idInstalacionesDecorativas != null) {
            productos.add(new Producto(null, "Paneles decorativos 3d", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles de PVC decorativos de textura de mármol", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles tipo piedra decorativos", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Separador de ambiente tipo pergola giratoria", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Paneles wpc decorativos", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Follaje artificial", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Microcemento", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Papel tapiz", 10.00, idInstalacionesDecorativas));
            productos.add(new Producto(null, "Impresión e instalación de vinilos decorativos", 10.00, idInstalacionesDecorativas));
        }

        // Revestimientos de piso y paredes
        String idRevestimientos = categoriaIds.get("Revestimientos de piso y paredes");
        if (idRevestimientos != null) {
            productos.add(new Producto(null, "Azulejos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Mozaiquillos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Baldosas", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Mármol", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Cuarzo", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Porcelanatos", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Piso cps", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Micro cemento", 10.00, idRevestimientos));
            productos.add(new Producto(null, "Resina epóxica", 10.00, idRevestimientos));
        }

        // Limpieza de sillones (Limpieza textil)
        String idLimpiezaTextil = categoriaIds.get("Limpieza textil");
        if (idLimpiezaTextil != null) {
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

        // Limpieza de áreas
        String idLimpiezaAreas = categoriaIds.get("Limpieza de áreas");
        if (idLimpiezaAreas != null) {
            productos.add(new Producto(null, "Limpieza de cocinas", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de baños", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de recámaras", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza general de vivienda", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de estacionamientos con hidrolavadora", 25.00, idLimpiezaAreas));
            productos.add(new Producto(null, "Limpieza de canales de techado", 25.00, idLimpiezaAreas));
        }
        
        // Mantenimientos preventivos
        String idMantenimientosPreventivos = categoriaIds.get("Mantenimientos preventivos");
        if (idMantenimientosPreventivos != null) {
            productos.add(new Producto(null, "Mantenimiento preventivo mensual", 25.00, idMantenimientosPreventivos));
        }
        
        // Trabajos de repello bofo de edificios
        String idRepello = categoriaIds.get("Trabajos de repello bofo de edificios");
        if (idRepello != null) {
            productos.add(new Producto(null, "Repello bofo de viviendas/edificios", 10.00, idRepello));
        }
        
        // Trabajos de pintura exterior de edificios
        String idPinturaExterior = categoriaIds.get("Trabajos de pintura exterior de edificios");
        if (idPinturaExterior != null) {
            productos.add(new Producto(null, "Pintura de altura", 10.00, idPinturaExterior));
        }
        
        // Trabajo de limpieza de vidrio y cambio de silicón de ventanas
        String idLimpiezaVentanas = categoriaIds.get("Trabajo de limpieza de vidrio y cambio de silicón de ventanas");
        if (idLimpiezaVentanas != null) {
            productos.add(new Producto(null, "Mantenimiento de ventanas", 10.00, idLimpiezaVentanas));
        }

        // Inspecciones con dron profesional
        String idInspeccionDrones = categoriaIds.get("Inspecciones con dron profesional");
        if (idInspeccionDrones != null) {
            productos.add(new Producto(null, "Inspección de áreas", 50.00, idInspeccionDrones));
        }
        
        // Remodelaciones
        String idRemodelaciones = categoriaIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null, "Proyecto de remodelación", 10.00, idRemodelaciones));
        }
        
        // Construcción
        String idConstruccion = categoriaIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null, "Proyecto de construcción", 10.00, idConstruccion));
        }
        
        // Chefs
        String idChefs = categoriaIds.get("Chefs");
        if (idChefs != null) {
            productos.add(new Producto(null, "Chef (festividades)", 25.00, idChefs));
        }
        
        // Saloneros
        String idSalonerros = categoriaIds.get("Salonerros");
        if (idSalonerros != null) {
            productos.add(new Producto(null, "Saloneros", 25.00, idSalonerros));
        }
        
        // Bartender
        String idBartender = categoriaIds.get("Bartender");
        if (idBartender != null) {
            productos.add(new Producto(null, "Bartender", 25.00, idBartender));
        }
        
        // Decoraciones
        String idDecoraciones = categoriaIds.get("Decoraciones");
        if (idDecoraciones != null) {
            productos.add(new Producto(null, "Decoraciones para fiestas", 25.00, idDecoraciones));
        }
        
        for (Producto producto : productos) {
            firestore.collection("productos").add(producto);
        }

        System.out.println("✅ Datos de categorías y productos poblados exitosamente.");
    }
}