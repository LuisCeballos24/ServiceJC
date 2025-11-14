package com.backend.servicejc.service;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value; // Importar @Value
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList; 
import java.util.List; 
import java.util.UUID;

@Service
public class FirebaseStorageService {

    private final Storage storage;
    private final String BUCKET_NAME; // Ahora es una variable de instancia, inyectada

    @Autowired
    // Inyectamos Storage (cliente) y el valor del bucket name
    public FirebaseStorageService(Storage storage, @Value("${firebase.storage.bucket-name}") String bucketName) {
        this.storage = storage;
        this.BUCKET_NAME = bucketName; // Asignamos el valor inyectado: "servicejc-d3aca.appspot.com"
    }

    /**
     * Sube un archivo a Firebase Storage y devuelve su URL pública.
     *
     * @param file El archivo MultipartFile subido desde el cliente.
     * @param path Prefijo de la carpeta de destino (ej: "citas/imagenes/").
     * @return El URL público (Download URL) del archivo.
     * @throws IOException Si ocurre un error al leer el archivo.
     */
    public String uploadFile(MultipartFile file, String path) throws IOException {
        if (file.isEmpty()) {
            return null; 
        }

        // Generar un nombre único para evitar colisiones
        String originalFileName = file.getOriginalFilename();
        String extension = originalFileName != null && originalFileName.contains(".") ?
                           originalFileName.substring(originalFileName.lastIndexOf('.')) : "";
        String fileName = path + UUID.randomUUID().toString() + extension;
        
        // Configurar los metadatos para que el archivo sea público
        BlobId blobId = BlobId.of(BUCKET_NAME, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType(file.getContentType())
                // Se asegura que los archivos subidos sean accesibles públicamente
                .setAcl(new ArrayList<>(List.of(com.google.cloud.storage.Acl.of(
                        com.google.cloud.storage.Acl.User.ofAllUsers(), com.google.cloud.storage.Acl.Role.READER))))
                .build();

        // Subir el archivo
        Blob blob = storage.create(blobInfo, file.getBytes());

        // Devolver el URL de descarga pública
        return String.format("https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media", BUCKET_NAME, fileName);
    }
}