import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:recomart/config/color.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // ignore: unused_field
  final TextEditingController _searchController = TextEditingController();
  final List<String> _suggestions = [
    "How to track order",
    "Refund policy",
    "AI Recommendation",
    "Payment methods",
    "Shipping fee",
    "Contact support"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help Center",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            _buildAnimated(
              delay: 0,
              child: const Text(
                "How can we help you?",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 20),
            _buildAnimated(
              delay: 100,
              child: _buildAutoCompleteSearch(),
            ),
            const SizedBox(height: 30),
            _buildAnimated(
              delay: 200,
              child: Row(
                children: [
                  _buildSupportCard(FeatherIcons.messageCircle, "Live Chat", "Start now", Colors.blue),
                  const SizedBox(width: 15),
                  _buildSupportCard(FeatherIcons.mail, "Email Us", "Get reply in 24h", AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 35),
            _buildAnimated(
              delay: 300,
              child: const Text("Top Questions", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildFAQList(),
            const SizedBox(height: 40),
            _buildAnimated(
              delay: 800,
              child: const Center(
                child: Text(
                  "Designed with ❤️ by Visionaries Team",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimated({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 700 + delay),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAutoCompleteSearch() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return _suggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Search topics...",
            prefixIcon: const Icon(FeatherIcons.search, size: 20, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(option, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportCard(IconData icon, String title, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
          ],
          border: Border.all(color: Colors.grey.shade50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    final List<Map<String, String>> faqs = [
      {"q": "How to track my order?", "a": "Go to Profile > Orders to see real-time updates of your packages."},
      {"q": "How does AI Recommendation work?", "a": "Our AI analyzes your interactions to suggest products you might like."},
      {"q": "Is my payment secure?", "a": "Yes, we use industry-standard encryption to protect your transaction data."},
      {"q": "Can I cancel my order?", "a": "Orders can be cancelled within 30 minutes of placement from the Order Details page."}
    ];

    return Column(
      children: faqs.asMap().entries.map((entry) {
        return _buildAnimated(
          delay: 400 + (entry.key * 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primary,
                title: Text(entry.value['q']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(entry.value['a']!, style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}