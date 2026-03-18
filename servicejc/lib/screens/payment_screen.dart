import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ IMPORTAMOS EL NUEVO SERVICIO QUE APUNTA A TU JAVA
import 'package:servicejc/services/payment_backend_service.dart'; 

class PaymentScreen extends StatefulWidget {
  final String citaId; 
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.citaId,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // ✅ USAMOS EL NUEVO SERVICIO
  final _paymentBackend = PaymentBackendService();

  // Controladores de texto
  final _cardNumberCtrl = TextEditingController();
  final _expDateCtrl = TextEditingController(); 
  final _cvvCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expDateCtrl.dispose();
    _cvvCtrl.dispose();
    _cardHolderCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE PROCESAMIENTO ---
  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Separar mes y año
      final expSplit = _expDateCtrl.text.split('/');
      final mes = expSplit[0];
      final anio = expSplit.length > 1 ? expSplit[1] : ''; 

      // 2. PREPARAR LOS DATOS (Debe coincidir con SolicitudPago.java)
      final payload = {
        "citaId": widget.citaId,
        "amount": widget.totalAmount,
        "cardNumber": _cardNumberCtrl.text.replaceAll(' ', ''),
        "expMonth": mes,
        "expYear": anio, 
        "cvv": _cvvCtrl.text,
        "cardHolder": _cardHolderCtrl.text,
        "email": "cliente@servicejc.com", // Idealmente dinámico en el futuro
        "phone": "+50760000000",       // Idealmente dinámico en el futuro
      };

      // 3. LLAMAR A TU BACKEND (JAVA)
      // Java se encargará de cobrar en Cubo, crear el comprobante y actualizar la cita
      await _paymentBackend.procesarPagoBackend(payload);

      // Si el código llega aquí, el backend respondió 200 OK
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Pago Aprobado! Abriendo WhatsApp para notificar al Admin...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        // 1. Armamos el mensaje automático para el Administrador
        final String mensajeAdmin = "✅ *NUEVO PAGO CONFIRMADO*\n\n"
            "¡Hola Admin! Acabo de realizar el pago de mi cita.\n"
            "*ID Cita:* ${widget.citaId}\n"
            "*Monto Pagado:* \$${widget.totalAmount.toStringAsFixed(2)}\n\n"
            "Quedo a la espera de la asignación del técnico.";
        
        // 2. Preparamos la URL de WhatsApp con el número del admin (68729697)
        final Uri whatsappUrl = Uri.parse(
          'https://wa.me/50768729697?text=${Uri.encodeComponent(mensajeAdmin)}'
        );

        // 3. Intentamos abrir WhatsApp y luego redirigimos al Home
        try {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("No se pudo abrir WhatsApp: $e");
        } finally {
          // Independientemente de si el cliente tiene WhatsApp instalado o no, 
          // lo mandamos de vuelta a la pantalla principal para que no se quede atrapado.
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- WIDGET AUXILIAR PARA ALTO CONTRASTE ---
  InputDecoration _customInputDecoration({required String label, required String hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      filled: true,
      fillColor: Colors.white, 
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.05), 
      appBar: AppBar(
        title: Text('Realizar Pago', style: AppTextStyles.h2.copyWith(color: AppColors.cardTitle)),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.cardTitle),
        elevation: 1, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Resumen del Monto
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Total a Pagar', style: AppTextStyles.bodyText.copyWith(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${widget.totalAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                Text('Datos de la Tarjeta', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                const SizedBox(height: 20),

                // Campo Número Tarjeta
                TextFormField(
                  controller: _cardNumberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 19, 
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500), 
                  decoration: _customInputDecoration(
                    label: 'Número de Tarjeta',
                    hint: '0000 0000 0000 0000',
                    icon: Icons.credit_card,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.replaceAll(' ', '').length < 13) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fila Vencimiento y CVV
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _expDateCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardExpirationFormatter(),
                        ],
                        decoration: _customInputDecoration(
                          label: 'Vencimiento',
                          hint: 'MM/YY',
                          icon: Icons.date_range,
                        ).copyWith(counterText: ""), 
                        validator: (v) {
                          if (v == null || !v.contains('/') || v.length < 5) return 'Use MM/YY';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _cvvCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _customInputDecoration(
                          label: 'CVV',
                          hint: '123',
                          icon: Icons.security,
                        ).copyWith(counterText: ""),
                        validator: (v) => (v == null || v.length < 3) ? 'Inválido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nombre Titular
                TextFormField(
                  controller: _cardHolderCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: _customInputDecoration(
                    label: 'Nombre del Titular',
                    hint: 'Como aparece en la tarjeta',
                    icon: Icons.person_outline,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                ),

                const SizedBox(height: 45),

                // Botón Pagar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'PAGAR AHORA',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CLASE FORMATEADORA PARA LA FECHA (MM/YY)
// ============================================================================
class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    
    if (newText.length < oldValue.text.length) return newValue;

    if (newText.length == 2) {
      return TextEditingValue(
        text: '$newText/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    } else if (newText.length > 2 && !newText.contains('/')) {
      final formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    return newValue;
  }
}