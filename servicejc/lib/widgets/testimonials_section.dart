import 'package:flutter/material.dart';
import 'package:servicejc/models/testimonio_model.dart';
import 'package:servicejc/services/testimonio_service.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/login_screen.dart'; // Asegúrate de importar tu Login

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFFFD700);
  static const Color primaryColor = Color(0xFF1E1E1E); // Fondo oscuro para el input

  final TestimonioService _testimonioService = TestimonioService();
  late Future<List<TestimonioModel>> _futureTestimonios;

  // Estado del usuario
  bool _isLoggedIn = false;
  String _nombreUsuario = "Anónimo";

  // Formulario
  final TextEditingController _comentarioController = TextEditingController();
  int _calificacionSeleccionada = 5; // Por defecto 5 estrellas
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _refreshTestimonios();
  }

  void _refreshTestimonios() {
    setState(() {
      _futureTestimonios = _testimonioService.getTestimoniosDestacados();
    });
  }

  // 1. Verificar si está logueado
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final nombre = prefs.getString('userName') ?? "Cliente"; // Guarda el nombre al login si puedes

    setState(() {
      _isLoggedIn = (token != null && token.isNotEmpty);
      _nombreUsuario = nombre;
    });
  }

  // 2. Enviar el comentario
  Future<void> _submitComment() async {
    if (_comentarioController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    // Creamos el modelo
    final nuevoTestimonio = TestimonioModel(
      id: '', // Se genera en backend
      nombreCliente: _nombreUsuario,
      comentario: _comentarioController.text,
      calificacion: _calificacionSeleccionada,
      destacado: true,
    );

    final success = await _testimonioService.enviarTestimonio(nuevoTestimonio);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _comentarioController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias por tu comentario!')),
        );
        _refreshTestimonios(); // Recargamos la lista para ver el nuevo (si es destacado)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar comentario.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Lo que nuestros clientes dicen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // LISTA DE TARJETAS (CARRUSEL)
        SizedBox(
          height: 220,
          child: FutureBuilder<List<TestimonioModel>>(
            future: _futureTestimonios,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }
              
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Se el primero en dejar tu opinión.",
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                );
              }

              final testimonials = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = testimonials[index];
                  return _buildTestimonialCard(context, testimonial);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 30),

        // 🔥 AQUÍ ESTÁ LA LÓGICA DE INPUT (LOGUEADO VS NO LOGUEADO)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _isLoggedIn ? _buildCommentForm() : _buildGuestPrompt(context),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // WIDGET: Tarjeta de Testimonio (Extraída para limpieza)
  Widget _buildTestimonialCard(BuildContext context, TestimonioModel testimonial) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75, 
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (starIndex) {
              return Icon(
                starIndex < testimonial.calificacion ? Icons.star : Icons.star_border,
                color: accentColor, size: 18,
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              '"${testimonial.comentario}"',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 14, height: 1.4),
              maxLines: 4, overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_pin, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Text(
                testimonial.nombreCliente,
                style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: Formulario para usuarios LOGUEADOS
  Widget _buildCommentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Deja tu opinión", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          
          // Selector de Estrellas
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _calificacionSeleccionada = index + 1),
                icon: Icon(
                  index < _calificacionSeleccionada ? Icons.star : Icons.star_border,
                  color: accentColor,
                  size: 30,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
          ),
          const SizedBox(height: 10),
          
          // Campo de Texto
          TextField(
            controller: _comentarioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Escribe tu experiencia aquí...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: primaryColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          
          // Botón Enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSending 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text("Enviar Comentario", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // WIDGET: Invitación para usuarios NO LOGUEADOS (Invitados)
  Widget _buildGuestPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.rate_review_outlined, color: accentColor, size: 40),
          const SizedBox(height: 10),
          const Text(
            "¿Ya probaste nuestros servicios?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Inicia sesión para compartir tu experiencia con nosotros.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: accentColor,
              side: const BorderSide(color: accentColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Iniciar Sesión / Registrarse"),
          ),
        ],
      ),
    );
  }
}