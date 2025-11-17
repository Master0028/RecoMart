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
  late BarChartData _chartData;

  @override
  void initState() {
    super.initState();
    _chartData = _buildChartData(false); 
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _chartData = _buildChartData(true); 
            });
          }
      });
    });
  }

  double _getFixedMaxY() {
    return 100.0; 
  }

  double _getRodValue(Map<String, dynamic> item, int rodIndex) {
    switch (rodIndex) {
      case 0:
        return item['orders']?.toDouble() ?? 50;
      case 1:
        return (item['revenue']?.toDouble() ?? 300000) / 10000;
      case 2:
        return (item['profit']?.toDouble() ?? 200000) / 10000;
      case 3:
        return item['products']?.toDouble() ?? 20;
      case 4:
        return item['categories']?.toDouble() ?? 5;
      default:
        return 0;
    }
  }
  
  String _getMetricName(int rodIndex) {
      switch (rodIndex) {
        case 0: return 'Orders';
        case 1: return 'Revenue';
        case 2: return 'Profit';
        case 3: return 'Products';
        case 4: return 'Categories';
        default: return 'Value';
      }
  }

  BarChartData _buildChartData(bool showData) {
    return BarChartData( 
      alignment: BarChartAlignment.spaceAround,
      maxY: _getFixedMaxY(), 
      minY: 0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final period = widget.data.isNotEmpty && groupIndex < widget.data.length 
                ? widget.data[groupIndex]['period'] 
                : 'Period';
            final metric = _getMetricName(rodIndex);
            final value = rod.toY.toInt();
            return BarTooltipItem(
              '$period\n$metric: $value',
              const TextStyle(color: Colors.black, fontSize: 12),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= widget.data.length) return const Text('');
              return Text(widget.data[value.toInt()]['period'] ?? '', style: const TextStyle(fontSize: 12));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      
      barGroups: List.generate(widget.data.length, (index) {
        final item = widget.data[index];
        
        return BarChartGroupData(
          x: index,
          barRods: [
            _buildAnimatedRod(showData ? _getRodValue(item, 0) : 0, Colors.blue),
            _buildAnimatedRod(showData ? _getRodValue(item, 1) : 0, Colors.green),
            _buildAnimatedRod(showData ? _getRodValue(item, 2) : 0, Colors.purple),
            _buildAnimatedRod(showData ? _getRodValue(item, 3) : 0, Colors.orange),
            _buildAnimatedRod(showData ? _getRodValue(item, 4) : 0, Colors.red),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Comparison (${widget.timeFrame})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              _chartData, 
              
              swapAnimationDuration: const Duration(milliseconds: 750),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  BarChartRodData _buildAnimatedRod(double toY, Color color) {
    return BarChartRodData(
      toY: toY, // Chỉ cần 'toY'
      color: color,
      width: 10,
      borderRadius: const BorderRadius.only( 
          topLeft: Radius.circular(3), 
          topRight: Radius.circular(3),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Orders', Colors.blue),
        _buildLegendItem('Revenue (x10k)', Colors.green),
        _buildLegendItem('Profit (x10k)', Colors.purple),
        _buildLegendItem('Products', Colors.orange),
        _buildLegendItem('Categories', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}