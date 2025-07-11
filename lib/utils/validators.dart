class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone) && phone.length >= 10;
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  static bool isValidAddress(String address) {
    return address.trim().isNotEmpty && address.trim().length >= 10;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!isValidEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (!isValidPassword(value)) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên';
    }
    if (!isValidName(value)) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!isValidPhone(value)) {
        return 'Số điện thoại không hợp lệ';
      }
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }
}
