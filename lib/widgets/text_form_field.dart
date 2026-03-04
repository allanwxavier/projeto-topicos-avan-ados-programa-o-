import 'package:flutter/material.dart';

class TextFormFieldCustomer extends StatelessWidget {
  final String label;
  final String hinttext;
  final TextEditingController controller;
  final TextInputType type;
  final IconData? suffixicon;
  final VoidCallback? ontap;

  const TextFormFieldCustomer({
    super.key,
    required this.label,
    required this.hinttext,
    required this.controller,
    required this.type,
    this.suffixicon,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      readOnly: ontap != null, // Se tiver onTap (como data/hora), impede de digitar
      onTap: ontap,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hinttext,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 91, 98, 106), fontSize: 12),
        suffixIcon: suffixicon != null ? Icon(suffixicon, color: Colors.grey) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7E9ED), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7E9ED), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
        ),
      ),
    );
  }
}