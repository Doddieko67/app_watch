# Limitación Conocida: Análisis de Imágenes con Gemini

**Fecha:** 2025-11-11
**Estado:** Limitación Técnica Temporal
**Severidad:** Media (funcionalidad no crítica)

---

## 📋 Resumen

El análisis de imágenes con la API de Gemini **presenta un bug conocido en el SDK de Dart** (`google_generative_ai` v0.4.7). El análisis de texto funciona perfectamente, pero el análisis multimodal con imágenes genera un error.

---

## ⚠️ Error Específico

```
Error al analizar imagen: Exception: Error al analizar imagen del plato:
Unhandled format for Content: {role: model}
This indicates a problem with the Google Generative AI SDK.
```

---

## 🔍 Investigación Realizada

### 1. Verificación de Implementación
✅ El código sigue el patrón oficial documentado:
```dart
final content = Content.multi([
  TextPart(prompt),
  DataPart('image/jpeg', imageBytes),
]);

final response = await model.generateContent(
  [content],
  generationConfig: GenerationConfig(...),
);
```

### 2. Tests Realizados
- ✅ **Análisis de texto**: Funciona perfectamente (200g pollo → 330 cal, 62g proteína)
- ✅ **API Key válida**: Verificada con múltiples endpoints
- ✅ **Descarga de imagen**: Exitosa (35,439 bytes desde Unsplash)
- ❌ **Análisis de imagen**: Falla con error de Content format

### 3. Modelos Probados
- `gemini-flash-latest`: ✅ Funciona para texto, ❌ Falla para imágenes
- `gemini-1.5-flash`: ❌ No disponible en API v1beta
- `gemini-1.5-pro`: ❌ No disponible en API v1beta

### 4. Intentos de Solución
1. ❌ Remover `responseMimeType` de `GenerationConfig` → Error persiste
2. ❌ Cambiar estructura de `Content.multi()` → Error persiste
3. ❌ Usar modelos alternativos → No disponibles o mismo error

### 5. Investigación en GitHub Issues
- **Issue #233** (Oct 2025): "Unhandled format for Content: {}" con tool calls
- **Issue #224** (Mar 2025): Mismo error en tareas complejas
- **Estado**: Ambos issues ABIERTOS sin solución
- **Repositorio**: Marcado como **deprecated** (google-gemini/deprecated-generative-ai-dart)

---

## 🎯 Causa Raíz

El error proviene del SDK `google_generative_ai` que **no maneja correctamente las respuestas multimodales** del modelo Gemini. Específicamente:

1. La petición con imágenes se envía correctamente
2. Gemini responde con un `Content` que tiene `role: "model"`
3. El SDK **no sabe cómo parsear** esa respuesta y lanza excepción

**Este es un bug del SDK, NO de nuestro código.**

---

## 💡 Soluciones Evaluadas

### Opción 1: Esperar Fix del SDK
- ❌ Repositorio marcado como "deprecated"
- ❌ Issues abiertos sin respuesta oficial
- ❌ No hay timeline de fix

### Opción 2: Migrar a SDK Alternativo
- ⚠️ `firebase_ai` (usa `InlineDataPart` en lugar de `DataPart`)
- ⚠️ Requiere configuración de Firebase
- ⚠️ Cambios significativos en toda la app

### Opción 3: Implementación Manual con HTTP
- ⚠️ Llamar directamente al REST API de Gemini
- ⚠️ Requiere manejar autenticación, streaming, etc.
- ⚠️ Mayor complejidad de mantenimiento

### Opción 4: Mantener Solo Análisis de Texto ✅ **IMPLEMENTADO**
- ✅ Funcionalidad core funciona perfectamente
- ✅ Usuarios pueden ingresar "pollo con arroz" y obtener análisis completo
- ✅ Cache, DB local, y fallbacks funcionan
- ⚠️ No hay análisis automático de fotos de platos

---

## 🚀 Estado Actual de la App

### Funcionalidades Operativas
- ✅ Análisis de texto con Gemini (ej: "200g pollo")
- ✅ Sistema de cache (instantáneo)
- ✅ Base de datos local de alimentos (offline)
- ✅ Búsqueda fuzzy en DB local
- ✅ Entrada manual de alimentos
- ✅ Análisis proporcional (ej: "150g" calcula 1.5x los valores de 100g)

### Funcionalidades con Limitación
- ⚠️ **Análisis de imágenes**: UI implementada pero funcionalidad bloqueada por bug del SDK
- ⚠️ Los 3 modos (Plato/Porción/Etiqueta) quedan como "preparados para el futuro"

---

## 📱 Experiencia del Usuario

### Flujo Actual
1. Usuario va a "Agregar Alimento"
2. Puede elegir entre **2 tabs**:
   - **Texto**: ✅ Funciona - escribe "200g pollo" y obtiene análisis completo
   - **Imagen**: ⚠️ UI visible pero al analizar muestra error

### Mensaje de Error para Usuario
```
"Error al analizar imagen: Exception: Error al analizar imagen del plato: ..."
```

**Recomendación UX**: Mostrar mensaje más amigable:
```
"El análisis de imágenes está temporalmente deshabilitado.
Por favor, usa el modo de texto o ingresa los valores manualmente."
```

---

## 🔮 Plan de Acción Futuro

### Corto Plazo (Ahora)
1. ✅ Documentar limitación
2. ⏳ Mejorar mensaje de error para usuario
3. ⏳ Considerar deshabilitar tab de "Imagen" temporalmente

### Mediano Plazo (1-2 meses)
1. Monitorear updates del SDK `google_generative_ai`
2. Evaluar `firebase_ai` cuando esté más maduro
3. Investigar si Gemini 2.0 Flash (cuando esté disponible) resuelve el problema

### Largo Plazo (3-6 meses)
1. Si no hay fix: implementar llamada directa a REST API de Gemini
2. Considerar usar servicios de terceros (OpenAI Vision, Claude Vision)

---

## 📚 Referencias

- **SDK Oficial**: [google_generative_ai v0.4.7](https://pub.dev/packages/google_generative_ai)
- **Issue #233**: [Unhandled format error con tool calls](https://github.com/google-gemini/deprecated-generative-ai-dart/issues/233)
- **Issue #224**: [Error en tareas complejas](https://github.com/google-gemini/deprecated-generative-ai-dart/issues/224)
- **Documentación Gemini**: [ai.google.dev](https://ai.google.dev)
- **Ejemplo Funcional de Texto**: [kazlauskas.dev](https://kazlauskas.dev/blog/flutter-generative-ai-app-using-gemini/)

---

## ✅ Conclusión

**El análisis de texto funciona perfectamente y es suficiente para v1.0 de la app.**

El análisis de imágenes es una feature **nice-to-have** que agregaremos cuando:
1. El SDK de Dart se actualice con un fix, O
2. Migremos a una solución alternativa (Firebase AI, REST API directo)

**La app es completamente funcional sin análisis de imágenes**, ya que:
- Los usuarios pueden escribir "ensalada con pollo 250g" y obtener análisis completo
- El sistema de cache hace que búsquedas repetidas sean instantáneas
- La DB local de 1000+ alimentos funciona offline
- La entrada manual siempre está disponible

---

**Última actualización:** 2025-11-11
**Próxima revisión**: Verificar updates del SDK mensualmente
