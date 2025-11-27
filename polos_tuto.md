# 📍 Guía del Módulo de Polos de Desarrollo

## Índice
1. [Visión General](#visión-general)
2. [Arquitectura del Módulo](#arquitectura-del-módulo)
3. [Estructura de Archivos](#estructura-de-archivos)
4. [Modelos de Datos](#modelos-de-datos)
5. [Flujo de Navegación](#flujo-de-navegación)
6. [Componentes Principales](#componentes-principales)
7. [Widget del Mapa de México](#widget-del-mapa-de-méxico)
8. [Funcionalidades Detalladas](#funcionalidades-detalladas)
9. [Guía de Personalización](#guía-de-personalización)
10. [Paleta de Colores](#paleta-de-colores)

---

## Visión General

El módulo de **Polos de Desarrollo** es una funcionalidad central de la app Plan México que permite visualizar, explorar e interactuar con los diferentes polos de desarrollo económico del país. 

### Características principales:
- 🗺️ Mapa interactivo de México con estados seleccionables
- 📍 Marcadores de polos con información detallada
- 🎨 Soporte completo para modo claro/oscuro
- 📱 Diseño responsivo (móvil y escritorio)
- 🔄 Animaciones fluidas de transición
- 📤 Funcionalidad de compartir información

---

## Arquitectura del Módulo

```
┌─────────────────────────────────────────────────────────────────┐
│                     ResponsiveScaffold                          │
│  (Maneja navegación bottom/sidebar según breakpoint 768px)     │
├─────────────────────────────────────────────────────────────────┤
│                        PolosScreen                              │
│  (Pantalla principal - gestiona estado y layouts)              │
├─────────────────────────────────────────────────────────────────┤
│    MexicoMapWidget          │        InfoPanel                 │
│  (Renderizado del mapa)     │  (Información de estados/polos)  │
├─────────────────────────────────────────────────────────────────┤
│                         PolosData                               │
│  (Datos estáticos de todos los polos)                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Estructura de Archivos

```
lib/
├── shared/
│   ├── screens/
│   │   └── polos_screen.dart          # Pantalla principal (3634 líneas)
│   ├── widgets/
│   │   └── mexico_map_widget.dart      # Widget del mapa (1521 líneas)
│   └── data/
│       └── polos_data.dart             # Datos de polos (687 líneas)
└── assets/
    └── images/
        └── mx-all.geo.json             # GeoJSON con geometría de estados
```

---

## Modelos de Datos

### 1. PoloMarker (polos_data.dart)
Representa un polo de desarrollo individual.

```dart
class PoloMarker {
  final int id;                    // ID numérico único
  final String idString;           // ID string (ej: 'sonora_hermosillo')
  final String nombre;             // Nombre del polo
  final String estado;             // Estado donde se ubica
  final String estadoCodigo;       // Código del estado (ej: 'SO')
  final double relativeX;          // Posición X relativa (0.0-1.0)
  final double relativeY;          // Posición Y relativa (0.0-1.0)
  final double lat;                // Latitud geográfica
  final double lng;                // Longitud geográfica
  final String areaHa;             // Área en hectáreas
  final Color color;               // Color del marcador
  final String tipo;               // 'energy', 'logistics', 'industry', 'tourism'
  final String tipoDisplay;        // 'nuevo', 'en_marcha', 'estrategico'
  final String region;             // Región geográfica
  final String vocacion;           // Vocación principal
  final List<String> sectoresClave;// Sectores económicos
  final String infraestructura;    // Proyectos de infraestructura
  final String descripcion;        // Descripción detallada
  final String empleoEstimado;     // Empleos proyectados
  final String beneficiosLargoPlazo;// Beneficios a futuro
}
```

### 2. StatePoloData (polos_screen.dart)
Información resumida por estado.

```dart
class StatePoloData {
  final int count;                 // Número de polos en el estado
  final List<String> descriptions; // Descripciones de cada polo
}
```

### 3. StateDetailData (polos_screen.dart)
Información detallada del estado para PODECOBI.

```dart
class StateDetailData {
  final String poloOficial;        // Nombre oficial del polo
  final List<String> sectoresFuertes;// Sectores económicos fuertes
  final String poblacion;          // Población del estado
  final String conectividad;       // Infraestructura de conectividad
  final String superficie;         // Superficie del polo
  final String inversion;          // Inversión proyectada
  final String poblacionBeneficiada;// Habitantes beneficiados
  final String empleos;            // Empleos estimados
  final String nombrePolo;         // Nombre del polo
  final String municipio;          // Municipio sede
  final String sectorPolo;         // Sector principal
  final String vocacion;           // Vocación económica
  final String organismos;         // Organismos involucrados
  final String oportunidades;      // Oportunidades de inversión
  final String beneficios;         // Beneficios esperados
  final List<String> proyectosFederales;// Proyectos federales asociados
}
```

### 4. PoloInfo (mexico_map_widget.dart)
Información de polo para comunicación entre widgets.

```dart
class PoloInfo {
  final String id;
  final String nombre;
  final String estado;
  final String descripcion;
  final String tipo;
  final List<String> imagenes;
  final String ubicacion;
  final double latitud;
  final double longitud;
}
```

### 5. MexicoState (mexico_map_widget.dart)
Representa un estado de la república.

```dart
class MexicoState {
  final String code;               // Código del estado
  final String name;               // Nombre del estado
  final List<List<Offset>> polygons;// Polígonos del contorno
}
```

---

## Flujo de Navegación

### Vista Móvil

```
┌──────────────────────────────────────────────────────────────┐
│                     ESTADO INICIAL                           │
│  - Mapa de México completo (altura 380px)                   │
│  - Panel con leyenda de categorías                          │
│  - Sectores estratégicos                                    │
└────────────────────────┬─────────────────────────────────────┘
                         │ Tap en estado
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                   ESTADO SELECCIONADO                        │
│  - Mapa del estado individual (altura 350px)                │
│  - Marcadores de polos visibles                             │
│  - Panel con estadísticas del estado                        │
│  - Botón "Ver detalles del estado"                          │
└────────────────────────┬─────────────────────────────────────┘
           │             │ Tap en marcador          │ Tap en 
           │             ▼                          │ "Ver detalles"
           │  ┌─────────────────────────────────┐   │
           │  │      POLO SELECCIONADO          │   │
           │  │  - Mini preview del mapa (110px)│   │
           │  │  - Dashboard con métricas       │   │
           │  │  - Botón "Saber más"            │   │
           │  │  - Acciones: Explorar/Compartir │   │
           │  └────────────┬────────────────────┘   │
           │               │ Tap "Saber más"        │
           │               ▼                        ▼
           │  ┌─────────────────────────────────────────────────┐
           │  │           INFORMACIÓN DETALLADA                 │
           │  │  - Vocación principal                          │
           │  │  - Sectores clave (lista completa)             │
           │  │  - Infraestructura                             │
           │  │  - Empleo estimado                             │
           │  │  - Beneficios a largo plazo                    │
           │  │  - Descripción completa                        │
           │  └─────────────────────────────────────────────────┘
           │
           │ Tap botón atrás / expandir
           ▼
    Regresa al estado anterior
```

### Vista Escritorio

```
┌────────────────────────────────────────────────────────────────────┐
│  ┌──────────────────────────┐  ┌────────────────────────────────┐ │
│  │                          │  │                                │ │
│  │     MAPA DE MÉXICO       │  │      PANEL DE INFORMACIÓN     │ │
│  │     (60% del ancho)      │  │      (40% del ancho)          │ │
│  │                          │  │                                │ │
│  │  - Vista completa        │  │  Sin selección:               │ │
│  │  - Hover para elevar     │  │  - Leyenda de categorías      │ │
│  │  - Click para seleccionar│  │  - Sectores estratégicos      │ │
│  │  - Zoom al estado        │  │                                │ │
│  │                          │  │  Estado seleccionado:         │ │
│  │                          │  │  - Estadísticas               │ │
│  │                          │  │  - Detalle de polos           │ │
│  │                          │  │                                │ │
│  │                          │  │  Polo seleccionado:           │ │
│  │                          │  │  - Dashboard completo         │ │
│  │                          │  │  - Acciones                   │ │
│  └──────────────────────────┘  └────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

---

## Componentes Principales

### PolosScreen (_PolosScreenState)

**Estado principal:**
```dart
String? _selectedStateCode;      // Código del estado seleccionado
String? _selectedStateName;      // Nombre del estado seleccionado
String? _hoveredStateName;       // Estado con hover (desktop)
PoloInfo? _selectedPolo;         // Polo actualmente seleccionado
bool _showDetailedInfo;          // Mostrar info detallada

// Animaciones
AnimationController _expandController; // Para mini mapa
bool _isExpanding;               // Animación de expansión activa
bool _isCollapsing;              // Animación de colapso activa
```

**Métodos de construcción principales:**

| Método | Descripción |
|--------|-------------|
| `_buildHeader()` | Header con título e icono |
| `_buildDesktopLayout()` | Layout de dos columnas para desktop |
| `_buildMobileLayout()` | Layout adaptativo para móvil |
| `_buildMapContainer()` | Contenedor del mapa completo |
| `_buildStateOnlyMapContainer()` | Contenedor con solo un estado |
| `_buildMiniMapPreview()` | Preview miniatura cuando hay polo |
| `_buildInfoPanel()` | Panel lateral de información |
| `_buildPoloInfo()` / `_buildPoloInfoNoScroll()` | Info del polo |
| `_buildStateInfo()` / `_buildStateInfoPanel()` | Info del estado |
| `_buildEmptyState()` | Estado inicial sin selección |
| `_buildSummaryContent()` | Dashboard resumido del polo |
| `_buildDetailedContent()` | Información completa del polo |

**Animaciones de transición:**
```dart
// Expansión: Mini mapa → Estado completo
_buildExpandingMapAnimation(isDark)

// Colapso: Estado completo → Mini mapa
_buildCollapsingMapAnimation(isDark)
```

---

## Widget del Mapa de México

### MexicoMapWidget

**Propiedades:**
```dart
Function(String stateCode, String stateName)? onStateSelected; // Callback selección
Function(PoloInfo polo)? onPoloSelected;   // Callback selección polo
Function(String? stateName)? onStateHover;  // Callback hover
String? selectedStateCode;                  // Estado seleccionado
String? selectedPoloId;                     // Polo seleccionado
VoidCallback? onBackToMap;                  // Callback regreso
List<String>? highlightedStates;           // Estados resaltados
bool autoShowDetail;                        // Mostrar detalle auto
double zoomScale;                           // Escala de zoom
bool showOnlySelected;                      // Solo mostrar estado sel.
bool hidePoloMarkers;                       // Ocultar marcadores
bool skipInitialAnimation;                  // Saltar animación inicial
```

### Painters

**MexicoMapPainter:**
Dibuja el mapa completo de México con:
- Renderizado de todos los estados
- Colores diferenciados para estados con/sin polos
- Efecto de elevación en hover
- Sombras dinámicas
- Marcadores de polos

**SingleStatePainter:**
Dibuja un solo estado cuando está seleccionado:
- Gradiente guinda
- Bordes blancos
- Sombra proyectada
- Marcadores de polos del estado

### Carga del GeoJSON

```dart
Future<void> _loadGeoJson() async {
  // 1. Cargar archivo GeoJSON
  final String jsonString = await rootBundle.loadString(
    'assets/images/mx-all.geo.json'
  );
  
  // 2. Parsear features
  final Map<String, dynamic> geoJson = json.decode(jsonString);
  final List<dynamic> features = geoJson['features'];
  
  // 3. Extraer polígonos de cada estado
  for (final feature in features) {
    // Soporta Polygon y MultiPolygon
    final geometry = feature['geometry'];
    // ...
  }
  
  // 4. Calcular bounds para normalización
  // 5. Inicializar animaciones de hover
}
```

### Detección de clics

```dart
MexicoState? _findStateAtPosition(Offset position, BoxConstraints constraints) {
  // 1. Escalar polígonos al tamaño actual
  // 2. Para cada estado, verificar si el punto está dentro
  // 3. Usar algoritmo ray-casting para detección
  
  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      // Algoritmo de ray-casting
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx < ...)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}
```

---

## Funcionalidades Detalladas

### 1. Selección de Estado

```dart
// En MexicoMapWidget
void _handleTap(TapDownDetails details, BoxConstraints constraints) {
  final state = _findStateAtPosition(details.localPosition, constraints);
  if (state != null) {
    // Notificar al padre
    widget.onStateSelected?.call(state.code, state.name);
    
    // Mostrar detalle si autoShowDetail
    if (widget.autoShowDetail) {
      setState(() {
        _detailState = state;
        _showStateDetail = true;
      });
      _selectionController.forward(from: 0);
    }
  }
}
```

### 2. Selección de Polo

Los marcadores son widgets clickeables:
```dart
List<Widget> _buildClickableMarkers(context, state, size, isDark) {
  return polos.map((polo) {
    // Calcular posición del marcador
    final markerX = ...;
    final markerY = ...;
    
    return Positioned(
      left: markerX - 20,
      top: markerY - 20,
      child: GestureDetector(
        onTap: () {
          final poloInfo = PoloInfo(...);
          widget.onPoloSelected?.call(poloInfo);
        },
        child: AnimatedContainer(
          // Animación de selección
          transform: Matrix4.translationValues(0, isSelected ? -8 : 0, 0),
          child: AnimatedScale(
            scale: isSelected ? 1.3 : 1.0,
            child: Container(...), // Marcador circular
          ),
        ),
      ),
    );
  }).toList();
}
```

### 3. Hover en Estados (Desktop)

```dart
void _handleHover(PointerHoverEvent event, BoxConstraints constraints) {
  final state = _findStateAtPosition(event.localPosition, constraints);
  
  if (state?.code != _hoveredStateCode) {
    // Animar salida del anterior
    _stateHoverControllers[_hoveredStateCode]?.reverse();
    
    // Animar entrada del nuevo
    _stateHoverControllers[state.code]?.forward();
    
    // Actualizar estado y notificar
    setState(() {
      _hoveredStateCode = state?.code;
      _hoverPosition = event.localPosition;
    });
    widget.onStateHover?.call(state?.name);
  }
}
```

### 4. Animación de Elevación

En `MexicoMapPainter._drawState()`:
```dart
// Calcular offset de elevación
final elevationOffset = hoverValue * 8;  // 8px máximo
final scaleBoost = 1.0 + (hoverValue * 0.05);  // 5% aumento

// Dibujar sombra
final shadowPaint = Paint()
  ..color = Colors.black.withOpacity(0.3 * hoverValue)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * hoverValue);

// Aplicar transformación al dibujar
x = centerX + (x - centerX) * scaleBoost;
y = centerY + (y - centerY) * scaleBoost - elevationOffset;
```

### 5. Compartir Polo

```dart
Future<void> _sharePolo(PoloInfo polo, PoloMarker? poloData) async {
  final buffer = StringBuffer();
  buffer.writeln('🇲🇽 Plan México - Polo de Desarrollo');
  buffer.writeln('📍 ${polo.nombre}');
  buffer.writeln('📌 ${polo.estado}');
  
  // Agregar tipo, región, vocación, sectores, etc.
  
  buffer.writeln('#PlanMéxico #DesarrolloNacional');
  
  await Share.share(buffer.toString(), subject: 'Plan México - ${polo.nombre}');
}
```

---

## Guía de Personalización

### Agregar un nuevo Polo

1. **Editar `polos_data.dart`:**
```dart
static const List<PoloMarker> polos = [
  // ... polos existentes
  
  PoloMarker(
    id: 19,  // Siguiente ID disponible
    idString: 'nuevo_estado_polo',
    nombre: 'Nombre del Polo',
    estado: 'Nombre del Estado',
    estadoCodigo: 'XX',  // Código de 2 letras
    relativeX: 0.5,  // 0.0 = izquierda, 1.0 = derecha dentro del estado
    relativeY: 0.5,  // 0.0 = abajo, 1.0 = arriba dentro del estado
    lat: 0.0,
    lng: 0.0,
    areaHa: '100 ha',
    color: PoloColors.industry,  // o energy, logistics, tourism
    tipo: 'industry',
    tipoDisplay: 'nuevo',  // o 'en_marcha', 'estrategico'
    region: 'Región',
    vocacion: 'Vocación principal',
    sectoresClave: ['Sector 1', 'Sector 2'],
    infraestructura: 'Descripción de infraestructura',
    descripcion: 'Descripción completa del polo',
    empleoEstimado: 'Est. X empleos',
    beneficiosLargoPlazo: 'Beneficios esperados',
  ),
];
```

2. **Agregar datos del estado (si es nuevo) en `polos_screen.dart`:**
```dart
final Map<String, StatePoloData> _statePoloData = {
  // ...
  'Nuevo Estado': const StatePoloData(
    count: 1,
    descriptions: ['Descripción del polo'],
  ),
};

final Map<String, StateDetailData> _stateDetailData = {
  // ...
  'Nuevo Estado': const StateDetailData(
    poloOficial: 'PODECOBI ...',
    sectoresFuertes: [...],
    poblacion: '...',
    conectividad: '...',
    // ... resto de campos
  ),
};
```

### Modificar colores de tipos de polo

En `polos_data.dart`:
```dart
class PoloColors {
  static const Color energy = Color(0xFFF59E0B);     // Amarillo
  static const Color logistics = Color(0xFF2563EB); // Azul
  static const Color industry = Color(0xFF16A34A);  // Verde
  static const Color tourism = Color(0xFF8B5CF6);   // Púrpura
}
```

### Agregar nueva categoría en la leyenda

En `_buildEmptyState()` o `_buildInitialInfoPanel()`:
```dart
Row(
  children: [
    Expanded(
      child: _buildCategoryButton(
        isDark,
        color: const Color(0xFFNUEVO_COLOR),
        label: 'Nueva categoría',
        isSelected: false,
      ),
    ),
    // ...
  ],
),
```

---

## Paleta de Colores

### Colores principales del tema

| Color | Código | Uso |
|-------|--------|-----|
| Guinda primario | `#691C32` | Encabezados, botones principales |
| Guinda oscuro | `#4A1525` | Gradientes, sombras |
| Dorado | `#BC955C` | Acentos, puntos, medallas |

### Colores de tipos de polo

| Tipo | Color | Código |
|------|-------|--------|
| Energía | Amarillo/Naranja | `#F59E0B` |
| Logística | Azul | `#2563EB` |
| Industria | Verde | `#16A34A` |
| Turismo | Púrpura | `#8B5CF6` |

### Colores de estado del proyecto

| Estado | Color | Uso |
|--------|-------|-----|
| En marcha | Verde oscuro | `#006847` |
| A licitar | Verde claro | `#B8D4B8` |
| Nuevos polos | Azul | `#2563EB` |
| En evaluación | Naranja | `#E89005` |
| Tercera etapa | Beige | `#D4B896` |

### Modo oscuro

| Elemento | Color |
|----------|-------|
| Fondo principal | `#13151A` → `#1E2029` |
| Cards | `#262830` |
| Bordes | `#3A3D47` |
| Texto principal | `#FFFFFF` |
| Texto secundario | `#A0A0A0` |

### Modo claro

| Elemento | Color |
|----------|-------|
| Fondo principal | `#F8F9FA` → `#E9ECEF` |
| Cards | `#FFFFFF` |
| Bordes | `#E5E7EB` |
| Texto principal | `#1A1A2E` |
| Texto secundario | `#6B7280` |

---

## Notas Importantes

1. **Posicionamiento de marcadores**: Los valores `relativeX` y `relativeY` son relativos al bounding box del estado (0.0-1.0), no coordenadas geográficas absolutas.

2. **GeoJSON**: El archivo `mx-all.geo.json` contiene la geometría de los estados. Si necesitas actualizar límites, modifica este archivo.

3. **Animaciones**: Usa `TickerProviderStateMixin` para múltiples AnimationControllers.

4. **Responsividad**: El breakpoint es 768px. Arriba es desktop (sidebar), abajo es móvil (bottom nav).

5. **Estados sin datos**: Si un estado no tiene datos en `_stateDetailData`, se muestra el mensaje "Información no encontrada".

---

*Última actualización: Noviembre 2025*
