# 🧪 Guía de Prueba: Análisis de Imágenes con Gemini AI

## 📋 Pre-requisitos

### 1. API Key de Gemini
**IMPORTANTE:** Debes configurar tu API key de Gemini antes de usar el análisis de imágenes.

**Cómo obtener API key:**
1. Visita: https://aistudio.google.com/app/apikey
2. Crea un proyecto o selecciona uno existente
3. Genera una nueva API key (gratis)
4. Copia la key

**Cómo configurar en la app:**
1. Abre la app
2. Ve a **Settings** (⚙️)
3. Sección "IA y API"
4. Toca "Configurar API Key de Gemini"
5. Pega tu API key
6. Guarda

### 2. Permisos
La app solicitará permisos para:
- 📷 **Cámara**: Para tomar fotos de alimentos
- 🖼️ **Galería**: Para seleccionar fotos existentes

## 🚀 Cómo Probar

### Paso 1: Crear una Comida
1. Ve a la pestaña **Nutrición** 🍽️
2. Toca el botón **"+"** (Agregar comida)
3. Se crea una comida nueva automáticamente

### Paso 2: Agregar Alimento con Imagen
1. Toca la comida recién creada
2. Toca **"Agregar alimento"**
3. Verás 2 tabs en la parte superior:
   - 📝 **Texto** (análisis por texto)
   - 📸 **Imagen** (análisis por imagen) ← **Selecciona este**

### Paso 3: Seleccionar Modo de Análisis

Verás 3 opciones:

#### 🍽️ Modo: Plato Completo
**Úsalo para:** Foto de un plato con varios alimentos

**Qué hace:**
- Detecta **TODOS** los alimentos en la imagen
- Estima cantidad de cada uno
- Calcula valores nutricionales por separado

**Ejemplo de uso:**
1. Toma foto de tu plato de comida
2. (Opcional) Agrega contexto: "almuerzo casero"
3. Toca **"Analizar Imagen"**
4. Espera ~5-10 segundos
5. Verás un card con la lista de alimentos detectados
6. Puedes:
   - **Guardar Todos**: Agrega todos los alimentos de una vez
   - **Editar individual**: Edita el primero y guárdalo

#### ⚖️ Modo: Porción Individual
**Úsalo para:** Estimar el tamaño de UNA porción

**Qué hace:**
- Identifica el alimento principal
- Estima la cantidad en gramos visualmente
- Usa referencias (plato=25cm, puño=100g)

**Ejemplo de uso:**
1. Toma foto de tu porción de arroz
2. (Opcional) Escribe: "arroz blanco cocido"
3. Toca **"Analizar Imagen"**
4. Gemini estimará: "Arroz blanco, 180g, ..."
5. Edita si es necesario y guarda

#### 🏷️ Modo: Etiqueta Nutricional
**Úsalo para:** Productos empaquetados con tabla nutricional

**Qué hace:**
- **Lee EXACTAMENTE** los valores de la etiqueta
- No estima, lee los números reales
- Muy preciso

**Ejemplo de uso:**
1. Toma foto de la tabla nutricional del producto
2. Asegúrate que se vean claros los valores
3. Toca **"Analizar Imagen"** (no necesitas contexto)
4. Gemini extrae todos los valores
5. Revisa y guarda

## 📸 Consejos para Mejores Resultados

### Para Platos:
- ✅ Buena iluminación
- ✅ Foto desde arriba (vista cenital)
- ✅ Todo el plato visible
- ✅ Alimentos bien separados visualmente
- ❌ No usar flash directo (genera brillo)

### Para Porciones:
- ✅ Incluir referencias de tamaño (plato, cubiertos)
- ✅ Foto clara y enfocada
- ✅ Mencionar el alimento en el contexto si no es obvio
- ✅ Vista lateral puede ayudar con altura/volumen

### Para Etiquetas:
- ✅ Foto clara y enfocada
- ✅ Texto legible
- ✅ Evitar sombras sobre los números
- ✅ Captura toda la tabla nutricional
- ✅ Preferir luz natural

