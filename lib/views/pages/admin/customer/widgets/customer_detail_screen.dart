import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/api_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userAvatar;

  const CustomerDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _persona;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _fetchData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService.getUserPersona(widget.userId);
      if (mounted) {
        setState(() {
          _persona = data;
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Customer Insights", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _persona == null
              ? const Center(child: Text("Could not load insights"))
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModernProfileHeader(),
                        const SizedBox(height: 20),
                        _buildAITags(),
                        const SizedBox(height: 20),
                        _buildStatsRow(),
                        const SizedBox(height: 20),
                        _buildRadarChartSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildModernProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40), // Chừa chỗ cho Avatar
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.userName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "ID: ${widget.userId}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'Monospace'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(widget.userAvatar),
              backgroundColor: Colors.grey[200],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAITags() {
    final tags = List<String>.from(_persona!['tags'] ?? []);
    final risk = _persona!['churn_risk'] ?? 'Low';
    
    Color riskColor = Colors.green;
    Color riskBg = Colors.green.shade50;
    if (risk == 'High') {
      riskColor = Colors.red;
      riskBg = Colors.red.shade50;
    } else if (risk == 'Medium') {
      riskColor = Colors.orange;
      riskBg = Colors.orange.shade50;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("AI Analysis Segments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Risk Chip Custom
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined, size: 16, color: riskColor),
                    const SizedBox(width: 6),
                    Text("Risk: $risk", style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              ...tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tag, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    final totalSpent = _persona!['total_spent'] ?? 0;
    final orderCount = _persona!['order_count'] ?? 0;

    return Row(
      children: [
        _buildFancyStatCard(
          "Total Spent",
          "${currencyFormat.format(totalSpent)}đ",
          Icons.attach_money_rounded,
          Colors.blue.shade600,
          Colors.blue.shade50,
        ),
        const SizedBox(width: 16),
        _buildFancyStatCard(
          "Orders",
          "$orderCount",
          Icons.shopping_bag_outlined,
          Colors.purple.shade600,
          Colors.purple.shade50,
        ),
      ],
    );
  }

  Widget _buildFancyStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            // Background Icon
            Positioned(
              right: -10,
              top: -10,
              child: Icon(icon, size: 60, color: color.withOpacity(0.1)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChartSection() {
    final categories = _persona!['favorite_categories'] as Map<String, dynamic>? ?? {};
    var keys = categories.keys.toList();
    var values = categories.values.map((e) => (e as num).toDouble()).toList();

    if (categories.isEmpty) return const SizedBox();

    while (keys.length < 3) {
      keys.add(""); 
      values.add(0);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Interest Radar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("AI Model Affinity Analysis", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("Active", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                radarBackgroundColor: Colors.transparent,
                gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                tickCount: 1,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                titlePositionPercentageOffset: 0.1, // Đẩy text ra xa hơn chút
                titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600),
                
                getTitle: (index, angle) {
                  if (index < keys.length) return RadarChartTitle(text: keys[index]);
                  return const RadarChartTitle(text: "");
                },
                
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withOpacity(0.2),
                    borderColor: AppColors.primary,
                    entryRadius: 4,
                    borderWidth: 2,
                    dataEntries: values.map((e) => RadarEntry(value: e)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}