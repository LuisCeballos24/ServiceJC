package com.backend.servicejc.service;

import com.backend.servicejc.model.SolicitudPago;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class CuboPaymentService {

    @Value("${cubo.api.key}")
    private String apiKey;

    @Value("${cubo.api.url}")
    private String apiUrl;

    public Map<String, Object> procesarPago(SolicitudPago solicitud) throws Exception {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-API-KEY", apiKey);

        // Cubo pide el monto en centavos
        int montoCentavos = (int) Math.round(solicitud.getAmount() * 100);

        Map<String, Object> body = new HashMap<>();
        body.put("clientName", solicitud.getCardHolder());
        body.put("clientEmail", solicitud.getEmail());
        body.put("clientPhone", solicitud.getPhone());
        body.put("description", "Pago Servicio JC - Cita " + solicitud.getCitaId());
        body.put("amount", montoCentavos);
        body.put("cardHolder", solicitud.getCardHolder());
        body.put("cardNumber", solicitud.getCardNumber());
        body.put("cvv", solicitud.getCvv());
        body.put("month", solicitud.getExpMonth());
        body.put("year", solicitud.getExpYear());

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(apiUrl, entity, Map.class);
            
            if (response.getStatusCode() == HttpStatus.OK || response.getStatusCode() == HttpStatus.CREATED) {
                return response.getBody();
            } else {
                throw new Exception("Error en Pasarela: " + response.getBody());
            }
        } catch (Exception e) {
            throw new Exception("Transacción rechazada: " + e.getMessage());
        }
    }
}