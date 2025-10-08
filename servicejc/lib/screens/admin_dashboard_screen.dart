import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:servicejc/models/tecnico.dart';
import 'package:servicejc/screens/citas_screen.dart'; // Importar la nueva pantalla de Citas
import 'package:servicejc/screens/clients_screen.dart'; // Importar la nueva pantalla de Clientes
import 'package:servicejc/screens/tecnicos_screen.dart'; // Importar la nueva pantalla de Tecnicos
import '../services/admin_api_service.dart';
import '../services/auth_service.dart'; // Importar el servicio de autenticación
import 'admin_management_screen.dart';
import 'login_screen.dart';
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

  void _logout() async {
    final authService = AuthService();
    await authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

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

  Widget _buildBarChart(List<Tecnico> tecnicos) {
    List<BarChartGroupData> barGroups = tecnicos.asMap().entries.map((entry) {
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

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.secondary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppColors.accent),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h4.copyWith(color: AppColors.white),
              ),
            ],
          ),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        value: 'N/A',
                        icon: Icons.person_add,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                  const SizedBox(height: 32),
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
