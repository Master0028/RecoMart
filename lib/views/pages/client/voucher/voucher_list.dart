import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class VoucherListPage extends StatelessWidget {
  const VoucherListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
          ),
        ),
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return _buildStatusText("Something went wrong");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4ECCA3)));
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return _buildStatusText("No coupons available");

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildPremiumVoucher(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MY REWARDS", 
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
                builder: (context, snap) => Text(
                  "${snap.data?.docs.length ?? 0} Active Coupons",
                  style: const TextStyle(color: Color(0xFF4ECCA3), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumVoucher(Map<String, dynamic> data) {
    final String code = data['code'] ?? 'N/A';
    final num discountValue = data['discountValue'] ?? 0;
    
    String displayDiscount = discountValue >= 1000 
        ? "${(discountValue / 1000).toStringAsFixed(0)}K" 
        : "$discountValue";

    String dateLabel = "New Arrival";
    if (data['createdAt'] != null) {
      DateTime date = (data['createdAt'] as Timestamp).toDate();
      dateLabel = "Added: ${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECCA3), Color(0xFF45B08C)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECCA3).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(5, 0),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayDiscount,
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E)),
                      ),
                      const Text("OFF", style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w900, fontSize: 10)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("SPECIAL DISCOUNT",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(code,
                            style: const TextStyle(color: Color(0xFF4ECCA3), fontFamily: 'Monospace', fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        const SizedBox(height: 8),
                        Text(dateLabel,
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildNotch(top: -10, left: 90),
          _buildNotch(bottom: -10, left: 90),
          Positioned(
            left: 100,
            top: 20,
            bottom: 20,
            child: Column(
              children: List.generate(6, (index) => Container(
                width: 1.5, height: 6,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: Colors.white10,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotch({double? top, double? bottom, double? left}) {
    return Positioned(
      top: top, bottom: bottom, left: left,
      child: const CircleAvatar(radius: 10, backgroundColor: Color(0xFF1A1A2E)),
    );
  }

  Widget _buildStatusText(String text) {
    return Center(child: Text(text, style: const TextStyle(color: Colors.white54)));
  }
}