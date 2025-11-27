import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mexico_locations.dart';
import '../../service/user_session_service.dart';

class RegistroScreen extends StatefulWidget {
  final VoidCallback? onRegistroExitoso;

  const RegistroScreen({super.key, this.onRegistroExitoso});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  String? _estadoSeleccionado;
  String? _ciudadSeleccionada;
  List<String> _ciudadesDisponibles = [];
  List<String> _estadosDisponibles = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    await MexicoLocationData.loadData();
    if (mounted) {
      setState(() {
        _estadosDisponibles = MexicoLocationData.estados;
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _onEstadoChanged(String? estado) {
    setState(() {
      _estadoSeleccionado = estado;
      _ciudadSeleccionada = null;
      _ciudadesDisponibles = estado != null 
          ? MexicoLocationData.getCiudades(estado) 
          : [];
    });
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoSeleccionado == null || _ciudadSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona tu estado y ciudad'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simular un pequeño delay para mejor UX
    await Future.delayed(const Duration(milliseconds: 800));

    // Registrar usuario
    UserSessionService().registerUser(
      nombreCompleto: _nombreController.text.trim(),
      estado: _estadoSeleccionado!,
      ciudad: _ciudadSeleccionada!,
      telefono: _telefonoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Registro exitoso! Bienvenido a Plan México'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Notificar que el registro fue exitoso
      widget.onRegistroExitoso?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? 500 : double.infinity),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Header
                    _buildHeader(isDark),
                    const SizedBox(height: 32),

                    // Formulario
                    _buildFormCard(isDark),
                    const SizedBox(height: 24),

                    // Botón de registro
                    _buildSubmitButton(isDark),
                    const SizedBox(height: 16),

                    // Nota de privacidad
                    _buildPrivacyNote(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Botón de regresar
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : const Color(0xFF691C32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF691C32),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF691C32), Color(0xFF4A1525)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF691C32).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.how_to_reg_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Únete a Plan México',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Regístrate para acceder a todas las funciones',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo: Nombre completo
          _buildLabel('Nombre completo', isDark),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nombreController,
            hint: 'Ej: Juan Pérez García',
            icon: Icons.person_rounded,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo: Estado
          _buildLabel('Estado', isDark),
          const SizedBox(height: 8),
          _isLoadingData
              ? _buildLoadingDropdown(isDark)
              : _buildDropdown(
                  value: _estadoSeleccionado,
                  hint: 'Selecciona tu estado',
                  icon: Icons.map_rounded,
                  items: _estadosDisponibles,
                  isDark: isDark,
                  onChanged: _onEstadoChanged,
                ),
          const SizedBox(height: 20),

          // Campo: Ciudad
          _buildLabel('Ciudad', isDark),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _ciudadSeleccionada,
            hint: _estadoSeleccionado == null 
                ? 'Primero selecciona un estado' 
                : 'Selecciona tu ciudad',
            icon: Icons.location_city_rounded,
            items: _ciudadesDisponibles,
            isDark: isDark,
            enabled: _estadoSeleccionado != null,
            onChanged: (ciudad) {
              setState(() => _ciudadSeleccionada = ciudad);
            },
          ),
          const SizedBox(height: 20),

          // Campo: Teléfono
          _buildLabel('Número de teléfono', isDark),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _telefonoController,
            hint: 'Ej: 55 1234 5678',
            icon: Icons.phone_rounded,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              _PhoneNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              final digitsOnly = value.replaceAll(' ', '');
              if (digitsOnly.length < 10) {
                return 'El teléfono debe tener 10 dígitos';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF691C32),
          size: 22,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF262830) : const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF691C32),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262830) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        menuMaxHeight: 300, // Altura máxima con scroll
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF691C32) : Colors.grey,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        hint: Text(
          hint,
          style: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
        ),
        dropdownColor: isDark ? const Color(0xFF262830) : Colors.white,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: enabled 
              ? (isDark ? Colors.white54 : const Color(0xFF6B7280))
              : Colors.grey,
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildLoadingDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262830) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF691C32).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando estados...',
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF691C32),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF691C32).withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Registrarme',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivacyNote(bool isDark) {
    return Text(
      'Al registrarte aceptas nuestros términos y condiciones\ny política de privacidad del Gobierno de México.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
        height: 1.5,
      ),
    );
  }
}

/// Formateador para números de teléfono (XX XXXX XXXX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
