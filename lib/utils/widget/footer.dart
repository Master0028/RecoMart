import 'package:flutter/material.dart';

// Đặt các hằng số kích thước để dễ quản lý
const double kPaddingHorizontal = 32.0;
const double kPaddingVertical = 48.0;

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return Container(
      // Màu nền trắng tinh khiết, hiện đại
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: kPaddingVertical,
        horizontal: isDesktop ? 96.0 : kPaddingHorizontal,
      ),
      child: const Material(
        color: Colors.transparent,
        child: FooterContent(), 
      ),
    );
  }
}

class FooterContent extends StatelessWidget {
  const FooterContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // Bố cục cho Desktop (Phân chia thành 2 phần chính)
  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: _buildBrandingAndLegal(),
            ),
            const SizedBox(width: 80),

            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumn("Products", [
                    "Product",
                    "Pricing",
                    "Log in",
                    "Request access",
                    "Partnerships"
                  ]),
                  _buildColumn(
                      "About us", ["About heilsa", "Contact us", "Features", "Careers"]),
                  _buildColumn("Resources",
                      ["Help center", "Book a demo", "Server status", "Blog"]),
                  SizedBox(
                      width: 150,
                      child: _buildColumn("Get in touch",
                          ["Questions or feedback?", "We’d love to hear from you"])),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 80, thickness: 0.5, color: Colors.black12),
        _buildSocialMediaRow(),
      ],
    );
  }

  // Bố cục cho Mobile (Tất cả xếp dọc)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandingAndLegal(),
        const SizedBox(height: 40),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColumn("Products", [
              "Product",
              "Pricing",
              "Log in",
              "Request access",
              "Partnerships"
            ], isMobile: true),
            const SizedBox(height: 24),
            _buildColumn(
                "About us", ["About heilsa", "Contact us", "Features", "Careers"],
                isMobile: true),
            const SizedBox(height: 24),
            _buildColumn("Resources",
                ["Help center", "Book a demo", "Server status", "Blog"],
                isMobile: true),
            const SizedBox(height: 24),
            _buildColumn("Get in touch",
                ["Questions or feedback?", "We’d love to hear from you"],
                isMobile: true),
          ],
        ),
        const Divider(height: 60, thickness: 0.5, color: Colors.black12),
        _buildSocialMediaRow(),
      ],
    );
  }

  // Widget riêng cho Logo và Legal
  Widget _buildBrandingAndLegal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHEIDTECH',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.black),
        ),
        const SizedBox(height: 30),

        const Text(
          '©2025 SworKit® by Nexercise, Inc.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),

        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Terms of Service | Privacy Policy',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black38
                  ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget riêng cho Social Media
  Widget _buildSocialMediaRow() {
    return Row(
      children: [
        // Khắc phục lỗi: Thay Icon và đảm bảo các tham số KHÔNG phải là const
        _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2), () {}), 
        _buildSocialIcon(Icons.share_rounded, Colors.black, () {}), 
        _buildSocialIcon(Icons.insert_chart_outlined_rounded, const Color(0xFFC13584), () {}),
        _buildSocialIcon(Icons.camera_alt_rounded, const Color(0xFFE4405F), () {}), // Tương đương Instagram 
        _buildSocialIcon(Icons.link, const Color(0xFF0A66C2), () {}), // Tương đương LinkedIn
      ],
    );
  }
  
  // Hàm tạo Icon Social có hiệu ứng nhấn
  // Khắc phục lỗi `const` bằng cách loại bỏ `const` khỏi `Icon` và `InkWell` nếu cần
  Widget _buildSocialIcon(IconData icon, Color color, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            // Loại bỏ const ở đây vì tham số `icon` và `color` được truyền từ bên ngoài (không phải const)
            icon: Icon(icon, color: color, size: 24),
            onPressed: onPressed,
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
          ),
        ),
      ),
    );
  }


  // Cột liên kết được tái sử dụng
  Widget _buildColumn(String title, List<String> items, {bool isMobile = false}) {
    final Widget columnContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black),
          ),
        ),
        // Danh sách liên kết
        ...items.map(
          (item) => InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                item,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ],
    );

    return isMobile
        ? columnContent
        : SizedBox(
            width: 140,
            child: columnContent,
          );
  }
}