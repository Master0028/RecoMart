import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/info_card.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/daily_progress.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/revenue_chart.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/advanced_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeFrame = 'Yearly';
  DateTime? _startDate;
  DateTime? _endDate;

  final Random _rnd = Random();
  late Map<String, String> _infoValues;

  late double _dailyProgress;
  late int _dailyCurrent;
  late int _dailyMax;

  int _reloadSeed = DateTime.now().millisecondsSinceEpoch;
  Timer? _autoReloadTimer;

  @override
  void initState() {
    super.initState();
    _generateAllRandom();
    _startAutoReload();
  }

  @override
  void dispose() {
    _autoReloadTimer?.cancel();
    super.dispose();
  }

  /// ================= AUTO RELOAD =================
  void _startAutoReload() {
    _autoReloadTimer?.cancel(); 

    _autoReloadTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) {
        if (mounted) {
          _reloadDashboard();
        }
      },
    );
  }

  void _reloadDashboard() {
    if (!mounted) return;
    setState(() {
      _reloadSeed = DateTime.now().millisecondsSinceEpoch;
      _generateAllRandom();
    });
    
    print("Dashboard reloaded at: ${DateTime.now()}");
  }

  void _generateAllRandom() {
    _infoValues = {
      "users": (_rnd.nextInt(9000) + 3000).toString(),
      "orders": (_rnd.nextInt(2000) + 500).toString(),
      "revenue": "${(_rnd.nextDouble() * 50 + 10).toStringAsFixed(1)}M",
      "profit": "${(_rnd.nextDouble() * 20 + 5).toStringAsFixed(1)}M",
    };

    _dailyMax = _rnd.nextInt(150000000) + 50000000;
    _dailyCurrent = _rnd.nextInt(_dailyMax);
    _dailyProgress = _dailyCurrent / _dailyMax;
  }

  void _onTimeFrameChanged(String? value) {
    setState(() {
      _selectedTimeFrame = value!;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTimeFrame = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feChartDataStub = [
      {'period': '2020', 'revenue': 5, 'orders': 120, 'profit': 2},
      {'period': '2021', 'revenue': 7.5, 'orders': 150, 'profit': 3},
      {'period': '2022', 'revenue': 6, 'orders': 180, 'profit': 2.5},
      {'period': '2023', 'revenue': 9, 'orders': 220, 'profit': 4.5},
      {'period': '2024', 'revenue': 12, 'orders': 300, 'profit': 6},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 24),
            _buildInfoCards(context),
            const SizedBox(height: 24),

            DailyProgress(
              key: ValueKey('daily_$_reloadSeed'),
              progress: _dailyProgress,
              currentValue: _dailyCurrent.toString(),
              maxValue: _dailyMax.toString(),
            ),

            const SizedBox(height: 24),
            const RevenueChart(),
            const SizedBox(height: 32),
            _buildPieCharts(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Analytics',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildTimeFilter(context),
              ],
            ),
            const SizedBox(height: 16),
            AdvancedChart(
              timeFrame: _selectedTimeFrame,
              data: feChartDataStub,
              startDate: _startDate,
              endDate: _endDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Store Overview',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Auto reload every 15s (with confirmation)',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ]),
        IconButton(
          tooltip: "Manual reload",
          icon: const Icon(Icons.refresh),
          onPressed: _reloadDashboard,
        ),
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final crossAxisCount =
        Responsive.isDesktop(context) ? 4 : Responsive.isTablet(context) ? 3 : 2;

    final cards = [
      InfoCard(
        title: "TOTAL USERS",
        value: _infoValues["users"]!,
        color: Colors.blue,
        icon: Icons.people_alt_rounded,
      ),
      InfoCard(
        title: "NEW ORDERS",
        value: _infoValues["orders"]!,
        color: Colors.orange,
        icon: Icons.shopping_cart_rounded,
      ),
      InfoCard(
        title: "REVENUE",
        value: _infoValues["revenue"]!,
        color: Colors.green,
        icon: Icons.attach_money_rounded,
      ),
      InfoCard(
        title: "PROFIT",
        value: _infoValues["profit"]!,
        color: Colors.purple,
        icon: Icons.trending_up_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: Responsive.isDesktop(context) ? 1.6 : 1.4,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => cards[i],
    );
  }

  Widget _buildPieCharts(BuildContext context) {
    final titles = ["Order Status", "User Segments", "Payment Methods"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isDesktop(context) ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: titles.length,
      itemBuilder: (_, i) => PieCard(
        key: ValueKey('pie_${_reloadSeed}_$i'),
        title: titles[i],
        seed: _reloadSeed + i,
      ),
    );
  }

  Widget _buildTimeFilter(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          value: _selectedTimeFrame,
          items: ['Yearly', 'Quarterly', 'Monthly', 'Weekly', 'Custom']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: _onTimeFrameChanged,
        ),
        if (_selectedTimeFrame == 'Custom')
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
      ],
    );
  }
}

/// ================= PIE CARD =================
class PieCard extends StatefulWidget {
  final String title;
  final int seed;

  const PieCard({super.key, required this.title, required this.seed});

  @override
  State<PieCard> createState() => _PieCardState();
}

class _PieCardState extends State<PieCard> {
  late List<double> values;

  @override
  void initState() {
    super.initState();
    final rnd = Random(widget.seed);
    values = List.generate(4, (_) => rnd.nextInt(40) + 10);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: List.generate(values.length, (i) {
                  return PieChartSectionData(
                    value: values[i],
                    title: '${values[i].toInt()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    color: Colors.primaries[i * 2],
                  );
                }),
              ),
              swapAnimationDuration:
                  const Duration(milliseconds: 900),
              swapAnimationCurve: Curves.easeOutBack,
            ),
          ),
        ]),
      ),
    );
  }
}
