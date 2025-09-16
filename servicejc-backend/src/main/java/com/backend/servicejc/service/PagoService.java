package com.backend.servicejc.service;

import com.backend.servicejc.model.Pago;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.concurrent.ExecutionException;

@Service
public class PagoService {

    private final Firestore firestore;
    private final String COLLECTION_NAME = "pagos";

    @Autowired
    public PagoService(Firestore firestore) {
        this.firestore = firestore;
    }

    // Método para procesar y registrar un pago
    public void processPayment(Pago pago) throws ExecutionException, InterruptedException {
        // En una implementación real, aquí se integraría con una pasarela de pago (ej. Stripe, PayPal, etc.)
        // La lógica de la pasarela de pago iría aquí.

        // Simula un pago exitoso
        pago.setEstado("aprobado");

        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
        pago.setId(docRef.getId()); // Asigna un ID al pago
        ApiFuture<com.google.cloud.firestore.WriteResult> result = docRef.set(pago);
        result.get(); // Espera a que la operación se complete
    }
}