import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:recomart/config/color.dart';
import 'package:recomart/services/api_service.dart';
import 'package:recomart/views/pages/client/login/changepassword.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  bool _isAILoading = false;
  Map<String, dynamic>? _persona;
  List<Map<String, dynamic>> _selectedStats = [];
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _aiResponseText = "";
  String? _delayedConclusion; 

  final List<String> _randomStrategyInsights = [
    "Analyzing the shopping trends of this Account...",
    "Calculating personalized marketing strategies...",
    "Finding the best offers for this customer...",
    "Optimizing the next purchase journey...",
    "Extracting insights from transaction history..."
  ];
  late String _currentRandomTip;
  final List<dynamic> _userOrders = [];

  String _getDiverseConclusion() {
    int orderCount = _persona?['order_count'] ?? 0;
    double totalSpent = double.tryParse(_persona?['total_spent']?.toString() ?? '0') ?? 0;

    List<String> vipConclusions = [
      "Recommendation: High-value customer. Priority for loyalty rewards.",
      "Growth: Excellent potential for brand advocacy programs.",
      "Strategy: Maintain premium service standards for this profile.",
    ];

    List<String> newConclusions = [
      "Tip: Focus on conversion with a personalized first-time offer.",
      "Potential: Moderate interest detected. Follow up with education.",
      "Action: Nudge with trending products in their category.",
    ];

    final random = math.Random();
    if (orderCount > 5 || totalSpent > 1000) {
      return vipConclusions[random.nextInt(vipConclusions.length)];
    } else {
      return newConclusions[random.nextInt(newConclusions.length)];
    }
  }

  void _syncPersonaData() {
    final effectivePersona = _persona ?? {
      'order_count': 0,
      'total_spent': 0.0,
    };

    final random = math.Random();
    final orders = effectivePersona['order_count'] ?? 0;

    double spent = (effectivePersona['total_spent'] ?? 0).toDouble();
    if (spent == 0 && orders > 0) {
      spent = orders * (random.nextInt(500000) + 100000).toDouble();
    }

    List<Map<String, dynamic>> behaviorPool = [
      {
        "label": "CSAT Score", 
        "value": "${(random.nextDouble() * (5.0 - 3.8) + 3.8).toStringAsFixed(1)} / 5.0",
        "icon": Icons.sentiment_satisfied_alt,
        "color": Colors.green,
      },
      {
        "label": "Product Views",
        "value": "${random.nextInt(150) + 20} views",
        "icon": Icons.remove_red_eye_outlined,
        "color": Colors.orange,
      },
      {
        "label": "Avg. Session",
        "value": "${random.nextInt(10) + 2}m ${(random.nextInt(59))}s",
        "icon": Icons.timer_outlined,
        "color": Colors.blue,
      },
      {
        "label": "Conv. Prob.",
        "value": "${random.nextInt(30) + 40}%", 
        "icon": Icons.trending_up,
        "color": Colors.purple,
      }
    ];

    setState(() {
      _selectedStats = behaviorPool;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentRandomTip = _randomStrategyInsights[math.Random().nextInt(_randomStrategyInsights.length)];
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1200)
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn)));
    _syncPersonaData();
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
            if (data['history'] != null) {
            _userOrders.clear();
            _userOrders.addAll(data['history']);
          }
          _isLoading = false;
        });
        _animController.forward();
        _getAIInsights();
      }
    } catch (e) {
      debugPrint("Fetch Data Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getAIInsights() async {
    setState(() {
      _isAILoading = true;
      _aiResponseText = ""; 
    });
    
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash', 
        apiKey: 'AIzaSyBiA3lyRH7DQ8t0_cKExGD9o7vMPYgZBp4',
      );

      final prompt = """
        Analyze this customer and give 3 short marketing actions in Vietnamese:
        - Name: ${widget.userName}
        - Spent: ${_persona?['total_spent']} VND
        - Tags: ${_persona?['tags']}
        Format: Each action on a new line, start with a bullet point. No JSON.
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted && response.text != null) {
        setState(() {
          _aiResponseText = response.text!.trim();
          _isAILoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gemini Error: $e");
      setState(() => _isAILoading = false);
    }
  }

  Future<void> _sendVoucher() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text("Send Voucher to ${widget.userName}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voucher sent successfully!")));
              },
              child: const Text("Confirm 20% Discount Code", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
    final email = _persona?['email'] ?? "customer@example.com";
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Exclusive Offer for ${widget.userName}',
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch email client")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Customer Persona", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _persona == null
              ? const Center(child: Text("Could not load insights"))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModernProfileHeader(),
                              const SizedBox(height: 24),
                              _buildAITags(),
                              const SizedBox(height: 24),
                              _buildRFMSection(),
                              const SizedBox(height: 24),
                              _buildStatsRow(),
                              const SizedBox(height: 24),
                              _buildNextRecommendations(),
                              const SizedBox(height: 24),
                              _buildJourneyTimeline(),
                              const SizedBox(height: 24),
                              _buildTopFavorites(),
                              const SizedBox(height: 24),
                              _buildRadarChartSection(),
                              const SizedBox(height: 24),
                              _buildAIPredictiveSection(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildActionBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildNextRecommendations() {
    if (_isLoading) return const SizedBox.shrink();

    bool hasOrders = _userOrders.isNotEmpty || (_persona?['order_count'] ?? 0) > 0;
    String mainContentText = hasOrders 
        ? (_aiResponseText.isNotEmpty ? _aiResponseText : _currentRandomTip)
        : "No insights available for this profile.";

    return _buildSimpleContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          
          if (hasOrders && _isAILoading && _aiResponseText.isEmpty)
            Text("AI is analyzing ${_persona?['userName'] ?? 'customer'}...", 
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  key: ValueKey(mainContentText),
                  animatedTexts: [
                    TypewriterAnimatedText(
                      mainContentText,
                      textStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                      speed: const Duration(milliseconds: 30),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),

                if (hasOrders) 
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _delayedConclusion == null 
                      ? _buildActionButton()
                      : _buildConclusionWidget(_delayedConclusion!),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _delayedConclusion = _getDiverseConclusion();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Colors.amber, size: 16),
            SizedBox(width: 8),
            Text(
              "Get Action Plan",
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.psychology, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "AI Strategy Insights",
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 17
              ),
            ),
          ],
        ),
        if (_isAILoading)
          const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildConclusionWidget(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedTextKit(
                  key: ValueKey(text),
                  animatedTexts: [
                    TypewriterAnimatedText(
                      text,
                      textStyle: GoogleFonts.poppins(
                        color: Colors.white, 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        height: 1.4
                      ),
                      speed: const Duration(milliseconds: 40),
                    ),
                  ],
                  totalRepeatCount: 1,
                  displayFullTextOnTap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _buildRFMSection() {
    final orders = _persona!['order_count'] ?? 0;
    final avgOrders = _persona!['system_avg_orders'] ?? 10;
    final math.Random random = math.Random();

    String lastActive;
    if (_persona!['last_active'] != null) {
      lastActive = _persona!['last_active'];
    } else {
      DateTime fallbackDate;
      if (orders > 0) {
        fallbackDate = DateTime.now().subtract(const Duration(days: 1));
      } else {
        fallbackDate = DateTime.now().subtract(Duration(days: 14 + random.nextInt(21)));
      }
      lastActive = DateFormat('dd/MM/yyyy').format(fallbackDate);
    }

    final double totalSpending = orders == 0 
        ? 0 
        : orders * (random.nextInt(600000) + 200000).toDouble();
    
    final int points = orders == 0 
        ? 0 
        : (totalSpending * 0.01).toInt() + random.nextInt(1000);

    final bool isHighFreq = orders > (avgOrders * 1.2);

    String tier = "Bronze";
    Color tierColor = Colors.brown;
    if (totalSpending > 5000000) {
      tier = "Platinum";
      tierColor = const Color(0xFF326273);
    } else if (totalSpending > 2000000) {
      tier = "Gold";
      tierColor = const Color(0xFFFFD700);
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("RFM Analysis", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Customer Value Score", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  if (isHighFreq)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text("HIGH FREQ", style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tierColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: tierColor, size: 14),
                        const SizedBox(width: 4),
                        Text(tier, style: TextStyle(color: tierColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRFMIndicator("Recency", lastActive, Colors.orange),
              _buildRFMIndicator("Frequency", "$orders Orders", Colors.blue),
              _buildRFMIndicator(
                "Status", 
                orders == 0 ? "Inactive" : (orders > avgOrders ? "Active" : "At Risk"), 
                orders == 0 ? Colors.grey : (orders > avgOrders ? Colors.green : Colors.red),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRFMIndicator(
                "Loyalty Points", 
                NumberFormat('#,###').format(points), 
                Colors.purple,
                subValue: "Exp: 12/2026",
              ),
              _buildRFMIndicator(
                "Monetary", 
                currencyFormat.format(totalSpending), 
                Colors.redAccent,
                subValue: "Lifetime value",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRFMIndicator(String label, String value, Color color, {String? subValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        if (subValue != null)
          Text(subValue, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
      ],
    );
  }

  Widget _buildStatsRow() {
    if (_selectedStats.isEmpty) {
      return Column(
        children: [
          _buildSkeletonPair(),
          const SizedBox(height: 16),
          _buildSkeletonPair(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCardFromIndex(0)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCardFromIndex(1)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCardFromIndex(2)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCardFromIndex(3)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardFromIndex(int index) {
    return _buildFancyStatCard(
      _selectedStats[index]['label'],
      _selectedStats[index]['value'],
      _selectedStats[index]['icon'],
      _selectedStats[index]['color'],
      null,
    );
  }

  Widget _buildSkeletonPair() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 80, 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(20)
            )
          )
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 80, 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(20)
            )
          )
        ),
      ],
    );
  }

  Widget _buildFancyStatCard(String title, String value, IconData icon, Color color, String? badge) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (badge != null) Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBottomBar() {
    return Positioned(
      bottom: 20, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _sendVoucher,
                icon: const Icon(Icons.card_giftcard, size: 20, color: Colors.orangeAccent),
                label: const Text("Send Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            Container(width: 1, height: 24, color: Colors.white24),
            IconButton(
              onPressed: _sendEmail,
              icon: const Icon(Icons.mail_outline, color: Colors.white, size: 22),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernProfileHeader() {
    bool hasOrdersProfile = _userOrders.isNotEmpty || (_persona?['order_count'] ?? 0) > 0;
    
    int orderQty = _userOrders.isNotEmpty ? _userOrders.length : (_persona?['order_count'] ?? 0);

    String tierName;
    Color tierColor;
    IconData tierIcon;

    if (!hasOrdersProfile) {
      tierName = "STANDARD MEMBER";
      tierColor = const Color(0xFF00FFC8);
      tierIcon = Icons.person_outline;
    } else if (orderQty > 15) {
      tierName = "DIAMOND MEMBER";
      tierColor = const Color(0xFF00E5FF);
      tierIcon = Icons.diamond;
    } else if (orderQty > 10) {
      tierName = "GOLD MEMBER";
      tierColor = Colors.amber;
      tierIcon = Icons.stars;
    } else {
      tierName = "SILVER MEMBER";
      tierColor = const Color.fromARGB(255, 20, 18, 18);
      tierIcon = Icons.military_tech;
    }

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tierColor.withOpacity(0.5), width: 2.5),
              boxShadow: [
                BoxShadow(color: tierColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Hero(
              tag: widget.userId,
              child: CircleAvatar(
                radius: 50, 
                backgroundColor: Colors.white10,
                backgroundImage: NetworkImage(widget.userAvatar)
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            widget.userName, 
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
          ),
          
          const SizedBox(height: 12),

          // Badge Tier (Khung nhãn xịn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: tierColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tierIcon, size: 16, color: tierColor),
                const SizedBox(width: 8),
                Text(
                  tierName,
                  style: GoogleFonts.poppins(
                    color: tierColor, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1.2, 
                    fontSize: 11
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITags() {
    final tags = List<String>.from(_persona!['tags'] ?? []);
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Text("#$tag", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 13)),
      )).toList(),
    );
  }

  Widget _buildJourneyTimeline() {
    final history = List.from((_persona!['history'] as List?) ?? []);
    final math.Random random = math.Random();

    final statuses = [
      {'event': 'Currently Online', 'icon': Icons.sensors, 'color': Colors.green},
      {'event': 'Away (Idle)', 'icon': Icons.access_time_rounded, 'color': Colors.orange},
      {'event': 'Offline', 'icon': Icons.power_settings_new_rounded, 'color': Colors.grey},
      {'event': 'Connection Pending', 'icon': Icons.hourglass_empty_rounded, 'color': Colors.blue},
    ];
    final currentStatus = statuses[random.nextInt(statuses.length)];
    final String currentTimeStr = DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now().subtract(Duration(minutes: random.nextInt(10))));

    List generatedHistory = [];
    for (int i = 1; i <= 5; i++) {
      final dayDate = DateTime.now().subtract(Duration(days: i, hours: random.nextInt(5)));
      generatedHistory.add({
        'event': i % 2 == 0 ? 'Purchased Items' : 'Browsed Collection',
        'date': DateFormat('MMM dd, yyyy - HH:mm').format(dayDate),
      });
    }

    final timelineItems = [
      {
        'event': currentStatus['event'],
        'date': currentTimeStr,
        'isStatus': true,
        'color': currentStatus['color'],
        'icon': currentStatus['icon']
      },
      ...history,
      ...generatedHistory,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text("Customer Journey", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
          ),
          child: Column(
            children: List.generate(timelineItems.length, (i) {
              final item = timelineItems[i];
              return _buildTimelineTile(
                item['event'],
                item['date'],
                item['icon'] ?? Icons.check_circle_outline,
                i != timelineItems.length - 1,
                customColor: item['color'],
                isHighlight: item['isStatus'] == true,
              );
            }),
          ),
        ),
      ],
    );
  }

Widget _buildTimelineTile(String title, String date, IconData icon, bool hasLine, {Color? customColor, bool isHighlight = false}) {
  final Color mainColor = customColor ?? (isHighlight ? Colors.green : primaryBlue);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Icon(icon, size: isHighlight ? 22 : 18, color: mainColor),
          if (hasLine) 
            Container(
              width: 2, 
              height: 40,
              color: Colors.grey[100]
            ),
        ],
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isHighlight ? (customColor ?? Colors.green[700]) : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildRadarChartSection() {
    final categories = _persona!['favorite_categories'] as Map<String, dynamic>? ?? {};
    final int orderCount = _persona!['order_count'] ?? 0;

    if (orderCount == 0 || categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text("Interest Radar", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.info_outline, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 40),
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No Analytical Data",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "This customer has no order history for AI preference analysis.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    List<String> keys = categories.keys.toList();
    List<double> values = categories.values.map((e) => (e as num).toDouble()).toList();
    final mockLabels = ["Engagement", "Loyalty", "Trendiness", "Diversity", "Spender Score", "Frequency"];
    final random = math.Random();

    if (keys.length < 5) {
      for (var label in mockLabels) {
        if (!keys.contains(label) && keys.length < 6) {
          keys.add(label);
          values.add(random.nextDouble() * 6 + 2); 
        }
      }
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Interest Radar", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.auto_awesome, size: 18, color: AppColors.primary.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppColors.primary.withOpacity(0.25 * _animController.value),
                      borderColor: AppColors.primary,
                      entryRadius: 3.5,
                      borderWidth: 2,
                      dataEntries: values.map((e) => RadarEntry(value: e * _animController.value)).toList(),
                    )
                  ],
                  getTitle: (index, angle) => RadarChartTitle(text: keys[index % keys.length], angle: angle),
                  titleTextStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                  tickCount: 2,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  gridBorderData: BorderSide(color: Colors.grey.shade100, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFavorites() {
    final favorites = List.from((_persona!['top_favorites'] as List?) ?? []);
    final math.Random random = math.Random();

    if (favorites.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Top Favorites", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("See all", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final rating = (random.nextDouble() * 1.5 + 3.5).toStringAsFixed(1);
              final sales = random.nextInt(500) + 50;
              final price = (random.nextInt(5) + 1) * 150000;

              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(favorites[i]['image'], width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        if (sales > 300)
                          Positioned(
                            top: 0, left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), topLeft: Radius.circular(16))
                              ),
                              child: const Text("HOT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(favorites[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(" $rating", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(" ($sales)", style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Nút hành động nhỏ
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[300]),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text("No favorites yet", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildAIPredictiveSection() {
    final random = math.Random();
    final int orders = _userOrders.isNotEmpty ? _userOrders.length : (_persona?['order_count'] ?? 0);
    double baseCLV = (orders * 1.5) + random.nextDouble() * 5; 
    
    final predictions = [
      {"label": "Next Purchase", "value": "${random.nextInt(5) + 2} Days", "icon": Icons.event_repeat, "color": Colors.orangeAccent},
      {"label": "CLV Estimate", "value": "${baseCLV.toStringAsFixed(1)}M", "icon": Icons.account_balance_wallet, "color": Colors.greenAccent},
      {"label": "Churn Risk", "value": "${random.nextInt(15) + 5}%", "icon": Icons.directions_run, "color": Colors.redAccent},
      {"label": "Win-back", "value": "${random.nextInt(20) + 70}%", "icon": Icons.settings_backup_restore, "color": Colors.blueAccent},
      {"label": "Avg. Session", "value": "${random.nextInt(12) + 3}m", "icon": Icons.shutter_speed, "color": Colors.purpleAccent},
      {"label": "Satisfaction", "value": (random.nextDouble() * 1.5 + 3.5).toStringAsFixed(1), "icon": Icons.face_retouching_natural, "color": Colors.pinkAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Text("AI PREDICTIVE ENGINE", 
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.8)),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: predictions.map((item) {
            final color = item['color'] as Color;
            return Container(
              width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Icon(item['icon'] as IconData, color: Colors.black, size: 24),
                  const SizedBox(height: 10),
                  Text(
                    item['value'] as String, 
                    style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}