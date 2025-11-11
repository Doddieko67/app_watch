# 🔄 Plan de Migración: google_generative_ai → firebase_ai

**Fecha de creación:** 2025-11-11
**Estado:** Planificado (No ejecutado)
**Prioridad:** Media
**Tiempo estimado:** 2-3 horas

---

## 📋 Contexto

### Problema Actual

El SDK `google_generative_ai` (v0.4.7) tiene un **bug conocido** que impide el análisis de imágenes multimodales:

```
Error: Unhandled format for Content: {role: model}
```

- ✅ **Análisis de texto**: Funciona perfectamente
- ❌ **Análisis de imágenes**: Bloqueado por bug del SDK
- ⚠️ **Issues abiertos**: #233, #224 en GitHub sin solución
- ⚠️ **Repositorio**: Marcado como "deprecated"

### Solución Propuesta

Migrar al nuevo SDK oficial: **`firebase_ai` (v3.5.0)**

- ✅ Publicado hace 8 días (activamente mantenido)
- ✅ Soporte confirmado para `InlineDataPart` con imágenes
- ✅ Usa modelos más nuevos (`gemini-2.5-flash`)
- ✅ SDK oficial recomendado por Flutter/Firebase

---

## 🆚 Comparación de SDKs

| Aspecto | `google_generative_ai` (Actual) | `firebase_ai` (Futuro) |
|---------|--------------------------------|------------------------|
| **Versión** | 0.4.7 | 3.5.0 |
| **Última actualización** | Hace meses | Hace 8 días ✅ |
| **Estado** | Deprecated ⚠️ | Oficial ✅ |
| **Análisis de texto** | ✅ Funciona | ✅ Funciona |
| **Análisis de imágenes** | ❌ Bug conocido | ✅ Funciona |
| **Autenticación** | API Key directa | Firebase Project ✅ |
| **Modelos** | gemini-flash-latest | gemini-2.5-flash ✅ |
| **Tipo de dato imagen** | `DataPart` | `InlineDataPart` |
| **Dependencias adicionales** | Ninguna | `firebase_core`, `firebase_auth` |
| **Configuración inicial** | Simple (solo API key) | Requiere setup Firebase |

---

## 🎯 Objetivos de la Migración

### Funcionales
1. ✅ Habilitar análisis de imágenes de alimentos
2. ✅ Mantener análisis de texto funcionando
3. ✅ Preservar sistema de cache existente
4. ✅ Mantener fallback a DB local

### Técnicos
1. ✅ Migrar a SDK oficial mantenido
2. ✅ Usar modelos más recientes de Gemini
3. ✅ Mejorar seguridad (autenticación vía Firebase)
4. ✅ Preparar app para futuras features de Firebase

---

## 📦 Dependencias Nuevas

### Agregar a `pubspec.yaml`

```yaml
dependencies:
  # Firebase Core (requerido)
  firebase_core: ^4.0.0

  # Firebase AI (Gemini)
  firebase_ai: ^3.5.0

  # OPCIONAL: Si queremos autenticación anónima
  firebase_auth: ^5.0.0

dev_dependencies:
  # Ya tenemos flutterfire_cli, pero verificar versión
  flutterfire_cli: ^1.0.0
```

### Remover (opcional, después de migración completa)

```yaml
# Mantener temporalmente durante transición, luego remover:
# google_generative_ai: ^0.4.7
```

---

## 🔧 Cambios de Código Necesarios

### 1. Inicialización de Firebase

**Archivo:** `lib/main.dart`

**Antes:**
```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**Después:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generado por flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. AiService - Configuración del Modelo

**Archivo:** `lib/core/services/ai_service.dart`

**Antes:**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  GenerativeModel? _geminiModel;

  void configureGemini(String apiKey) {
    _geminiModel = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(...),
    );
  }
}
```

**Después:**
```dart
import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  GenerativeModel? _geminiModel;

  void configureGemini() {
    // Ya no necesita API key - usa Firebase Auth
    _geminiModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash', // Modelo más nuevo
    );
  }
}
```

### 3. Análisis de Imágenes - Cambio de DataPart a InlineDataPart

**Archivo:** `lib/core/services/ai_service.dart`

**Antes:**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final content = Content.multi([
  TextPart(prompt),
  DataPart('image/jpeg', imageBytes),
]);

