import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboard;
  final int? maxlines;
  final double height;
  final bool expands;

  final String hintText;
  final ValueChanged<String>? onChange;
  final bool obscureText;

  final Widget? suffixIcon;
  const CustomTextField(
      {Key? key,
      this.maxlines = 1,
      this.height = 100,
      this.expands = false,
      this.keyboard = TextInputType.emailAddress,
      required this.validator,
      required this.textController,
      required this.hintText,
      required this.onChange,
      this.suffixIcon,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List dimensions = deviceDimensions(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: dimensions[1] * 0.8,
      height: height,
      child: TextFormField(
        obscureText: obscureText,
        expands: expands,
        maxLines: maxlines,
        onChanged: onChange,
        keyboardType: keyboard,
        controller: textController,
        validator: validator,
        style: const TextStyle(color: Colors.blue),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[200]),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(
                color: Colors.white, width: 3.0, style: BorderStyle.solid),
          ),
        ),
      ),
    );
  }
}
