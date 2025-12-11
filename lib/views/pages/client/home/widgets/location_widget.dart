import 'package:recomart/config/color.dart';
import 'package:recomart/config/icon.dart';
import 'package:recomart/helpers/text_helper.dart';
import 'package:flutter/material.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({
    super.key,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final String _location = '123 ABC Street, XYZ District, Hanoi City';
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.secondary,
                size: IconSize.large,
              ),
              const SizedBox(width: 5), 
              Text(
                // Keep FE display logic
                TextHelper.textLimit(_location, 25),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}