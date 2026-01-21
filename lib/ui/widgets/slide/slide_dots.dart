import 'package:flutter/material.dart';

class SlideDots extends StatelessWidget {
  final bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3.3),
      height: isActive ? 10 : 6,
      width: isActive ? 10 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        border: isActive
            ? Border.all(
                color: Color(0xff927DFF),
                width: 2.0,
              )
            : Border.all(
                color: Colors.transparent,
                width: 1,
              ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class SlideDotsHomepage extends StatelessWidget {
  final int? dotsActive, dotsLength;
  SlideDotsHomepage({this.dotsActive, this.dotsLength});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dotsLength,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var isActive = false;
        if (dotsActive == index) isActive = true;
        return AnimatedContainer(
          duration: Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          height: 7,
          width: 7,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.grey,
            border: isActive
                ? Border.all(
                    color: Color(0xff927DFF),
                    width: 2.0,
                  )
                : Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        );
      },
    );
  }
}
