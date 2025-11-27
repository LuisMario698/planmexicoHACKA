import 'package:flutter/foundation.dart';

/// Modelo de datos del usuario registrado
class UserData {
  final String nombreCompleto;
  final String estado;
  final String ciudad;
  final String telefono;
  final DateTime fechaRegistro;

  UserData({
    required this.nombreCompleto,
    required this.estado,
    required this.ciudad,
    required this.telefono,
    required this.fechaRegistro,
  });

  /// Obtiene el primer nombre del usuario
  String get primerNombre {
    final nombres = nombreCompleto.split(' ');
    return nombres.isNotEmpty ? nombres.first : nombreCompleto;
  }

  /// Obtiene las iniciales del usuario (máximo 2 letras)
  String get iniciales {
    final nombres = nombreCompleto.split(' ');
    if (nombres.length >= 2) {
      return '${nombres[0][0]}${nombres[1][0]}'.toUpperCase();
    } else if (nombres.isNotEmpty && nombres[0].isNotEmpty) {
      return nombres[0][0].toUpperCase();
    }
    return 'U';
  }
}

/// Servicio singleton para manejar la sesión del usuario
/// La sesión se mantiene mientras la app esté abierta (en memoria)
class UserSessionService extends ChangeNotifier {
  static final UserSessionService _instance = UserSessionService._internal();
  
  factory UserSessionService() => _instance;
  
  UserSessionService._internal();

  UserData? _currentUser;

  /// Verifica si hay un usuario registrado/logueado
  bool get isLoggedIn => _currentUser != null;

  /// Obtiene los datos del usuario actual
  UserData? get currentUser => _currentUser;

  /// Registra un nuevo usuario y lo loguea
  void registerUser({
    required String nombreCompleto,
    required String estado,
    required String ciudad,
    required String telefono,
  }) {
    _currentUser = UserData(
      nombreCompleto: nombreCompleto,
      estado: estado,
      ciudad: ciudad,
      telefono: telefono,
      fechaRegistro: DateTime.now(),
    );
    notifyListeners();
  }

  /// Cierra la sesión del usuario
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Actualiza los datos del usuario
  void updateUser({
    String? nombreCompleto,
    String? estado,
    String? ciudad,
    String? telefono,
  }) {
    if (_currentUser != null) {
      _currentUser = UserData(
        nombreCompleto: nombreCompleto ?? _currentUser!.nombreCompleto,
        estado: estado ?? _currentUser!.estado,
        ciudad: ciudad ?? _currentUser!.ciudad,
        telefono: telefono ?? _currentUser!.telefono,
        fechaRegistro: _currentUser!.fechaRegistro,
      );
      notifyListeners();
    }
  }
}
