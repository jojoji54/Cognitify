import 'package:cognitify/data/available_datasets.dart';
import 'package:cognitify/models/dataset_info.dart';
import 'package:cognitify/services/preferences_service.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hive/hive.dart';

class DatasetSelectionScreen extends StatefulWidget {
  @override
  State<DatasetSelectionScreen> createState() => _DatasetSelectionScreenState();
}

class _DatasetSelectionScreenState extends State<DatasetSelectionScreen> {
  late Box<DatasetInfo> datasetBox;

  @override
  void initState() {
    super.initState();
    loadDatasets();
  }

  void loadDatasets() {
    // La caja ya está abierta en main.dart
    datasetBox = Hive.box<DatasetInfo>('datasets');
    setState(() {});
  }

  Future<void> downloadDataset(DatasetInfo dataset) async {
    // Aquí pondremos la lógica para descargar el dataset
    await PreferencesService.setDatasetSelected(dataset.type, true);
    datasetBox.add(dataset);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Seleccionar Dataset",
          style: const NeumorphicStyle(
            depth: 8,
            intensity: 0.8,
            color: Colors.black,
          ),
          textStyle: NeumorphicTextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: availableDatasets.map((dataset) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: NeumorphicButton(
                onPressed: () => downloadDataset(dataset),
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  depth: 6,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            size: 30,
                            color: Color.fromARGB(255, 80, 39, 176),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataset.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 47, 47, 47),
                                ),
                              ),
                              Text(
                                "Tipo: ${dataset.type}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 80, 80, 80),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Color.fromARGB(255, 150, 150, 150),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
