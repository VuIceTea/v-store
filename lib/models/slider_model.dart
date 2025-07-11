class SliderModel {
  String? id;
  String? images;
  String? title;
  String? description;

  SliderModel({this.id, this.images, this.title, this.description});

  String? getId() {
    return id;
  }

  void setId(String id) {
    this.id = id;
  }

  void setImages(String images) {
    this.images = images;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setDescription(String description) {
    this.description = description;
  }

  String? getImages() {
    return images;
  }

  String? getTitle() {
    return title;
  }

  String? getDescription() {
    return description;
  }

  List<SliderModel>? getSlides() {
    List<SliderModel> slides = [];

    SliderModel slide = SliderModel();
    slide.setId('1');
    slide.setImages('assets/images/onboardingImgs/onboarding_1.png');
    slide.setTitle('Choose Products');
    slide.setDescription(
      'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.',
    );
    slides.add(slide);

    slide = SliderModel();
    slide.setId('2');
    slide.setImages('assets/images/onboardingImgs/onboarding_2.png');
    slide.setTitle('Make Payment');
    slide.setDescription(
      'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.',
    );
    slides.add(slide);

    slide = SliderModel();
    slide.setId('3');
    slide.setImages('assets/images/onboardingImgs/onboarding_3.png');
    slide.setTitle('Get Your Order');
    slide.setDescription(
      'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.',
    );
    slides.add(slide);
    return slides;
  }
}
