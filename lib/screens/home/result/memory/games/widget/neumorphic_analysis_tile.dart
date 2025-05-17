import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';

class NeumorphicAnalysisTile extends StatefulWidget {
  final bool isLoading;
  final String analysisResult;
  final VoidCallback onAnalyze;

  const NeumorphicAnalysisTile({
    Key? key,
    required this.isLoading,
    required this.analysisResult,
    required this.onAnalyze,
  }) : super(key: key);

  @override
  _NeumorphicAnalysisTileState createState() => _NeumorphicAnalysisTileState();
}

class _NeumorphicAnalysisTileState extends State<NeumorphicAnalysisTile> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        color: NeumorphicTheme.baseColor(context),
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: widget.isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.analytics_outlined, size: 30),
            title: const Text(
              "Analizar Resultados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: widget.isLoading
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 30),
                    onPressed: widget.isLoading ? null : widget.onAnalyze,
                  ),
            onTap: widget.isLoading ? null : widget.onAnalyze,
          ),
          if (widget.analysisResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.analysisResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
