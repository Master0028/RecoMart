import 'package:flutter/material.dart';

class DailyProgress extends StatefulWidget {
  final double progress; // 0.0 -> 1.0
  final String currentValue;
  final String minValue;
  final String maxValue;

  const DailyProgress({
    super.key,
    required this.progress,
    required this.currentValue,
    this.minValue = "0",
    required this.maxValue,
  });

  @override
  State<DailyProgress> createState() => _DailyProgressState();
}

class _DailyProgressState extends State<DailyProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<int> _percentAnim;
  late Animation<int> _valueAnim;

  int _parseNumber(String v) {
    return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant DailyProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.currentValue != widget.currentValue) {
      _controller.dispose();
      _initAnimation();
    }
  }

  void _initAnimation() {
    final endPercent = (widget.progress * 100).round();
    final endValue = _parseNumber(widget.currentValue);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _percentAnim = IntTween(
      begin: 0,
      end: endPercent,
    ).animate(_controller);

    _valueAnim = IntTween(
      begin: 0,
      end: endValue,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Daily Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 6),

              /// % animated
              Text(
                "${_percentAnim.value}%",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// Values row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.minValue,
                      style: const TextStyle(color: Colors.grey)),
                  Text(
                    _valueAnim.value.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(widget.maxValue,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 10),

              /// Animated progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: _progressAnim.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                      Colors.orange,
                      Colors.green,
                      _progressAnim.value,
                    )!,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
