import 'package:flutter/material.dart';

class BookMarkPageView extends StatelessWidget {
  final double width;
  final double height;
  final List<String> bookmarkCodeList;
  final Function(int) onBookMarkPressedCallback;
  final Function(int) onBookMarkLongPressedCallback;

  const BookMarkPageView(
      {Key? key,
      required this.width,
      required this.height,
      required this.bookmarkCodeList,
      required this.onBookMarkPressedCallback,
      required this.onBookMarkLongPressedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController controller =
        PageController(initialPage: 0, viewportFraction: 0.3);
    return Container(
        width: width,
        height: height,
        child: PageView(
          controller: controller,
          children: _viewsFromBookMarkCodeList(),
        ));
  }

  Color _getForegroundColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.white;
    }
    return Colors.black;
  }

  Color _getBackgroundColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.amber;
    }
    return Colors.white;
  }

  List<Widget> _viewsFromBookMarkCodeList() {
    return List.generate(
        bookmarkCodeList.length,
        (index) => Center(
            widthFactor: 1.1,
            heightFactor: 1.1,
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith(_getBackgroundColor),
                foregroundColor:
                    MaterialStateProperty.resolveWith(_getForegroundColor),
              ),
              onPressed: () {
                onBookMarkPressedCallback(index);
              },
              onLongPress: () {
                onBookMarkLongPressedCallback(index);
              },
              child: Text(bookmarkCodeList[index]),
            )));
  }
}