final response = await _geminiModel!.generateContent([content]);
```

**Después:**
```dart
import 'package:firebase_ai/firebase_ai.dart';

final content = Content.multi([
  TextPart(prompt),
  InlineDataPart('image/jpeg', imageBytes), // Cambio aquí
]);

final response = await _geminiModel!.generateContent([content]);
```

### 4. Configuración de API Key (Ya no necesaria)

**Archivo:** `lib/features/settings/presentation/screens/settings_home_screen.dart`

**Cambio:** La sección de "Gemini API Key" puede:
- **Opción A**: Removerse completamente (autenticación vía Firebase)
- **Opción B**: Convertirse en un botón "Iniciar sesión con Google" para autenticación

---

## 📋 Plan de Implementación Detallado

### **Fase 1: Setup de Firebase** (30-45 minutos)

#### 1.1 Instalar FlutterFire CLI (si no está)
```bash
dart pub global activate flutterfire_cli
```

#### 1.2 Configurar Firebase para el proyecto
```bash
flutterfire configure
```
- Seleccionar/crear proyecto de Firebase
- Configurar para Android e iOS
- Genera `firebase_options.dart` automáticamente

#### 1.3 Agregar dependencias
```bash
flutter pub add firebase_core
flutter pub add firebase_ai
flutter pub add firebase_auth  # Opcional
```

#### 1.4 Habilitar Gemini API en Firebase Console
1. Ir a Firebase Console → Proyecto
2. Build → Vertex AI
3. Habilitar Gemini API
4. Configurar cuotas (gratis hasta cierto límite)

#### 1.5 Actualizar `main.dart`
- Agregar inicialización de Firebase (ver código arriba)
- Compilar y verificar que no haya errores

**Checklist Fase 1:**
- [ ] FlutterFire CLI instalado
- [ ] `flutterfire configure` ejecutado
- [ ] `firebase_options.dart` generado
- [ ] Dependencias agregadas
- [ ] Gemini habilitado en Firebase Console
- [ ] App compila sin errores
- [ ] Firebase inicializa correctamente

---

### **Fase 2: Migrar AiService** (1-1.5 horas)

#### 2.1 Crear branch de trabajo
```bash
git checkout -b feature/migrate-firebase-ai
```

#### 2.2 Actualizar imports en `ai_service.dart`
```dart
// Remover:
// import 'package:google_generative_ai/google_generative_ai.dart';

// Agregar:
import 'package:firebase_ai/firebase_ai.dart';
```

#### 2.3 Actualizar método `configureGemini()`
```dart
// ANTES: void configureGemini(String apiKey)
// DESPUÉS: void configureGemini()

void configureGemini() {
  _geminiModel = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
  );
}
```

#### 2.4 Actualizar llamadas en Settings
**Archivo:** `lib/features/settings/presentation/providers/settings_provider.dart`

```dart
// ANTES:
if (apiKey != null && apiKey.isNotEmpty) {
  aiService.configureGemini(apiKey);
}

