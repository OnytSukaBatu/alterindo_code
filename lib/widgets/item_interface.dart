import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemInterface extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  const ItemInterface({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<ItemInterface> createState() => _ItemInterfaceState();
}

class _ItemInterfaceState extends State<ItemInterface> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.2,
      child: Column(
        children: [
          Container(
            height: width * 0.135,
            width: width * 0.135,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
