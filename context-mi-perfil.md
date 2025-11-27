# 👤 Contexto: Sección "Mi Perfil"

Esta sección permite al usuario registrar y gestionar su información personal para personalizar su experiencia en la app.

---

## 📝 Datos de Registro del Usuario

### Campos Requeridos

| Campo | Tipo | Descripción | Validación |
|-------|------|-------------|------------|
| 👤 **Nombre** | `String` | Nombre completo del usuario | Mínimo 3 caracteres |
| 📱 **Número telefónico** | `String` | Número de 10 dígitos | Solo números, formato mexicano |
| 🗺️ **Estado** | `Dropdown` | Estado de la República | Selección de lista (32 estados) |
| 🏘️ **Municipio** | `Dropdown` | Municipio del estado seleccionado | Depende del estado elegido |

---

## 🎯 Propósito del Registro

### ¿Para qué se usa cada dato?

| Dato | Uso en la App |
|------|---------------|
| **Nombre** | Personalizar saludos y comunicaciones |
| **Número** | Notificaciones SMS de empleos/eventos (opcional futuro) |
| **Estado** | Filtrar polos, empleos y noticias de la región |
| **Municipio** | Calcular distancias aproximadas a empleos y polos |

---

## 🖼️ Diseño de Pantalla

### Pantalla de Registro (Primera vez)

```
┌─────────────────────────────────────┐
│         🇲🇽 Plan México              │
│                                     │
│    Configura tu perfil para        │
│    personalizar tu experiencia      │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  👤 Nombre completo                 │
│  ┌─────────────────────────────┐   │
│  │ Juan Pérez García           │   │
│  └─────────────────────────────┘   │
│                                     │
│  📱 Número telefónico              │
│  ┌─────────────────────────────┐   │
│  │ 6621234567                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  🗺️ Estado                         │
│  ┌─────────────────────────────┐   │
│  │ Sonora                    ▼ │   │
│  └─────────────────────────────┘   │
│                                     │
│  🏘️ Municipio                      │
│  ┌─────────────────────────────┐   │
│  │ Puerto Peñasco            ▼ │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      💾 Guardar Perfil      │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Pantalla de Perfil (Ya registrado)

```
┌─────────────────────────────────────┐
│  ← Mi Perfil                        │
├─────────────────────────────────────┤
│                                     │
│         ┌───────────┐               │
│         │    👤     │               │
│         │   Avatar  │               │
│         └───────────┘               │
│                                     │
│       Juan Pérez García             │
│       Puerto Peñasco, Sonora        │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📋 Información Personal            │
│  ┌─────────────────────────────┐   │
│  │ 👤 Nombre                   │   │
│  │    Juan Pérez García     ✏️ │   │
│  ├─────────────────────────────┤   │
│  │ 📱 Teléfono                 │   │
│  │    662 123 4567          ✏️ │   │
│  ├─────────────────────────────┤   │
│  │ 📍 Ubicación                │   │
│  │    Puerto Peñasco, Sonora✏️ │   │
│  └─────────────────────────────┘   │
│                                     │
│  ⚙️ Preferencias                    │
│  ┌─────────────────────────────┐   │
│  │ 🌙 Tema oscuro          🔘  │   │
│  ├─────────────────────────────┤   │
│  │ 🔔 Notificaciones       🔘  │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## 💾 Almacenamiento

### Local (SharedPreferences)

```dart
// Claves para SharedPreferences
const String KEY_USER_NAME = 'user_name';
const String KEY_USER_PHONE = 'user_phone';
const String KEY_USER_STATE = 'user_state';
const String KEY_USER_MUNICIPALITY = 'user_municipality';
const String KEY_IS_REGISTERED = 'is_registered';
```

### Modelo de Usuario

```dart
class UserProfile {
  final String nombre;
  final String telefono;
  final String estado;
  final String municipio;
  final DateTime fechaRegistro;
  
  UserProfile({
    required this.nombre,
    required this.telefono,
    required this.estado,
    required this.municipio,
    required this.fechaRegistro,
  });
}
```

---

## 🔄 Flujo de Usuario

```
┌──────────────────┐
│ App se abre      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     NO      ┌──────────────────┐
│ ¿Usuario         │─────────────▶│ Mostrar pantalla │
│ registrado?      │              │ de registro      │
└────────┬─────────┘              └────────┬─────────┘
         │ SÍ                              │
         ▼                                 ▼
┌──────────────────┐              ┌──────────────────┐
│ Ir a Home con    │              │ Guardar datos    │
│ datos cargados   │◀─────────────│ y continuar      │
└──────────────────┘              └──────────────────┘
```

---

## 📋 Lista de Municipios

Los municipios se cargarán dinámicamente según el estado seleccionado.

**Fuente de datos:** Catálogo de INEGI o lista estática por estado.

### Ejemplo para Sonora:
- Hermosillo
- Puerto Peñasco
- Nogales
- Ciudad Obregón
- Guaymas
- San Luis Río Colorado
- Caborca
- Navojoa
- ... (todos los municipios)

---

## 🎨 Notas de Diseño

- **Colores:** Paleta institucional (guinda, dorado, verde)
- **Tema:** Respetar modo claro/oscuro
- **Validaciones:** Mostrar errores inline en rojo
- **UX:** Campos con íconos para mejor identificación
- **Accesibilidad:** Labels claros y tamaño de texto legible

---

## 📝 Pendientes de Implementación

- [ ] Pantalla de registro inicial
- [ ] Pantalla de edición de perfil
- [ ] Lista de estados (32)
- [ ] Lista de municipios por estado
- [ ] Validación de campos
- [ ] Almacenamiento en SharedPreferences
- [ ] Modelo UserProfile
- [ ] Provider/Service para gestión de usuario
- [ ] Integración con sección "Mi Región"

---

## 🔗 Integración con "Mi Región"

Una vez que el usuario registra su **estado** y **municipio**, la sección "Mi Región" utilizará estos datos para:

1. Mostrar el Hero personalizado con su ubicación
2. Filtrar empleos cercanos
3. Mostrar polos de su estado
4. Calcular distancias aproximadas
5. Mostrar noticias locales relevantes

---

*Última actualización: 26 de noviembre de 2025*
