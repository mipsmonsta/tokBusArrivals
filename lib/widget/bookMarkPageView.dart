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

  Widget _getImageCloseButton(Function(int) closedPressed, int index) {
    return ClipOval(
        child: Material(
      color: Colors.amber, // Button color
      child: InkWell(
        splashColor: Colors.black,
        // Splash color
        onTap: () {
          closedPressed(index);
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withAlpha(155)),
              shape: BoxShape.circle,
            ),
            width: 24.0,
            height: 24.0,
            child: Icon(Icons.close, color: Colors.black, size: 18.0)),
      ),
    ));
  }

  List<Widget> _viewsFromBookMarkCodeList() {
    return List.generate(
        bookmarkCodeList.length,
        (index) => Center(
            widthFactor: 1.1,
            heightFactor: 1.1,
            child: Stack(clipBehavior: Clip.none, children: [
              OutlinedButton(
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
              ),
              Positioned(
                  child: _getImageCloseButton(
                      onBookMarkLongPressedCallback, index),
                  right: -8.0,
                  top: -5.0)
            ])));
  }
}
