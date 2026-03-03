import 'dart:async';
import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/screens/servicios_screen.dart'; 

class PromotionsSection extends StatefulWidget {
  final List<CategoriaPrincipalModel> servicios;

  const PromotionsSection({super.key, required this.servicios});

  @override
  State<PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<PromotionsSection> {
  static const Color accentColor = Color(0xFFFFD700);
  final PageController _pageController = PageController(viewportFraction: 0.95);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      // ✅ CORREGIDO: Aseguramos bloques con llaves
      if (widget.servicios.isNotEmpty && _pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= widget.servicios.take(5).length) {
          _currentPage = 0;
          _pageController.jumpToPage(0);
        } else {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  // ✅ CORREGIDO: Todos los if/else tienen llaves
  String _getImagePath(CategoriaPrincipalModel categoria) {
    final String data = "${categoria.id} ${categoria.nombre}".toLowerCase();

    if (data.contains('decor')) {
      return 'assets/images/services/decoracion.png';
    } else if (data.contains('eban') || data.contains('mader')) {
      return 'assets/images/services/ebanistas.png';
    } else if (data.contains('panel') || data.contains('solar')) {
      return 'assets/images/services/paneles.png';
    } else if (data.contains('ventan') || data.contains('vidrio')) {
      return 'assets/images/services/ventanas.png';
    } else if (data.contains('aire') || data.contains('acond')) {
      return 'assets/images/services/aire_acondicionado.png';
    } else if (data.contains('elect')) {
      return 'assets/images/services/electricidad.png';
    } else if (data.contains('limp')) {
      return 'assets/images/services/limpieza_general.png';
    } else if (data.contains('plom') || data.contains('agua')) {
      return 'assets/images/services/plomeria.png';
    } else if (data.contains('remodel')) {
      return 'assets/images/services/remodelaciones.png';
    } else if (data.contains('const')) {
      return 'assets/images/services/construccion.png';
    } else if (data.contains('pint')) {
      return 'assets/images/services/pintura.png';
    }
    
    return 'assets/images/services/mantenimiento.png';
  }

  @override
  Widget build(BuildContext context) {
    final promos = widget.servicios.take(5).toList();

    // ✅ CORREGIDO
    if (promos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '🔥 Promociones Destacadas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: promos.length,
            padEnds: true,
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              final servicio = promos[index];
              return GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => ServiciosScreen(categoria: servicio)));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(_getImagePath(servicio)),
                      fit: BoxFit.cover
                    )
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('OFERTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          servicio.nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}