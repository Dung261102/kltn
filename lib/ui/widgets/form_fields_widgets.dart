
import 'package:flutter/material.dart';

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

  FormFields({
    Key? key,
    this.controller,
    this.data,
    this.txtHint,
    this.obsecure = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      child: TextFormField(
        controller: controller,
        obscureText: obsecure,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(data,color: Colors.grey,),
          hintText: txtHint
        ),
      ),
    );
  }

}