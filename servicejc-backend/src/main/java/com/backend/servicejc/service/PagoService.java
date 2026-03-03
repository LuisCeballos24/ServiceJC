package com.backend.servicejc.service;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.model.Pago;
import com.backend.servicejc.model.SolicitudPago;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Map;

@Service
public class PagoService {

    private final Firestore firestore;
    private final CuboPaymentService cuboPaymentService; // 🟢 Inyectamos el servicio de Cubo
    private final CitaService citaService;               // 🟢 Inyectamos el servicio de Citas
    private final String COLLECTION_NAME = "pagos";

    @Autowired
    public PagoService(Firestore firestore, CuboPaymentService cuboPaymentService, CitaService citaService) {
        this.firestore = firestore;
        this.cuboPaymentService = cuboPaymentService;
        this.citaService = citaService;
    }

    // Método para procesar y registrar un pago REAL
    // 🔴 CAMBIO: Recibe SolicitudPago (con la tarjeta) y el usuarioId. Retorna el ID del pago.
    public String processPayment(SolicitudPago solicitud, String usuarioId) throws Exception {
        
        // 1. INTEGRACIÓN CON LA PASARELA DE PAGO (CuboPago)
        Map<String, Object> cuboResponse = cuboPaymentService.procesarPago(solicitud);

        // Extraer el ID de transacción de Cubo para auditoría
        String transactionId = cuboResponse.containsKey("transaction_id") 
                                ? String.valueOf(cuboResponse.get("transaction_id")) 
                                : "ID_DESCONOCIDO";

        // 2. CREAR EL OBJETO PAGO (Tu modelo para Firestore)
        Pago pago = new Pago();
        pago.setCitaId(solicitud.getCitaId());
        pago.setMonto(solicitud.getAmount());
        pago.setEstado("aprobado"); 
        pago.setMetodoDePago("tarjeta de crédito"); 
        
        // Agregar datos de auditoría
        pago.setUsuarioId(usuarioId);
        pago.setTransaccionCuboId(transactionId);
        pago.setFechaHora(new Date());

        // 3. GUARDAR EN FIRESTORE (Usando tu lógica original)
        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
        pago.setId(docRef.getId()); // Asigna un ID al pago
        ApiFuture<com.google.cloud.firestore.WriteResult> result = docRef.set(pago);
        result.get(); // Espera a que la operación se complete

        // 4. 🟢 NUEVO: ACTUALIZAR EL ESTADO DE LA CITA A "PAGADA"
        Cita citaActual = citaService.getCitaById(solicitud.getCitaId());
        if (citaActual != null) {
            citaActual.setEstado("PAGADA");
            citaService.updateCita(solicitud.getCitaId(), citaActual);
        }

        // Retornamos el ID para que el Controller se lo devuelva a Flutter
        return pago.getId();
    }
}