// DESPUÉS: (Ya no necesita API key)
aiService.configureGemini();
```

#### 2.5 Actualizar análisis de imágenes
- Cambiar `DataPart` → `InlineDataPart`
- Actualizar `analyzeFullPlate()`
- Actualizar `analyzePortionSize()`
- Actualizar `analyzeNutritionLabel()`

#### 2.6 Remover/Actualizar UI de API Key en Settings
**Opciones:**
- **A) Remover completamente** (recomendado para simplificar)
- **B) Mantener como botón "Conectar con Google"**

**Checklist Fase 2:**
- [ ] Branch `feature/migrate-firebase-ai` creado
- [ ] Imports actualizados
- [ ] `configureGemini()` sin parámetro apiKey
- [ ] `InlineDataPart` en lugar de `DataPart`
- [ ] 3 métodos de imagen actualizados
- [ ] UI de Settings actualizada
- [ ] No hay errores de compilación

---

### **Fase 3: Testing Exhaustivo** (30-45 minutos)

#### 3.1 Actualizar `test_gemini.dart`
```dart
// Actualizar script para usar firebase_ai
// Probar modelos disponibles: gemini-2.5-flash, gemini-2.5-pro
```

#### 3.2 Tests de Análisis de Texto
```bash
dart run test_gemini.dart
```
- [ ] Test simple ("2+2") funciona
- [ ] Análisis de alimento ("200g pollo") funciona
- [ ] JSON válido generado
- [ ] Cache funciona correctamente

#### 3.3 Tests de Análisis de Imágenes
- [ ] Descarga de imagen exitosa
- [ ] Análisis de plato completo funciona ✅
- [ ] Análisis de porción funciona
- [ ] Análisis de etiqueta funciona
- [ ] JSON válido con múltiples alimentos

#### 3.4 Tests en la App (Manual)
```bash
flutter build apk --debug
# Instalar en dispositivo/emulador
```

**Tests manuales:**
- [ ] Agregar alimento por texto → Funciona
- [ ] Agregar alimento por imagen → Funciona ✅
- [ ] Modo "Plato completo" → Detecta múltiples alimentos
- [ ] Modo "Porción" → Estima cantidad
- [ ] Modo "Etiqueta" → Lee valores nutricionales
- [ ] Cache funciona (segunda búsqueda instantánea)
- [ ] Fallback a DB local funciona (offline)

#### 3.5 Tests de Regresión
- [ ] Recordatorios siguen funcionando
- [ ] Fitness tracker sin cambios
- [ ] Settings se abre correctamente
- [ ] Navegación funciona
- [ ] Notificaciones programadas

**Checklist Fase 3:**
- [ ] `test_gemini.dart` actualizado
- [ ] Todos los tests de texto pasan
- [ ] Todos los tests de imagen pasan ✅
- [ ] Tests manuales en app pasan
- [ ] No hay regresiones en otros módulos

---

### **Fase 4: Cleanup y Documentación** (30 minutos)

#### 4.1 Remover Código Viejo
```bash
# Verificar que no haya referencias a google_generative_ai
grep -r "google_generative_ai" lib/
```

#### 4.2 Remover Dependencia Vieja
```yaml
# pubspec.yaml - Remover:
# google_generative_ai: ^0.4.7
```

#### 4.3 Actualizar Documentación
- [ ] `.claude/contexts/04_ai_strategy.md` → Actualizar con firebase_ai
- [ ] `.claude/contexts/13_nutrition_ai_fix.md` → Marcar como resuelto
- [ ] `.claude/contexts/16_gemini_image_limitation.md` → Agregar resolución
- [ ] `.claude/contexts/17_firebase_ai_migration_plan.md` → Marcar como completado
- [ ] `15_changelog.md` → Agregar entrada de migración

#### 4.4 Crear Commit
```bash
git add .
git commit -m "feat(ai): migrate from google_generative_ai to firebase_ai

BREAKING CHANGE: API Key configuration removed. App now uses Firebase Authentication.

RESUELVE:
- ✅ Análisis de imágenes ahora funciona completamente
- ✅ Bug de 'Unhandled format for Content' resuelto
- ✅ Migrado a SDK oficial firebase_ai v3.5.0
- ✅ Usando modelo más reciente (gemini-2.5-flash)

CAMBIOS:
- Inicialización de Firebase en main.dart
- AiService usa FirebaseAI en lugar de GenerativeModel directo
- InlineDataPart en lugar de DataPart para imágenes
- Removida sección de API Key en Settings

TESTS:
- ✅ Análisis de texto funciona
- ✅ Análisis de imágenes funciona (3 modos)
- ✅ Cache y fallbacks operativos
- ✅ Sin regresiones en otros módulos

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Checklist Fase 4:**
- [ ] Referencias a SDK viejo removidas
- [ ] Dependencia vieja removida de pubspec.yaml
- [ ] Documentación actualizada (5 archivos)
- [ ] Commit creado con mensaje detallado

---

## ⚖️ Decisión: ¿Cuándo Migrar?

### Opción A: **Migrar Ahora** ✅ Recomendado

**Pros:**
- ✅ Desbloquea análisis de imágenes inmediatamente
- ✅ Usa SDK oficial mantenido activamente
- ✅ Preparación para futuras features de Firebase
- ✅ Mejor seguridad (no API key hardcoded)
- ✅ Acceso a modelos más nuevos (2.5 Flash)

