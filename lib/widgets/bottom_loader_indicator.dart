import 'package:flutter/material.dart';

class BottomLoaderIndicator extends StatelessWidget {
  const BottomLoaderIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        alignment: Alignment.center,
        child: const Center(
          child: SizedBox(
            width: 33,
            height: 33,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}