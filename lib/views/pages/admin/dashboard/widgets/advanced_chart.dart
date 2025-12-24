import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdvancedChart extends StatefulWidget {
  final String timeFrame;
  final List<Map<String, dynamic>> data;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdvancedChart({
    super.key,
    required this.timeFrame,
    required this.data,
    this.startDate,
    this.endDate,
  });

  @override
  State<AdvancedChart> createState() => _AdvancedChartState();
}

class _AdvancedChartState extends State<AdvancedChart> {
  bool isPlaying = false;
  int touchedGroupIndex = -1;

  late List<Map<String, dynamic>> _chartData;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _randomizeAll();
    _playAnimation();
  }

  @override
  void didUpdateWidget(covariant AdvancedChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeFrame != widget.timeFrame) {
      setState(() {
        isPlaying = false;
        _randomizeAll();
      });
      _playAnimation();
    }
  }

  void _playAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => isPlaying = true);
      }
    });
  }

  void _randomizeAll() {
    _chartData = widget.data.map(_randomizeItem).toList();
  }

  Map<String, dynamic> _randomizeItem(Map<String, dynamic> item) {
    double r(double min, double max) =>
        min + _random.nextDouble() * (max - min);

    return {
      'period': item['period'] ?? '',
      'orders': r(20, 90),
      'revenue': r(200000, 900000),
      'profit': r(100000, 600000),
      'products': r(10, 70),
      'categories': r(5, 40),
    };
  }

  double _getRodValue(Map<String, dynamic> item, int rodIndex) {
    switch (rodIndex) {
      case 0: return item['orders'];
      case 1: return item['revenue'] / 10000;
      case 2: return item['profit'] / 10000;
      case 3: return item['products'];
      case 4: return item['categories'];
      default: return 0;
    }
  }

  String _getMetricName(int i) =>
      ['Orders', 'Revenue', 'Profit', 'Products', 'Categories'][i];

  Color _getColor(int i) =>
      [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink][i];

  LinearGradient _getGradient(Color c) => LinearGradient(
        colors: [c.withOpacity(0.6), c],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  double get _maxY {
    double max = 0;
    for (final item in _chartData) {
      for (int i = 0; i < 5; i++) {
        max = max < _getRodValue(item, i) ? _getRodValue(item, i) : max;
      }
    }
    return (max * 1.2).clamp(20, 120);
  }

  double get _barWidth =>
      (_chartData.length > 8) ? 8 : 14;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChart(
        BarChartData(
          maxY: _maxY,
          minY: 0,
          groupsSpace: 12,
          barTouchData: _touchData(),
          titlesData: _titles(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_chartData.length, (x) {
            final item = _chartData[x];
            final faded =
                touchedGroupIndex != -1 && touchedGroupIndex != x;

            return BarChartGroupData(
              x: x,
              barRods: List.generate(5, (i) {
                return BarChartRodData(
                  toY: isPlaying ? _getRodValue(item, i) : 0,
                  width: _barWidth,
                  gradient:
                      _getGradient(_getColor(i).withOpacity(faded ? 0.4 : 1)),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                );
              }),
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 700),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  BarTouchData _touchData() => BarTouchData(
        touchCallback: (e, r) {
          setState(() {
            touchedGroupIndex =
                r?.spot?.touchedBarGroupIndex ?? -1;
          });
        },
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (_, __, rod, i) => BarTooltipItem(
            '${_getMetricName(i)}\n',
            const TextStyle(color: Colors.white70),
            children: [
              TextSpan(
                text: rod.toY.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      );

  FlTitlesData _titles() => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _chartData[v.toInt()]['period'],
                style: TextStyle(
                  fontSize: 11,
                  color: touchedGroupIndex == v.toInt()
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: const TextStyle(fontSize: 10)),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
}
