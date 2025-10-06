import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importar la librería de gráficos
import 'package:servicejc/models/tecnico.dart';
import '../services/admin_api_service.dart';
import 'admin_management_screen.dart'; // Importar la nueva pantalla
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminApiService _apiService = AdminApiService();
  late Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _apiService.getDashboardMetrics();
  }

  void _eliminarTecnico(String tecnicoId) async {
    try {
      await _apiService.eliminarTecnico(tecnicoId);
      setState(() {
        _metricsFuture = _apiService.getDashboardMetrics();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Técnico eliminado', style: AppTextStyles.bodyText),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: AppTextStyles.bodyText),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Función de utilidad para crear una tarjeta de métrica
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppColors.secondary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(color: AppColors.white70),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.accent,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para el gráfico de barras (simulación simple)
  Widget _buildBarChart(List<Tecnico> tecnicos) {
    List<BarChartGroupData> barGroups = tecnicos.asMap().entries.map((entry) {
      final int index = entry.key;
      final Tecnico tecnico = entry.value;
      // Usaremos un valor simulado para la altura (ej: la cantidad de citas completadas)
      final double y = (index + 1) * 10.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: y,
            color: AppColors.accent,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    angle: -0.8,
                    child: Text(
                      tecnicos[value.toInt()].nombre.split(
                        ' ',
                      )[0], // Muestra solo el primer nombre
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  );
                },
                interval: 1.0,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                'Citas (simuladas)',
                style: AppTextStyles.caption.copyWith(color: AppColors.white70),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white70,
                    ),
                  );
                },
              ),
            ),
          ),
          alignment: BarChartAlignment.spaceAround,
          maxY: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.accent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTextStyles.h3.copyWith(color: AppColors.danger),
              ),
            );
          } else if (snapshot.hasData) {
            final metrics = snapshot.data!;
            final List<dynamic> tecnicosData = metrics['tecnicosMasDestacados'];
            final List<Tecnico> tecnicos = tecnicosData
                .map((data) => Tecnico.fromJson(data))
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard de Métricas
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMetricCard(
                        title: 'Técnicos Activos',
                        value: '${metrics['tecnicosActivos']}',
                        icon: Icons.people_alt,
                        color: AppColors.iconButton,
                      ),
                      _buildMetricCard(
                        title: 'Citas Activas',
                        value: '${metrics['citasActivas']}',
                        icon: Icons.calendar_today,
                        color: AppColors.floatingButton,
                      ),
                      _buildMetricCard(
                        title: 'Ganancias Totales',
                        value: '\$${metrics['totalGanancias']}',
                        icon: Icons.attach_money,
                        color: AppColors.success,
                      ),
                      _buildMetricCard(
                        title: 'Total Usuarios',
                        value:
                            'N/A', // Puedes agregar esta métrica al backend si es necesaria
                        icon: Icons.person_add,
                        color: AppColors.accent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  // Gráfico de Barras
                  Text(
                    'Técnicos más destacados (por citas completadas)',
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  tecnicos.isNotEmpty
                      ? _buildBarChart(tecnicos)
                      : Text(
                          'No hay datos de técnicos.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white54,
                          ),
                        ),

                  const SizedBox(height: 32),

                  // Lista de técnicos (como antes)
                  Text(
                    'Gestión de Técnicos',
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tecnicos.length,
                    itemBuilder: (context, index) {
                      final tecnico = tecnicos[index];
                      return Card(
                        color: AppColors.secondary,
                        child: ListTile(
                          title: Text(
                            tecnico.nombre,
                            style: AppTextStyles.listTitle,
                          ),
                          subtitle: Text(
                            'Correo: ${tecnico.correo}',
                            style: AppTextStyles.listSubtitle.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.danger,
                            ),
                            onPressed: () => _eliminarTecnico(tecnico.correo),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'No hay datos disponibles',
                style: AppTextStyles.h3.copyWith(color: AppColors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
