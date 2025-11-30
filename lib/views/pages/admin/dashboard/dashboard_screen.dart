import 'package:recomart/utils/responsive.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/info_card.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/daily_progress.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/revenue_chart.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/advanced_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recomart/views/pages/admin/dashboard/widgets/recommendation_monitor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeFrame = 'Yearly';
  DateTime? _startDate;
  DateTime? _endDate;

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
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
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
    final List<Map<String, dynamic>> feChartDataStub = [
        {'period': 'Stub Data', 'revenue': 1000000},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCards(context),
            const SizedBox(height: 20),
            DailyProgress(
              progress: 0.48,
              currentValue: "39,169,000",
              maxValue: "100,000,000",
            ),
            const SizedBox(height: 20),
            // Revenue Chart (FE logic)
            const RevenueChart(),
            const SizedBox(height: 20),
            Text(
              'Advanced Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimeFilter(context),
            const SizedBox(height: 20),
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

  Widget _buildInfoCards(BuildContext context) {
    int crossAxisCount = Responsive.isDesktop(context) ? 4 : 2;
    double childAspectRatio = Responsive.isDesktop(context) ? 3.0 : 2.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        final cards = [
          InfoCard(title: "TOTAL USERS", value: "1,234", color: Colors.blue),
          InfoCard(title: "NEW USERS", value: "56", color: Colors.green),
          InfoCard(title: "ORDERS", value: "789", color: Colors.orange),
          InfoCard(title: "REVENUE", value: "39,169,000", color: Colors.purple),
          InfoCard(title: "TOP PRODUCT", value: "Laptop XYZ", color: Colors.red),
        ];
        return cards[index];
      },
    );
  }

  Widget _buildTimeFilter(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          value: _selectedTimeFrame,
          items: ['Yearly', 'Quarterly', 'Monthly', 'Weekly', 'Custom']
              .map((frame) => DropdownMenuItem(value: frame, child: Text(frame)))
              .toList(),
          onChanged: _onTimeFrameChanged,
        ),
        const SizedBox(width: 16),
        if (_selectedTimeFrame == 'Custom')
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            child: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}'
                  : 'Select Date Range',
            ),
          ),
      ],
    );
  }
}