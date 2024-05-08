import 'package:flutter/material.dart';

class ValidatedTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String placeholder;
  final String value;
  const ValidatedTextField({required this.placeholder, required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(
              offset: value.length),
        ),
      ),
      decoration: InputDecoration(
        labelText: placeholder,
      ),
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      onChanged: (value) {
        onChanged(value);
      },
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Ввод email обязателен';
        }
        return null;
      },
    );
  }
}
