# 📍 Contexto: Sección "Mi Región"

Esta sección está diseñada para hacer que el usuario sienta la app como **suya**, mostrando información personalizada basada en su ubicación (municipio y estado).

---

## 🏗️ Estructura de Módulos (8 en total)

---

### 1. 🎯 Encabezado dinámico (Hero personalizado)

**Módulo superior con:**

#### 📍 Municipio y Estado
> Puerto Peñasco, Sonora

#### Subtítulo:
> Información actualizada de tu región — Polos, empleo, avances y oportunidades.

#### Imagen/Diseño:
- Fondo del mapa del estado
- Color institucional (vino/guinda)
- Ícono del municipio

**Objetivo:** Esto hace que sientan la app "suya".

---

### 2. 📊 Tarjetas de resumen "Mi Región Hoy" (Overview rápido)

**Ubicación:** Justo debajo del hero

**Tarjetas tipo "snapshot":**

| Ícono | Métrica | Ejemplo |
|-------|---------|---------|
| 💼 | Empleos nuevos | 4 |
| 📚 | Cursos disponibles | 2 |
| 📈 | Avance de obras | +3% |
| 📰 | Noticias recientes | 1 |
| 🏭 | Polos cercanos | 2 |
| 🎓 | Eventos / talleres | 1 |

> **Nota:** El avance de obras solo se muestra si el estado tiene un polo.

**Objetivo:** El usuario piensa *"Ah cabrón, tengo cosas nuevas"* — esto es lo que hace regresar DIARIO.

---

### 3. 💼 Módulo "Empleos asociados a los Polos" (EL MÁS IMPORTANTE)

**Título:** Oportunidades laborales en tu región

**Lista de tarjetas con:**
- Título del empleo
- Empresa
- Sector (con ícono)
- Distancia aproximada (basada en municipio del usuario, NO GPS)
- Salario
- Botón "Ver"

**Botón al final:** `Ver más empleos`

> **Nota:** La distancia se calcula tomando en cuenta el municipio registrado por el usuario (aún no implementado el registro de usuario).

---

### 4. 📚 Módulo "Cursos y Talleres para tu Región"

**Título:** Capacítate para los sectores de tu región

**Secciones:**
- 🔧 Cursos técnicos
- 💻 Cursos digitales
- 🛠️ Talleres laborales
- 🎓 Becas de certificación

**Formato:** Tarjetas pequeñas tipo "Evento"

**Botón al final:** `Ver todos los cursos`

---

### 5. 🏗️ Módulo "Avances de obras y proyectos en tu zona"

**Título:** Avance del Desarrollo en tu Región

**Tarjetas con:**
- Nombre de la obra
- Porcentaje de avance (barra de progreso)
- Última actualización
- Foto (si hay disponible)

**Ejemplo:**
```
🏗️ Centro logístico Peñasco - 37%
   Actualizado hace 3 días
```

**Botón al final:** `Ver todos los avances`

> **Nota:** Este módulo está centrado en las tarjetas de avances de los polos, si es que hay alguno en el estado seleccionado.

---

### 6. 📰 Módulo "Noticias y Actualizaciones Locales"

**Título:** Noticias del desarrollo en {estado}

**Contenido:**
- Noticias cortas
- Eventos públicos
- Comunicados importantes
- Obras recién anunciadas

**Formato:** Tarjetas simples

**Ejemplo:**
> "Nuevo proyecto de energía anunciado en tu región."

**Botón al final:** `Más noticias`

---

### 7. 🏭 Módulo "Polos cercanos a tu Región"

**Título:** Polos del Plan México cerca de ti

**Tarjetas con:**
- Nombre del polo
- Sector (con ícono)
- Ubicación

**Botón al final:** `Explorar polos`

---

### 8. 🗳️ Módulo "Participa y mejora tu región"

**Objetivo:** Este módulo aumenta la retención del usuario.

**Incluye:**
- 📋 Encuesta activa
- ❓ Pregunta del día
- 💬 Opinión ciudadana
- 💡 "¿Qué te gustaría mejorar?"

**Tarjeta de acción:**
> "Ayúdanos a mejorar este polo — responde esta encuesta."

---

## 🎨 Notas de Diseño

