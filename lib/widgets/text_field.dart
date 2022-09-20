import 'package:flutter/material.dart';

class TextFieldd extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  const TextFieldd(this.controller, this.label, {super.key, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(5, 8, 10, 5),
        isDense: true,
        labelText: label,
        hintText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white38,
        prefixIcon: const Icon(Icons.people),
      ),
    );
  }
}
