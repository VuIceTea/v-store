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
    slide.setImages('assets/images/onboardingImgs/onboarding_1.jpg');
    slide.setTitle('Chọn sản phẩm yêu thích');
    slide.setDescription(
      'Khám phá hàng trăm sản phẩm thời trang và mỹ phẩm chính hãng, phù hợp với phong cách riêng của bạn.',
    );
    slides.add(slide);

    slide = SliderModel();
    slide.setId('2');
    slide.setImages('assets/images/onboardingImgs/onboarding_2.jpg');
    slide.setTitle('Thanh toán dễ dàng');
    slide.setDescription(
      'Chọn phương thức thanh toán bạn muốn và hoàn tất đơn hàng chỉ trong vài bước đơn giản.',
    );
    slides.add(slide);

    slide = SliderModel();
    slide.setId('3');
    slide.setImages('assets/images/onboardingImgs/onboarding_3.jpg');
    slide.setTitle('Giao hàng nhanh chóng');
    slide.setDescription(
      'Theo dõi và nhận sản phẩm nhanh chóng tại nhà — an toàn, tiện lợi và đúng hẹn.',
    );
    slides.add(slide);
    return slides;
  }
}