- **Colores:** Usar paleta institucional (guinda #691C32, dorado #BC955C, verde #006847)
- **Tema:** Debe respetar modo claro/oscuro
- **Responsive:** Adaptar a web (desktop) y móvil
- **UX:** Cada módulo debe ser independiente y scrolleable

---

## 📱 Distribución Visual de Módulos

```
┌─────────────────────────────────────────┐
│  1. 🎯 HERO PERSONALIZADO               │
│  ┌─────────────────────────────────────┐│
│  │  📍 Puerto Peñasco, Sonora          ││
│  │  Información actualizada de tu      ││
│  │  región - Polos, empleo y más       ││
│  │         [Fondo: mapa del estado]    ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│  2. 📊 MI REGIÓN HOY (Tarjetas rápidas) │
│  ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ 💼 4 │ │ 📚 2 │ │ 📈3% │            │
│  │Empleo│ │Cursos│ │Avance│            │
│  └──────┘ └──────┘ └──────┘            │
│  ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ 📰 1 │ │ 🏭 2 │ │ 🎓 1 │            │
│  │Notici│ │Polos │ │Event │            │
│  └──────┘ └──────┘ └──────┘            │
├─────────────────────────────────────────┤
│  3. 💼 EMPLEOS (EL MÁS IMPORTANTE)      │
│  ┌─────────────────────────────────────┐│
│  │ 🔧 Técnico Soldador     $18,000/mes ││
│  │    Empresa XYZ · 12 km              ││
│  ├─────────────────────────────────────┤│
│  │ 💻 Desarrollador Jr     $25,000/mes ││
│  │    Tech Corp · 8 km                 ││
│  └─────────────────────────────────────┘│
│            [Ver más empleos →]          │
├─────────────────────────────────────────┤
│  4. 📚 CURSOS Y TALLERES                │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │🔧Técnic│ │💻Digita│ │🛠️Taller│      │
│  │  12    │ │   8    │ │   5    │      │
│  └────────┘ └────────┘ └────────┘      │
│            [Ver todos →]                │
├─────────────────────────────────────────┤
│  5. 🏗️ AVANCES DE OBRAS                 │
│  ┌─────────────────────────────────────┐│
│  │ Centro Logístico Peñasco            ││
│  │ ████████████░░░░░░░ 67%             ││
│  │ Actualizado hace 3 días             ││
│  └─────────────────────────────────────┘│
│            [Ver proyectos →]            │
├─────────────────────────────────────────┤
│  6. 📰 NOTICIAS LOCALES                 │
│  ┌─────────────────────────────────────┐│
│  │ 📌 Inauguran nueva planta solar     ││
│  │    Hace 2 horas · Energía           ││
│  ├─────────────────────────────────────┤│
│  │ 📌 500 empleos nuevos en Sonora     ││
│  │    Ayer · Economía                  ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│  7. 🏭 POLOS CERCANOS A TI              │
│  ┌─────────┐  ┌─────────┐              │
│  │ [Mapa]  │  │ [Mapa]  │              │
│  │ Polo 1  │  │ Polo 2  │              │
│  │ 45 km   │  │ 120 km  │              │
│  └─────────┘  └─────────┘              │
│            [Ver en mapa →]              │
├─────────────────────────────────────────┤
│  8. 🗳️ PARTICIPACIÓN                    │
│  ┌─────────────────────────────────────┐│
│  │ 📋 ¿Qué opinas del desarrollo?      ││
│  │                                     ││
│  │    [🗳️ Responder encuesta]          ││
│  │    [💬 Enviar sugerencia]           ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

---

## 📐 Especificaciones de Diseño

| Módulo | Altura aprox. | Prioridad | Scrolleable interno |
|--------|---------------|-----------|---------------------|
| 1. Hero | 180px | Alta | No |
| 2. Resumen | 120px | Alta | Horizontal |
| 3. Empleos | 250px | **MÁXIMA** | Vertical (3 items) |
| 4. Cursos | 140px | Media | Horizontal |
| 5. Avances | 150px | Media | Vertical (2 items) |
| 6. Noticias | 160px | Media | Vertical (2 items) |
| 7. Polos | 140px | Baja | Horizontal |
| 8. Participación | 120px | Baja | No |

---

## 🎨 Colores por Módulo

- **Hero**: Fondo guinda (#691C32) con gradiente
- **Tarjetas resumen**: Fondo claro con borde dorado (#BC955C)
- **Empleos**: Cards blancas con acento verde (#006847)
- **Cursos**: Cards con iconos coloridos
- **Avances**: Barras de progreso en verde
- **Noticias**: Estilo minimal con separadores
- **Polos**: Mini-mapas con marcadores
- **Participación**: Botones prominentes en guinda

---

## 📝 Pendientes de Implementación

- [ ] Sistema de registro de usuario (para obtener municipio)
- [ ] API de empleos
- [ ] API de cursos/talleres
- [ ] API de noticias locales
- [ ] API de avances de obras
- [ ] Sistema de encuestas dinámicas

---

*Última actualización: 26 de noviembre de 2025*