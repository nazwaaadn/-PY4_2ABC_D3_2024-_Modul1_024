import 'package:flutter/material.dart';

class AlertHelper {
  static void show(
    BuildContext context, {
    required String type, // 'error', 'success', 'warning', 'info'
    required String message,
  }) {
    // Definisi Warna & Label berdasarkan Type
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (type) {
      case 'success':
        bgColor = const Color(0xFFD4EDDA).withOpacity(0.3);
        textColor = const Color(0xFF155724);
        borderColor = const Color(0xFFC3E6CB);
        label = "Success! ";
        break;
      case 'warning':
        bgColor = const Color(0xFFFFF3CD).withOpacity(0.3);
        textColor = const Color(0xFF856404);
        borderColor = const Color(0xFFFFEEBA);
        label = "Warning! ";
        break;
      case 'info':
        bgColor = const Color(0xFFD1ECF1).withOpacity(0.3);
        textColor = const Color(0xFF0C5460);
        borderColor = const Color(0xFFBEE5EB);
        label = "Info! ";
        break;
      default: // error
        bgColor = const Color.fromARGB(255, 255, 232, 234).withOpacity(0.3);
        textColor = const Color(0xFF721C24);
        borderColor = const Color.fromARGB(255, 170, 12, 28);
        label = "Error! ";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,
          left: 10,
          right: 10,
        ), // Bisa diatur posisi
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: textColor),
                    children: [
                      TextSpan(
                        text: label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: message),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Icon(Icons.close, color: textColor, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
