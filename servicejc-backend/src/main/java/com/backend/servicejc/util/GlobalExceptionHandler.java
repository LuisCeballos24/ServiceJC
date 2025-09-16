package com.backend.servicejc.util;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    // Maneja excepciones de tipo IllegalArgumentException
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgumentException(IllegalArgumentException ex) {
        // Devuelve un estado HTTP 400 (Bad Request) con el mensaje de error de la excepción
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    // Maneja cualquier otra excepción no especificada
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGenericException(Exception ex) {
        // Devuelve un estado HTTP 500 (Internal Server Error) y un mensaje genérico
        // Puedes loguear 'ex' para ver el detalle del error en el servidor
        return new ResponseEntity<>("Ocurrió un error inesperado. Intente de nuevo más tarde.", HttpStatus.INTERNAL_SERVER_ERROR);
    }
}