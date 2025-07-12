import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_store/models/slider_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  int currentPage = 0;
  PageController pageController = PageController();
  List<SliderModel> slides = SliderModel().getSlides()!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                      text: '${currentPage + 1}',
                      children: [
                        TextSpan(
                          text: '/${slides.length}',
                          style: TextStyle(
                            color: Color.fromRGBO(168, 168, 169, 1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      skipAction();
                    },
                    child: Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: pageController,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 300,
                            width: 350,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(slides[index].getImages()!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            slides[index].getTitle()!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            slides[index].getDescription()!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(168, 168, 169, 1),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    if (currentPage > 0)
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton(
                          onPressed: () {
                            preAction();
                          },
                          child: Text(
                            'Quay lại',
                            style: TextStyle(
                              color: Color.fromRGBO(168, 168, 169, 1),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(slides.length, (index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: 5),
                            height: currentPage == index ? 8 : 10,
                            width: currentPage == index ? 40 : 10,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? Color.fromRGBO(23, 34, 59, 1)
                                  : Color.fromRGBO(
                                      168,
                                      168,
                                      169,
                                      1,
                                    ).withOpacity(.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          nextAction();
                        },
                        child: Text(
                          currentPage < slides.length - 1
                              ? 'Kế tiếp'
                              : 'Bắt đầu',
                          style: TextStyle(
                            color: Color.fromRGBO(248, 55, 88, 1),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  skipAction() {
    BuildContext context = this.context;
    Navigator.pushReplacementNamed(context, '/main', arguments: 0);
  }

  nextAction() {
    BuildContext context = this.context;
    if (currentPage == slides.length - 1) {
      Navigator.pushReplacementNamed(context, '/main', arguments: 0);
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage++;
      });
    }
  }

  preAction() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: Duration(microseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage--;
      });
    }
  }
}
