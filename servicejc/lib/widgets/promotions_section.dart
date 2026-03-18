import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 👈 IMPORTANTE
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/screens/servicios_screen.dart';
import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final promos = widget.servicios.take(5).toList();

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 🔥 IMAGEN DESDE FIREBASE
                        if (servicio.imageUrl != null && servicio.imageUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: servicio.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.secondary),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.secondary,
                              child: const Icon(Icons.broken_image, color: Colors.white54),
                            ),
                          )
                        else
                          Container(color: AppColors.secondary),

                        // DEGRADADO
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),

                        // TEXTO O SOBREPOSICIÓN
                        Container(
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
                                child: const Text('OFERTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                servicio.nombre,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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