import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:servicejc/models/tecnico.dart';
import 'package:servicejc/screens/citas_screen.dart';
import 'package:servicejc/screens/clients_screen.dart';
import 'package:servicejc/screens/tecnicos_screen.dart';
import '../services/admin_api_service.dart';
import 'admin_management_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

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
    // ... (Método sin cambios)
  }

  void _logout() async {
    // ... (Método sin cambios)
  }

  // WIDGET OPTIMIZADO: Metric Card (Más compacto y horizontal)
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppColors.secondary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), // Redondeo menor
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Reducido de 16.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20), // Reducido de 30
                const SizedBox(width: 5), // Reducido de 10
                Flexible(
                  // Usar Flexible para manejar títulos largos
                  child: Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white70,
                    ), // Fuente más pequeña
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Reducido de 10
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.accent,
                fontSize: 24, // Reducido de 32
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET OPTIMIZADO: Option Card (Más compacto)
  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.secondary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Reducido de 16.0
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: AppColors.accent), // Reducido de 40
              const SizedBox(height: 5), // Reducido de 10
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.white,
                ), // Fuente más pequeña
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // El BarChart se mantiene igual, no es necesario optimizarlo
  Widget _buildBarChart(List<Tecnico> tecnicos) {
    List<BarChartGroupData> barGroups = tecnicos.asMap().entries.map((entry) {
      // ... (código de BarChart)
      final int index = entry.key;
      final Tecnico tecnico = entry.value;
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
                      tecnicos[value.toInt()].nombre.split(' ')[0],
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
        title: Text(
          'Panel de Administración',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accent),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
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
              padding: const EdgeInsets.all(12.0), // Reducido de 16.0
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sección de Métricas (Más compacta) ---
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8, // Reducido de 16
                    mainAxisSpacing: 8, // Reducido de 16
                    childAspectRatio: 1.8, // Hizo los cuadros más horizontales
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
                        value: 'N/A',
                        icon: Icons.person_add,
                        color: AppColors.accent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24), // Reducido de 32
                  // --- Sección de Opciones de Navegación (Más compacta, 3 por fila) ---
                  GridView.count(
                    crossAxisCount: 3, // Tres tarjetas por fila
                    crossAxisSpacing: 8, // Reducido de 16
                    mainAxisSpacing: 8, // Reducido de 16
                    childAspectRatio: 1.0, // Cuadradas
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOptionCard(
                        title: 'Gestión de Técnicos',
                        icon: Icons.people,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TecnicosScreen(),
                            ),
                          );
                        },
                      ),
                      _buildOptionCard(
                        title: 'Gestión de Citas',
                        icon: Icons.calendar_month,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CitasScreen(),
                            ),
                          );
                        },
                      ),
                      _buildOptionCard(
                        title: 'Gestión de Clientes',
                        icon: Icons.person,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClientsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Sección de Gráfico ---
                  Text(
                    'Técnicos más destacados (por citas completadas)',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  tecnicos.isNotEmpty
                      ? _buildBarChart(tecnicos)
                      : Text(
                          'No hay datos de técnicos.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white54,
                          ),
                        ),
                  const SizedBox(height: 24),
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
