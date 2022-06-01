import 'package:flutter/material.dart';
import 'package:messenger/constants/colors.dart';

Widget messageTile(String message, bool sendByMe) {
  return Row(
    mainAxisAlignment:
        sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      Flexible(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: sendByMe ? messageBlueColor : messageGrayColor,
              borderRadius: BorderRadius.only(
                topLeft: sendByMe ? const Radius.circular(15) : Radius.zero,
                topRight: sendByMe ? Radius.zero : const Radius.circular(15),
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(15),
              )),
          child: Text(
            message,
            style: TextStyle(
              color: sendByMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    ],
  );
}
