import 'package:flutter/material.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

// Importa los modelos desde sus respectivos archivos
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/models/user_address_model.dart';
// Este modelo está en tu archivo original, así que lo importamos.

// Clase de simulación de un servicio que obtiene las citas asignadas
class CitaService {
  Future<List<CitaModel>> fetchCitasAsignadas(String technicianId) async {
    // Simula un retraso de red
    await Future.delayed(const Duration(seconds: 2));

    // Datos de ejemplo para la lista de citas
    return [
      CitaModel(
        id: 'cita_001',
        userId: 'user_001',
        tecnicoId: technicianId,
        fecha: DateTime.now().add(const Duration(days: 1)),
        hora: '10:00 AM',
        status: 'Asignada',
        costoTotal: 75.00,
        descripcion: 'El aire acondicionado gotea y hace un ruido fuerte.',
        cliente: UserModel(
          id: 'user_001',
          nombre: 'Juan Pérez',
          correo: 'juan.perez@example.com',
          telefono: '6677-8899',
          direccion: UserAddressModel(
            barrio: 'Los Sauces',
            house: 'Casa 12',
            province: 'Panamá',
            district: 'Panamá',
            corregimiento: 'Ancón',
          ),
          rol: 'USUARIO_FINAL',
        ),
        productos: {
          ProductModel(
            id: 'lmsae',
            nombre: 'Limpieza, mantenimiento y solución de aire acondicionado',
            costo: 30.00,
            servicioId: 'aire_acondicionado',
          ): 1,
          ProductModel(
            id: 'cvrf',
            nombre: 'Carga de válvula o recarga de filtro',
            costo: 25.00,
            servicioId: 'aire_acondicionado',
          ): 1,
        },
      ),
      CitaModel(
        id: 'cita_002',
        userId: 'user_002',
        tecnicoId: technicianId,
        fecha: DateTime.now().add(const Duration(days: 2)),
        hora: '02:30 PM',
        status: 'Asignada',
        costoTotal: 25.00,
        descripcion: 'La cerradura de la puerta principal está atascada.',
        cliente: UserModel(
          id: 'user_002',
          nombre: 'Ana Gómez',
          correo: 'ana.gomez@example.com',
          telefono: '5566-7788',
          direccion: UserAddressModel(
            barrio: 'El Dorado',
            house: 'Apto 5B',
            province: 'Panamá Oeste',
            district: 'Arraiján',
            corregimiento: 'Veracruz',
          ),
          rol: 'USUARIO_FINAL',
        ),
        productos: {
          ProductModel(
            id: 'i_cerraduras',
            nombre: 'Instalación de cerraduras en puertas de madera',
            costo: 25.00,
            servicioId: 'ebanisteria',
          ): 1,
        },
      ),
    ];
  }
}

class TechnicianPanelScreen extends StatefulWidget {
  const TechnicianPanelScreen({super.key});

  @override
  State<TechnicianPanelScreen> createState() => _TechnicianPanelScreenState();
}

class _TechnicianPanelScreenState extends State<TechnicianPanelScreen> {
  late Future<List<CitaModel>> _futureCitas;
  final CitaService _citaService = CitaService();
  final String _technicianId = 'tech_001'; // ID de técnico simulado

  @override
  void initState() {
    super.initState();
    _futureCitas = _citaService.fetchCitasAsignadas(_technicianId);
  }

  void _confirmarCita(String citaId) {
    // Lógica para enviar la confirmación a Firebase
    // En un proyecto real, esto actualizaría el campo 'status' a 'Confirmada'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cita $citaId confirmada exitosamente.')),
    );
    // Vuelve a cargar la lista para reflejar el cambio (si el estado se actualiza)
    setState(() {
      _futureCitas = _citaService.fetchCitasAsignadas(_technicianId);
    });
  }

  Widget _buildCitaCard(CitaModel cita) {
    // Usa el UserAddressModel para acceder correctamente a los detalles de la dirección
    final UserAddressModel? address = cita.cliente?.direccion;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cita Asignada',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const Divider(color: AppColors.white54, height: 20),

            // Nombre del Cliente
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  cita.cliente?.nombre ?? 'Cliente Desconocido',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fecha y Hora
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${cita.hora}, ${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year}',
                  style: AppTextStyles.listSubtitle,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dirección
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${address?.barrio ?? 'N/A'}, ${address?.house ?? 'N/A'} - ${address?.corregimiento ?? 'N/A'}, ${address?.district ?? 'N/A'}, ${address?.province ?? 'N/A'}',
                    style: AppTextStyles.listSubtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón de Confirmar Cita
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _confirmarCita(cita.id),
                icon: const Icon(
                  Icons.check,
                  color: AppColors.elevatedButtonForeground,
                ),
                label: const Text('Confirmar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Técnico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<CitaModel>>(
          future: _futureCitas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No tienes citas asignadas.',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              );
            } else {
              final citas = snapshot.data!;
              return ListView.builder(
                itemCount: citas.length,
                itemBuilder: (context, index) {
                  final cita = citas[index];
                  return _buildCitaCard(cita);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
