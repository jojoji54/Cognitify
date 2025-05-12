# Cognitify

Cognitify es una aplicación móvil diseñada para ayudar en la detección temprana del deterioro cognitivo leve (DCL) y otros trastornos neurodegenerativos, como el Alzheimer. La app permite a los usuarios evaluar sus funciones cognitivas a través de pruebas simples y registrar su progreso a lo largo del tiempo. Es ideal para personas que desean monitorear su salud mental de forma accesible y privada, sin necesidad de acudir a centros médicos para cada evaluación.

## 📋 Características Principales

* Pruebas cognitivas rápidas y accesibles.
* Almacenamiento local seguro con Hive.
* Gráficas para visualizar evolución cognitiva.
* Configuración personalizada según edad y nivel educativo.
* Feedback inmediato tras cada prueba.

## Estructura del proyecto

lib/
├── main.dart                 # Punto de entrada de la app
├── app.dart                  # Configuración global y temas
├── models/                   # Modelos de datos
│   └── test_result.dart      # Resultados de tests
│   └── user_profile.dart     # Perfil del usuario
├── providers/                # Lógica de estado y manejo de datos
│   └── user_provider.dart    # Perfil del usuario
│   └── results_provider.dart # Resultados de tests
├── screens/                  # Pantallas principales
│   ├── home_screen.dart      # Pantalla de inicio
│   ├── test_selection_screen.dart  # Selección de pruebas
│   ├── test_execution/
│   │   ├── memory_test_screen.dart # Test de memoria visual
│   │   └── attention_test_screen.dart # Test de atención selectiva
│   ├── results_screen.dart   # Pantalla de resultados
│   └── settings_screen.dart  # Pantalla de configuración
├── widgets/                  # Componentes reutilizables
│   ├── test_card.dart        # Tarjetas para seleccionar tests
│   └── result_chart.dart     # Gráficas de resultados
├── services/                 # Servicios para lógica de negocio
│   ├── storage_service.dart  # Manejo de Hive y persistencia
│   └── stats_service.dart    # Análisis y cálculos estadísticos
├── utils/                    # Utilidades y constantes
│   └── test_constants.dart   # Constantes de pruebas
├── data/                     # Datos de configuración y textos
│   └── locales/              # Archivos de localización
│       └── en.arb            # Traducciones en inglés
│       └── es.arb            # Traducciones en español
└── assets/                   # Recursos estáticos
    ├── images/              # Imágenes para tests y fondo
    └── sounds/              # Efectos de sonido


## 🧠 Pruebas Incluidas

1. **Memoria Visual** - Prueba de retención de imágenes en pares.
2. **Atención Selectiva** - Identificación rápida de elementos diferentes.
3. **Tiempos de Reacción** (opcional) - Medición de velocidad mental.

## 📦 Tecnologías Utilizadas

* **Flutter** - Para la interfaz de usuario y lógica de la aplicación.
* **Hive** - Para almacenamiento local de resultados.
* **fl\_chart** - Para visualización de datos.

## 🚀 Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/tu-usuario/Cognitify.git
   ```
2. Entra en el directorio del proyecto:

   ```bash
   cd Cognitify
   ```
3. Instala las dependencias:

   ```bash
   flutter pub get
   ```
4. Corre la aplicación:

   ```bash
   flutter run
   ```

## 📝 Uso

* Abre la aplicación y configura tu perfil (edad, nivel educativo).
* Realiza las pruebas cognitivas para medir tu rendimiento.
* Revisa tu progreso en el panel de resultados.

## 📅 Roadmap

* Añadir más pruebas cognitivas (N-back, fluidez verbal).
* Implementar exportación de resultados en PDF.
* Incluir análisis predictivo para detección temprana de cambios.
* Mejorar la interfaz con animaciones y transiciones suaves.

## 🤝 Contribuciones

¡Contribuciones, ideas y sugerencias son bienvenidas! Puedes crear un fork del proyecto y enviar tus pull requests.

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.