## 🧪 Casos de Prueba Sugeridos

### Test 1: Plato Simple
**Objetivo:** Verificar detección múltiple básica
1. Toma foto de: arroz + pollo + ensalada
2. Modo: Plato
3. Espera resultado con 3 alimentos detectados
4. Guarda todos

### Test 2: Porción Individual
**Objetivo:** Verificar estimación de tamaño
1. Toma foto de: 1 manzana sobre un plato
2. Modo: Porción
3. Contexto: "manzana"
4. Verifica que estime ~180-200g

### Test 3: Etiqueta de Producto
**Objetivo:** Verificar lectura exacta
1. Toma foto de tabla nutricional de cualquier producto
2. Modo: Etiqueta
3. Verifica que los valores coincidan exactamente

### Test 4: Con Contexto
**Objetivo:** Verificar que el contexto mejora precisión
1. Toma foto de pasta con salsa
2. Modo: Plato
3. Contexto: "pasta con salsa boloñesa casera"
4. Verifica que identifique ingredientes de la salsa

### Test 5: Edición Manual
**Objetivo:** Verificar flujo completo
1. Analiza cualquier imagen
2. Edita los valores nutricionales manualmente
3. Guarda
4. Verifica que se guardó con tus edits

## 🐛 Solución de Problemas

### "No se encontró API key de Gemini"
**Solución:** Configura tu API key en Settings (ver Pre-requisitos)

### "Sin conexión a internet"
**Problema:** El análisis de imágenes requiere internet
**Solución:** Conéctate a WiFi o datos móviles

### "Error al analizar imagen"
**Posibles causas:**
- Imagen muy borrosa o oscura
- API key inválida o expirada
- Límite de requests de Gemini alcanzado (poco probable, son 60/min gratis)
- Imagen demasiado grande (>10MB)

**Soluciones:**
- Toma otra foto con mejor iluminación
- Verifica tu API key en Settings
- Espera 1 minuto e intenta de nuevo
- Usa una imagen más pequeña

### "Análisis muy lento"
**Normal:** Gemini puede tomar 5-15 segundos
**Si tarda >30 segundos:** Verifica tu conexión a internet

### Alimentos detectados incorrectamente
**Es normal:** IA puede equivocarse
**Solución:** Edita manualmente antes de guardar
**Tip:** Usa el campo de contexto para mejorar precisión

## 📊 Qué Esperar

### Tiempos Típicos:
- Plato completo: 8-15 segundos
- Porción individual: 5-10 segundos
- Etiqueta nutricional: 3-8 segundos

### Precisión Esperada:
- Etiqueta nutricional: ~95% (lee números exactos)
- Porción individual: ~80% (depende de referencias)
- Plato completo: ~70% (múltiples alimentos es más difícil)

### Limitaciones Conocidas:
- Alimentos muy mezclados (ej: guiso) son difíciles de separar
- Salsas y líquidos son aproximaciones
- Alimentos muy pequeños pueden no detectarse
- Alimentos del mismo color pueden confundirse

## ✅ Checklist de Prueba

- [ ] API key configurada en Settings
- [ ] Permisos de cámara otorgados
- [ ] Probado modo Plato con 2+ alimentos
- [ ] Probado modo Porción con 1 alimento
- [ ] Probado modo Etiqueta con producto empaquetado
- [ ] Probado "Guardar Todos" con múltiples alimentos
- [ ] Probado edición manual de valores
- [ ] Probado campo de contexto opcional
- [ ] Verificado que se guardan en la comida correcta
- [ ] Verificado que aparecen en el resumen del día

## 🎯 Feedback

Después de probar, anota:
1. ¿Qué tan precisos fueron los análisis?
2. ¿Qué alimentos detectó bien/mal?
3. ¿Los tiempos fueron aceptables?
4. ¿La UI es clara e intuitiva?
5. ¿Algún bug o error encontrado?

---

**Última actualización:** 2025-11-10
**Versión:** Fase 6.11 - Análisis de imágenes con Gemini AI
