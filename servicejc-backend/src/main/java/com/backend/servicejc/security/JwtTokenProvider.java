package com.backend.servicejc.security;

import io.jsonwebtoken.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import java.util.Date;

@Component
public class JwtTokenProvider {

    // En producción, esto debería estar en application.properties
    @Value("${app.jwtSecret:JWTSecretKeyMuchaSeguridadServiceJC}")
    private String jwtSecret;

    @Value("${app.jwtExpirationInMs:604800000}") // 7 días en milisegundos
    private int jwtExpirationInMs;

    // Generar Token
   public String generateToken(Authentication authentication) {
        // Obtenemos el ID directamente porque lo pusimos en el AuthService manual
        String userId = authentication.getName(); // Aquí vendrá el ID del usuario
        
        // OJO: Cambia a HS256 para evitar problemas de clave corta
        return Jwts.builder()
                .setSubject(userId)
                .setIssuedAt(new Date())
                .setExpiration(new Date(new Date().getTime() + jwtExpirationInMs))
                .signWith(SignatureAlgorithm.HS256, jwtSecret) 
                .compact();
    }

    // Obtener ID del Usuario desde el Token
    public String getUserIdFromJWT(String token) {
        Claims claims = Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token)
                .getBody();

        return claims.getSubject();
    }

    // Validar Token
    public boolean validateToken(String authToken) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(authToken);
            return true;
        } catch (SignatureException ex) {
            System.out.println("Firma JWT inválida");
        } catch (MalformedJwtException ex) {
            System.out.println("Token JWT inválido");
        } catch (ExpiredJwtException ex) {
            System.out.println("Token JWT expirado");
        } catch (UnsupportedJwtException ex) {
            System.out.println("Token JWT no soportado");
        } catch (IllegalArgumentException ex) {
            System.out.println("La cadena claims JWT está vacía");
        }
        return false;
    }
}