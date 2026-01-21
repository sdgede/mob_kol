import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:another_carousel_pro/another_carousel_pro.dart';

import '../../../services/config/config.dart' as config;
import '../../../services/config/router_generator.dart';
import '../../../services/utils/slider_utils.dart';
import 'slide_dots.dart';
import 'slide_item.dart';

class SliderLayoutView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SliderLayoutViewState();
}

class _SliderLayoutViewState extends State<SliderLayoutView> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  String textPrevious = '', textNextFinish = config.NEXT;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      if (_currentPage == 0) {
        textPrevious = '';
      } else {
        textPrevious = config.PREVIOUS;
      }

      if (_currentPage == SliderUtils.instance.sliderArrayList.length - 1) {
        textNextFinish = config.SKIP;
      } else {
        textNextFinish = config.NEXT;
      }
    });
  }

  @override
  Widget build(BuildContext context) => topSliderLayout();

  Widget topSliderLayout() => Container(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: SliderUtils.instance.sliderArrayList.length,
                itemBuilder: (ctx, i) => SlideItem(i),
              ),
              Stack(
                alignment: AlignmentDirectional.topStart,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () async {
                        if (textNextFinish == config.SKIP) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('first_time', false);
                          Navigator.pushReplacementNamed(context, RouterGenerator.pageHomeLogin);
                        }

                        if (_currentPage != SliderUtils.instance.sliderArrayList.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                          _onPageChanged(_currentPage + 1);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 15.0, bottom: 15.0),
                        child: Text(
                          textNextFinish,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      // splashColor: Colors.transparent,
                      // highlightColor: Colors.transparent,
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: () {
                          if (_currentPage != 0) {
                            _pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
                            _onPageChanged(_currentPage - 1);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                          child: Text(
                            textPrevious,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        // splashColor: Colors.transparent,
                        // highlightColor: Colors.transparent,
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                      )),
                  Container(
                    alignment: AlignmentDirectional.bottomCenter,
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < SliderUtils.instance.sliderArrayList.length; i++)
                          if (i == _currentPage) SlideDots(true) else SlideDots(false)
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}

class SliderHomeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3.1,
      width: MediaQuery.of(context).size.width,
      // child: AnotherCarousel(
      //   images: [
      //     Image.asset(
      //       'assets/images/saldomutasi.png',
      //       fit: BoxFit.cover,
      //     ),
      //     Image.asset(
      //       'assets/images/ppob.png',
      //       fit: BoxFit.cover,
      //     ),
      //     Image.asset(
      //       'assets/images/tfsonline.png',
      //       fit: BoxFit.cover,
      //     ),
      //     Image.asset(
      //       'assets/images/rekening.png',
      //       fit: BoxFit.cover,
      //     ),
      //   ],
      //   boxFit: BoxFit.fitWidth,
      //   dotSize: 0,
      //   dotSpacing: 15.0,
      //   dotColor: Colors.lightGreenAccent,
      //   indicatorBgPadding: 5.0,
      //   dotBgColor: Colors.transparent,
      //   borderRadius: false,
      //   moveIndicatorFromBottom: 180.0,
      //   noRadiusForIndicator: true,
      //   overlayShadow: false,
      //   overlayShadowColors: Colors.transparent,
      //   overlayShadowSize: 0,
      // ),
    );
  }
}

class SliderHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3.0,
      width: MediaQuery.of(context).size.width,
      // child: AnotherCarousel(
      //   images: [
      //     Image.asset(
      //       'assets/images/tab-slide.png',
      //       fit: BoxFit.cover,
      //     ),
      //     Image.asset(
      //       'assets/images/dep-slide.png',
      //       fit: BoxFit.cover,
      //     ),
      //     Image.asset(
      //       'assets/images/kredit-slide.png',
      //       fit: BoxFit.cover,
      //     ),
      //     // Image.asset(
      //     //   'assets/images/tabusaha-slider.png',
      //     //   fit: BoxFit.cover,
      //     // ),
      //     // Image.asset(
      //     //   'assets/images/tabkeluarga-slider.png',
      //     //   fit: BoxFit.cover,
      //     // ),
      //     // Image.asset(
      //     //   'assets/images/deposito-slider.png',
      //     //   fit: BoxFit.cover,
      //     // ),
      //     // Image.asset(
      //     //   'assets/images/tabjangka-slider.png',
      //     //   fit: BoxFit.cover,
      //     // ),
      //     // Image.asset(
      //     //   'assets/images/kredit-slider.png',
      //     //   fit: BoxFit.cover,
      //     // ),
      //   ],
      //   dotSize: 0,
      //   dotSpacing: 15.0,
      //   dotColor: Colors.lightGreenAccent,
      //   indicatorBgPadding: 5.0,
      //   dotBgColor: Colors.transparent,
      //   borderRadius: false,
      //   moveIndicatorFromBottom: 300.0,
      //   noRadiusForIndicator: true,
      //   overlayShadow: false,
      //   overlayShadowColors: Colors.transparent,
      //   overlayShadowSize: 0,
      // ),
    );
  }
}
