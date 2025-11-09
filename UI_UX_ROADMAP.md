# 🎨 UI/UX Roadmap - Post Release

Este documento contiene todos los cambios de diseño y experiencia de usuario que se implementarán **DESPUÉS** del release inicial (v1.0.0).

## 📋 Estado Actual

**Fecha de separación:** 2025-11-08
**Motivo:** Priorizar funcionalidad antes que diseño
**Implementación:** Post v1.0.0 (después de Fase 7.5)

---

## 🎯 Visión de Diseño

### Estilo Principal: **Brutalist Dark UI**

Basarse fielmente en `brutalist_dark_ui.jpg` para:
- Diseño general de la app
- Patrones de UI
- Estructura visual
- Elementos de interacción

**Características clave:**
- Formas geométricas definidas
- Contraste alto
- Elementos grandes y directos
- Sin ornamentación innecesaria
- Funcionalidad sobre decoración

---

## 🎨 Sistema de Temas

### Cambio de Paradigma

**ANTES:**
- Dark/Light theme toggle
- Color picker personalizado

**DESPUÉS:**
- Temas predefinidos con identidad única
- Cada tema tiene su paleta de colores completa
- Sin toggle dark/light (cada tema define su luminosidad)

### Temas Propuestos

1. **Sakura Theme**
   - Colores rosados/florales
   - Inspiración japonesa
   - Soft y delicado

2. **Capuccino Theme**
   - Tonos café/crema
   - Cálido y acogedor
   - Colores tierra

3. **Tokyo Night Theme**
   - Neones sobre oscuro
   - Cyberpunk aesthetic
   - Azules/morados/rosas brillantes

4. **[Otros temas a definir]**
   - Dracula
   - Nord
   - Gruvbox
   - Catppuccin

---

## 📝 Tipografía

### Objetivo: Amigable y Bold

**Inspiración:** Duolingo, apps educativas modernas

**Características:**
- Peso bold por defecto en la mayoría de textos
- Tipografía rounded/friendly
- Alta legibilidad
- Jerarquía visual clara con peso de fuente

**Fuentes candidatas:**
- Nunito (rounded, friendly)
- Poppins (modern, clean)
- Space Grotesk (geometric, bold)
- Work Sans (versatile, readable)

---

## 🔲 Filosofía de Widgets

### Minimalismo Grande

**Principios:**
1. **Más iconos, menos texto**
   - Iconografía clara y reconocible
   - Texto solo cuando es absolutamente necesario
   - Labels cortos y directos

2. **Tamaño generoso**
   - Widgets más grandes (más espacio, más táctil)
   - Padding generoso
   - Touch targets de mínimo 48x48dp

3. **Información esencial**
   - Mostrar solo lo importante
   - Progressive disclosure
   - Evitar sobrecarga visual

---

## 🧩 Cambios por Módulo

### Navigation Bar
- [x] Eliminar labels de texto ✅ (Implementado en Fase 6.8)
- [x] Solo iconos grandes ✅ (Implementado en Fase 6.8)
- [ ] Iconos adaptados al tema activo
- [ ] Animaciones de transición entre tabs

### Home Dashboard
- [ ] Cards más grandes con más padding
- [ ] Iconos prominentes en cada card
- [ ] Texto reducido al mínimo
- [ ] Animaciones suaves al entrar

### Recordatorios
- [ ] Iconos más grandes en ReminderCard
- [ ] Botones de acción más prominentes
- [ ] Eliminar texto descriptivo redundante
- [ ] Prioridad visual con color/tamaño, no solo badges

### Fitness
- [ ] WorkoutCard con iconos grandes de tipo de workout
- [ ] Estadísticas visuales (iconos + números grandes)
- [ ] Eliminar descripciones textuales largas
- [ ] Gráficas minimalistas y claras

### Nutrition
- [ ] MealCard con iconos de comida prominentes
- [ ] Macros visuales (circular progress con números grandes)
- [ ] Menos texto, más visualización de datos
- [ ] Color coding para macros

### Sueño/Estudio
- [ ] Iconos grandes para estado de sueño
- [ ] Visualización del tiempo (grandes, bold)
- [ ] Cronómetro visual minimalista
- [ ] Menos texto explicativo

---

## ⚡ Performance UX

### Transiciones Instantáneas

**Problema identificado:** Pantallas de carga de 100ms que aparecen y desaparecen rápidamente generan sensación incómoda.

**Soluciones:**

1. **Cambio de rutas:**
   - Eliminar loading indicators en transiciones instantáneas
   - Usar skeleton screens solo si carga >300ms
   - Transiciones suaves sin flicker

2. **Cambio de día (Nutrition):**
   - ✅ Caché de datos previos mientras carga nuevos ✅ (Implementado en Fase 6.8)
   - Sin loading indicator para cambios rápidos
   - Actualización suave sin parpadeos

3. **Regla general:**
   - Si carga <200ms: sin loading indicator
   - Si carga 200-500ms: usar skeleton screen
   - Si carga >500ms: loading indicator con mensaje

---

## 🎬 Animaciones y Micro-interacciones

### Principios
- Smooth y suaves (60 FPS mínimo)
- Significativas (cada animación tiene propósito)
- Rápidas (100-300ms en general)
- Skippable (no bloquean interacción)

### Tipos de animaciones

1. **Entrada de elementos:**
   - Fade in + slide up
   - Stagger effect en listas
   - Scale in para modales

2. **Interacciones:**
   - Ripple effects en botones
   - Scale feedback en tap
   - Color transitions suaves

3. **Navegación:**
   - Hero animations entre pantallas relacionadas
   - Shared element transitions
   - Slide transitions coherentes

4. **Estados:**
   - Loading: skeleton o spinner minimalista
   - Success: checkmark animado + color
   - Error: shake + color de alerta

---

## 🚀 Plan de Implementación UI/UX

### Post v1.0.0 Release

**Fase UI 1: Fundamentos** (1-2 semanas)
1. Implementar sistema de temas predefinidos
2. Actualizar tipografía a bold/friendly
3. Crear biblioteca de iconos custom

**Fase UI 2: Componentes** (2-3 semanas)
1. Rediseñar widgets base (cards, buttons, inputs)
2. Implementar tamaños más grandes
3. Aplicar Brutalist Dark UI a componentes

**Fase UI 3: Pantallas** (2-3 semanas)
1. Rediseñar cada módulo según nuevos principios
2. Más iconos, menos texto
3. Layouts minimalistas y espaciosos

**Fase UI 4: Animaciones** (1 semana)
1. Implementar micro-interacciones
2. Hero animations
3. Transiciones suaves

**Fase UI 5: Pulido** (1 semana)
1. Ajustes finales
2. Testing de usabilidad
3. Optimización de performance

---

## 📊 Métricas de Éxito

**Objetivo UX:**
- Reducción del 30% en tiempo de completar tareas comunes
- Aumento en satisfacción visual (user feedback)
- Mantener 60 FPS en todas las animaciones
- Reducir fatiga visual (menos texto, mejor jerarquía)

---

## 📝 Notas

- Este documento se actualizará con mockups y diseños específicos
- Se pueden agregar referencias visuales (screenshots, wireframes)
- Feedback de usuarios beta será incorporado aquí

**Última actualización:** 2025-11-08
**Versión del documento:** 1.0.0
