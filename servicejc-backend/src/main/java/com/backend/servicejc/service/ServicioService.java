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

    // 💡 1. Implementación del Nivel 1 (para /api/categorias_principales)
    public List<CategoriaPrincipalModel> fetchCategoriasPrincipales() throws ExecutionException, InterruptedException {
        // Asumiendo que usted tiene un POJO CategoriaPrincipalModel
        ApiFuture<QuerySnapshot> future = firestore.collection("categorias_principales").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream()
                // Aquí deberá mapear a su POJO CategoriaPrincipalModel
                .map(doc -> doc.toObject(CategoriaPrincipalModel.class))
                .collect(Collectors.toList());
    }

    public List<Servicio> fetchServiciosByCategoriaId(String categoriaPrincipalId)
            throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios")
                .whereEqualTo("categoriaPrincipalId", categoriaPrincipalId)
                .get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream()
                .map(doc -> doc.toObject(Servicio.class))
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
                    if (p != null)
                        p.setId(doc.getId());
                    return p;
                })
                .filter(p -> p != null)
                .collect(Collectors.toList());
    }

    private final Map<String, String> SERVICIO_TO_CATEGORIA_MAP = Map.ofEntries(
            Map.entry("Electricidad", "MANT_REP"),
            Map.entry("Plomería", "MANT_REP"),
            Map.entry("Instalaciones menores", "MANT_REP"),
            Map.entry("Aire acondicionado (instalación y mantenimiento)", "MANT_REP"),
            Map.entry("Soldadura", "MANT_REP"),
            Map.entry("Aluminio y vidrio", "MANT_REP"),
            Map.entry("Mantenimiento de Ventanas", "MANT_REP"),

            Map.entry("Pintores", "ACABADOS_ESP"),
            Map.entry("Pintura Exterior de Edificios", "ACABADOS_ESP"),
            Map.entry("Cielo raso", "ACABADOS_ESP"),
            Map.entry("Instalaciones decorativas", "ACABADOS_ESP"),
            Map.entry("Revestimientos de piso y paredes", "ACABADOS_ESP"),

            Map.entry("Ebanistas", "REMODEL_CONST"),
            Map.entry("Repello Bofo", "REMODEL_CONST"),
            Map.entry("Remodelaciones", "REMODEL_CONST"),
            Map.entry("Construcción", "REMODEL_CONST"),

            Map.entry("Limpieza Textil", "LIMPIEZA"),
            Map.entry("Limpieza General", "LIMPIEZA"),
            Map.entry("Limpieza de Canales", "LIMPIEZA"),
            Map.entry("Mantenimientos preventivos", "LIMPIEZA"),

            Map.entry("Filtraciones", "ESPECIALIZADOS"),
            Map.entry("Energía Solar", "ESPECIALIZADOS"),
            Map.entry("Inspecciones con Dron Profesional", "ESPECIALIZADOS"),

            Map.entry("Reuniones y Festividades", "EVENTOS"));

    private final List<Map.Entry<String, String>> CATEGORIAS_PRINCIPALES = List.of(
            Map.entry("MANT_REP", "Mantenimiento y Reparaciones Técnicas"),
            Map.entry("REMODEL_CONST", "Remodelación y Construcción"),
            Map.entry("ACABADOS_ESP", "Acabados y Revestimientos"),
            Map.entry("LIMPIEZA", "Limpieza Especializada y General"),
            Map.entry("ESPECIALIZADOS", "Servicios Técnicos Especializados"),
            Map.entry("EVENTOS", "Servicios para Eventos y Logística"));

    // --- MÉTODO DE POBLAMIENTO MEJORADO ---
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> futureServicios = firestore.collection("servicios").get();
        if (!futureServicios.get().isEmpty()) {
            System.out.println("Las colecciones ya contienen datos. No se poblarán.");
            return;
        }

        System.out.println("Poblando colecciones 'categorias_principales', 'servicios' y 'productos'...");

        // 1. Población de Categorías Principales (Nuevo nivel jerárquico)
        Map<String, String> principalIds = new HashMap<>();
        for (Map.Entry<String, String> entry : CATEGORIAS_PRINCIPALES) {
            Map<String, Object> categoria = new HashMap<>();
            categoria.put("id", entry.getKey());
            categoria.put("nombre", entry.getValue());
            ApiFuture<DocumentReference> addedDocRef = firestore.collection("categorias_principales").add(categoria);
            principalIds.put(entry.getKey(), addedDocRef.get().getId());
        }

        // 2. Población de Servicios (Sub-pantalla) y enlace a la Categoría Principal
        Map<String, String> servicioIds = new HashMap<>();
        List<String> nombresServicios = new ArrayList<>(SERVICIO_TO_CATEGORIA_MAP.keySet());

        for (String nombre : nombresServicios) {
            Map<String, Object> servicio = new HashMap<>();
            servicio.put("nombre", nombre);
            String principalId = SERVICIO_TO_CATEGORIA_MAP.get(nombre);

            // Usamos el ID interno como valor de referencia, aunque no es el ID de
            // Firestore
            // ya que la clase Servicio solo tiene 'nombre'. Si la clase Servicio tiene mas
            // campos,
            // usaríamos un POJO, aquí usamos Map para incluir el enlace.
            servicio.put("categoriaPrincipalId", principalId);

            ApiFuture<DocumentReference> addedDocRef = firestore.collection("servicios").add(servicio);
            servicioIds.put(nombre, addedDocRef.get().getId());
        }

        // 3. Población de Productos (ítems específicos) con Lógica de Inspección
        List<Producto> productos = new ArrayList<>();
        final Double COSTO_INSPECCION = 10.00;

        // --- MANTENIMIENTO Y REPARACIONES TÉCNICAS (MANT_REP) ---
        String idElectricidad = servicioIds.get("Electricidad");
        if (idElectricidad != null) {
            // Servicios de costo fijo
            productos.add(
                    new Producto(null, "Instalación/Cambio: Lámpara/Bombilla/Toma/Interruptor", 25.00, idElectricidad));
            productos.add(
                    new Producto(null, "Instalación/Revisión: Ventilador de Techo/Abanico", 30.00, idElectricidad));
            productos.add(new Producto(null, "Instalación/Revisión: Breaker/Caja de Fusibles", 40.00, idElectricidad));
            productos.add(
                    new Producto(null, "Revisión y Solución de Mal Funcionamiento Eléctrico", 20.00, idElectricidad));
            // Servicio que requiere inspección
            productos.add(new Producto(null, "Inspección y Cotización de Proyecto Nuevo o Reparación Mayor",
                    COSTO_INSPECCION, idElectricidad));
        }

        String idPlomeria = servicioIds.get("Plomería");
        if (idPlomeria != null) {
            // Servicios de costo fijo
            productos.add(new Producto(null, "Instalación/Cambio: Grifo de Lavamanos/Fregador (2 mangueras)", 30.00,
                    idPlomeria)); // Unificado
            productos.add(new Producto(null, "Instalación/Cambio: Llave de Ángulo/Chorro", 30.00, idPlomeria)); // Unificado
            productos.add(
                    new Producto(null, "Instalación/Revisión: Ferretería de Inodoro (Cisterna)", 80.00, idPlomeria)); // Precio
                                                                                                                      // del
                                                                                                                      // original
            productos.add(new Producto(null, "Instalación/Destape de Desagües y Tuberías", 30.00, idPlomeria));
            productos.add(
                    new Producto(null, "Instalación: Inodoro, Lavamanos, Bañera o Plato de Ducha", 40.00, idPlomeria)); // Unificado
            // Servicio que requiere inspección
            productos.add(new Producto(null, "Inspección y Cotización de Proyecto Nuevo o Reparación Mayor",
                    COSTO_INSPECCION, idPlomeria));
        }

        String idInstalacionesMenores = servicioIds.get("Instalaciones menores");
        if (idInstalacionesMenores != null) {
            // Servicios de costo fijo
            productos.add(new Producto(null, "Instalación de Cuadro/Espejo/Elemento Decorativo", 25.00,
                    idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de Tablilla/Repisa/Rodapié", 25.00, idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de Soporte de TV (hasta 50 pulgadas)", 30.00,
                    idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de Soporte de TV (más de 50 pulgadas)", 50.00,
                    idInstalacionesMenores));
            productos.add(new Producto(null, "Instalación de Cortina/Riel de Cortinas", 25.00, idInstalacionesMenores));
            // Servicio que requiere inspección
            productos.add(new Producto(null, "Inspección y Cotización por Solicitud Específica", COSTO_INSPECCION,
                    idInstalacionesMenores));
        }

        String idAireAcondicionado = servicioIds.get("Aire acondicionado (instalación y mantenimiento)");
        if (idAireAcondicionado != null) {
            // Servicios de costo fijo
            productos.add(
                    new Producto(null, "Limpieza y Mantenimiento de A/C (9 a 18 BTU)", 30.00, idAireAcondicionado));
            productos.add(new Producto(null, "Carga de Válvula o Recarga de Filtro", 25.00, idAireAcondicionado));
            // Servicio que requiere inspección
            productos.add(
                    new Producto(null, "Inspección y Cotización: Instalación Nueva, Reparación Mayor o Reubicación",
                            COSTO_INSPECCION, idAireAcondicionado));
        }

        String idSoldadura = servicioIds.get("Soldadura");
        if (idSoldadura != null) {
            // Servicios de costo fijo
            productos.add(new Producto(null, "Instalación de Puerta de Hierro/Verja", 75.00, idSoldadura)); // Usando el
                                                                                                            // precio
                                                                                                            // más alto
            productos.add(new Producto(null, "Instalación de Cerradura (Metálica)", 50.00, idSoldadura));
            productos.add(new Producto(null, "Reparación de Pasamanos (Simple)", 50.00, idSoldadura));
            // Servicios que requieren inspección (Mantenimientos y Proyectos)
            productos
                    .add(new Producto(null, "Inspección y Cotización: Mantenimiento de Puertas/Canales, Proyecto Nuevo",
                            COSTO_INSPECCION, idSoldadura));
        }

        String idAluminioVidrio = servicioIds.get("Aluminio y vidrio");
        if (idAluminioVidrio != null) {
            // Servicios que requieren inspección (el archivo lo indica para la mayoría)
            productos.add(
                    new Producto(null, "Inspección y Cotización: Confección de Proyecto Nuevo o Reparación Compleja",
                            COSTO_INSPECCION, idAluminioVidrio));
        }

        String idMantenimientoVentanas = servicioIds.get("Mantenimiento de Ventanas");
        if (idMantenimientoVentanas != null) {
            // Servicio que requiere inspección
            productos.add(new Producto(null,
                    "Inspección y Cotización: Mantenimiento/Reparación de Ventanas (Edificios/Fábricas/Proyectos)",
                    COSTO_INSPECCION, idMantenimientoVentanas));
        }

        // --- REMODELACIÓN Y CONSTRUCCIÓN (REMODEL_CONST) ---

        // Todos los servicios de esta categoría requieren inspección de $10.00 para
        // cotizar el proyecto.
        String idRemodelaciones = servicioIds.get("Remodelaciones");
        if (idRemodelaciones != null) {
            productos.add(new Producto(null,
                    "Inspección y Cotización: Planificación, Diseño, Demoliciones, Albañilería y Proyectos",
                    COSTO_INSPECCION, idRemodelaciones));
        }

        String idConstruccion = servicioIds.get("Construcción");
        if (idConstruccion != null) {
            productos.add(new Producto(null,
                    "Inspección y Cotización: Proyectos de Construcción (Hormigón, Metálica, Liviana, Paneles)",
                    COSTO_INSPECCION, idConstruccion));
        }

        String idRepello = servicioIds.get("Repello Bofo");
        if (idRepello != null) {
            productos.add(new Producto(null, "Inspección y Cotización: Repello Bofo en Viviendas o Edificios",
                    COSTO_INSPECCION, idRepello));
        }

        String idEbanistas = servicioIds.get("Ebanistas");
        if (idEbanistas != null) {
            // Servicios de costo fijo
            productos.add(new Producto(null, "Instalación: Puerta de Madera (sin cerradura)", 40.00, idEbanistas));
            productos.add(new Producto(null, "Instalación: Cerradura/Jamba de Madera", 25.00, idEbanistas));
            // Servicios que requieren inspección (Mantenimientos y Proyectos)
            productos.add(new Producto(null,
                    "Inspección y Cotización: Proyectos Nuevos, Renovaciones, Reparaciones o Confección de Mobiliario",
                    COSTO_INSPECCION, idEbanistas));
        }

        // --- ACABADOS Y REVESTIMIENTOS (ACABADOS_ESP) ---

        String idPintores = servicioIds.get("Pintores");
        if (idPintores != null) {
            // Servicios de costo fijo (mano de obra)
            productos.add(new Producto(null, "Costo por metro cuadrado (Solo mano de obra)", 8.00, idPintores));
            productos.add(new Producto(null, "Pintura y Repello en Interiores (por m²)", 15.00, idPintores));
            // Servicio que requiere inspección (El archivo de Pintura General lo sugiere)
            productos.add(new Producto(null,
                    "Inspección y Cotización: Aplicación de Pintura Especializada (Epóxica, Grado Alimenticio, etc.) o Proyectos Grandes",
                    COSTO_INSPECCION, idPintores));
        }

        String idPinturaExterior = servicioIds.get("Pintura Exterior de Edificios");
        if (idPinturaExterior != null) {
            // Servicio que requiere inspección
            productos.add(new Producto(null,
                    "Inspección y Cotización: Pintura, Reparación o Mantenimiento de Fachadas/Azoteas/Fosos",
                    COSTO_INSPECCION, idPinturaExterior));
        }

        String idCieloRaso = servicioIds.get("Cielo raso");
        if (idCieloRaso != null) {
            productos.add(new Producto(null,
                    "Inspección y Cotización: Proyectos Nuevos o Solicitudes Específicas (Gypsum, ACM, PVC, Modulares)",
                    COSTO_INSPECCION, idCieloRaso));
        }

        String idInstalacionesDecorativas = servicioIds.get("Instalaciones decorativas");
        if (idInstalacionesDecorativas != null) {
            productos.add(new Producto(null,
                    "Inspección y Cotización: Proyectos Nuevos, Paneles Decorativos, Microcemento o Vinilos",
                    COSTO_INSPECCION, idInstalacionesDecorativas));
        }

        String idRevestimientos = servicioIds.get("Revestimientos de piso y paredes");
        if (idRevestimientos != null) {
            productos.add(new Producto(null,
                    "Inspección y Cotización: Instalación de Revestimientos (Azulejos, Mármol, Porcelanato, Resina Epóxica)",
                    COSTO_INSPECCION, idRevestimientos));
        }

        // --- LIMPIEZA ESPECIALIZADA Y GENERAL (LIMPIEZA) ---

        String idLimpiezaTextil = servicioIds.get("Limpieza Textil");
        if (idLimpiezaTextil != null) {
            // Servicios de costo fijo (usando el precio más bajo del CSV como estándar para
            // unidades)
            productos.add(new Producto(null, "Limpieza de Sillón (1 puesto)", 40.00, idLimpiezaTextil));
            productos
                    .add(new Producto(null, "Limpieza de Sillón Grande (tipo L / 5 puestos)", 75.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Limpieza de Comedor (4 puestos)", 40.00, idLimpiezaTextil));
            productos.add(new Producto(null, "Limpieza de Colchón (unidad)", 50.00, idLimpiezaTextil));
            productos.add(
                    new Producto(null, "Limpieza Interior de Vehículo (Sedan/Camioneta)", 60.00, idLimpiezaTextil)); // Unificado
        }

        String idLimpiezaGeneral = servicioIds.get("Limpieza General");
        if (idLimpiezaGeneral != null) {
            // Servicios de costo fijo (limpieza básica/por área)
            productos.add(new Producto(null, "Limpieza de Cocina, Recámara, Sala, Baño o Garaje (por área)", 50.00,
                    idLimpiezaGeneral)); // Unificado en 50.00
            productos.add(new Producto(null, "Limpieza General de Vivienda/Áreas Sociales/Gimnasio", 60.00,
                    idLimpiezaGeneral));
            productos.add(new Producto(null, "Limpieza de Estacionamiento/Rampas con Hidrolavadora", 75.00,
                    idLimpiezaGeneral));
            // Servicio que requiere inspección (Describe tu solicitud)
            productos.add(new Producto(null,
                    "Inspección y Cotización por Solicitud Específica (Limpieza Profunda/Especializada)",
                    COSTO_INSPECCION, idLimpiezaGeneral));
        }

        String idLimpiezaCanales = servicioIds.get("Limpieza de Canales");
        if (idLimpiezaCanales != null) {
            // Servicio que requiere inspección (El archivo lo indica)
            productos.add(
                    new Producto(null, "Inspección y Cotización: Limpieza de Canaletas de Techados y Canales Pluviales",
                            COSTO_INSPECCION, idLimpiezaCanales));
        }

        String idMantenimientosPreventivos = servicioIds.get("Mantenimientos preventivos");
        if (idMantenimientosPreventivos != null) {
            // Servicio que requiere inspección (El archivo lo indica para el levantamiento)
            productos.add(new Producto(null,
                    "Inspección y Levantamiento para Plan de Mantenimiento Preventivo (Viviendas/Edificios/Fábricas)",
                    COSTO_INSPECCION, idMantenimientosPreventivos));
        }

        // --- SERVICIOS TÉCNICOS ESPECIALIZADOS (ESPECIALIZADOS) ---

        String idFiltraciones = servicioIds.get("Filtraciones");
        if (idFiltraciones != null) {
            // La inspección visual es el primer paso con un costo fijo
            productos.add(new Producto(null, "Inspección Visual de Filtraciones para Determinación de Herramienta",
                    COSTO_INSPECCION, idFiltraciones));
            productos.add(new Producto(null, "Inspección con Cámara Térmica", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con Cámara Endoscópica/Ultrasonido", 150.00, idFiltraciones));
            productos.add(new Producto(null, "Inspección con Dron (Filtraciones en Fachadas)", 150.00, idFiltraciones));
        }

        String idInspeccionDrones = servicioIds.get("Inspecciones con Dron Profesional");
        if (idInspeccionDrones != null) {
            // Servicio que requiere inspección (El archivo lo indica)
            productos.add(new Producto(null,
                    "Inspección y Cotización: Techados, Fisuras en Fachadas y Seguimiento de Trabajos",
                    COSTO_INSPECCION, idInspeccionDrones));
            productos.add(new Producto(null, "Servicio de Dron para Ceremonias/Eventos (Cotización Previa)",
                    COSTO_INSPECCION, idInspeccionDrones)); // O se puede poner un costo fijo de base
        }

        String idEnergiaSolar = servicioIds.get("Energía Solar");
        if (idEnergiaSolar != null) {
            // Servicio que requiere inspección
            productos.add(
                    new Producto(null, "Inspección y Cotización: Mantenimiento, Reparaciones o Instalaciones Nuevas",
                            COSTO_INSPECCION, idEnergiaSolar));
        }

        // --- SERVICIOS PARA EVENTOS (EVENTOS) ---

        String idReuniones = servicioIds.get("Reuniones y Festividades");
        if (idReuniones != null) {
            // Servicios por hora (costo fijo)
            productos.add(new Producto(null, "Contratación: Cocinero (2 horas)", 60.00, idReuniones));
            productos.add(new Producto(null, "Contratación: Salonero (2 horas)", 50.00, idReuniones));
            productos.add(new Producto(null, "Contratación: Bartender (2 horas)", 60.00, idReuniones));
            productos.add(new Producto(null, "Contratación: Decorador (2 horas)", 60.00, idReuniones));
            productos.add(
                    new Producto(null, "Logística: Movilización/Acomodo de Mobiliario (2 horas)", 80.00, idReuniones));
            productos.add(new Producto(null, "Logística: Valet Parking (2 horas)", 40.00, idReuniones));
            productos.add(new Producto(null, "Logística: Conductor Designado (2 horas)", 70.00, idReuniones));
            // Servicio que requiere inspección
            productos.add(new Producto(null, "Inspección y Cotización por Solicitud Específica", COSTO_INSPECCION,
                    idReuniones));
        }

        // 4. Inserción de Productos
        for (Producto producto : productos) {
            firestore.collection("productos").add(producto);
        }

        System.out.println(
                "✅ Datos de categorías, servicios y productos poblados exitosamente con lógica de inspección.");
    }
}