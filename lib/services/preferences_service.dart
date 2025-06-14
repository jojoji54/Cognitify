// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _secuenceofnumbersmemoryDatasetSelectedKey = 'secuenceofnumbersmemoryDatasetSelected';
   static const _cardpairsDatasetSelectedKey = 'cardpairsmemoryDatasetSelected';
  static const _attentionDatasetSelectedKey = 'attentionDatasetSelected';
  static const _reasoningDatasetSelectedKey = 'reasoningDatasetSelected';

  // Inicializar SharedPreferences
  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Verificar si un dataset ha sido seleccionado
  static Future<bool> isDatasetSelected(String datasetType) async {
    final prefs = await getPrefs();
    final key = _getDatasetKey(datasetType);
    return prefs.getBool(key) ?? false;
  }

  // Marcar un dataset como seleccionado
  static Future<void> setDatasetSelected(
      String datasetType, bool selected) async {
    final prefs = await getPrefs();
    final key = _getDatasetKey(datasetType);
    await prefs.setBool(key, selected);
  }

// Obtener la clave correcta para cada tipo de dataset
  static String _getDatasetKey(String datasetType) {
    switch (datasetType) {
      case "Secuencia de Números":
        return _secuenceofnumbersmemoryDatasetSelectedKey;
      case "Parejas de Cartas":
        return _cardpairsDatasetSelectedKey;
      case "atención":
        return _attentionDatasetSelectedKey;
      case "razonamiento":
        return _reasoningDatasetSelectedKey;
      default:
        return ""; // Devuelve una cadena vacía si no está en la lista
    }
  }

  // Marcar todos los datasets como no seleccionados (para debugging o reset)
   static Future<void> resetAllDatasets() async {
    final prefs = await getPrefs();
    await prefs.remove(_secuenceofnumbersmemoryDatasetSelectedKey);
    await prefs.remove(_cardpairsDatasetSelectedKey);
    await prefs.remove(_attentionDatasetSelectedKey);
    await prefs.remove(_reasoningDatasetSelectedKey);
  } 
}
