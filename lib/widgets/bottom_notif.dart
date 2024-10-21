import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void bottomNotif({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required String image,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      final double height = MediaQuery.of(context).size.height;
      return SizedBox(
        height: height * 0.4,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: icon != Icons.close,
              child: Icon(
                icon,
                color: Colors.green,
                size: 40,
              ),
            ),
            Visibility(
              visible: image.isNotEmpty,
              child: Image.asset(
                image,
                scale: 10,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              textAlign: TextAlign.center,
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Visibility(
              visible: title.isNotEmpty,
              child: Text(
                textAlign: TextAlign.center,
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 75,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
