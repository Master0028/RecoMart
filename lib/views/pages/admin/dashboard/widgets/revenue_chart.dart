import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  bool isPlaying = false;
  int touchedGroupIndex = -1;

  final Random _random = Random();

  late List<List<double>> _chartData;

  @override
  void initState() {
    super.initState();

    _chartData = List.generate(4, (_) => _randomMonthData());

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

  List<double> _randomMonthData() {
    double r(double min, double max) =>
        min + _random.nextDouble() * (max - min);

    return [
      r(200, 700), // Prod A
      r(250, 750), // Prod B
      r(300, 800), // Prod C
      r(180, 650), // Prod D
    ];
  }

  LinearGradient _getGradient(Color color) {
    return LinearGradient(
      colors: [color.withOpacity(0.5), color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
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
            color: const Color(0xFF9E9E9E).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Revenue Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                Text(
                  " 2.5% ",
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "vs last month",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.more_horiz, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: 800,
          minY: 0,
          barTouchData: _buildTouchData(),
          titlesData: _buildTitles(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_chartData.length, (index) {
            final data = _chartData[index];
            final isTouched = touchedGroupIndex == index;
            final opacity =
                (touchedGroupIndex == -1 || isTouched) ? 1.0 : 0.4;

            return BarChartGroupData(
              x: index,
              barRods: [
                _makeRod(data[0], Colors.teal, opacity),
                _makeRod(data[1], Colors.blue, opacity),
                _makeRod(data[2], Colors.purple, opacity),
                _makeRod(data[3], Colors.indigo, opacity),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  BarTouchData _buildTouchData() {
    return BarTouchData(
      enabled: true,
      touchCallback: (event, response) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              response?.spot == null) {
            touchedGroupIndex = -1;
            return;
          }
          touchedGroupIndex =
              response!.spot!.touchedBarGroupIndex;
        });
      },
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          const labels = ["Prod A", "Prod B", "Prod C", "Prod D"];
          return BarTooltipItem(
            '${labels[rodIndex]}\n',
            const TextStyle(color: Colors.white70, fontSize: 12),
            children: [
              TextSpan(
                text: '\$${rod.toY.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles() {
    const months = ["Jan", "Feb", "Mar", "Apr"];

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final isTouched = touchedGroupIndex == value.toInt();
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                months[value.toInt()],
                style: TextStyle(
                  fontSize: isTouched ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  color: isTouched
                      ? Colors.blue[800]
                      : Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return Text(
              value.toInt().toString(),
              style: TextStyle(color: Colors.grey[400], fontSize: 10),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  BarChartRodData _makeRod(double yValue, Color color, double opacity) {
    return BarChartRodData(
      toY: isPlaying ? yValue : 0,
      gradient: _getGradient(color.withOpacity(opacity)),
      width: 10,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: 800,
        color: Colors.grey.withOpacity(0.05),
      ),
    );
  }

  Widget _buildLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem("Prod A", Colors.teal),
        SizedBox(width: 16),
        _LegendItem("Prod B", Colors.blue),
        SizedBox(width: 16),
        _LegendItem("Prod C", Colors.purple),
        SizedBox(width: 16),
        _LegendItem("Prod D", Colors.indigo),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String title;
  final Color color;

  const _LegendItem(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
