import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenuePieChart extends StatefulWidget {
  const RevenuePieChart({super.key});

  @override
  State<RevenuePieChart> createState() => _RevenuePieChartState();
}

class _RevenuePieChartState extends State<RevenuePieChart> {
  final Random _random = Random();
  int touchedIndex = -1;
  bool isPlaying = false;

  late List<_PieData> _data;

  @override
  void initState() {
    super.initState();

    _data = _generateRandomData();

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => isPlaying = true);
      }
    });
  }

  List<_PieData> _generateRandomData() {
    double r(double min, double max) =>
        min + _random.nextDouble() * (max - min);

    return [
      _PieData('Product A', r(10, 40), Colors.teal),
      _PieData('Product B', r(10, 40), Colors.blue),
      _PieData('Product C', r(10, 40), Colors.purple),
      _PieData('Product D', r(10, 40), Colors.indigo),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Revenue Distribution",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          response!.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                startDegreeOffset: isPlaying ? 270 : 0,
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: List.generate(_data.length, (i) {
                  final isTouched = i == touchedIndex;
                  final radius = isTouched ? 70.0 : 60.0;

                  return PieChartSectionData(
                    color: _data[i].color,
                    value: _data[i].value,
                    radius: radius,
                    title: isTouched
                        ? '${_data[i].value.toStringAsFixed(1)}%'
                        : '',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 900),
              swapAnimationCurve: Curves.easeOutBack,
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: _data
                .map((e) => _buildLegendItem(e.label, e.color))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;

  _PieData(this.label, this.value, this.color);
}
