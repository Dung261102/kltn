import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';  // Import theme

// class FormFields extends StatelessWidget
// {
//   final TextEditingController controller;
//   final IconData data;
//   final String txtHint;
//   bool obsecure=true;
//
//   FormFields({Key key, this.controller, this.data, this.txtHint,this.obsecure}) : super(key: key);

class FormFields extends StatelessWidget {
  final TextEditingController? controller;  // Cho phép null
  final IconData? data;                     // Cho phép null
  final String? txtHint;                    // Cho phép null
  final bool obsecure;                      // Mặc định là true
  final FocusNode? focusNode; // Thêm dòng này

  FormFields({
    Key? key,
    this.controller,
    this.focusNode, // Thêm dòng này
    this.data,
    this.txtHint,
    this.obsecure = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode, // Thêm dòng này
        obscureText: obsecure,
        style: titleStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(data, color: Colors.blueAccent),
          hintText: txtHint,
          hintStyle: subTitleStyle.copyWith(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}