**Contras:**
- ⚠️ Requiere 2-3 horas de trabajo
- ⚠️ Setup de Firebase puede ser confuso la primera vez
- ⚠️ Añade dependencias (firebase_core, firebase_ai)

**Mejor momento:** Cuando tengas 3 horas seguidas para implementación + testing.

---

### Opción B: **Migrar Más Tarde** (No recomendado)

**Pros:**
- ✅ Sin trabajo inmediato
- ✅ App funciona para análisis de texto

**Contras:**
- ❌ Análisis de imágenes sigue bloqueado
- ❌ Usando SDK deprecated
- ❌ Deuda técnica se acumula
- ❌ Potenciales breaking changes futuros

**Mejor momento:** Nunca - mejor hacerlo ahora que después.

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Firebase configuración falla
**Mitigación:**
- Seguir documentación oficial de FlutterFire
- Verificar cada paso antes de continuar
- Usar `flutterfire configure` (automatiza todo)

### Riesgo 2: App no compila después de migración
**Mitigación:**
- Trabajar en branch separado (`feature/migrate-firebase-ai`)
- Mantener dependencia vieja hasta que todo funcione
- Rollback fácil con `git checkout main`

### Riesgo 3: Cuotas de Firebase excedidas
**Mitigación:**
- Gemini tiene capa gratuita generosa
- Monitorear uso en Firebase Console
- Implementar rate limiting si es necesario

### Riesgo 4: Usuarios existentes pierden configuración
**Mitigación:**
- No aplicable - la app aún no tiene usuarios en producción
- Si ya hubiera: migración de datos de API key a Firebase Auth

---

## 📊 Comparación de Esfuerzo vs Beneficio

| Aspecto | Esfuerzo | Beneficio |
|---------|----------|-----------|
| Setup Firebase | 30 min ⚠️ | Alto (infraestructura futura) ✅ |
| Actualizar AiService | 1 hora ⚠️ | Alto (desbloquea imágenes) ✅ |
| Testing | 30 min ⚠️ | Alto (confianza en cambios) ✅ |
| Documentación | 30 min ⚠️ | Medio (claridad futura) ✅ |
| **TOTAL** | **2-3 horas ⚠️** | **Muy Alto ✅** |

**Conclusión:** El esfuerzo vale la pena. 3 horas de trabajo desbloquean una feature completa y migran a tecnología moderna.

---

## 📚 Referencias

### Documentación Oficial
- [Firebase AI Package](https://pub.dev/packages/firebase_ai)
- [Firebase AI Documentation](https://firebase.google.com/docs/ai-logic)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Gemini API Documentation](https://ai.google.dev/docs)

### Documentación Interna
- [16. Limitación de Imágenes](.claude/contexts/16_gemini_image_limitation.md) - Bug actual
- [04. Estrategia de IA](.claude/contexts/04_ai_strategy.md) - Arquitectura actual
- [13. Fix de Gemini AI](.claude/contexts/13_nutrition_ai_fix.md) - Fixes previos

### Ejemplos de Código
- [Medium: Firebase AI with Flutter](https://alfredobs97.medium.com/the-future-of-flutter-genai-is-here-meet-the-firebase-ai-sdk-1ac5b4b22e9c)
- [Firebase Blog: Building AI Apps](https://firebase.blog/posts/2025/05/building-ai-apps/)

---

## ✅ Checklist Final

Antes de considerar la migración completa:

### Pre-Migración
- [ ] Leer este documento completo
- [ ] Reservar 3 horas de trabajo ininterrumpido
- [ ] Tener cuenta de Google/Firebase lista
- [ ] Branch `feature/migrate-firebase-ai` creado
- [ ] Backup de código actual

### Durante Migración
- [ ] Fase 1 completada (Setup Firebase)
- [ ] Fase 2 completada (Migrar AiService)
- [ ] Fase 3 completada (Testing)
- [ ] Fase 4 completada (Cleanup)

### Post-Migración
- [ ] Análisis de imágenes funciona ✅
- [ ] Todos los tests pasan
- [ ] Documentación actualizada
- [ ] Commit creado
- [ ] Merge a main
- [ ] Deploy/release nuevo APK

---

**Última actualización:** 2025-11-11
**Estado:** Documento completo - Listo para ejecución
**Próximo paso:** Decidir cuándo ejecutar la migración (recomendado: próxima sesión de 3 horas)
