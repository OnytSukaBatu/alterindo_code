import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void loading({
  required context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading',
                  style: GoogleFonts.poppins(),
                ),
                SizedBox(width: 15),
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    color: Colors.grey,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
